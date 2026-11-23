/// GUI end-to-end test: drives the real app against a Stash server seeded by
/// https://github.com/Alchemist-Aloha/stash-test-server.
///
/// Devices cannot read host environment variables, so the server is passed
/// with `--dart-define`; the test skips when `STASH_URL` is empty:
///
/// ```bash
/// set -a; source ../stash-test-server/stash-test-server.env; set +a
/// flutter test integration_test -d linux \
///   --dart-define=STASH_URL=$STASH_URL --dart-define=STASH_API_KEY=$STASH_API_KEY
/// ```
///
/// On the Android emulator the host's loopback is `http://10.0.2.2:9999`.
///
/// Preferences and credentials stay in memory; the test never reads or
/// overwrites the developer's profiles or keychain.
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/one_time_tips.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/player_surface.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/main.dart' as app;
import 'package:wakelock_plus/wakelock_plus.dart';

const _url = String.fromEnvironment('STASH_URL');
const _apiKey = String.fromEnvironment('STASH_API_KEY');

// Values from stash-test-server fixtures/profile.json (pinned by tag v1).
const _sceneTitle = 'Pocket Garden';
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
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isEmpty == gone) return;
  }
  final onScreen = find
      .byType(RichText)
      .evaluate()
      .map((e) => (e.widget as RichText).text.toPlainText())
      .where((t) => t.trim().isNotEmpty)
      .take(60)
      .toList();
  throw TestFailure(
    'Timed out after $timeout waiting for $finder'
    '${gone ? ' to disappear' : ''}\nOn screen: $onScreen',
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'first-run setup connects to the test server and browses the library',
    skip: _url.isEmpty,
    timeout: const Timeout(Duration(minutes: 10)),
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({
        'app_language': 'en',
        'last_app_update_check_timestamp':
            DateTime.now().millisecondsSinceEpoch,
        // The test covers server setup, not the one-time browsing tips or auto-next.
        for (final tip in OneTimeTip.values) tip.key: false,
        PlayerSettingsStore.playEndBehaviorKey: 'stop',
        PlayerSettingsStore.resumePlayPositionKey: false,
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

      if (app.isTestMode) {
        // The shell skips the first-run prompt in test mode.
        final scaffold = find.byType(Scaffold).first;
        await _pumpUntil(tester, scaffold);
        unawaited(
          GoRouter.of(tester.element(scaffold)).push('/settings/server'),
        );
      } else {
        final configure = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_configure_now),
        );
        await _pumpUntil(tester, configure);
        await tester.tap(configure);
      }

      final add = find.text(l10n.settings_server_profile_add);
      await _pumpUntil(tester, add);
      await tester.tap(add.last);

      await _pumpUntil(tester, _field(l10n.common_url));
      await tester.enterText(
        _field(l10n.settings_server_profile_name),
        'stash-test-server',
      );
      await tester.enterText(_field(l10n.common_url), _url);
      await tester.enterText(_field(l10n.settings_server_auth_apikey), _apiKey);

      final testButton = find.text(l10n.settings_server_test);
      await tester.ensureVisible(testButton);
      await tester.tap(testButton);
      // Success shows the server version; failures start with "Error".
      await _pumpUntil(
        tester,
        find.textContaining(RegExp(r'^(v?\d+\.\d+|Error)')),
      );
      expect(find.textContaining(RegExp(r'^Error')), findsNothing);

      final save = find.text(l10n.common_save);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await _pumpUntil(tester, _field(l10n.common_url), gone: true);
      expect(find.text('stash-test-server'), findsWidgets);

      await _backTo(tester, '/scenes');
      final sceneCard = find.byWidgetPredicate(
        (widget) => widget is SceneCard && widget.scene.title == _sceneTitle,
        description: 'SceneCard for $_sceneTitle',
      );
      await _pumpUntil(tester, sceneCard);
      final id = tester.widget<SceneCard>(sceneCard).scene.id;
      await tester.ensureVisible(sceneCard);
      await tester.tap(sceneCard);
      await _pumpUntil(
        tester,
        find.byWidgetPredicate(
          (widget) => widget is PlayerSurface && widget.scene.id == id,
          description: 'player surface for $_sceneTitle',
        ),
      );
      expect(_location(tester), '/scenes/scene/$id');

      // The portrait player can occupy the viewport above the lazy title.
      await tester.scrollUntilVisible(
        find.descendant(
          of: find.byKey(const Key('scene_header_identity')),
          matching: find.text(_sceneTitle),
        ),
        150,
        scrollable: find.ancestor(
          of: find.byType(PlayerSurface),
          matching: find.byType(Scrollable),
        ),
      );
      await _backTo(tester, '/scenes');

      for (final (icon, names) in _tabs) {
        final tab = _navTab(icon);
        await _pumpUntil(tester, tab);
        await tester.tap(tab.first);
        await _pumpUntil(tester, _anyText(names));
      }
    },
  );
}
