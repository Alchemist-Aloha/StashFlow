import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/preferences/shared_preferences_provider.dart';

part 'layout_settings_provider.g.dart';

/// Opt-in clearance for system taskbars that do not report a usable inset.
@riverpod
class MiniPlayerBottomSpacerEnabled extends _$MiniPlayerBottomSpacerEnabled {
  @override
  bool build() {
    return ref
            .watch(sharedPreferencesProvider)
            .getBool('mini_player_bottom_spacer_enabled') ??
        false;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    await ref
        .read(sharedPreferencesProvider)
        .setBool('mini_player_bottom_spacer_enabled', value);
  }
}

/// Extra bottom clearance in logical pixels, independent of the app UI scale.
/// The chosen offset is retained while the spacer is disabled.
@riverpod
class MiniPlayerBottomOffset extends _$MiniPlayerBottomOffset {
  static const defaultValue = 64.0;
  static const maxValue = 200.0;

  @override
  double build() {
    return _normalize(
      ref
              .watch(sharedPreferencesProvider)
              .getDouble('mini_player_bottom_offset') ??
          defaultValue,
    );
  }

  double _normalize(double value) =>
      value.isFinite ? value.clamp(0.0, maxValue) : defaultValue;

  Future<void> set(double value) async {
    final offset = _normalize(value);
    if (state == offset) return;
    state = offset;
    await ref
        .read(sharedPreferencesProvider)
        .setDouble('mini_player_bottom_offset', offset);
  }
}

enum GridColumnSetting {
  scene('scene_grid_columns_v2'),
  performer('performer_grid_columns_v2'),
  gallery('gallery_grid_columns_v2'),
  image('image_grid_columns_v2'),
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

/// Controls playback-position bars on scene cards; enabled for existing installs.
@riverpod
class ShowScenePlaybackProgress extends _$ShowScenePlaybackProgress {
  static const _storageKey = 'show_scene_playback_progress';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_storageKey, value);
  }
}

const _showSceneMetadataKey = 'show_scene_metadata_section';

/// Captures the install's default before startup can create other preferences.
/// An explicit choice (including a restored one) always takes precedence.
Future<void> initializeSceneMetadataVisibility(SharedPreferences prefs) async {
  if (prefs.containsKey(_showSceneMetadataKey)) return;
  await prefs.setBool(_showSceneMetadataKey, prefs.getKeys().isNotEmpty);
}

/// Controls whether scene pages include the technical metadata disclosure.
@riverpod
class ShowSceneMetadataSection extends _$ShowSceneMetadataSection {
  @override
  bool build() {
    return ref
            .watch(sharedPreferencesProvider)
            .getBool(_showSceneMetadataKey) ??
        false;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_showSceneMetadataKey, value);
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
