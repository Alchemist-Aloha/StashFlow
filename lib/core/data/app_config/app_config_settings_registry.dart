import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final class AppConfigSettingException implements Exception {
  const AppConfigSettingException(this.key);

  final String key;

  @override
  String toString() => 'AppConfigSettingException($key)';
}

enum _SettingType { boolean, integer, doubleValue, string, stringList }

final class _Setting {
  const _Setting(this.key, this.type, [this.validator]);

  final String key;
  final _SettingType type;
  final bool Function(Object value)? validator;

  bool accepts(Object value) {
    final typeMatches = switch (type) {
      _SettingType.boolean => value is bool,
      _SettingType.integer => value is int,
      _SettingType.doubleValue => value is double && value.isFinite,
      _SettingType.string => value is String,
      _SettingType.stringList =>
        value is List<String> ||
            (value is List && value.every((item) => item is String)),
    };
    return typeMatches && (validator?.call(value) ?? true);
  }
}

/// Allowlist of portable, user-facing preferences.
final class AppConfigSettingsRegistry {
  const AppConfigSettingsRegistry();

  static final List<_Setting> _settings = [
    _string(
      'app_language',
      allowed: {
        'en',
        'de',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'ru',
        'zh',
        'zh_Hans',
        'zh_Hant',
      },
    ),
    _string('app_theme_mode', allowed: {'system', 'light', 'dark'}),
    _int('app_theme_seed_color'),
    _bool('use_true_black'),
    _double('app_global_scale_factor', min: 0.5, max: 2.0),
    _int('max_image_cache_size_mb', min: 1),
    _int('max_video_cache_size_mb', min: 1),
    _int('max_performer_avatars', min: 0, max: 20),
    _bool('show_performer_avatars'),
    _bool('hide_scene_technical_metadata'),
    _double('performer_avatar_size', min: 8, max: 128),
    _double('card_title_font_size', min: 0, max: 72),
    _bool('image_fullscreen_vertical_swipe'),
    _bool('show_random_navigation'),
    _bool('scene_random_respect_active_filter'),
    _bool('main_page_gravity_orientation'),
    for (final prefix in const [
      'scene',
      'gallery',
      'performer',
      'image',
      'studio',
      'tag',
      'group',
      'scene_marker',
    ]) ...[_string('${prefix}_sort_field'), _bool('${prefix}_sort_descending')],
    for (final key in const [
      'scene_filter_state',
      'gallery_filter_state',
      'performer_filter_state',
      'image_filter_state',
      'studio_filter_state',
      'group_list_filter',
      'scene_marker_filter_state',
    ])
      _jsonString(key),
    for (final key in const [
      'scene_organized_only_v2',
      'gallery_organized_only_v2',
      'image_organized_only_v2',
    ])
      _string(key, allowed: {'all', 'organized', 'unorganized'}),
    _bool('tag_favorites_only'),
    _string(
      'entity_image_filter_method',
      allowed: {'directEntity', 'relatedGalleries'},
    ),
    for (final kind in const ['performer', 'studio', 'tag', 'group']) ...[
      _string('entity_media_${kind}_sort_field'),
      _bool('entity_media_${kind}_sort_descending'),
      _jsonString('entity_media_${kind}_filter_state'),
      _string(
        'entity_media_${kind}_organized_only_v2',
        allowed: {'all', 'organized', 'unorganized'},
      ),
    ],
    for (final kind in const ['performer', 'studio', 'tag']) ...[
      _string('entity_galleries_${kind}_sort_field'),
      _bool('entity_galleries_${kind}_sort_descending'),
      _jsonString('entity_galleries_${kind}_filter_state'),
      _string(
        'entity_galleries_${kind}_organized_only_v2',
        allowed: {'all', 'organized', 'unorganized'},
      ),
    ],
    _jsonString('navigation_tabs_config', expectList: true),
    _jsonString('desktop_keybinds'),
    _double('desktop_volume', min: 0, max: 1),
    _bool('desktop_is_muted'),
    _string('video_play_end_behavior', allowed: {'stop', 'next', 'loop'}),
    _bool('video_use_double_tap_seek'),
    _bool('video_background_playback'),
    _bool('video_native_pip'),
    _bool('video_gravity_orientation'),
    _bool('use_actual_scene_video_in_miniplayer'),
    _string('default_subtitle_language'),
    _double('subtitle_font_size', min: 8, max: 96),
    _double('subtitle_position_bottom_ratio', min: 0, max: 1),
    _string('subtitle_text_alignment', allowed: {'left', 'center', 'right'}),
    _bool('video_direct_play_on_navigation'),
    _bool('feed_start_random'),
    _bool('video_resume_play_position'),
    _bool('show_video_debug_info'),
    _bool('allow_web_password_login'),
    _bool('enable_proxy_auth_modes'),
    _bool('enable_debug_logging'),
    _bool('app_lock_enabled'),
    _int('app_lock_background_seconds', min: 0, max: 86400),
    _bool('app_lock_on_launch'),
    _bool('scene_tiktok_layout'),
    _bool('scene_grid_layout'),
    _bool('gallery_grid_layout'),
    _bool('scene_marker_grid_layout'),
    _bool('performer_media_grid_layout'),
    _bool('performer_galleries_grid_layout'),
    _bool('studio_media_grid_layout'),
    _bool('studio_galleries_grid_layout'),
    _bool('tag_media_grid_layout'),
    _bool('tag_galleries_grid_layout'),
    _bool('group_media_grid_layout'),
    for (final key in const [
      'scene_grid_columns_v2',
      'performer_grid_columns_v2',
      'gallery_grid_columns_v2',
      'image_grid_columns_v2',
      'studio_grid_columns_v2',
      'tag_grid_columns_v2',
      'group_grid_columns_v2',
      'scene_marker_grid_columns_v2',
    ])
      _int(key, min: 0, max: 12),
  ];

  Set<String> get managedKeys =>
      Set.unmodifiable(_settings.map((setting) => setting.key));

  Future<Map<String, Object>> read(SharedPreferences prefs) async {
    final result = <String, Object>{};
    for (final setting in _settings) {
      final value = prefs.get(setting.key);
      if (value == null) continue;
      if (!setting.accepts(value)) throw AppConfigSettingException(setting.key);
      result[setting.key] = value is List
          ? List<String>.unmodifiable(value.cast<String>())
          : value;
    }
    return result;
  }

  void validate(Map<String, Object> values) {
    final byKey = {for (final setting in _settings) setting.key: setting};
    for (final entry in values.entries) {
      final setting = byKey[entry.key];
      if (setting == null || !setting.accepts(entry.value)) {
        throw AppConfigSettingException(entry.key);
      }
    }
  }

  Future<void> replace(
    SharedPreferences prefs,
    Map<String, Object> values,
  ) async {
    validate(values);
    final snapshot = await read(prefs);
    try {
      await _writeAll(prefs, values);
    } catch (_) {
      await _writeAll(prefs, snapshot);
      rethrow;
    }
  }

  Future<void> _writeAll(
    SharedPreferences prefs,
    Map<String, Object> values,
  ) async {
    for (final key in managedKeys) {
      if (!await prefs.remove(key)) throw AppConfigSettingException(key);
    }
    for (final entry in values.entries) {
      final value = entry.value;
      final saved = switch (value) {
        bool value => await prefs.setBool(entry.key, value),
        int value => await prefs.setInt(entry.key, value),
        double value => await prefs.setDouble(entry.key, value),
        String value => await prefs.setString(entry.key, value),
        List value => await prefs.setStringList(
          entry.key,
          value.cast<String>(),
        ),
        _ => false,
      };
      if (!saved) throw AppConfigSettingException(entry.key);
    }
  }

  static _Setting _bool(String key) => _Setting(key, _SettingType.boolean);

  static _Setting _int(String key, {int? min, int? max}) =>
      _Setting(key, _SettingType.integer, (value) {
        final number = value as int;
        return (min == null || number >= min) && (max == null || number <= max);
      });

  static _Setting _double(String key, {double? min, double? max}) =>
      _Setting(key, _SettingType.doubleValue, (value) {
        final number = value as double;
        return (min == null || number >= min) && (max == null || number <= max);
      });

  static _Setting _string(String key, {Set<String>? allowed}) => _Setting(
    key,
    _SettingType.string,
    allowed == null ? null : (value) => allowed.contains(value),
  );

  static _Setting _jsonString(String key, {bool expectList = false}) =>
      _Setting(key, _SettingType.string, (value) {
        try {
          final decoded = jsonDecode(value as String);
          return expectList ? decoded is List : decoded is Map;
        } catch (_) {
          return false;
        }
      });
}
