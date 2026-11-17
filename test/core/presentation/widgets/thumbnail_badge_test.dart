import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/thumbnail_badge.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  for (final compact in [true, false]) {
    testWidgets('badge follows live UI scale (compact: $compact)', (
      tester,
    ) async {
      final scale = ValueNotifier(0.8);
      addTearDown(scale.dispose);
      await pumpTestWidget(
        tester,
        child: ValueListenableBuilder<double>(
          valueListenable: scale,
          builder: (context, factor, child) => Theme(
            data: AppTheme.buildTheme(
              Brightness.dark,
              Colors.teal,
              fontSizeFactor: factor,
              useTrueBlack: true,
            ),
            child: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ThumbnailBadge.rating(
                    context,
                    rating100: 80,
                    compact: compact,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      for (final factor in [0.8, 1.0, 1.5]) {
        scale.value = factor;
        await tester.pump();
        final context = tester.element(find.byType(ThumbnailBadge));
        final star = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(star.size, (compact ? 10 : 14) * factor);
        expect(star.color, context.colors.ratingColor);
        expect(find.text('4.0'), findsOneWidget);
        expect(
          ThumbnailBadge.inset(context, compact: compact),
          (compact ? 4 : 8) * factor,
        );
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(ThumbnailBadge),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          container.padding,
          EdgeInsets.symmetric(
            horizontal: (compact ? 4 : 6) * factor,
            vertical: (compact ? 1 : 2) * factor,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
