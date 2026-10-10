import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_details_bottom_sheet.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('long press opens image details without rating controls', (
    tester,
  ) async {
    final repository = MockGraphQLImageRepository();
    const image = entity.Image(
      id: 'image-1',
      title: 'Image title',
      rating100: 60,
      date: '2026-08-03',
      files: [
        entity.ImageFile(
          width: 1200,
          height: 800,
          path: '/images/image-1.jpg',
          size: 1572864,
        ),
      ],
      paths: entity.ImagePaths(thumbnail: ''),
    );
    repository.withData([image]);

    await pumpTestWidget(
      tester,
      child: const Scaffold(body: ImageCard(image: image)),
      overrides: [imageRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.pump();

    await tester.longPress(find.byType(ImageCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ImageDetailsBottomSheet), findsOneWidget);
    expect(find.byType(ImageDetailsContent), findsOneWidget);
    expect(find.text('Image Details'), findsOneWidget);
    expect(find.text('/images/image-1.jpg'), findsOneWidget);
    expect(find.text('Image title'), findsOneWidget);
    expect(find.text('File Size'), findsOneWidget);
    expect(find.text('1.50 MB'), findsOneWidget);
    for (final text in ['Image title', 'image-1', '1200 x 800', '1.50 MB']) {
      expect(
        find.ancestor(
          of: find.text(text),
          matching: find.byType(SelectionArea),
        ),
        findsOneWidget,
      );
    }
    final detailsSheet = find.byType(ImageDetailsBottomSheet);
    expect(
      find.descendant(of: detailsSheet, matching: find.byType(RatingButton)),
      findsNothing,
    );
    expect(find.byType(RatingPicker), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(ImageDetailsBottomSheet), findsNothing);
  });
}
