import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/appearance_settings_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/theme_color_picker_dialog.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_color_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';
import 'package:stash_app_flutter/core/presentation/theme/font_family_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';

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

  testWidgets('AppearanceSettingsPage saves selected font', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const AppearanceSettingsPage(),
    );
    await tester.pumpAndSettle();

    final dropdown = find.byType(DropdownButtonFormField<AppFontFamily>);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    final lora = find.text('Lora').last;
    expect(tester.widget<Text>(lora).style?.fontFamily, 'Lora');
    await tester.tap(lora);
    await tester.pumpAndSettle();

    expect(prefs.getString(appFontFamilyPreferenceKey), 'lora');
  });

  testWidgets('custom color dialog persists only on Apply', (tester) async {
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const AppearanceSettingsPage(),
    );
    await tester.pumpAndSettle();
    final custom = find.byKey(const Key('custom-theme-color'));
    await tester.ensureVisible(custom);
    await tester.pumpAndSettle();
    await tester.tap(custom);
    await tester.pumpAndSettle();
    expect(find.byType(ThemeColorPickerDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(prefs.getInt(appThemeSeedColorPreferenceKey), isNull);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(prefs.getInt(appThemeSeedColorPreferenceKey), 0xFF123456);

    await tester.tap(custom);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'FF123456',
    );
    await tester.enterText(find.byType(TextField), 'FFFFFF');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(prefs.getInt(appThemeSeedColorPreferenceKey), 0xFF123456);
  });

  testWidgets('AppearanceSettingsPage saves app language', (tester) async {
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const AppearanceSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('App Language'), findsOneWidget);
    expect(find.text('System'), findsWidgets);
    await tester.tap(find.text('App Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(prefs.getString(appLanguagePreferenceKey), 'es');
    expect(find.text('Español'), findsOneWidget);
  });
}
