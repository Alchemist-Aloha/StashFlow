import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/presentation/pages/tag_details_page.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('tag details has no app bar title', (tester) async {
    const tag = Tag(
      id: 'tag-1',
      name: 'Tag One',
      sceneCount: 0,
      imageCount: 0,
      galleryCount: 0,
      performerCount: 0,
      favorite: false,
    );

    await pumpTestWidget(
      tester,
      overrides: [
        tagDetailsProvider('tag-1').overrideWith((ref) => tag),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.tag,
          'tag-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.tag,
          'tag-1',
        ).overrideWith((ref) => []),
      ],
      child: const TagDetailsPage(tagId: 'tag-1'),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<AppBar>(find.byType(AppBar)).title, isNull);
  });
}
