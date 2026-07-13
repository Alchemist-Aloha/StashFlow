import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('SettingsSectionCard wraps content in shared panel chrome', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const SettingsPageShell(
        title: 'Settings',
        child: SettingsPageBody(
          child: SettingsSectionCard(
            title: 'Appearance',
            subtitle: 'Theme and scale',
            child: Text('panel body'),
          ),
        ),
      ),
    );

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme and scale'), findsOneWidget);
    expect(find.text('panel body'), findsOneWidget);
    expect(find.byType(SettingsPanelCard), findsOneWidget);
  });
}
