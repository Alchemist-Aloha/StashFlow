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

  /// Updates the visible state immediately and completes after persistence.
  Future<void> set(bool value) async {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
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

  /// Updates the visible state immediately and completes after persistence.
  Future<void> set(bool value) async {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

final autoHideTopAppBarProvider = NotifierProvider<AutoHideTopAppBar, bool>(
  AutoHideTopAppBar.new,
);

/// Controls whether list-page app bars hide while scrolling down.
class AutoHideTopAppBar extends Notifier<bool> {
  static const storageKey = 'auto_hide_top_app_bar';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(storageKey) ?? false;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(storageKey, value);
  }
}
