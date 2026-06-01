import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

void main() {
  test(
    'SceneSort keeps runtime non-random sort after random default seed changes',
    () async {
      SharedPreferences.setMockInitialValues({
        'scene_sort_field': 'random',
        'scene_sort_descending': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(sceneSortProvider).sort, 'random');

      container
          .read(sceneSortProvider.notifier)
          .setSort(sort: 'title', descending: false);
      expect(container.read(sceneSortProvider).sort, 'title');
      expect(container.read(sceneSortProvider).randomSeed, isNull);

      container.read(sceneRandomSeedProvider.notifier).next();

      expect(container.read(sceneSortProvider).sort, 'title');
      expect(container.read(sceneSortProvider).descending, false);
      expect(container.read(sceneSortProvider).randomSeed, isNull);
    },
  );
}
