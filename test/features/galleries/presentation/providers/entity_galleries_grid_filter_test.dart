import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery_filter.dart';
import 'package:stash_app_flutter/features/galleries/data/repositories/graphql_gallery_repository.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';

class _FakeGraphQLGalleryRepository implements GraphQLGalleryRepository {
  GalleryFilter? lastFilter;
  String? lastSearch;
  String? lastSort;
  bool? lastDescending;
  int? lastPage;
  int? lastPerPage;

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
  }) async {
    lastPage = page;
    lastPerPage = perPage;
    lastSearch = filter;
    lastSort = sort;
    lastDescending = descending;
    lastFilter = galleryFilter;
    return const [];
  }

  @override
  Future<Gallery> getGalleryById(String id, {bool refresh = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateGalleryRating(String id, int rating100) async {}
}

Future<ProviderContainer> _containerWith(
  _FakeGraphQLGalleryRepository repository,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      galleryRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test(
    'performer galleries overwrite saved performer filter with page performer',
    () async {
      final repository = _FakeGraphQLGalleryRepository();
      final container = await _containerWith(repository);

      container
          .read(
            entityGalleryFilterStateProvider(
              EntityGalleryFilterKind.performer,
            ).notifier,
          )
          .update(
            const GalleryFilter(
              performers: MultiCriterion(value: ['preset-performer']),
              tags: HierarchicalMultiCriterion(value: ['preset-tag']),
            ),
          );

      await container.read(
        entityGalleryGridProvider(
          EntityGalleryFilterKind.performer,
          'page-performer',
        ).future,
      );

      expect(repository.lastFilter?.performers?.value, ['page-performer']);
      expect(repository.lastFilter?.tags?.value, ['preset-tag']);
    },
  );

  test(
    'entity gallery grids do not inherit galleries page sort and filters',
    () async {
      final repository = _FakeGraphQLGalleryRepository();
      final container = await _containerWith(repository);

      container
          .read(gallerySortProvider.notifier)
          .setSort(sort: 'title', descending: true);
      container
          .read(galleryFilterStateProvider.notifier)
          .update(const GalleryFilter(rating100: IntCriterion(value: 60)));

      await container.read(
        entityGalleryGridProvider(
          EntityGalleryFilterKind.performer,
          'page-performer',
        ).future,
      );

      expect(repository.lastSort, 'path');
      expect(repository.lastDescending, false);
      expect(repository.lastFilter?.rating100, isNull);
      expect(repository.lastFilter?.performers?.value, ['page-performer']);
    },
  );

  test('studio and tag galleries overwrite their scoped filters', () async {
    final repository = _FakeGraphQLGalleryRepository();
    final container = await _containerWith(repository);

    container
        .read(
          entityGalleryFilterStateProvider(
            EntityGalleryFilterKind.studio,
          ).notifier,
        )
        .update(
          const GalleryFilter(
            studios: HierarchicalMultiCriterion(value: ['preset-studio']),
            tags: HierarchicalMultiCriterion(value: ['preset-tag']),
          ),
        );

    await container.read(
      entityGalleryGridProvider(
        EntityGalleryFilterKind.studio,
        'page-studio',
      ).future,
    );
    expect(repository.lastFilter?.studios?.value, ['page-studio']);
    expect(repository.lastFilter?.tags?.value, ['preset-tag']);

    container
        .read(
          entityGalleryFilterStateProvider(
            EntityGalleryFilterKind.tag,
          ).notifier,
        )
        .update(
          const GalleryFilter(
            studios: HierarchicalMultiCriterion(value: ['preset-studio']),
            tags: HierarchicalMultiCriterion(value: ['preset-tag']),
          ),
        );

    await container.read(
      entityGalleryGridProvider(EntityGalleryFilterKind.tag, 'page-tag').future,
    );
    expect(repository.lastFilter?.studios?.value, ['preset-studio']);
    expect(repository.lastFilter?.tags?.value, ['page-tag']);
  });
}
