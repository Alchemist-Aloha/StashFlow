/// GUI end-to-end test: drives the real app against a Stash server seeded by
/// https://github.com/Alchemist-Aloha/stash-test-server.
///
/// Devices cannot read host environment variables, so the server is passed
/// with `--dart-define`; the test skips when `STASH_URL` is empty:
///
/// ```bash
/// set -a; source ../stash-test-server/stash-test-server.env; set +a
/// flutter test integration_test -d linux \
///   --dart-define="STASH_URL=$STASH_URL" \
///   --dart-define="STASH_API_KEY=$STASH_API_KEY" \
///   --dart-define="STASH_USERNAME=$STASH_USERNAME" \
///   --dart-define="STASH_PASSWORD=$STASH_PASSWORD"
/// ```
///
/// On the Android emulator the host's loopback is `http://10.0.2.2:9999`.
///
/// Profiles and stored credentials stay in memory; session cookies use a
/// disposable support directory instead of the developer's app data.
library;

import 'dart:convert';
import 'dart:io' show HttpClient, HttpHeaders, Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/one_time_tips.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/features/navigation/presentation/widgets/mini_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/player_surface.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/video_progress_bar.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/main.dart' as app;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'e2e_helpers.dart';

const _hostSupportDir = String.fromEnvironment('STASH_E2E_SUPPORT_DIR');

// Values from stash-test-server fixtures/profile.json (pinned by tag v1).
const _excludedSceneTitle = 'Ember Field';
const _tabs = <(IconData, Set<String>)>[
  (Icons.people, {'Mara Quill', 'Theo Vance', 'Iris Kade', 'June Ash'}),
  (
    Icons.business,
    {'Meridian Media Group', 'Aurora Pictures', 'Northwind Studio'},
  ),
  (Icons.local_offer, {'Abstract', 'Fractal', 'Geometry', 'Nature', 'Ocean'}),
  (
    Icons.perm_media,
    {'Ocean Studies', 'Geometry Pack', 'Favourites Selection'},
  ),
];

Future<void> _search(
  WidgetTester tester,
  AppLocalizations l10n,
  String query,
) async {
  await tapWhenReady(tester, find.byTooltip(l10n.common_search));
  final field = find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        widget.decoration?.hintText == l10n.scenes_search_hint,
    description: 'scene search field',
  );
  await pumpUntil(tester, field);
  await tester.enterText(field, query);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await pumpUntil(tester, field, gone: true);
}

Future<void> _exerciseSceneSearch(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  final filter = find.byTooltip(l10n.common_filter);
  final apply = find.text(l10n.common_apply_filters);
  final organized = find.byWidgetPredicate(
    (widget) =>
        widget is BooleanCriterionInput &&
        widget.label == l10n.common_organized,
  );
  await _search(tester, l10n, _excludedSceneTitle);
  await pumpUntil(tester, sceneCard(_excludedSceneTitle));
  expect(find.byType(SceneCard), findsOneWidget);

  await tapWhenReady(tester, filter);
  await tapWhenReady(
    tester,
    find.descendant(of: organized, matching: find.text(l10n.common_yes)),
  );
  await tapWhenReady(tester, apply);
  await pumpUntil(tester, find.text(l10n.common_no_items));
  expect(find.byType(SceneCard), findsNothing);

  await _search(tester, l10n, sceneTitle);
  await pumpUntil(tester, sceneCard(sceneTitle));
  expect(find.byType(SceneCard), findsOneWidget);

  await _search(tester, l10n, _excludedSceneTitle);
  await pumpUntil(tester, find.text(l10n.common_no_items));
  await tapWhenReady(tester, filter);
  await tapWhenReady(tester, find.text(l10n.common_reset));
  await tapWhenReady(tester, apply);
  await pumpUntil(tester, sceneCard(_excludedSceneTitle));
  expect(find.byType(SceneCard), findsOneWidget);

  // The server-seeded preset clears the active search and changes list order.
  final presets = find.byTooltip(l10n.common_saved_filters);
  final topRated = find.text('Top rated');
  await tapWhenReady(tester, presets);
  await tapWhenReady(tester, topRated);
  await pumpUntil(tester, topRated, gone: true);
  await pumpUntilCondition(tester, () {
    final first = find.byType(SceneCard).evaluate().firstOrNull?.widget;
    return first is SceneCard && first.scene.title == 'Coastal Drift';
  }, 'Coastal Drift to become the first scene after applying Top rated');

  await _search(tester, l10n, sceneTitle);
  await pumpUntil(tester, sceneCard(sceneTitle));
}

// Independent, uncached server reads distinguish real writes from UI state.
Future<Map<String, dynamic>> _stash(
  HttpClient client,
  String query,
  Map<String, Object?> variables,
) async {
  final request = await client.postUrl(Uri.parse(stashUrl).resolve('/graphql'));
  request.headers.set('ApiKey', stashApiKey);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  request.write(jsonEncode({'query': query, 'variables': variables}));
  final response = await request.close();
  final body = await utf8.decoder.bind(response).join();
  expect(response.statusCode, 200, reason: body);
  final result = jsonDecode(body) as Map<String, dynamic>;
  expect(result['errors'], isNull, reason: body);
  return result['data'] as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _readScene(HttpClient client, String id) async {
  final data = await _stash(
    client,
    r'''
    query SceneState($id: ID!) {
      findScene(id: $id) { rating100 resume_time play_duration play_history }
    }
  ''',
    {'id': id},
  );
  return data['findScene'] as Map<String, dynamic>;
}

Future<void> _restoreScene(
  HttpClient client,
  String id,
  Map<String, dynamic> original,
) async {
  final current = await _readScene(client, id);
  if (current['rating100'] != original['rating100']) {
    await _stash(
      client,
      r'''
      mutation RestoreRating($input: SceneUpdateInput!) {
        sceneUpdate(input: $input) { rating100 }
      }
    ''',
      {
        'input': {'id': id, 'rating100': original['rating100']},
      },
    );
  }
  if (current['resume_time'] != original['resume_time'] ||
      current['play_duration'] != original['play_duration']) {
    await _stash(
      client,
      r'''
      mutation RestoreActivity($id: ID!, $resume: Float, $duration: Float) {
        sceneResetActivity(id: $id, reset_resume: true, reset_duration: true)
        sceneSaveActivity(id: $id, resume_time: $resume, playDuration: $duration)
      }
    ''',
      {
        'id': id,
        'resume': original['resume_time'],
        'duration': original['play_duration'],
      },
    );
  }
  final originalPlays = (original['play_history'] as List).toSet();
  final newPlays = (current['play_history'] as List)
      .where((time) => !originalPlays.contains(time))
      .toList();
  if (newPlays.isNotEmpty) {
    await _stash(
      client,
      r'''
      mutation RestorePlays($id: ID!, $times: [Timestamp!]) {
        sceneDeletePlay(id: $id, times: $times) { count }
      }
    ''',
      {'id': id, 'times': newPlays},
    );
  }
  expect(
    await _readScene(client, id),
    original,
    reason: 'restore scene fixture',
  );
}

Future<void> _exerciseScene(WidgetTester tester, AppLocalizations l10n) async {
  final card = sceneCard(sceneTitle);
  final id = tester.widget<SceneCard>(card).scene.id;
  final server = HttpClient();
  addTearDown(() => server.close(force: true));
  final original = await _readScene(server, id);
  addTearDown(() => _restoreScene(server, id, original));
  final container = ProviderScope.containerOf(tester.element(card));
  final playerNotifier = container.read(playerStateProvider.notifier);
  final surface = find.byWidgetPredicate(
    (widget) =>
        widget is PlayerSurface && widget.scene.id == id && widget.showControls,
    description: 'player surface for $sceneTitle',
  );
  final rating = find.byKey(const Key('scene_rating_controls'));
  final oneStar = find.descendant(of: rating, matching: find.text('1'));
  final miniPlayer = find.byType(MiniPlayer);
  Future<void> openScene() async {
    await tapWhenReady(tester, card);
    await pumpUntil(tester, surface);
    await pumpUntil(tester, miniPlayer, gone: true);
    expect(location(tester), '/scenes/scene/$id');
  }

  Future<void> stopScene() async {
    await backTo(tester, '/scenes');
    await pumpUntil(tester, miniPlayer);
    await tapWhenReady(
      tester,
      find.descendant(
        of: miniPlayer,
        matching: find.byTooltip(l10n.common_close),
      ),
    );
    await pumpUntil(tester, miniPlayer, gone: true);
    await pumpUntilCondition(
      tester,
      () => playerNotifier.currentVideoController == null,
      'the native playback session to release',
    );
  }

  Future<void> revealRating() async {
    final title = find.descendant(
      of: find.byKey(const Key('scene_header_title')),
      matching: find.text(sceneTitle),
    );
    await pumpUntil(tester, title.hitTestable());

    // The title is pinned outside the list. Raise the panel by its handle so
    // portrait video leaves enough room for the rating row to be tapped.
    final handle = find.byKey(const Key('scene_panel_handle')).hitTestable();
    await pumpUntil(tester, handle);
    await tester.drag(handle, Offset(0, -tester.getCenter(handle).dy));
    await pumpUntil(tester, rating.hitTestable());
  }

  try {
    await openScene();
    final player = tester.widget<PlayerSurface>(surface).controller.player;
    final initialPosition = player.state.position;
    await pumpUntilCondition(
      tester,
      () =>
          player.state.playing &&
          (player.state.width ?? 0) > 0 &&
          player.state.position >
              initialPosition + const Duration(milliseconds: 500),
      'authenticated native playback to decode video and advance',
    );

    Future<void> setPlaying(bool playing) async {
      final tooltip = playing ? l10n.common_play : l10n.common_pause;
      final button = find.descendant(
        of: surface,
        matching: find.byTooltip(tooltip),
      );
      // Inline controls open hidden and auto-hide while playing; reveal them
      // by tapping the video like a viewer would. Tap through the finder, not
      // tapAt: macOS renders into a non-implicit view that tapAt never reaches.
      if (button.hitTestable().evaluate().isEmpty) {
        await pumpUntil(tester, button);
        await tester.tap(button.first, warnIfMissed: false);
        await pumpUntil(tester, button.hitTestable());
      }
      await tapWhenReady(tester, button);
      await pumpUntilCondition(
        tester,
        () => player.state.playing == playing,
        playing ? 'playback to start' : 'playback to pause',
      );
    }

    // Pause first so uninterrupted playback cannot satisfy the seek check.
    await setPlaying(false);

    final slider = find.descendant(
      of: find.byType(VideoProgressBar),
      matching: find.byType(Slider),
    );
    final midpoint = player.state.duration ~/ 2;
    expect(
      player.state.position,
      lessThan(midpoint - const Duration(seconds: 2)),
    );
    await tapWhenReady(tester, slider);
    await pumpUntilCondition(
      tester,
      () =>
          (player.state.position - midpoint).abs() < const Duration(seconds: 1),
      'the native position to seek to the middle of the video',
    );
    final seekedAt = player.state.position;
    await setPlaying(true);
    await pumpUntilCondition(
      tester,
      () =>
          player.state.position > seekedAt + const Duration(milliseconds: 250),
      'playback to advance after the seek',
    );
    await setPlaying(false);
    final pausedAt = player.state.position;

    await revealRating();
    expect(oneStar, findsNothing);
    await tapWhenReady(tester, rating);
    await tapWhenReady(tester, find.byTooltip(l10n.scene_rating_stars(1)));
    await tapWhenReady(tester, find.text(l10n.common_apply));
    await pumpUntil(tester, oneStar);
    await stopScene();

    final saved = await _readScene(server, id);
    expect(saved['rating100'], 20);
    expect(saved['resume_time'], closeTo(pausedAt.inMilliseconds / 1000, 1));

    await openScene();
    final resumed = tester.widget<PlayerSurface>(surface).controller.player;
    expect(resumed, isNot(same(player)));
    await pumpUntilCondition(
      tester,
      () =>
          resumed.state.playing &&
          (resumed.state.width ?? 0) > 0 &&
          resumed.state.position > Duration.zero,
      'reopened scene to decode video in a new session',
    );
    expect(
      resumed.state.position.inMilliseconds / 1000,
      closeTo(saved['resume_time'] as num, 2),
      reason: 'the new player should start at the saved position, not zero',
    );
    await revealRating();
    expect(oneStar, findsOneWidget);

    // Returning through the mini-player must keep the active native session.
    await backTo(tester, '/scenes');
    await tapWhenReady(
      tester,
      find.descendant(
        of: miniPlayer,
        matching: find.byTooltip(l10n.common_pause),
      ),
    );
    await pumpUntilCondition(
      tester,
      () => !resumed.state.playing,
      'the mini-player to pause the active session',
    );
    final miniPosition = resumed.state.position;
    await tapWhenReady(
      tester,
      find.descendant(of: miniPlayer, matching: find.text(sceneTitle)),
    );
    await pumpUntil(tester, miniPlayer, gone: true);
    await pumpUntil(tester, surface);
    expect(location(tester), '/scenes/scene/$id');
    expect(
      tester.widget<PlayerSurface>(surface).controller.player,
      same(resumed),
    );
    expect(resumed.state.position, greaterThanOrEqualTo(miniPosition));

    await stopScene();
  } finally {
    if (playerNotifier.currentVideoController != null) {
      playerNotifier.stop();
      await pumpUntilCondition(
        tester,
        () => playerNotifier.currentVideoController == null,
        'playback cleanup before restoring the fixture',
      );
    }
  }
}

class _IsolatedSupportPath extends PathProviderPlatform {
  _IsolatedSupportPath(this.inner, this.supportPath);

  final PathProviderPlatform inner;
  final String supportPath;

  @override
  Future<String> getApplicationSupportPath() async => supportPath;

  @override
  Future<String?> getTemporaryPath() => inner.getTemporaryPath();

  @override
  Future<String?> getApplicationCachePath() => inner.getApplicationCachePath();

  @override
  Future<String?> getApplicationDocumentsPath() =>
      inner.getApplicationDocumentsPath();
}

// Headless Linux need not provide the desktop power-management portal.
class _NoopWakelock implements WakelockPlusLinuxPlugin {
  @override
  bool get isMock => true;

  @override
  Future<void> toggle({required bool enable}) async {}

  @override
  Future<bool> get enabled async => false;
}

void main() {
  // The waits below drive frames explicitly. Avoid extra live/pointer frames
  // contending with native player startup on hosted Apple runners.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  testWidgets(
    'connects with both auth modes, filters the library, and plays and edits a scene',
    skip: stashUrl.isEmpty,
    timeout: const Timeout(Duration(minutes: 10)),
    (tester) async {
      expect(stashApiKey, isNotEmpty, reason: 'pass STASH_API_KEY');
      expect(stashUsername, isNotEmpty, reason: 'pass STASH_USERNAME');
      expect(stashPassword, isNotEmpty, reason: 'pass STASH_PASSWORD');
      expect(
        app.isTestMode,
        isFalse,
        reason: 'native playback needs real app mode',
      );
      final platform = PathProviderPlatform.instance;
      var supportPath = _hostSupportDir;
      if (supportPath.isEmpty) {
        final cacheDir = await getTemporaryDirectory();
        // macOS can return the sandbox cache path before it exists.
        await cacheDir.create(recursive: true);
        final support = await cacheDir.createTemp('stashflow-e2e-support-');
        supportPath = support.path;
        addTearDown(() => support.delete(recursive: true));
      }
      PathProviderPlatform.instance = _IsolatedSupportPath(
        platform,
        supportPath,
      );
      addTearDown(() => PathProviderPlatform.instance = platform);
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({
        'app_language': 'en',
        'last_app_update_check_timestamp':
            DateTime.now().millisecondsSinceEpoch,
        // Keep the short fixture from auto-advancing; leave resume enabled.
        for (final tip in OneTimeTip.values) tip.key: false,
        PlayerSettingsStore.playEndBehaviorKey: 'stop',
        PlayerSettingsStore.controlsAutoHideSecondsKey:
            PlayerSettingsStore.maxControlsAutoHideSeconds,
      });
      if (Platform.isLinux) {
        final wakelock = wakelockPlusPlatformInstance;
        wakelockPlusPlatformInstance = _NoopWakelock();
        addTearDown(() => wakelockPlusPlatformInstance = wakelock);
      }
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

      final configure = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(l10n.common_configure_now),
      );
      await tapWhenReady(tester, configure);
      const apiProfile = 'stash-test-server-api-key';
      await fillProfile(tester, l10n, apiProfile);
      await tester.enterText(
        field(l10n.settings_server_auth_apikey),
        stashApiKey,
      );
      await testAndSaveProfile(tester, l10n, apiProfile);

      await backTo(tester, '/scenes');
      await pumpUntil(tester, sceneCard(sceneTitle));
      await switchToPasswordProfile(tester, l10n);
      await _exerciseSceneSearch(tester, l10n);
      await _exerciseScene(tester, l10n);

      for (final (icon, names) in _tabs) {
        final tab = navTab(icon);
        await pumpUntil(tester, tab);
        await tester.tap(tab.first);
        await pumpUntil(tester, anyText(names));
      }
    },
  );
}
