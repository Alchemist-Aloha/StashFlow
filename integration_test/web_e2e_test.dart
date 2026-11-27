/// Browser end-to-end test: drives the web build against a Stash server
/// seeded by https://github.com/Alchemist-Aloha/stash-test-server plus
/// `scripts/e2e_seed_extra_images.sh` (AVIF and JPEG XL images).
///
/// Browsers run integration tests through `flutter drive` and chromedriver.
/// The app's dev server proxies Stash (`test_driver/web_dev_config.yaml`) so
/// password login shares one origin, as when Stash serves the web build:
///
/// ```bash
/// chromedriver --port=4444 &
/// cp test_driver/web_dev_config.yaml web_dev_config.yaml
/// set -a; source ../stash-test-server/stash-test-server.env; set +a
/// flutter drive -d web-server --browser-name=chrome --headless \
///   --web-port=8099 \
///   --web-browser-flag=--autoplay-policy=no-user-gesture-required \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/web_e2e_test.dart \
///   --dart-define=STASH_URL=http://localhost:8099 \
///   --dart-define="STASH_API_KEY=$STASH_API_KEY" \
///   --dart-define="STASH_USERNAME=$STASH_USERNAME" \
///   --dart-define="STASH_PASSWORD=$STASH_PASSWORD"
/// ```
library;

import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWasm;
import 'package:flutter/rendering.dart' show RenderImage;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql/client.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/preferences/one_time_tips.dart';
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/player_surface.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/main.dart' as app;

import 'e2e_helpers.dart';

/// Set when the test is built with `--wasm`, so a silent JavaScript fallback
/// cannot pass for a WebAssembly run.
const _expectWasm = bool.fromEnvironment('E2E_EXPECT_WASM');

/// Image file names written by `scripts/e2e_seed_extra_images.sh`.
const _extraImages = ['e2e-avif.avif', 'e2e-jxl.jxl'];

Future<void> _exercisePlayback(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  final card = sceneCard(sceneTitle);
  final scene = tester.widget<SceneCard>(card).scene;
  final id = scene.id;
  final container = ProviderScope.containerOf(tester.element(card));
  final playerNotifier = container.read(playerStateProvider.notifier);
  final surface = find.byWidgetPredicate(
    (widget) =>
        widget is PlayerSurface && widget.scene.id == id && widget.showControls,
    description: 'player surface for $sceneTitle',
  );

  await tapWhenReady(tester, card);
  await pumpUntil(tester, surface);
  try {
    final player = tester.widget<PlayerSurface>(surface).controller.player;
    final initialPosition = player.state.position;
    await pumpUntilCondition(
      tester,
      () =>
          player.state.playing &&
          player.state.position >
              initialPosition + const Duration(milliseconds: 500),
      'browser playback to start and advance',
    );

    // Inline controls open hidden; reveal them like a viewer before pausing.
    final pause = find.descendant(
      of: surface,
      matching: find.byTooltip(l10n.common_pause),
    );
    if (pause.hitTestable().evaluate().isEmpty) {
      await pumpUntil(tester, pause);
      await tester.tap(pause.first, warnIfMissed: false);
      await pumpUntil(tester, pause.hitTestable());
    }
    await tapWhenReady(tester, pause);
    await pumpUntilCondition(
      tester,
      () => !player.state.playing,
      'browser playback to pause',
    );

    // A resumed scene opens with Media.start; seeking before it must report
    // the new position, not snap the progress bar back to the resume point.
    await playerNotifier.playScene(
      scene,
      scene.paths.stream!,
      initialPosition: const Duration(seconds: 10),
    );
    final resumed = container.read(playerStateProvider).player!;
    await pumpUntilCondition(
      tester,
      () => resumed.state.position >= const Duration(seconds: 10),
      'resumed playback to reach its start position',
    );
    await playerNotifier.seek(const Duration(seconds: 2));
    await pumpUntilCondition(
      tester,
      () => resumed.state.position < const Duration(seconds: 6),
      'a seek before the resume point to report that position',
    );
  } finally {
    playerNotifier.stop();
    await pumpUntilCondition(
      tester,
      () => playerNotifier.currentVideoController == null,
      'browser playback to release',
    );
  }
}

Future<void> _exerciseExtraImages(WidgetTester tester) async {
  final scaffold = find.byType(Scaffold).first;
  final router = GoRouter.of(tester.element(scaffold));
  final ids = await _extraImageIds(tester);
  for (final (name, id) in ids) {
    unawaited(router.push('/galleries/images/$id'));
    final page = find.byType(ImageFullscreenPage);
    await pumpUntil(tester, page);
    final decoded = find.descendant(
      of: page,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is RawImage &&
            widget.image != null &&
            widget.image!.width > 1,
        description: 'decoded image',
      ),
    );
    final broken = find.descendant(
      of: page,
      matching: find.byIcon(Icons.broken_image),
    );
    await pumpUntilCondition(
      tester,
      () => decoded.evaluate().isNotEmpty || broken.evaluate().isNotEmpty,
      '$name to decode or fail',
    );
    expect(broken, findsNothing, reason: '$name must decode in the browser');
    final image = tester.renderObject<RenderImage>(decoded.first).image!;
    expect((image.width, image.height), (640, 480), reason: name);
    router.pop();
    await pumpUntil(tester, page, gone: true);
  }
}

/// Looks up the seeded AVIF and JPEG XL images through the app's own client.
Future<List<(String, String)>> _extraImageIds(WidgetTester tester) async {
  final scaffold = find.byType(Scaffold).first;
  final container = ProviderScope.containerOf(tester.element(scaffold));
  final client = container.read(graphqlClientProvider);
  final result = await client.query(
    QueryOptions(
      document: gql(r'''
        query ExtraImages {
          findImages(
            image_filter: { path: { value: "e2e-", modifier: INCLUDES } }
          ) { images { id files { path } } }
        }
      '''),
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );
  expect(result.exception, isNull);
  final found = result.data!['findImages'] as Map<String, dynamic>;
  final images = (found['images'] as List).cast<Map<String, dynamic>>();
  String idOf(String name) =>
      images.firstWhere(
            (image) => (image['files'] as List)
                .cast<Map<String, dynamic>>()
                .any((file) => (file['path'] as String).endsWith(name)),
            orElse: () => fail('$name was not seeded'),
          )['id']
          as String;
  return [for (final name in _extraImages) (name, idOf(name))];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  testWidgets(
    'connects, plays a scene, and decodes AVIF and JPEG XL images in the browser',
    skip: stashUrl.isEmpty,
    timeout: const Timeout(Duration(minutes: 10)),
    (tester) async {
      expect(stashApiKey, isNotEmpty, reason: 'pass STASH_API_KEY');
      expect(kIsWasm, _expectWasm, reason: 'compiled as WebAssembly');
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({
        'app_language': 'en',
        'last_app_update_check_timestamp':
            DateTime.now().millisecondsSinceEpoch,
        for (final tip in OneTimeTip.values) tip.key: false,
        PlayerSettingsStore.playEndBehaviorKey: 'stop',
        PlayerSettingsStore.controlsAutoHideSecondsKey:
            PlayerSettingsStore.maxControlsAutoHideSeconds,
      });
      final l10n = lookupAppLocalizations(const Locale('en'));

      // Keep the test binding's error handlers active while pumping the app.
      final onError = FlutterError.onError;
      final onPlatformError = PlatformDispatcher.instance.onError;
      final print = debugPrint;
      try {
        await app.main();
      } finally {
        FlutterError.onError = onError;
        PlatformDispatcher.instance.onError = onPlatformError;
        debugPrint = print;
      }

      await tapWhenReady(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_configure_now),
        ),
      );
      const profile = 'stash-test-server-api-key';
      await fillProfile(tester, l10n, profile);
      await tester.enterText(
        field(l10n.settings_server_auth_apikey),
        stashApiKey,
      );
      await testAndSaveProfile(tester, l10n, profile);
      await backTo(tester, '/scenes');
      await pumpUntil(tester, sceneCard(sceneTitle));

      await _exercisePlayback(tester, l10n);
      await _exerciseExtraImages(tester);

      // The browser keeps the HttpOnly session cookie, so password login only
      // works when the app shares the server's origin (as when Stash serves
      // it); the test proxies Stash through the app's dev server.
      if (stashUsername.isNotEmpty) {
        await switchToPasswordProfile(tester, l10n);
        await pumpUntil(tester, sceneCard(sceneTitle));
        // The active client now authenticates only with the session cookie.
        expect(await _extraImageIds(tester), hasLength(_extraImages.length));
      }
    },
  );
}
