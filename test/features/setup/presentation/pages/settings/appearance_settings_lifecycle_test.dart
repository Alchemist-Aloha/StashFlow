import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/appearance_settings_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('AppearanceSettingsPage does not register no-op focus listeners', () {
    final source = File(
      'lib/features/setup/presentation/pages/settings/appearance_settings_page.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('addListener(_onTextFieldFocusChanged)')));
    expect(source, isNot(contains('_onTextFieldFocusChanged')));
  });

  testWidgets('AppearanceSettingsPage renders shared settings panel chrome', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const AppearanceSettingsPage(),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsPageBody), findsOneWidget);
    expect(find.byType(SettingsPanelCard), findsWidgets);
  });
}
