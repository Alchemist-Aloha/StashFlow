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
/// Preferences are in memory (`setMockInitialValues`), so a desktop run never
/// reads or overwrites the developer's real profiles. Credentials still go to
/// the platform keychain; the test deletes the keys it created.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/main.dart' as app;

const _url = String.fromEnvironment('STASH_URL');
const _apiKey = String.fromEnvironment('STASH_API_KEY');

// Values from stash-test-server fixtures/profile.json (pinned by tag v1).
const _sceneTitles = {
  'Coastal Drift',
  'Harbor Lights',
  'Ember Field',
  'Prism Study',
  'Mandelbrot Zoom',
  'Cellular Bloom',
  'Pocket Garden',
  'Pulse Lab',
};
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

Future<bool> _appears(WidgetTester tester, Finder finder, Duration timeout) =>
    _pumpUntil(
      tester,
      finder,
      timeout: timeout,
    ).then((_) => true, onError: (Object _) => false);

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

Future<void> _deleteProfileSecrets() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('server_profiles');
  final ids = [
    'test', // written by the drawer's "Test connection"
    if (raw != null)
      for (final p in jsonDecode(raw) as List<dynamic>)
        (p as Map<String, dynamic>)['id'] as String,
  ];
  const storage = FlutterSecureStorage();
  for (final id in ids) {
    for (final key in ['api_key', 'username', 'password', 'cookie_header']) {
      try {
        await storage.delete(key: 'profile_${id}_$key');
      } on Object catch (_) {
        // Keychain unavailable (unsigned macOS build): the app used prefs.
      }
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'first-run setup connects to the test server and browses the library',
    skip: _url.isEmpty,
    timeout: const Timeout(Duration(minutes: 10)),
    (tester) async {
      SharedPreferences.setMockInitialValues({
        // Skip the first-run language picker and the GitHub update dialog.
        'app_language': 'en',
        'last_app_update_check_timestamp':
            DateTime.now().millisecondsSinceEpoch,
      });
      final l10n = lookupAppLocalizations(const Locale('en'));

      // main() installs its own error hooks; flutter_test requires them back.
      final onError = FlutterError.onError;
      final print = debugPrint;
      try {
        await app.main();

        // First launch prompts for a server; test builds skip that prompt.
        // The empty scenes list behind the dialog offers the same button.
        final configure = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_configure_now),
        );
        if (await _appears(tester, configure, const Duration(seconds: 20))) {
          await tester.tap(configure);
        } else {
          unawaited(
            GoRouter.of(tester.element(find.byType(Scaffold).first))
                .push('/settings/server'),
          );
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
        await tester.enterText(
          _field(l10n.settings_server_auth_apikey),
          _apiKey,
        );

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
        final sceneCard = _anyText(_sceneTitles);
        await _pumpUntil(tester, sceneCard);

        final title = (sceneCard.evaluate().first.widget as Text).data!;
        await tester.tap(sceneCard.first);
        await tester.pump(const Duration(seconds: 1));
        expect(_location(tester), startsWith('/scenes/scene/'));
        await _pumpUntil(tester, find.text(title));
        // Let playback start so the native player initializes on this platform.
        await tester.pump(const Duration(seconds: 3));
        await _backTo(tester, '/scenes');

        for (final (icon, names) in _tabs) {
          final tab = _navTab(icon);
          await _pumpUntil(tester, tab);
          await tester.tap(tab.first);
          await _pumpUntil(tester, _anyText(names));
        }
      } finally {
        FlutterError.onError = onError;
        debugPrint = print;
        await _deleteProfileSecrets();
      }
    },
  );
}
