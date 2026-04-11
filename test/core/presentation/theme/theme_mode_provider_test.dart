import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_mode_provider.dart';

void main() {
  group('AppThemeModeNotifier', () {
    test(
      'Should default to ThemeMode.system when no preference is saved',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final themeMode = container.read(appThemeModeProvider);
        expect(themeMode, ThemeMode.system);
      },
    );

    test('Should restore to ThemeMode.dark when "dark" is saved', () async {
      SharedPreferences.setMockInitialValues({
        appThemeModePreferenceKey: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final themeMode = container.read(appThemeModeProvider);
      expect(themeMode, ThemeMode.dark);
    });

    test('Should restore to ThemeMode.light when "light" is saved', () async {
      SharedPreferences.setMockInitialValues({
        appThemeModePreferenceKey: 'light',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final themeMode = container.read(appThemeModeProvider);
      expect(themeMode, ThemeMode.light);
    });

    test(
      'Calling setThemeMode(ThemeMode.dark) updates state and saves "dark"',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        // Read initial state
        expect(container.read(appThemeModeProvider), ThemeMode.system);

        // Update state
        await container
            .read(appThemeModeProvider.notifier)
            .setThemeMode(ThemeMode.dark);

        // Verify state
        expect(container.read(appThemeModeProvider), ThemeMode.dark);

        // Verify preferences
        expect(prefs.getString(appThemeModePreferenceKey), 'dark');
      },
    );

    test(
      'Calling setThemeMode(ThemeMode.light) updates state and saves "light"',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        // Update state
        await container
            .read(appThemeModeProvider.notifier)
            .setThemeMode(ThemeMode.light);

        // Verify state
        expect(container.read(appThemeModeProvider), ThemeMode.light);

        // Verify preferences
        expect(prefs.getString(appThemeModePreferenceKey), 'light');
      },
    );

    test(
      'Calling setThemeMode(ThemeMode.system) updates state and saves "system"',
      () async {
        SharedPreferences.setMockInitialValues({
          appThemeModePreferenceKey: 'dark', // Start with dark
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        // Read initial state
        expect(container.read(appThemeModeProvider), ThemeMode.dark);

        // Update state
        await container
            .read(appThemeModeProvider.notifier)
            .setThemeMode(ThemeMode.system);

        // Verify state
        expect(container.read(appThemeModeProvider), ThemeMode.system);

        // Verify preferences
        expect(prefs.getString(appThemeModePreferenceKey), 'system');
      },
    );

    test('Calling setThemeMode with the same mode returns early', () async {
      SharedPreferences.setMockInitialValues({
        appThemeModePreferenceKey: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // The current state is initialized as ThemeMode.dark because we set 'dark' in preferences.
      expect(container.read(appThemeModeProvider), ThemeMode.dark);

      // Manually remove it from preferences to ensure it's not saved again
      await prefs.remove(appThemeModePreferenceKey);

      // Verify it's actually removed
      expect(prefs.getString(appThemeModePreferenceKey), null);

      // Update state to the same mode
      await container
          .read(appThemeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      // Verify state is still dark
      expect(container.read(appThemeModeProvider), ThemeMode.dark);

      // Verify preferences wasn't written to (since we removed it and it returned early)
      // When SharedPreferences sets values in tests, we cleared it.
      expect(prefs.getString(appThemeModePreferenceKey), null);
    });
  });
}
