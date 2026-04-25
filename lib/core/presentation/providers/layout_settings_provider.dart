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

@riverpod
class SceneGridColumns extends _$SceneGridColumns {
  static const _storageKey = 'scene_grid_columns_v2';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setInt(_storageKey, 0);
    } else {
      await prefs.setInt(_storageKey, value);
    }
  }
}

@riverpod
class PerformerGridColumns extends _$PerformerGridColumns {
  static const _storageKey = 'performer_grid_columns_v2';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setInt(_storageKey, 0);
    } else {
      await prefs.setInt(_storageKey, value);
    }
  }
}

@riverpod
class GalleryGridColumns extends _$GalleryGridColumns {
  static const _storageKey = 'gallery_grid_columns_v2';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setInt(_storageKey, 0);
    } else {
      await prefs.setInt(_storageKey, value);
    }
  }
}

@riverpod
class ImageGridColumns extends _$ImageGridColumns {
  static const _storageKey = 'image_grid_columns_v2';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setInt(_storageKey, 0);
    } else {
      await prefs.setInt(_storageKey, value);
    }
  }
}

@riverpod
class StudioGridColumns extends _$StudioGridColumns {
  static const _storageKey = 'studio_grid_columns_v2';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setInt(_storageKey, 0);
    } else {
      await prefs.setInt(_storageKey, value);
    }
  }
}

@riverpod
class TagGridColumns extends _$TagGridColumns {
  static const _storageKey = 'tag_grid_columns_v2';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setInt(_storageKey, 0);
    } else {
      await prefs.setInt(_storageKey, value);
    }
  }
}

@riverpod
class MaxPerformerAvatars extends _$MaxPerformerAvatars {
  static const _storageKey = 'max_performer_avatars';

  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(_storageKey) ?? 3;
  }

  Future<void> set(int value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_storageKey, value);
  }
}
