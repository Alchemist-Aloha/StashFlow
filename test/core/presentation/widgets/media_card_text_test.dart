import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/media_card_text.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  for (final scale in [0.8, 1.0, 1.5]) {
    for (final brightness in Brightness.values) {
      testWidgets('metadata uses theme dimensions ($scale, $brightness)', (
        tester,
      ) async {
        var moreCount = 0;
        await pumpTestWidget(
          tester,
          child: Theme(
            data: AppTheme.buildTheme(
              brightness,
              Colors.teal,
              fontSizeFactor: scale,
              useTrueBlack: true,
            ),
            child: Scaffold(
              body: SizedBox(
                width: 160,
                child: MediaCardMetadata(
                  title: 'A long title that should wrap and then truncate',
                  subtitle: 'A studio name that should truncate',
                  onMore: () => moreCount++,
                  performers: const Text('Performer'),
                ),
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(MediaCardMetadata));
        final padding = tester.widget<Padding>(
          find
              .descendant(
                of: find.byType(MediaCardMetadata),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(
          padding.padding,
          EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
        );
        final title = tester.widget<Text>(find.textContaining('A long title'));
        expect(title.style?.fontSize, context.dimensions.cardTitleFontSize);
        expect(title.maxLines, MediaCardText.titleMaxLines);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.more_vert)).size,
          16 * scale,
        );
        final action = tester.getSize(find.byTooltip('More'));
        expect(action.width, greaterThanOrEqualTo(48));
        expect(action.height, greaterThanOrEqualTo(48));
        expect(find.text('Performer'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byTooltip('More'));
        expect(moreCount, 1);
      });
    }
  }
}
