import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_bottom_sheet.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_details_bottom_sheet.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('long press opens image details with rating controls', (
    tester,
  ) async {
    final repository = MockGraphQLImageRepository();
    const image = entity.Image(
      id: 'image-1',
      title: 'Image title',
      rating100: 60,
      date: '2026-08-03',
      files: [
        entity.ImageFile(width: 1200, height: 800, path: '/images/image-1.jpg'),
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

    expect(find.byType(RatingBottomSheet), findsOneWidget);
    expect(find.byType(ImageDetailsContent), findsOneWidget);
    expect(find.text('Image Details'), findsOneWidget);
    expect(find.text('/images/image-1.jpg'), findsOneWidget);
    final ratingSheet = find.byType(RatingBottomSheet);
    expect(
      find.descendant(of: ratingSheet, matching: find.byType(RatingButton)),
      findsOneWidget,
    );
    expect(find.byType(RatingPicker), findsNothing);
    await tester.tap(find.byType(RatingButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(RatingPicker), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RatingPicker),
        matching: find.byIcon(Icons.star),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: find.byType(RatingPicker),
        matching: find.byIcon(Icons.star_border),
      ),
      findsNWidgets(2),
    );
  });
}
