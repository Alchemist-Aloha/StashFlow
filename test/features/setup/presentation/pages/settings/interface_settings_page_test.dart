import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/interface_settings_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';

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

      expect(find.byType(SettingsPageBody), findsOneWidget);
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

  testWidgets(
    'InterfaceSettingsPage exposes and saves group and marker layout settings',
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

      await tester.scrollUntilVisible(
        find.byKey(const Key('marker-layout-segmented')),
        200,
      );
      final markerSegmented = find.byKey(const Key('marker-layout-segmented'));
      tester
          .widget<SegmentedButton<String>>(markerSegmented)
          .onSelectionChanged!({'list'});
      await tester.pumpAndSettle();

      expect(prefs.getBool('scene_marker_grid_layout'), isFalse);

      await tester.scrollUntilVisible(
        find.byKey(const Key('group-layout-segmented')),
        200,
      );
      final groupSegmented = find.byKey(const Key('group-layout-segmented'));
      tester
          .widget<SegmentedButton<String>>(groupSegmented)
          .onSelectionChanged!({'list'});
      await tester.pumpAndSettle();

      expect(prefs.getBool('group_media_grid_layout'), isFalse);
    },
  );

  testWidgets('InterfaceSettingsPage saves performer list grid columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const InterfaceSettingsPage(),
    );
    await tester.pumpAndSettle();

    final slider = find.byKey(const Key('performer-list-grid-columns-slider'));

    await tester.scrollUntilVisible(slider, 200);
    tester.widget<Slider>(slider).onChanged!(5);
    await tester.pumpAndSettle();

    expect(prefs.getInt('performer_grid_columns_v2'), 5);
  });

  testWidgets('InterfaceSettingsPage saves the entity image filter method', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const InterfaceSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entity image filtering'), findsOneWidget);
    expect(find.text('Direct entity'), findsOneWidget);

    await tester.tap(find.text('Related galleries'));
    await tester.pumpAndSettle();

    expect(
      prefs.getString(entityImageFilterMethodPreferenceKey),
      EntityImageFilterMethod.relatedGalleries.name,
    );
  });

  testWidgets('InterfaceSettingsPage saves the random filter toggle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const InterfaceSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Respect active filters for random scene'),
      findsOneWidget,
    );

    final toggle = find.descendant(
      of: find.widgetWithText(
        SwitchListTile,
        'Respect active filters for random scene',
      ),
      matching: find.byType(Switch),
    );

    expect(tester.widget<Switch>(toggle).value, isTrue);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(prefs.getBool('scene_random_respect_active_filter'), isFalse);
  });

  testWidgets('InterfaceSettingsPage saves scene metadata visibility', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const InterfaceSettingsPage(),
    );
    await tester.pumpAndSettle();

    final toggle = find.descendant(
      of: find.widgetWithText(SwitchListTile, 'Hide scene metadata by default'),
      matching: find.byType(Switch),
    );

    expect(tester.widget<Switch>(toggle).value, isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(prefs.getBool('hide_scene_technical_metadata'), isFalse);
  });
}
