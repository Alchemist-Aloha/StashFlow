/// Helpers shared by the GUI end-to-end tests, which drive the real app
/// against a Stash server seeded by
/// https://github.com/Alchemist-Aloha/stash-test-server.
library;

import 'dart:async';

import 'package:flutter/gestures.dart' show HitTestResult;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_card.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_drawer.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

/// Server credentials, passed with `--dart-define` because devices and
/// browsers cannot read host environment variables.
const stashUrl = String.fromEnvironment('STASH_URL');
const stashApiKey = String.fromEnvironment('STASH_API_KEY');
const stashUsername = String.fromEnvironment('STASH_USERNAME');
const stashPassword = String.fromEnvironment('STASH_PASSWORD');

// Values from stash-test-server fixtures/profile.json (pinned by tag v1).
const sceneTitle = 'Pocket Garden';

Finder anyText(Set<String> values) => find.byWidgetPredicate(
  (w) => w is Text && values.contains(w.data),
  description: 'Text in $values',
);

Finder field(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextField));

Finder navTab(IconData icon) => find.descendant(
  of: find.byWidgetPredicate((w) => w is NavigationBar || w is NavigationRail),
  matching: find.byIcon(icon),
);

/// Pumps frames until [finder] matches; avoids pumpAndSettle, which never
/// settles while loading indicators or video run.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 60),
  bool gone = false,
}) async {
  await pumpUntilCondition(
    tester,
    () => finder.evaluate().isEmpty == gone,
    '$finder${gone ? ' to disappear' : ''}',
    timeout: timeout,
  );
}

Future<void> pumpUntilCondition(
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
String location(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .routerDelegate
        .currentConfiguration
        .last
        .matchedLocation;

Future<void> backTo(WidgetTester tester, String path) async {
  for (var i = 0; i < 4 && location(tester) != path; i++) {
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(location(tester), path);
}

Future<void> tapWhenReady(WidgetTester tester, Finder finder) async {
  await pumpUntil(tester, finder);
  try {
    // Layout can move the target after one scroll, so scroll on every frame.
    await pumpUntilCondition(tester, () {
      if (finder.hitTestable().evaluate().isNotEmpty) return true;
      unawaited(Scrollable.ensureVisible(tester.element(finder.first)));
      return false;
    }, '${finder.hitTestable()}');
  } on TestFailure catch (e) {
    final box = tester.renderObject<RenderBox>(finder.first);
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final hit = HitTestResult();
    tester.binding.hitTestInView(hit, center, tester.view.viewId);
    throw TestFailure(
      '${e.message}\nAt $center the top hit is: '
      '${hit.path.take(3).map((entry) => entry.target).join(' <- ')}',
    );
  }
  await tester.tap(finder);
}

Finder sceneCard(String title) => find.byWidgetPredicate(
  (widget) => widget is SceneCard && widget.scene.title == title,
  description: 'SceneCard for $title',
);

Future<void> fillProfile(
  WidgetTester tester,
  AppLocalizations l10n,
  String name,
) async {
  final add = find.byTooltip(l10n.settings_server_profile_add);
  await tapWhenReady(tester, add);
  await pumpUntil(tester, field(l10n.common_url));
  await tester.enterText(field(l10n.settings_server_profile_name), name);
  await tester.enterText(field(l10n.common_url), stashUrl);
}

Future<void> testAndSaveProfile(
  WidgetTester tester,
  AppLocalizations l10n,
  String name,
) async {
  final drawer = find.byType(ServerProfileDrawer);
  Finder result(RegExp pattern) =>
      find.descendant(of: drawer, matching: find.textContaining(pattern));
  final error = result(RegExp(r'^Error'));
  final retrying = error.evaluate().isNotEmpty;
  await tapWhenReady(tester, find.text(l10n.settings_server_test));
  if (retrying) await pumpUntil(tester, error, gone: true);
  await pumpUntil(tester, result(RegExp(r'^(v?\d+\.\d+|Error)')));
  expect(error, findsNothing);
  await tapWhenReady(tester, find.text(l10n.common_save));
  await pumpUntil(tester, field(l10n.common_url), gone: true);
  await pumpUntil(tester, find.text(name));
}

/// Adds a password profile, checks a wrong password is rejected, then logs in
/// with the right one and switches to that profile.
Future<void> switchToPasswordProfile(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  const name = 'stash-test-server-password';
  final scaffold = find.byType(Scaffold).first;
  unawaited(GoRouter.of(tester.element(scaffold)).push('/settings/server'));
  await fillProfile(tester, l10n, name);
  await tapWhenReady(tester, find.text(l10n.settings_server_auth_password));
  final username = field(l10n.settings_server_username);
  final password = field(l10n.settings_server_password);
  await pumpUntil(tester, username);
  await tester.enterText(username, stashUsername);
  await tester.enterText(password, 'definitely-wrong');
  await tapWhenReady(tester, find.text(l10n.settings_server_test));
  await pumpUntil(tester, find.text('Error: Login failed. Check credentials.'));
  expect(password, findsOneWidget);
  await tapWhenReady(tester, password);
  await tester.enterText(password, stashPassword);
  expect(
    tester.widget<TextField>(password).controller?.text == stashPassword,
    isTrue,
    reason: 'the correction must replace the failed password',
  );
  await testAndSaveProfile(tester, l10n, name);
  await tapWhenReady(tester, find.text(name));
  final card = find.ancestor(
    of: find.text(name),
    matching: find.byType(ServerProfileCard),
  );
  await pumpUntil(
    tester,
    find.descendant(of: card, matching: find.byIcon(Icons.check)),
  );
  await backTo(tester, '/scenes');
}
