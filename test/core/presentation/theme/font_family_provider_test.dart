import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/theme/font_family_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer containerWithPrefs(SharedPreferences prefs) {
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  test('font choice persists and unknown values fall back to system', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = containerWithPrefs(prefs);
    addTearDown(container.dispose);

    expect(container.read(appFontFamilyProvider), AppFontFamily.system);
    await container
        .read(appFontFamilyProvider.notifier)
        .setFontFamily(AppFontFamily.serif);
    expect(prefs.getString(appFontFamilyPreferenceKey), 'serif');

    final restored = containerWithPrefs(prefs);
    addTearDown(restored.dispose);
    expect(restored.read(appFontFamilyProvider), AppFontFamily.serif);

    await prefs.setString(appFontFamilyPreferenceKey, 'missing-font');
    final unknown = containerWithPrefs(prefs);
    addTearDown(unknown.dispose);
    expect(unknown.read(appFontFamilyProvider), AppFontFamily.system);

    await unknown
        .read(appFontFamilyProvider.notifier)
        .setFontFamily(AppFontFamily.jetBrainsMono);
    expect(prefs.getString(appFontFamilyPreferenceKey), 'jetbrains_mono');
  });

  test('selected family reaches light and dark text themes', () {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final theme = AppTheme.buildTheme(
        brightness,
        const Color(0xFF0F766E),
        fontFamily: AppFontFamily.manrope.fontFamily,
      );
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Manrope');
      expect(theme.textTheme.titleMedium?.fontFamily, 'Manrope');
    }
  });
}
