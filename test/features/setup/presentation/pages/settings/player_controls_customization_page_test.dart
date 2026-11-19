import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_controls_layout.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/player_controls_customization_page.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  for (final scale in [0.5, 2.0]) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('edits the selected mode at width $width, scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await pumpTestWidget(
          tester,
          prefs: prefs,
          child: Theme(
            data: AppTheme.buildTheme(
              Brightness.light,
              Colors.teal,
              fontSizeFactor: scale,
            ),
            child: const PlayerControlsCustomizationPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(PlayerControlsCustomizationPage)),
        );

        final cast = find.byKey(const ValueKey(PlayerControlButton.cast));
        await tester.scrollUntilVisible(cast, 100);
        await tester.ensureVisible(cast);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(of: cast, matching: find.byType(Switch)),
        );
        await tester.pumpAndSettle();
        expect(
          container
              .read(inlinePlayerControlsLayoutProvider)
              .singleWhere((i) => i.button == PlayerControlButton.cast)
              .visible,
          isFalse,
        );

        // Switch to fullscreen and move fullscreen toggle to the top right.
        await tester.tap(find.text('Fullscreen').first);
        await tester.pumpAndSettle();
        final fs = find.byKey(const ValueKey(PlayerControlButton.fullscreen));
        final topRight = find.descendant(
          of: fs,
          matching: find.byIcon(Icons.north_east_rounded),
        );
        await tester.scrollUntilVisible(fs, 100);
        await tester.ensureVisible(topRight);
        await tester.pumpAndSettle();
        await tester.tap(topRight);
        await tester.pumpAndSettle();
        expect(
          container
              .read(fullscreenPlayerControlsLayoutProvider)
              .singleWhere((i) => i.button == PlayerControlButton.fullscreen)
              .placement,
          PlayerControlPlacement.topRight,
        );
        expect(
          container
              .read(fullscreenPlayerControlsLayoutProvider)
              .singleWhere((i) => i.button == PlayerControlButton.cast)
              .visible,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
