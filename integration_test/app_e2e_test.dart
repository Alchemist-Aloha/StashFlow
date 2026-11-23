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

import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, HttpHeaders, Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_card.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_drawer.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/main.dart' as app;
import 'package:wakelock_plus/wakelock_plus.dart';

const _url = String.fromEnvironment('STASH_URL');
const _apiKey = String.fromEnvironment('STASH_API_KEY');
const _username = String.fromEnvironment('STASH_USERNAME');
const _password = String.fromEnvironment('STASH_PASSWORD');

// Values from stash-test-server fixtures/profile.json (pinned by tag v1).
const _sceneTitle = 'Pocket Garden';
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

Finder _anyText(Set<String> values) => find.byWidgetPredicate(
  (w) => w is Text && values.contains(w.data),
  description: 'Text in $values',
);

Finder _field(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextField));

Finder _navTab(IconData icon) => find.descendant(
  of: find.byWidgetPredicate((w) => w is NavigationBar || w is NavigationRail),
  matching: find.byIcon(icon),
);

/// Pumps frames until [finder] matches; avoids pumpAndSettle, which never
/// settles while loading indicators or video run.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 60),
  bool gone = false,
}) async {
  await _pumpUntilCondition(
    tester,
    () => finder.evaluate().isEmpty == gone,
    '$finder${gone ? ' to disappear' : ''}',
    timeout: timeout,
  );
}

Future<void> _pumpUntilCondition(
  WidgetTester tester,
  bool Function() condition,
  String description, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  final deadline = DateTime.now().add(timeout);
  do {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  } while (DateTime.now().isBefore(deadline));
  final onScreen = find
      .byType(RichText)
      .evaluate()
      .map((e) => (e.widget as RichText).text.toPlainText())
      .where((t) => t.trim().isNotEmpty)
      .take(60)
      .toList();
  throw TestFailure(
    'Timed out after $timeout waiting for $description\nOn screen: $onScreen',
  );
}

// `uri` keeps the base location under pushed routes; the last match is the top page.
String _location(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .routerDelegate
        .currentConfiguration
        .last
        .matchedLocation;

Future<void> _backTo(WidgetTester tester, String path) async {
  for (var i = 0; i < 4 && _location(tester) != path; i++) {
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(_location(tester), path);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _pumpUntil(tester, finder);
  await tester.ensureVisible(finder);
  await _pumpUntil(tester, finder.hitTestable());
  await tester.tap(finder);
}

Finder _sceneCard(String title) => find.byWidgetPredicate(
  (widget) => widget is SceneCard && widget.scene.title == title,
  description: 'SceneCard for $title',
);

Future<void> _fillProfile(
  WidgetTester tester,
  AppLocalizations l10n,
  String name,
) async {
  final add = find.byTooltip(l10n.settings_server_profile_add);
  await _tap(tester, add);
  await _pumpUntil(tester, _field(l10n.common_url));
  await tester.enterText(_field(l10n.settings_server_profile_name), name);
  await tester.enterText(_field(l10n.common_url), _url);
}

Future<void> _testAndSaveProfile(
  WidgetTester tester,
  AppLocalizations l10n,
  String name,
) async {
  final drawer = find.byType(ServerProfileDrawer);
  Finder result(RegExp pattern) =>
      find.descendant(of: drawer, matching: find.textContaining(pattern));
  final error = result(RegExp(r'^Error'));
  final retrying = error.evaluate().isNotEmpty;
  await _tap(tester, find.text(l10n.settings_server_test));
  if (retrying) await _pumpUntil(tester, error, gone: true);
  await _pumpUntil(tester, result(RegExp(r'^(v?\d+\.\d+|Error)')));
  expect(error, findsNothing);
  await _tap(tester, find.text(l10n.common_save));
  await _pumpUntil(tester, _field(l10n.common_url), gone: true);
  await _pumpUntil(tester, find.text(name));
}

Future<void> _switchToPasswordProfile(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  const name = 'stash-test-server-password';
  final scaffold = find.byType(Scaffold).first;
  unawaited(GoRouter.of(tester.element(scaffold)).push('/settings/server'));
  await _fillProfile(tester, l10n, name);
  await _tap(tester, find.text(l10n.settings_server_auth_password));
  final username = _field(l10n.settings_server_username);
  final password = _field(l10n.settings_server_password);
  await _pumpUntil(tester, username);
  await tester.enterText(username, _username);
  await tester.enterText(password, 'definitely-wrong');
  await _tap(tester, find.text(l10n.settings_server_test));
  await _pumpUntil(
    tester,
    find.text('Error: Login failed. Check credentials.'),
  );
  expect(password, findsOneWidget);
  await _tap(tester, password);
  await tester.enterText(password, _password);
  expect(
    tester.widget<TextField>(password).controller?.text == _password,
    isTrue,
    reason: 'the correction must replace the failed password',
  );
  await _testAndSaveProfile(tester, l10n, name);
  await _tap(tester, find.text(name));
  final card = find.ancestor(
    of: find.text(name),
    matching: find.byType(ServerProfileCard),
  );
  await _pumpUntil(
    tester,
    find.descendant(of: card, matching: find.byIcon(Icons.check)),
  );
  await _backTo(tester, '/scenes');
}

Future<void> _search(
  WidgetTester tester,
  AppLocalizations l10n,
  String query,
) async {
  await _tap(tester, find.byTooltip(l10n.common_search));
  final field = find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        widget.decoration?.hintText == l10n.scenes_search_hint,
    description: 'scene search field',
  );
  await _pumpUntil(tester, field);
  await tester.enterText(field, query);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await _pumpUntil(tester, field, gone: true);
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
  await _pumpUntil(tester, _sceneCard(_excludedSceneTitle));
  expect(find.byType(SceneCard), findsOneWidget);

  await _tap(tester, filter);
  await _tap(
    tester,
    find.descendant(of: organized, matching: find.text(l10n.common_yes)),
  );
  await _tap(tester, apply);
  await _pumpUntil(tester, find.text(l10n.common_no_items));
  expect(find.byType(SceneCard), findsNothing);

  await _search(tester, l10n, _sceneTitle);
  await _pumpUntil(tester, _sceneCard(_sceneTitle));
  expect(find.byType(SceneCard), findsOneWidget);

  await _search(tester, l10n, _excludedSceneTitle);
  await _pumpUntil(tester, find.text(l10n.common_no_items));
  await _tap(tester, filter);
  await _tap(tester, find.text(l10n.common_reset));
  await _tap(tester, apply);
  await _pumpUntil(tester, _sceneCard(_excludedSceneTitle));
  expect(find.byType(SceneCard), findsOneWidget);
  await _search(tester, l10n, _sceneTitle);
  await _pumpUntil(tester, _sceneCard(_sceneTitle));
}

// Independent, uncached server reads distinguish real writes from UI state.
Future<Map<String, dynamic>> _stash(
  HttpClient client,
  String query,
  Map<String, Object?> variables,
) async {
  final request = await client.postUrl(Uri.parse(_url).resolve('/graphql'));
  request.headers.set('ApiKey', _apiKey);
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
  final card = _sceneCard(_sceneTitle);
  final id = tester.widget<SceneCard>(card).scene.id;
  final server = HttpClient();
  addTearDown(() => server.close(force: true));
  final original = await _readScene(server, id);
  addTearDown(() => _restoreScene(server, id, original));
  final container = ProviderScope.containerOf(tester.element(card));
  final playerNotifier = container.read(playerStateProvider.notifier);
  final surface = find.byWidgetPredicate(
    (widget) => widget is PlayerSurface && widget.scene.id == id,
    description: 'player surface for $_sceneTitle',
  );
  final rating = find.byKey(const Key('scene_rating_controls'));
  final oneStar = find.descendant(of: rating, matching: find.text('1'));
  Future<void> openScene() async {
    await _tap(tester, card);
    await _pumpUntil(tester, surface);
    expect(_location(tester), '/scenes/scene/$id');
  }

  Future<void> stopScene() async {
    await _backTo(tester, '/scenes');
    final miniPlayer = find.byType(MiniPlayer);
    await _tap(
      tester,
      find.descendant(
        of: miniPlayer,
        matching: find.byTooltip(l10n.common_close),
      ),
    );
    await _pumpUntil(tester, miniPlayer, gone: true);
    await _pumpUntilCondition(
      tester,
      () => playerNotifier.currentVideoController == null,
      'the native playback session to release',
    );
  }

  try {
    await openScene();
    final player = tester.widget<PlayerSurface>(surface).controller.player;
    final initialPosition = player.state.position;
    await _pumpUntilCondition(
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
      await _tap(
        tester,
        find.descendant(of: surface, matching: find.byTooltip(tooltip)),
      );
      await _pumpUntilCondition(
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
    await _tap(tester, slider);
    await _pumpUntilCondition(
      tester,
      () =>
          (player.state.position - midpoint).abs() < const Duration(seconds: 1),
      'the native position to seek to the middle of the video',
    );
    final seekedAt = player.state.position;
    await setPlaying(true);
    await _pumpUntilCondition(
      tester,
      () =>
          player.state.position > seekedAt + const Duration(milliseconds: 250),
      'playback to advance after the seek',
    );
    await setPlaying(false);
    final pausedAt = player.state.position;

    final identity = find.descendant(
      of: find.byKey(const Key('scene_header_identity')),
      matching: find.text(_sceneTitle),
    );
    final detailsScroll = find.ancestor(
      of: surface,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(identity, 150, scrollable: detailsScroll);
    await tester.scrollUntilVisible(rating, 150, scrollable: detailsScroll);
    expect(oneStar, findsNothing);
    await _tap(tester, rating);
    await _tap(tester, find.byTooltip(l10n.scene_rating_stars(1)));
    await _tap(tester, find.text(l10n.common_apply));
    await _pumpUntil(tester, oneStar);
    await stopScene();

    final saved = await _readScene(server, id);
    expect(saved['rating100'], 20);
    expect(saved['resume_time'], closeTo(pausedAt.inMilliseconds / 1000, 1));

    await openScene();
    final resumed = tester.widget<PlayerSurface>(surface).controller.player;
    expect(resumed, isNot(same(player)));
    await _pumpUntilCondition(
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
    await tester.scrollUntilVisible(rating, 150, scrollable: detailsScroll);
    expect(oneStar, findsOneWidget);
    await stopScene();
  } finally {
    if (playerNotifier.currentVideoController != null) {
      playerNotifier.stop();
      await _pumpUntilCondition(
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
    skip: _url.isEmpty,
    timeout: const Timeout(Duration(minutes: 10)),
    (tester) async {
      expect(_apiKey, isNotEmpty, reason: 'pass STASH_API_KEY');
      expect(_username, isNotEmpty, reason: 'pass STASH_USERNAME');
      expect(_password, isNotEmpty, reason: 'pass STASH_PASSWORD');
      expect(
        app.isTestMode,
        isFalse,
        reason: 'native playback needs real app mode',
      );
      final platform = PathProviderPlatform.instance;
      final cacheDir = await getTemporaryDirectory();
      // macOS can return the sandbox cache path before it exists.
      await cacheDir.create(recursive: true);
      final support = await cacheDir.createTemp('stashflow-e2e-support-');
      PathProviderPlatform.instance = _IsolatedSupportPath(
        platform,
        support.path,
      );
      addTearDown(() async {
        PathProviderPlatform.instance = platform;
        await support.delete(recursive: true);
      });
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
      await _tap(tester, configure);
      const apiProfile = 'stash-test-server-api-key';
      await _fillProfile(tester, l10n, apiProfile);
      await tester.enterText(_field(l10n.settings_server_auth_apikey), _apiKey);
      await _testAndSaveProfile(tester, l10n, apiProfile);

      await _backTo(tester, '/scenes');
      await _pumpUntil(tester, _sceneCard(_sceneTitle));
      await _switchToPasswordProfile(tester, l10n);
      await _exerciseSceneSearch(tester, l10n);
      await _exerciseScene(tester, l10n);

      for (final (icon, names) in _tabs) {
        final tab = _navTab(icon);
        await _pumpUntil(tester, tab);
        await tester.tap(tab.first);
        await _pumpUntil(tester, _anyText(names));
      }
    },
  );
}
