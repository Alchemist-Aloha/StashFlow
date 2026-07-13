import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';

void main() {
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

      container
          .read(sceneRandomRespectActiveFilterProvider.notifier)
          .set(false);

      expect(container.read(sceneRandomRespectActiveFilterProvider), isFalse);
      expect(prefs.getBool('scene_random_respect_active_filter'), isFalse);
    },
  );
}
