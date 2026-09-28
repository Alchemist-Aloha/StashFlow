import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/features/galleries/data/repositories/graphql_gallery_repository.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery_filter.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/pages/gallery_details_page.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';

import '../../../../helpers/test_helpers.dart';

class _RatingGalleryRepository implements GraphQLGalleryRepository {
  Gallery gallery = const Gallery(
    id: 'gallery-1',
    title: 'Gallery One',
    imageCount: 30,
  );
  bool failRating = false;
  final ratings = <int>[];
  final refreshes = <bool>[];

  @override
  Future<Gallery> getGalleryById(String id, {bool refresh = false}) async {
    refreshes.add(refresh);
    return gallery;
  }

  @override
  Future<void> updateGalleryRating(String id, int rating100) async {
    if (failRating) throw Exception('rating failed');
    ratings.add(rating100);
    gallery = Gallery(
      id: id,
      title: gallery.title,
      imageCount: gallery.imageCount,
      rating100: rating100,
    );
  }

  @override
  Future<List<Gallery>> findGalleries({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GalleryFilter? galleryFilter,
    String? performerId,
    String? studioId,
    String? tagId,
  }) async => [gallery, const Gallery(id: 'gallery-2', title: 'Other Gallery')];
}

void main() {
  testWidgets(
    'gallery rating confirms, clears, and preserves state on failure',
    (tester) async {
      final galleries = _RatingGalleryRepository();
      final images = MockGraphQLImageRepository()..withEmpty();
      await pumpTestWidget(
        tester,
        overrides: [
          galleryRepositoryProvider.overrideWithValue(galleries),
          imageRepositoryProvider.overrideWithValue(images),
        ],
        child: const GalleryDetailsPage(galleryId: 'gallery-1'),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(GalleryDetailsPage)),
      );
      await container.read(galleryListProvider.future);
      await tester.pumpAndSettle();
      final button = find.byKey(const Key('gallery_action_rating'));
      expect(tester.widget<RatingButton>(button).rating100, isNull);
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('4 Stars'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(galleries.ratings, isEmpty);
      Future<void> rate({bool clear = false}) async {
        await tester.tap(button);
        await tester.pumpAndSettle();
        await tester.tap(
          clear ? find.text('Clear Rating') : find.byTooltip('4 Stars'),
        );
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
      }

      await rate();
      expect(galleries.ratings, [80]);
      expect(galleries.refreshes, contains(true));
      expect(tester.widget<RatingButton>(button).rating100, 80);
      final list = container.read(galleryListProvider).requireValue;
      expect(list.map((gallery) => gallery.id), ['gallery-1', 'gallery-2']);
      expect(list.first.rating100, 80);
      await rate(clear: true);
      expect(galleries.ratings, [80, 0]);
      expect(tester.widget<RatingButton>(button).rating100, 0);
      galleries.failRating = true;
      await rate();
      expect(galleries.ratings, [80, 0]);
      expect(tester.widget<RatingButton>(button).rating100, 0);
      expect(find.textContaining('Failed to update rating'), findsOneWidget);
    },
  );

  for (final width in [320.0, 1100.0]) {
    for (final scale in [0.8, 1.5]) {
      testWidgets('gallery rating fits width $width at scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final images = MockGraphQLImageRepository()..withEmpty();
        await pumpTestWidget(
          tester,
          overrides: [
            galleryDetailsProvider('gallery-1').overrideWith(
              (ref) => const Gallery(
                id: 'gallery-1',
                title: 'Gallery One',
                rating100: 55,
                date: '2026-08-09',
                imageCount: 30,
              ),
            ),
            imageRepositoryProvider.overrideWithValue(images),
          ],
          child: Theme(
            data: AppTheme.buildTheme(
              Brightness.light,
              const Color(0xFF0F766E),
              fontSizeFactor: scale,
            ),
            child: const GalleryDetailsPage(galleryId: 'gallery-1'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('gallery_action_rating')), findsOneWidget);
        if (width == 320 && scale == 1.5) {
          expect(
            tester.getSize(find.text('Gallery One')).width,
            greaterThan(200),
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('gallery details browses images and collapses while scrolling', (
    tester,
  ) async {
    const gallery = Gallery(
      id: 'gallery-1',
      title: 'Gallery One',
      details: 'Compact gallery description',
      date: '2026-08-09',
      imageCount: 30,
      code: 'GAL-001',
      photographer: 'Photographer One',
      filePaths: ['/gallery/gallery-one.zip'],
      tagIds: ['tag-1'],
      tagNames: ['Tag One'],
      chapters: [
        GalleryChapter(id: 'chapter-1', title: 'Opening', imageIndex: 3),
      ],
      studioId: 'studio-1',
      studioName: 'Studio One',
      performerIds: ['performer-1'],
      performerNames: ['Performer One'],
    );
    final repository = MockGraphQLImageRepository()
      ..withData(
        List.generate(
          30,
          (index) => entity.Image(
            id: 'image-$index',
            title: 'Image $index',
            files: const [entity.ImageFile(width: 100, height: 100, path: '')],
            paths: const entity.ImagePaths(image: '', thumbnail: ''),
          ),
        ),
      );

    await pumpTestWidget(
      tester,
      overrides: [
        galleryDetailsProvider('gallery-1').overrideWith((ref) => gallery),
        imageRepositoryProvider.overrideWithValue(repository),
      ],
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Theme(
            data: theme.copyWith(
              appBarTheme: theme.appBarTheme.copyWith(
                titleTextStyle: theme.appBarTheme.titleTextStyle!.copyWith(
                  fontSize: 18,
                ),
              ),
            ),
            child: const GalleryDetailsPage(galleryId: 'gallery-1'),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gallery_details_expanded')), findsOneWidget);
    expect(find.byKey(const Key('gallery_action_rating')), findsOneWidget);
    expect(find.text('Gallery Details'), findsNothing);
    expect(tester.widget<AppBar>(find.byType(AppBar)).title, isNull);
    expect(find.text('Gallery One'), findsOneWidget);
    expect(find.text('Compact gallery description'), findsOneWidget);
    expect(find.text('Studio One'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('gallery_studio_link'))).dy,
      greaterThan(tester.getTopLeft(find.text('Gallery One')).dy),
    );
    final count = find.byKey(const Key('gallery_image_count'));
    expect(
      tester.getTopLeft(count).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const Key('gallery_studio_link'))).dy,
      ),
    );
    final rating = find.byKey(const Key('gallery_action_rating'));
    final info = find.byKey(const Key('gallery_action_info'));
    expect(
      tester.getCenter(info).dy,
      closeTo(tester.getCenter(rating).dy, 0.1),
    );
    expect(
      tester.getTopLeft(info).dx,
      greaterThan(tester.getTopRight(rating).dx),
    );
    expect(find.text('Performer One'), findsOneWidget);
    // Metadata chip icons are sized by the shared chip recipe.
    expect(tester.widget<Icon>(find.byIcon(Icons.image_rounded)).size, 16);
    expect(find.byIcon(Icons.sort), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
    expect(find.byIcon(Icons.bookmarks_outlined), findsOneWidget);
    expect(repository.findImageCalls.last.galleryId, 'gallery-1');

    await tester.tap(find.byKey(const Key('gallery_action_info')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gallery_details_sheet')), findsOneWidget);
    expect(find.text('GAL-001'), findsOneWidget);
    expect(find.text('Photographer One'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ImageCard).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gallery_details_collapsed')), findsOneWidget);
    expect(find.byKey(const Key('gallery_action_rating')), findsOneWidget);

    final scrollPosition = Scrollable.of(
      tester.element(find.byType(ImageCard).first),
    ).position;
    final offsetBeforeExpand = scrollPosition.pixels;

    await tester.tap(find.byIcon(Icons.expand_more_rounded));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gallery_details_expanded')), findsOneWidget);
    expect(find.byKey(const Key('gallery_action_rating')), findsOneWidget);
    expect(scrollPosition.pixels, offsetBeforeExpand);
  });
}
