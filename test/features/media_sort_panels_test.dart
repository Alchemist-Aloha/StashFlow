import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/list_sort_bottom_sheet.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/gallery_sort.dart';
import 'package:stash_app_flutter/features/galleries/presentation/pages/galleries_page.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart'
    show EntityGalleryFilterKind, entityGallerySortProvider;
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/entity_gallery_grid.dart';
import 'package:stash_app_flutter/features/images/presentation/pages/images_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/scene_sort.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/entity_scene_media_grid.dart';

import '../helpers/test_helpers.dart';

class _EmptyGalleryList extends GalleryList {
  @override
  Future<List<Gallery>> build() async => [];
}

void main() {
  Future<void> openSort(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
  }

  Future<void> expandAdvanced(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(ExpansionTile));
    await tester.tap(find.text('Advanced sort options'));
    await tester.pumpAndSettle();
  }

  Future<void> chooseAndApply(WidgetTester tester, String label) async {
    final chip = find.widgetWithText(ChoiceChip, label);
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply Sort'));
    await tester.pumpAndSettle();
  }

  test('shared catalogues round-trip all server keys and gallery aliases', () {
    expect(SceneSortField.values, hasLength(31));
    expect(GallerySortOption.values, hasLength(13));
    for (final field in SceneSortField.values) {
      expect(SceneSortField.fromKey(field.key), field);
    }
    for (final option in GallerySortOption.values) {
      expect(GallerySortOption.fromKey(option.key), option);
    }
    expect(SceneSortField.fromKey(null), SceneSortField.date);
    expect(SceneSortField.fromKey('unknown'), SceneSortField.date);
    expect(GallerySortOption.fromKey(null), GallerySortOption.path);
    expect(GallerySortOption.fromKey('unknown'), GallerySortOption.path);
    expect(GallerySortOption.fromKey('rating100'), GallerySortOption.rating);
    expect(
      GallerySortOption.fromKey('image_count'),
      GallerySortOption.imageCount,
    );
    expect(
      GallerySortOption.fromKey('zip_file_count'),
      GallerySortOption.fileCount,
    );
    expect(
      SceneSortField.commonOptions,
      containsAll([
        SceneSortField.random,
        SceneSortField.updatedAt,
        SceneSortField.lastPlayedAt,
      ]),
    );
  });

  for (final kind in EntityMediaFilterKind.values) {
    testWidgets('$kind scene grid uses the complete shared scene catalogue', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: EntitySceneMediaGrid(
          title: 'Entity scenes',
          entityId: 'entity-1',
          filterKind: kind,
          mediaAsync: const AsyncData([]),
          isGridView: true,
          gridColumns: 2,
          queueId: 'entity-queue',
          onRefresh: () async {},
          onFetchNextPage: () {},
        ),
      );
      await openSort(tester);
      final sheet = tester.widget<ListSortBottomSheet<SceneSortField>>(
        find.byType(ListSortBottomSheet<SceneSortField>),
      );
      expect(sheet.options, SceneSortField.values);
      expect(sheet.commonOptions, SceneSortField.commonOptions);
      expect(sheet.initialOption, SceneSortField.random);
      expect(sheet.resetOption, SceneSortField.random);
      expect(find.byType(ChoiceChip), findsNWidgets(7));
      expect(find.widgetWithText(ChoiceChip, 'Last Played At'), findsOneWidget);
      await expandAdvanced(tester);
      expect(find.byType(ChoiceChip), findsNWidgets(31));
      await chooseAndApply(tester, 'Bitrate');
      final container = ProviderScope.containerOf(
        tester.element(find.byType(EntitySceneMediaGrid)),
      );
      expect(container.read(entityMediaSortProvider(kind)).sort, 'bitrate');
      await openSort(tester);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Bitrate'))
            .selected,
        isTrue,
      );
      expect(find.byType(ChoiceChip), findsNWidgets(8));
    });
  }

  for (final kind in <EntityGalleryFilterKind?>[
    null,
    ...EntityGalleryFilterKind.values,
  ]) {
    testWidgets('$kind gallery grid groups the shared gallery catalogue', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        overrides: [galleryListProvider.overrideWith(_EmptyGalleryList.new)],
        child: kind == null
            ? const GalleriesPage()
            : EntityGalleryGrid(
                title: 'Entity galleries',
                entityId: 'entity-1',
                filterKind: kind,
                galleriesAsync: const AsyncData([]),
                isGridView: true,
                gridColumns: 2,
                onRefresh: () async {},
                onFetchNextPage: () {},
              ),
      );
      await openSort(tester);
      final sheet = tester.widget<ListSortBottomSheet<GallerySortOption>>(
        find.byType(ListSortBottomSheet<GallerySortOption>),
      );
      expect(sheet.options, GallerySortOption.values);
      expect(sheet.commonOptions, GallerySortOption.commonOptions);
      expect(find.byType(ChoiceChip), findsNWidgets(7));
      for (final label in ['Random', 'Updated At', 'Image Count']) {
        expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
      }
      await expandAdvanced(tester);
      expect(find.byType(ChoiceChip), findsNWidgets(13));
      await chooseAndApply(tester, 'Tag Count');
      final container = ProviderScope.containerOf(
        tester.element(
          find.byType(kind == null ? GalleriesPage : EntityGalleryGrid),
        ),
      );
      final sort = kind == null
          ? container.read(gallerySortProvider).sort
          : container.read(entityGallerySortProvider(kind)).sort;
      expect(sort, 'tag_count');
      await openSort(tester);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tag Count'))
            .selected,
        isTrue,
      );
    });
  }

  for (final surface in ['scene', 'gallery', 'image']) {
    for (final width in [320.0, 1200.0]) {
      for (final scale in [0.8, 1.5]) {
        testWidgets('$surface sort at width $width / scale $scale', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 480);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final page = switch (surface) {
            'scene' => EntitySceneMediaGrid(
              title: 'Entity scenes',
              entityId: 'entity-1',
              filterKind: EntityMediaFilterKind.performer,
              mediaAsync: const AsyncData([]),
              isGridView: true,
              gridColumns: 2,
              queueId: 'entity-queue',
              onRefresh: () async {},
              onFetchNextPage: () {},
            ),
            'gallery' => EntityGalleryGrid(
              title: 'Entity galleries',
              entityId: 'entity-1',
              filterKind: EntityGalleryFilterKind.performer,
              galleriesAsync: const AsyncData([]),
              isGridView: true,
              gridColumns: 2,
              onRefresh: () async {},
              onFetchNextPage: () {},
            ),
            _ => const ImagesPage(),
          };
          await pumpTestWidget(
            tester,
            overrides: [
              galleryListProvider.overrideWith(_EmptyGalleryList.new),
              imageRepositoryProvider.overrideWithValue(
                MockGraphQLImageRepository(),
              ),
            ],
            child: Theme(
              data: AppTheme.buildTheme(
                Brightness.light,
                Colors.teal,
                fontSizeFactor: scale,
              ),
              child: page,
            ),
          );
          await openSort(tester);
          expect(find.byType(ChoiceChip), findsNWidgets(7));
          expect(find.text('Apply Sort').hitTestable(), findsOneWidget);
          await expandAdvanced(tester);
          expect(find.text('Apply Sort').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets(
    'image sorting groups common choices without losing advanced sorts',
    (tester) async {
      await pumpTestWidget(
        tester,
        overrides: [
          imageRepositoryProvider.overrideWithValue(
            MockGraphQLImageRepository(),
          ),
        ],
        child: const ImagesPage(),
      );
      await openSort(tester);
      expect(find.byType(ChoiceChip), findsNWidgets(7));
      for (final label in ['Random', 'Updated At', 'Resolution']) {
        expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
      }
      await expandAdvanced(tester);
      expect(find.byType(ChoiceChip), findsNWidgets(15));
      await chooseAndApply(tester, 'Tag Count');
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ImagesPage)),
      );
      expect(container.read(imageSortProvider).sort, 'tag_count');
      await openSort(tester);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tag Count'))
            .selected,
        isTrue,
      );
    },
  );
}
