import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/preferences/shared_preferences_provider.dart';

part 'layout_settings_provider.g.dart';

@riverpod
class PerformerMediaGridLayout extends _$PerformerMediaGridLayout {
  static const _storageKey = 'performer_media_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

@riverpod
class PerformerGalleriesGridLayout extends _$PerformerGalleriesGridLayout {
  static const _storageKey = 'performer_galleries_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

@riverpod
class StudioMediaGridLayout extends _$StudioMediaGridLayout {
  static const _storageKey = 'studio_media_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

@riverpod
class StudioGalleriesGridLayout extends _$StudioGalleriesGridLayout {
  static const _storageKey = 'studio_galleries_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

@riverpod
class TagMediaGridLayout extends _$TagMediaGridLayout {
  static const _storageKey = 'tag_media_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

@riverpod
class TagGalleriesGridLayout extends _$TagGalleriesGridLayout {
  static const _storageKey = 'tag_galleries_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}
