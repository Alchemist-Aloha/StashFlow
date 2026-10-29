import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/app_config/app_config_settings_registry.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'spacer settings persist and round-trip through configuration backup',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final enabled = container.listen(
        miniPlayerBottomSpacerEnabledProvider,
        (_, _) {},
      );
      final offset = container.listen(
        miniPlayerBottomOffsetProvider,
        (_, _) {},
      );
      addTearDown(enabled.close);
      addTearDown(offset.close);
      expect(enabled.read(), isFalse);
      expect(offset.read(), 64);

      await container
          .read(miniPlayerBottomSpacerEnabledProvider.notifier)
          .set(true);
      await container.read(miniPlayerBottomOffsetProvider.notifier).set(120);
      await container
          .read(miniPlayerBottomSpacerEnabledProvider.notifier)
          .set(false);
      const registry = AppConfigSettingsRegistry();
      final backup = await registry.read(prefs);
      expect(backup, {
        'mini_player_bottom_spacer_enabled': false,
        'mini_player_bottom_offset': 120.0,
      });
      await registry.replace(prefs, {});
      await registry.replace(prefs, backup);
      container.invalidate(miniPlayerBottomSpacerEnabledProvider);
      container.invalidate(miniPlayerBottomOffsetProvider);
      expect(enabled.read(), isFalse);
      expect(offset.read(), 120);
      await container
          .read(miniPlayerBottomSpacerEnabledProvider.notifier)
          .set(true);
      expect(offset.read(), 120);

      for (final invalid in [-1.0, 201.0, double.nan, double.infinity]) {
        await expectLater(
          registry.replace(prefs, {'mini_player_bottom_offset': invalid}),
          throwsA(isA<AppConfigSettingException>()),
        );
      }
      expect(prefs.getDouble('mini_player_bottom_offset'), 120);
    },
  );

  for (final (saved, expected) in [
    (-1.0, 0.0),
    (201.0, 200.0),
    (double.nan, 64.0),
  ]) {
    test('invalid saved offset $saved is normalized to $expected', () async {
      SharedPreferences.setMockInitialValues({
        'mini_player_bottom_offset': saved,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      expect(container.read(miniPlayerBottomOffsetProvider), expected);
    });
  }
}
