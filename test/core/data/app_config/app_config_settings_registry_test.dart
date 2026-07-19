import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/app_config/app_config_settings_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const registry = AppConfigSettingsRegistry();

  test('exports only explicitly managed settings', () async {
    SharedPreferences.setMockInitialValues({
      'app_theme_mode': 'dark',
      'show_random_navigation': true,
      'max_image_cache_size_mb': 500,
      'app_global_scale_factor': 1.2,
      'search_history_scenes': ['private'],
      'secure_fallback_profile_x_api_key': 'secret',
      'unknown': 'internal',
    });
    final prefs = await SharedPreferences.getInstance();
    expect(await registry.read(prefs), {
      'app_theme_mode': 'dark',
      'show_random_navigation': true,
      'max_image_cache_size_mb': 500,
      'app_global_scale_factor': 1.2,
    });
  });

  test('validates types and constrained values before replacement', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
    final prefs = await SharedPreferences.getInstance();
    for (final invalid in <Map<String, Object>>[
      {'app_theme_mode': 1},
      {'app_theme_mode': 'neon'},
      {'subtitle_position_bottom_ratio': 2.0},
      {'unknown': true},
    ]) {
      expect(
        () => registry.replace(prefs, invalid),
        throwsA(isA<AppConfigSettingException>()),
      );
    }
    expect(prefs.getString('app_theme_mode'), 'light');
  });

  test(
    'full replacement removes absent managed keys and preserves unmanaged',
    () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'dark',
        'show_random_navigation': false,
        'search_history_scenes': ['keep'],
      });
      final prefs = await SharedPreferences.getInstance();
      await registry.replace(prefs, {'app_theme_mode': 'light'});
      expect(prefs.getString('app_theme_mode'), 'light');
      expect(prefs.containsKey('show_random_navigation'), isFalse);
      expect(prefs.getStringList('search_history_scenes'), ['keep']);
    },
  );

  test('catalog is explicit and stable', () {
    expect(
      registry.managedKeys,
      containsAll(<String>{
        'app_language',
        'app_theme_mode',
        'app_theme_seed_color',
        'use_true_black',
        'app_global_scale_factor',
        'navigation_tabs_config',
        'desktop_keybinds',
        'video_play_end_behavior',
        'app_lock_enabled',
        'scene_grid_columns_v2',
      }),
    );
    expect(registry.managedKeys, isNot(contains('server_profiles')));
    expect(registry.managedKeys, isNot(contains('search_history_scenes')));
  });
}
