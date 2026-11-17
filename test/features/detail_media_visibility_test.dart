import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/core/presentation/providers/related_entities_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/section_header.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/presentation/pages/group_details_page.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_details_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performer_details_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/presentation/pages/studio_details_page.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_details_provider.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/presentation/pages/tag_details_page.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  final scene = Scene(
    id: 'scene',
    title: 'Available scene',
    date: DateTime(2024),
    rating100: null,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: null,
    files: const [],
    paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
    urls: const [],
    studioId: null,
    studioName: null,
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
  const gallery = Gallery(
    id: 'gallery',
    title: 'Available gallery',
    coverPath: '',
  );
  const performer = Performer(
    id: 'owner',
    name: 'Owner',
    urls: [],
    birthdate: null,
    aliasList: [],
    favorite: false,
    imagePath: null,
    sceneCount: 1,
    imageCount: 0,
    galleryCount: 1,
    groupCount: 0,
    tagIds: [],
    tagNames: [],
  );
  const studio = Studio(
    id: 'owner',
    name: 'Owner',
    sceneCount: 1,
    imageCount: 0,
    galleryCount: 1,
    performerCount: 0,
    favorite: false,
  );
  const tag = Tag(
    id: 'owner',
    name: 'Owner',
    sceneCount: 1,
    imageCount: 0,
    galleryCount: 1,
    performerCount: 0,
    favorite: false,
  );
  final cases = [
    (
      kind: EntityMediaFilterKind.performer,
      galleryKind: EntityGalleryFilterKind.performer,
      page: const PerformerDetailsPage(performerId: 'owner'),
      details: performerDetailsProvider('owner')
          .overrideWith((ref) => performer),
    ),
    (
      kind: EntityMediaFilterKind.studio,
      galleryKind: EntityGalleryFilterKind.studio,
      page: const StudioDetailsPage(studioId: 'owner'),
      details: studioDetailsProvider('owner').overrideWith((ref) => studio),
    ),
    (
      kind: EntityMediaFilterKind.tag,
      galleryKind: EntityGalleryFilterKind.tag,
      page: const TagDetailsPage(tagId: 'owner'),
      details: tagDetailsProvider('owner').overrideWith((ref) => tag),
    ),
    (
      kind: EntityMediaFilterKind.group,
      galleryKind: null,
      page: const GroupDetailsPage(groupId: 'owner'),
      details: groupDetailsProvider('owner').overrideWith(
        (ref) => const Group(id: 'owner', name: 'Owner', sceneCount: 1),
      ),
    ),
  ];

  for (final testCase in cases) {
    for (final hasMedia in [false, true]) {
      for (final hasGalleries
          in testCase.galleryKind == null ? [false] : [false, true]) {
        testWidgets(
          '${testCase.kind.name}: media=$hasMedia, galleries=$hasGalleries',
          (tester) async {
            // Keep every section in view so absence cannot pass due to lazy builds.
            tester.view.physicalSize = const Size(800, 2000);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await pumpTestWidget(
              tester,
              overrides: [
                testCase.details,
                relatedEntitiesProvider.overrideWith((ref, query) => []),
                entityMediaPreviewProvider(
                  testCase.kind,
                  'owner',
                ).overrideWith((ref) => hasMedia ? [scene] : []),
                if (testCase.galleryKind case final kind?)
                  entityGalleryPreviewProvider(
                    kind,
                    'owner',
                  ).overrideWith((ref) => hasGalleries ? [gallery] : []),
              ],
              child: testCase.page,
            );
            await tester.pumpAndSettle();

            expect(
              find.byType(SceneStrip),
              hasMedia ? findsOneWidget : findsNothing,
            );
            expect(
              find.widgetWithText(SectionHeader, 'Media'),
              hasMedia ? findsOneWidget : findsNothing,
            );
            expect(
              find.byType(GalleryStrip),
              hasGalleries ? findsOneWidget : findsNothing,
            );
            expect(
              find.widgetWithText(SectionHeader, 'Galleries'),
              hasGalleries ? findsOneWidget : findsNothing,
            );
            expect(find.text('No media found'), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('${testCase.kind.name}: loading and error remain recoverable', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final pending = Completer<List<Scene>>();
      var response = pending.future;
      final provider = entityMediaPreviewProvider(testCase.kind, 'owner');
      await pumpTestWidget(
        tester,
        overrides: [
          testCase.details,
          relatedEntitiesProvider.overrideWith((ref, query) => []),
          provider.overrideWith((ref) => response),
          if (testCase.galleryKind case final kind?)
            entityGalleryPreviewProvider(
              kind,
              'owner',
            ).overrideWith((ref) => []),
        ],
        child: testCase.page,
      );
      await tester.pump();
      expect(find.widgetWithText(SectionHeader, 'Media'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.completeError(StateError('preview failed'));
      await tester.pumpAndSettle();
      expect(find.textContaining('preview failed'), findsOneWidget);
      expect(find.widgetWithText(SectionHeader, 'Media'), findsOneWidget);

      response = Future.value([]);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      container.invalidate(provider);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SectionHeader, 'Media'), findsNothing);
      expect(find.textContaining('preview failed'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
