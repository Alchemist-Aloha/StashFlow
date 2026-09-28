import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performer_details_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('performer details has no app bar title', (tester) async {
    const performer = Performer(
      id: 'performer-1',
      name: 'Performer One',
      urls: [],
      birthdate: null,
      aliasList: [],
      favorite: false,
      imagePath: null,
      sceneCount: 0,
      imageCount: 0,
      galleryCount: 0,
      groupCount: 0,
      tagIds: [],
      tagNames: [],
    );

    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider(
          'performer-1',
        ).overrideWith((ref) => performer),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
      ],
      child: const PerformerDetailsPage(performerId: 'performer-1'),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<AppBar>(find.byType(AppBar)).title, isNull);
  });
}
