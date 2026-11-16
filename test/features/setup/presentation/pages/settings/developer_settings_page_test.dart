import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/one_time_tips.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/developer_settings_page.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('Develop settings re-arms every one-time tip', (tester) async {
    SharedPreferences.setMockInitialValues({
      for (final tip in OneTimeTip.values) tip.key: false,
    });
    final prefs = await SharedPreferences.getInstance();

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const DeveloperSettingsPage(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset-one-time-tips')));
    await tester.pumpAndSettle();

    for (final tip in OneTimeTip.values) {
      expect(tip.isPending(prefs), isTrue, reason: tip.name);
    }
    expect(find.text('First-run tips will show again.'), findsOneWidget);
  });
}
