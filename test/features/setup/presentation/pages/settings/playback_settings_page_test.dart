import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/playback_settings_page.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'video_gravity_orientation': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('PlaybackSettingsPage renders gravity orientation toggle', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gravity-controlled orientation'), findsOneWidget);
    expect(find.textContaining('Allow rotating between matching orientations'), findsOneWidget);

    // Find the switch that is part of the gravity orientation ListTile
    // We can use descendant search
    final gravitySwitch = find.descendant(
      of: find.ancestor(
        of: find.text('Gravity-controlled orientation'),
        matching: find.byType(SwitchListTile),
      ),
      matching: find.byType(Switch),
    );

    expect(tester.widget<Switch>(gravitySwitch).value, isTrue);

    await tester.tap(gravitySwitch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(gravitySwitch).value, isFalse);
    expect(prefs.getBool('video_gravity_orientation'), isFalse);
  });

  testWidgets('PlaybackSettingsPage defaults direct-play-on-navigation to enabled', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();

    // Expect translated text, hardcoded matching text 'Direct-play on scene navigation' from en localization
    expect(find.text('Direct-play on scene navigation'), findsOneWidget);

    final directPlaySwitch = find.descendant(
      of: find.widgetWithText(SwitchListTile, 'Direct-play on scene navigation'),
      matching: find.byType(Switch),
    );

    expect(tester.widget<Switch>(directPlaySwitch).value, isTrue);
  });
}
