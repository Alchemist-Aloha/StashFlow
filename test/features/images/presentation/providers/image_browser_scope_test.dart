import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/domain/entities/filter_options.dart';
import 'package:stash_app_flutter/core/utils/pagination.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_browser_context.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

const _image = Image(id: '1', files: [], paths: ImagePaths());

class _DelayedImages extends MockGraphQLImageRepository {
  final nextPage = Completer<List<Image>>();

  /// Gallery whose first page is full, so the provider asks for page 2.
  String? fullPageGallery;

  @override
  Future<List<Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
    ImageFilter? imageFilter,
  }) {
    if (page == 2) return nextPage.future;
    return super
        .findImages(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort,
          descending: descending,
          galleryId: galleryId,
          imageFilter: imageFilter,
        )
        .then(
          (images) => galleryId != null && galleryId == fullPageGallery
              ? [
                  for (var i = 0; i < (perPage ?? 1); i++)
                    _image.copyWith(id: 'page-$i'),
                ]
              : images,
        );
  }
}

void main() {
  late ProviderContainer library;
  late _DelayedImages repository;
  late SharedPreferences prefs;

  ProviderContainer gallery(String id) {
    final scope = ProviderContainer(
      parent: library,
      overrides: [
        imageBrowserContextProvider.overrideWithValue(
          ImageBrowserContext.gallery(id, path: '/gallery/$id'),
        ),
      ],
    );
    addTearDown(scope.dispose);
    return scope;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = _DelayedImages()..withData([_image]);
    library = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        imageRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(library.dispose);
  });

  test(
    'gallery queries, selection, random seed and pagination are independent',
    () async {
      repository.fullPageGallery = 'a';
      library.read(imageSearchQueryProvider.notifier).update('library search');
      library
          .read(imageFilterStateProvider.notifier)
          .updateFilter(const ImageFilter(rating100: IntCriterion(value: 80)));
      library
          .read(imageOrganizedOnlyProvider.notifier)
          .set(OrganizedFilter.organized);
      library.read(imageSortProvider.notifier).setSort(sort: 'random');
      library
          .read(imageFullscreenCurrentIdProvider.notifier)
          .setCurrent('library-image');
      await library.read(imageListProvider.future);
      final seed = library.read(imageRandomSeedProvider);
      final first = gallery('a');
      final second = gallery('b');
      await first.read(imageListProvider.future);
      expect(repository.findImageCalls.last.galleryId, 'a');
      expect(repository.findImageCalls.last.filter, isNull);
      expect(repository.findImageCalls.last.imageFilter, const ImageFilter());
      expect(first.read(imageSortProvider).sort, 'path');
      expect(first.read(imageFullscreenCurrentIdProvider), isNull);
      await second.read(imageListProvider.future);
      expect(repository.findImageCalls.last.galleryId, 'b');

      first.read(imageSearchQueryProvider.notifier).update('gallery search');
      first.read(imageSortProvider.notifier).setSort(sort: 'random');
      first
          .read(imageFullscreenCurrentIdProvider.notifier)
          .setCurrent('gallery-image');
      await first.read(imageListProvider.notifier).refresh();
      expect(library.read(imageRandomSeedProvider), seed);
      expect(library.read(imageSearchQueryProvider), 'library search');
      expect(
        library.read(imageFilterStateProvider).filter.rating100?.value,
        80,
      );
      expect(
        library.read(imageOrganizedOnlyProvider),
        OrganizedFilter.organized,
      );
      expect(library.read(imageFullscreenCurrentIdProvider), 'library-image');
      expect(second.read(imageSearchQueryProvider), '');
      expect(second.read(imageSortProvider).sort, 'path');

      final pending = first.read(imageListProvider.notifier).fetchNextPage();
      repository.nextPage.complete([_image.copyWith(id: '2')]);
      await pending;
      expect(
        first.read(imageListProvider).requireValue.length,
        kDefaultPageSize + 1,
      );
      expect(library.read(imageListProvider).requireValue, [_image]);
      expect(second.read(imageListProvider).requireValue, [_image]);
    },
  );

  test(
    'reset, presets and save-default cannot remove or persist gallery scope',
    () async {
      library.read(imageSortProvider.notifier).setSort(sort: 'rating');
      await library.read(imageSortProvider.notifier).saveAsDefault();
      final saved = {for (final key in prefs.getKeys()) key: prefs.get(key)};
      final scope = gallery('a');
      scope.read(imageFilterStateProvider.notifier).setGalleryId('other');
      scope.read(imageFilterStateProvider.notifier).clearGalleryId();
      scope.read(imageFilterStateProvider.notifier).clear();
      scope
          .read(imageFilterStateProvider.notifier)
          .updateFilter(const ImageFilter(rating100: IntCriterion(value: 20)));
      scope.read(imageSortProvider.notifier).setSort(sort: 'date');
      scope
          .read(imageOrganizedOnlyProvider.notifier)
          .set(OrganizedFilter.organized);
      await scope.read(imageFilterStateProvider.notifier).saveAsDefault();
      await scope.read(imageSortProvider.notifier).saveAsDefault();
      await scope.read(imageOrganizedOnlyProvider.notifier).saveAsDefault();
      await scope.read(imageListProvider.future);
      expect(repository.findImageCalls.last.galleryId, 'a');
      expect(repository.findImageCalls.last.imageFilter?.rating100?.value, 20);
      expect({for (final key in prefs.getKeys()) key: prefs.get(key)}, saved);
      expect(library.read(imageFilterStateProvider).galleryId, isNull);
      expect(library.read(imageSortProvider).sort, 'rating');
    },
  );

  for (final method in EntityImageFilterMethod.values) {
    for (final kind in EntityGalleryFilterKind.values) {
      test(
        'entity restriction survives reset/preset for $kind, $method',
        () async {
          await library
              .read(entityImageFilterMethodSettingProvider.notifier)
              .set(method);
          final scope = ProviderContainer(
            parent: library,
            overrides: [
              imageBrowserContextProvider.overrideWithValue(
                ImageBrowserContext.entity(
                  kind,
                  'entity',
                  path: '/entity-images/${kind.name}/entity',
                ),
              ),
            ],
          );
          addTearDown(scope.dispose);
          scope.read(imageFilterStateProvider.notifier).clear();
          scope
              .read(imageFilterStateProvider.notifier)
              .updateFilter(
                const ImageFilter(rating100: IntCriterion(value: 60)),
              );
          await scope.read(imageListProvider.future);
          final expected = imageFilterForEntityGalleries(
            kind: kind,
            entityId: 'entity',
            method: method,
          ).copyWith(rating100: const IntCriterion(value: 60));
          expect(repository.findImageCalls.last.imageFilter, expected);
          expect(
            library.read(imageFilterStateProvider).filter,
            const ImageFilter(),
          );
        },
      );
    }
  }

  test(
    'confirmed ratings patch every live list without refetching or reseeding',
    () async {
      final scope = gallery('a');
      await library.read(imageListProvider.future);
      await scope.read(imageListProvider.future);
      final calls = repository.findImageCalls.length;
      final seed = scope.read(imageRandomSeedProvider);
      await scope.read(imageChangedProvider.notifier).updateRating(_image, 90);
      expect(library.read(imageListProvider).requireValue.single.rating100, 90);
      expect(scope.read(imageListProvider).requireValue.single.rating100, 90);
      expect(repository.findImageCalls.length, calls);
      expect(scope.read(imageRandomSeedProvider), seed);
    },
  );

  test('late pagination cannot overwrite a changed query', () async {
    repository.fullPageGallery = 'a';
    final scope = gallery('a');
    await scope.read(imageListProvider.future);
    final pending = scope.read(imageListProvider.notifier).fetchNextPage();
    scope.read(imageSearchQueryProvider.notifier).update('new');
    await scope.read(imageListProvider.future);
    repository.nextPage.complete([_image.copyWith(id: 'stale')]);
    await pending;
    expect(
      scope.read(imageListProvider).requireValue.map((image) => image.id),
      isNot(contains('stale')),
    );
  });

  test(
    'late pagination safely finishes after its route scope is disposed',
    () async {
      repository.fullPageGallery = 'a';
      final scope = ProviderContainer(
        parent: library,
        overrides: [
          imageBrowserContextProvider.overrideWithValue(
            const ImageBrowserContext.gallery('a', path: '/gallery/a'),
          ),
        ],
      );
      await scope.read(imageListProvider.future);
      final pending = scope.read(imageListProvider.notifier).fetchNextPage();
      scope.dispose();
      repository.nextPage.complete([_image.copyWith(id: 'stale')]);
      await pending;
      expect(library.read(imageFilterStateProvider).galleryId, isNull);
    },
  );
}
