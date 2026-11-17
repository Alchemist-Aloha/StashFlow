import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/providers/related_entities_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/related_entities.dart';
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

  testWidgets('tag details show aliases, hierarchy and related performers', (
    tester,
  ) async {
    const tag = Tag(
      id: 'tag-1',
      name: 'Tag One',
      sceneCount: 0,
      imageCount: 0,
      galleryCount: 0,
      performerCount: 0,
      favorite: false,
      aliases: ['First', 'Second'],
      parents: [TagRelation(id: 'tag-0', name: 'Parent Tag')],
      children: [TagRelation(id: 'tag-2', name: 'Child Tag')],
    );
    RelatedEntityQuery query(RelatedEntityKind kind) =>
        (kind: kind, owner: RelatedEntityOwner.tag, id: 'tag-1');

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
        relatedEntitiesProvider(query(RelatedEntityKind.performers))
            .overrideWith(
              (ref) => [
                (
                  id: 'p1',
                  title: 'Remy',
                  subtitle: null,
                  imagePath: null,
                  route: '/performers/performer/p1',
                ),
              ],
            ),
        for (final kind in [
          RelatedEntityKind.studios,
          RelatedEntityKind.groups,
          RelatedEntityKind.markers,
        ])
          relatedEntitiesProvider(query(kind)).overrideWith((ref) => []),
      ],
      child: const TagDetailsPage(tagId: 'tag-1'),
    );
    await tester.pumpAndSettle();

    expect(find.text('First, Second'), findsOneWidget);
    expect(find.text('Parent Tags'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Parent Tag'), findsOneWidget);
    expect(find.text('Sub-Tags'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Child Tag'), findsOneWidget);
    final performer = find.widgetWithText(RelatedEntityTile, 'Remy');
    await tester.scrollUntilVisible(
      performer,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(performer, findsOneWidget);
    // Empty related lists render no section.
    expect(find.text('Studios'), findsNothing);
  });
}
