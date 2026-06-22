import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/interface_settings_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets(
    'InterfaceSettingsPage saves actual scene video miniplayer toggle',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const InterfaceSettingsPage(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Show Edit Button'), findsNothing);
      expect(find.text('Use actual scene video in miniplayer'), findsOneWidget);
      expect(
        find.textContaining('Show the live scene video surface'),
        findsOneWidget,
      );

      final toggle = find.descendant(
        of: find.widgetWithText(
          SwitchListTile,
          'Use actual scene video in miniplayer',
        ),
        matching: find.byType(Switch),
      );

      expect(tester.widget<Switch>(toggle).value, isTrue);

      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(toggle).value, isFalse);
      expect(
        prefs.getBool(PlayerSettingsStore.useActualSceneVideoInMiniPlayerKey),
        isFalse,
      );
    },
  );
}
