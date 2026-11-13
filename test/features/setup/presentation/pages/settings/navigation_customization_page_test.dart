import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/navigation_customization_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  for (final scale in [0.5, 1.0, 2.0]) {
    for (final width in [500.0, 1200.0]) {
      testWidgets(
        'tab list renders and scrolls at width $width, scale $scale',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await pumpTestWidget(
            tester,
            child: Theme(
              data: AppTheme.buildTheme(
                Brightness.light,
                Colors.teal,
                fontSizeFactor: scale,
              ),
              child: const NavigationCustomizationPage(),
            ),
          );
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('markers')),
            100,
          );
          expect(find.byType(SettingsPanelCard), findsOneWidget);
          expect(find.byKey(const ValueKey('markers')), findsOneWidget);
          expect(
            tester
                .widget<Switch>(
                  find.descendant(
                    of: find.byKey(const ValueKey('markers')),
                    matching: find.byType(Switch),
                  ),
                )
                .value,
            isFalse,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'drag handle reorders immediately and switches persist visibility',
    (tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const NavigationCustomizationPage(),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationCustomizationPage)),
      );
      final handle = find.byType(ReorderableDragStartListener).first;
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        container.read(navigationTabsProvider).first.type,
        isNot(NavigationTabType.scenes),
      );

      final scenes = find.byKey(const ValueKey('scenes'));
      await tester.tap(
        find.descendant(of: scenes, matching: find.byType(Switch)),
      );
      await tester.pumpAndSettle();
      final saved =
          (jsonDecode(prefs.getString('navigation_tabs_config')!) as List)
              .cast<Map<String, dynamic>>();
      expect(saved.first['id'], isNot('scenes'));
      expect(
        saved.singleWhere((tab) => tab['id'] == 'scenes')['visible'],
        false,
      );
      final images = find.byKey(const ValueKey('images'));
      await tester.scrollUntilVisible(images, 100);
      final imagesSwitch = find.descendant(
        of: images,
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(imagesSwitch).value, isFalse);
      await tester.tap(imagesSwitch);
      await tester.pumpAndSettle();
      final updated =
          (jsonDecode(prefs.getString('navigation_tabs_config')!) as List)
              .cast<Map<String, dynamic>>();
      expect(
        updated.singleWhere((tab) => tab['id'] == 'images')['visible'],
        isTrue,
      );
      final markers = find.byKey(const ValueKey('markers'));
      await tester.scrollUntilVisible(markers, 100);
      final markerSwitch = find.descendant(
        of: markers,
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(markerSwitch).value, isFalse);
      await tester.tap(markerSwitch);
      await tester.pumpAndSettle();
      final savedMarkers =
          (jsonDecode(prefs.getString('navigation_tabs_config')!) as List)
              .cast<Map<String, dynamic>>();
      expect(
        savedMarkers.singleWhere((tab) => tab['id'] == 'markers')['visible'],
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
