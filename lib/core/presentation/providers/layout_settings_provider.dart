import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/preferences/shared_preferences_provider.dart';

part 'layout_settings_provider.g.dart';

enum GridLayoutSetting {
  performerMedia('performer_media_grid_layout', true),
  performerGalleries('performer_galleries_grid_layout', true),
  studioMedia('studio_media_grid_layout', true),
  studioGalleries('studio_galleries_grid_layout', true),
  tagMedia('tag_media_grid_layout', true),
  tagGalleries('tag_galleries_grid_layout', true),
  groupMedia('group_media_grid_layout', true),
  gallery('gallery_grid_layout', true),
  sceneMarker('scene_marker_grid_layout', true);

  const GridLayoutSetting(this.storageKey, this.defaultValue);

  final String storageKey;
  final bool defaultValue;
}

final gridLayoutSettingProvider =
    NotifierProvider.family<GridLayoutSettingNotifier, bool, GridLayoutSetting>(
      GridLayoutSettingNotifier.new,
    );

class GridLayoutSettingNotifier extends Notifier<bool> {
  GridLayoutSettingNotifier(this.setting);

  final GridLayoutSetting setting;

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(setting.storageKey) ?? setting.defaultValue;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(setting.storageKey, value);
  }
}

enum GridColumnSetting {
  scene('scene_grid_columns_v2'),
  performer('performer_grid_columns_v2'),
  gallery('gallery_grid_columns_v2'),
  image('image_grid_columns_v2'),
  studio('studio_grid_columns_v2'),
  tag('tag_grid_columns_v2'),
  group('group_grid_columns_v2'),
  sceneMarker('scene_marker_grid_columns_v2');

  const GridColumnSetting(this.storageKey);

  final String storageKey;
}

final gridColumnSettingProvider =
    NotifierProvider.family<GridColumnSettingNotifier, int?, GridColumnSetting>(
      GridColumnSettingNotifier.new,
    );

class GridColumnSettingNotifier extends Notifier<int?> {
  GridColumnSettingNotifier(this.setting);

  final GridColumnSetting setting;

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getInt(setting.storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(int? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(setting.storageKey, value ?? 0);
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

@riverpod
class ShowPerformerAvatars extends _$ShowPerformerAvatars {
  static const _storageKey = 'show_performer_avatars';

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
class HideSceneTechnicalMetadata extends _$HideSceneTechnicalMetadata {
  static const _storageKey = 'hide_scene_technical_metadata';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_storageKey, value);
  }
}

@riverpod
class PerformerAvatarSize extends _$PerformerAvatarSize {
  static const _storageKey = 'performer_avatar_size';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getDouble(_storageKey) ?? 16.0;
  }

  Future<void> set(double value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_storageKey, value);
  }
}

@riverpod
class CardTitleFontSize extends _$CardTitleFontSize {
  static const _storageKey = 'card_title_font_size';

  @override
  double? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getDouble(_storageKey);
    return value == 0 ? null : value;
  }

  Future<void> set(double? value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      await prefs.setDouble(_storageKey, 0);
    } else {
      await prefs.setDouble(_storageKey, value);
    }
  }
}

@riverpod
class AppGlobalScale extends _$AppGlobalScale {
  static const _storageKey = 'app_global_scale_factor';
  static const _legacyKey = 'app_font_size_factor';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Migration: prefer new key, fallback to legacy
    return prefs.getDouble(_storageKey) ?? prefs.getDouble(_legacyKey) ?? 1.0;
  }

  Future<void> set(double value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_storageKey, value);
  }
}
