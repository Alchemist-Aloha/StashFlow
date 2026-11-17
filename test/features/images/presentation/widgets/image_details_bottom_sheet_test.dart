import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Image;
import 'package:stash_app_flutter/core/presentation/widgets/related_entities.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_details_bottom_sheet.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('image details show metadata, tags and galleries', (
    tester,
  ) async {
    const image = Image(
      id: '15',
      title: 'Earth',
      files: [],
      paths: ImagePaths(thumbnail: null, preview: null, image: null),
      code: 'IMG-AUDIT',
      photographer: 'Audit Photographer',
      details: 'Audit image details',
      oCounter: 2,
      organized: true,
      tags: [ImageTag(id: 't1', name: 'Demo')],
      galleries: [
        ImageGallery(id: 'g1', title: 'Solar System'),
        ImageGallery(id: 'g2', path: '/data/Trip.zip'),
      ],
    );

    await pumpTestWidget(
      tester,
      child: const SingleChildScrollView(
        child: ImageDetailsContent(image: image),
      ),
    );
    await tester.pumpAndSettle();

    for (final text in [
      'IMG-AUDIT',
      'Audit Photographer',
      'Audit image details',
      '2',
      'Yes',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.widgetWithText(ActionChip, 'Demo'), findsOneWidget);
    expect(
      find.widgetWithText(RelatedEntityTile, 'Solar System'),
      findsOneWidget,
    );
    // Untitled galleries fall back to their file name.
    expect(find.widgetWithText(RelatedEntityTile, 'Trip.zip'), findsOneWidget);
  });
}
