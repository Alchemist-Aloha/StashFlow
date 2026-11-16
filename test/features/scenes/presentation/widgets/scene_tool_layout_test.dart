import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_tool_layout.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  for (final scale in [0.8, 1.5]) {
    for (final size in [const Size(320, 640), const Size(1600, 900)]) {
      testWidgets('tool layout fits $size at UI scale $scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        bool? isWide;
        await pumpTestWidget(
          tester,
          child: Theme(
            data: AppTheme.buildTheme(
              Brightness.dark,
              Colors.teal,
              fontSizeFactor: scale,
              useTrueBlack: true,
            ),
            child: Scaffold(
              body: SceneToolLayout(
                configExpanded: true,
                onToggleConfig: () {},
                compactConfigHeightFactor: 0.5,
                controlsBuilder: (wide) {
                  isWide = wide;
                  return const SceneToolPanelHeading(
                    icon: Icons.tune,
                    title: 'Settings',
                  );
                },
                results: Column(
                  children: [
                    const Expanded(
                      child: SceneToolEmptyResults(
                        icon: Icons.search,
                        message: 'No results',
                      ),
                    ),
                    SceneToolPaginationBar(
                      page: 1,
                      totalPages: 2,
                      onPrevious: null,
                      onNext: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(isWide, size.width >= 1000 * scale);
        expect(tester.widget<Icon>(find.byIcon(Icons.tune)).size, 20 * scale);
        expect(tester.widget<Icon>(find.byIcon(Icons.search)).size, 48 * scale);
        final controls = tester.getRect(find.byType(SceneToolPanelHeading));
        final results = tester.getRect(find.byType(SceneToolEmptyResults));
        if (isWide!) {
          expect(controls.width, 340 * scale);
          expect(results.left, greaterThan(controls.right));
        } else {
          expect(find.text('Configuration'), findsOneWidget);
          expect(results.top, greaterThan(controls.bottom));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
