import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';

void main() {
  Future<ProviderContainer> createContainer([
    Map<String, Object> initialValues = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('entity random sort seeds', () {
    test('performer sort captures and clears random seed', () async {
      final container = await createContainer();

      container
          .read(performerSortProvider.notifier)
          .setSort(sort: 'random', descending: true);

      expect(container.read(performerSortProvider).randomSeed, isNotNull);

      container
          .read(performerSortProvider.notifier)
          .setSort(sort: 'name', descending: false);

      expect(container.read(performerSortProvider).randomSeed, isNull);
    });

    test(
      'performer sort stays non-random after random default seed changes',
      () async {
        final container = await createContainer({
          'performer_sort_field': 'random',
          'performer_sort_descending': true,
        });

        expect(container.read(performerSortProvider).sort, 'random');

        container
            .read(performerSortProvider.notifier)
            .setSort(sort: 'name', descending: false);

        expect(container.read(performerSortProvider).sort, 'name');
        expect(container.read(performerSortProvider).randomSeed, isNull);

        container.read(performerRandomSeedProvider.notifier).next();

        expect(container.read(performerSortProvider).sort, 'name');
        expect(container.read(performerSortProvider).randomSeed, isNull);
      },
    );

    test('image sort captures and clears random seed', () async {
      final container = await createContainer();

      container
          .read(imageSortProvider.notifier)
          .setSort(sort: 'random', descending: true);

      expect(container.read(imageSortProvider).randomSeed, isNotNull);

      container
          .read(imageSortProvider.notifier)
          .setSort(sort: 'path', descending: false);

      expect(container.read(imageSortProvider).randomSeed, isNull);
    });

    test(
      'image sort stays non-random after random default seed changes',
      () async {
        final container = await createContainer({
          'image_sort_field': 'random',
          'image_sort_descending': true,
        });

        expect(container.read(imageSortProvider).sort, 'random');

        container
            .read(imageSortProvider.notifier)
            .setSort(sort: 'path', descending: false);

        expect(container.read(imageSortProvider).sort, 'path');
        expect(container.read(imageSortProvider).randomSeed, isNull);

        container.read(imageRandomSeedProvider.notifier).next();

        expect(container.read(imageSortProvider).sort, 'path');
        expect(container.read(imageSortProvider).randomSeed, isNull);
      },
    );

    test('gallery sort captures and clears random seed', () async {
      final container = await createContainer();

      container
          .read(gallerySortProvider.notifier)
          .setSort(sort: 'random', descending: true);

      expect(container.read(gallerySortProvider).randomSeed, isNotNull);

      container
          .read(gallerySortProvider.notifier)
          .setSort(sort: 'path', descending: false);

      expect(container.read(gallerySortProvider).randomSeed, isNull);
    });

    test(
      'gallery sort stays non-random after random default seed changes',
      () async {
        final container = await createContainer({
          'gallery_sort_field': 'random',
          'gallery_sort_descending': true,
        });

        expect(container.read(gallerySortProvider).sort, 'random');

        container
            .read(gallerySortProvider.notifier)
            .setSort(sort: 'path', descending: false);

        expect(container.read(gallerySortProvider).sort, 'path');
        expect(container.read(gallerySortProvider).randomSeed, isNull);

        container.read(galleryRandomSeedProvider.notifier).next();

        expect(container.read(gallerySortProvider).sort, 'path');
        expect(container.read(gallerySortProvider).randomSeed, isNull);
      },
    );

    test('studio sort captures and clears random seed', () async {
      final container = await createContainer();

      container
          .read(studioSortProvider.notifier)
          .setSort(sort: 'random', descending: true);

      expect(container.read(studioSortProvider).randomSeed, isNotNull);

      container
          .read(studioSortProvider.notifier)
          .setSort(sort: 'name', descending: false);

      expect(container.read(studioSortProvider).randomSeed, isNull);
    });

    test(
      'studio sort stays non-random after random default seed changes',
      () async {
        final container = await createContainer({
          'studio_sort_field': 'random',
          'studio_sort_descending': true,
        });

        expect(container.read(studioSortProvider).sort, 'random');

        container
            .read(studioSortProvider.notifier)
            .setSort(sort: 'name', descending: false);

        expect(container.read(studioSortProvider).sort, 'name');
        expect(container.read(studioSortProvider).randomSeed, isNull);

        container.read(studioRandomSeedProvider.notifier).next();

        expect(container.read(studioSortProvider).sort, 'name');
        expect(container.read(studioSortProvider).randomSeed, isNull);
      },
    );

    test('tag sort captures and clears random seed', () async {
      final container = await createContainer();

      container
          .read(tagSortProvider.notifier)
          .setSort(sort: 'random', descending: true);

      expect(container.read(tagSortProvider).randomSeed, isNotNull);

      container
          .read(tagSortProvider.notifier)
          .setSort(sort: 'name', descending: false);

      expect(container.read(tagSortProvider).randomSeed, isNull);
    });

    test(
      'tag sort stays non-random after random default seed changes',
      () async {
        final container = await createContainer({
          'tag_sort_field': 'random',
          'tag_sort_descending': true,
        });

        expect(container.read(tagSortProvider).sort, 'random');

        container
            .read(tagSortProvider.notifier)
            .setSort(sort: 'name', descending: false);

        expect(container.read(tagSortProvider).sort, 'name');
        expect(container.read(tagSortProvider).randomSeed, isNull);

        container.read(tagRandomSeedProvider.notifier).next();

        expect(container.read(tagSortProvider).sort, 'name');
        expect(container.read(tagSortProvider).randomSeed, isNull);
      },
    );

    test('group sort captures and clears random seed', () async {
      final container = await createContainer();

      container
          .read(groupSortProvider.notifier)
          .setSort(sort: 'random', descending: true);

      expect(container.read(groupSortProvider).randomSeed, isNotNull);

      container
          .read(groupSortProvider.notifier)
          .setSort(sort: 'name', descending: false);

      expect(container.read(groupSortProvider).randomSeed, isNull);
    });
  });
}
