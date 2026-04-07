import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_color_provider.dart';

void main() {
  group('AppThemeColorNotifier', () {
    test(
      'build() returns defaultSeedColor when no preference is saved',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final color = container.read(appThemeColorProvider);
        expect(color, equals(defaultSeedColor));
      },
    );

    test('build() returns saved color from SharedPreferences', () async {
      const savedColor = Color(0xFF123456);
      SharedPreferences.setMockInitialValues({
        appThemeSeedColorPreferenceKey: savedColor.toARGB32(),
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final color = container.read(appThemeColorProvider);
      expect(color, equals(savedColor));
    });

    test(
      'setThemeColor() updates state and saves to SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        const newColor = Color(0xFF654321);

        // Verify initial state
        expect(container.read(appThemeColorProvider), equals(defaultSeedColor));
        expect(prefs.getInt(appThemeSeedColorPreferenceKey), isNull);

        // Call setThemeColor
        await container
            .read(appThemeColorProvider.notifier)
            .setThemeColor(newColor);

        // Verify new state
        expect(container.read(appThemeColorProvider), equals(newColor));
        // Verify value in SharedPreferences
        expect(
          prefs.getInt(appThemeSeedColorPreferenceKey),
          equals(newColor.toARGB32()),
        );
      },
    );

    test('setThemeColor() does nothing if color is the same', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      // initial state is defaultSeedColor
      expect(container.read(appThemeColorProvider), equals(defaultSeedColor));

      // try to set the same color
      await container
          .read(appThemeColorProvider.notifier)
          .setThemeColor(defaultSeedColor);

      // state is still the same and preferences wasn't updated
      expect(container.read(appThemeColorProvider), equals(defaultSeedColor));
      expect(prefs.getInt(appThemeSeedColorPreferenceKey), isNull);
    });
  });
}
