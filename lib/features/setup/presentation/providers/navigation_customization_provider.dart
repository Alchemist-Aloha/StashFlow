import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';

final randomNavigationEnabledProvider =
    NotifierProvider<RandomNavigationEnabled, bool>(
      RandomNavigationEnabled.new,
    );

class RandomNavigationEnabled extends Notifier<bool> {
  static const _storageKey = 'show_random_navigation';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  void set(bool value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_storageKey, value);
  }
}

final sceneRandomRespectActiveFilterProvider =
    NotifierProvider<SceneRandomRespectActiveFilter, bool>(
      SceneRandomRespectActiveFilter.new,
    );

class SceneRandomRespectActiveFilter extends Notifier<bool> {
  static const _storageKey = 'scene_random_respect_active_filter';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  void set(bool value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_storageKey, value);
  }
}
