import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';

void main() {
  test('random navigation defaults on and its save can be awaited', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(randomNavigationEnabledProvider), isTrue);
    await container.read(randomNavigationEnabledProvider.notifier).set(false);
    expect(container.read(randomNavigationEnabledProvider), isFalse);
    expect(prefs.getBool('show_random_navigation'), isFalse);
  });

  test('top app bar auto-hide defaults off and persists updates', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(autoHideTopAppBarProvider), isFalse);

    await container.read(autoHideTopAppBarProvider.notifier).set(true);

    expect(container.read(autoHideTopAppBarProvider), isTrue);
    expect(prefs.getBool(AutoHideTopAppBar.storageKey), isTrue);
  });

  test(
    'scene random respect filter defaults to enabled and persists updates',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(sceneRandomRespectActiveFilterProvider), isTrue);

      await container
          .read(sceneRandomRespectActiveFilterProvider.notifier)
          .set(false);

      expect(container.read(sceneRandomRespectActiveFilterProvider), isFalse);
      expect(prefs.getBool('scene_random_respect_active_filter'), isFalse);
    },
  );
}
