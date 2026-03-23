import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/preferences/shared_preferences_provider.dart';

const appThemeSeedColorPreferenceKey = 'app_theme_seed_color';
const defaultSeedColor = Color(0xFF0F766E);

class AppThemeColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final colorValue = prefs.getInt(appThemeSeedColorPreferenceKey);
    // Use standard Color constructor with 32-bit int value
    return colorValue != null ? Color(colorValue) : defaultSeedColor;
  }

  Future<void> setThemeColor(Color color) async {
    if (state == color) return;
    state = color;
    final prefs = ref.read(sharedPreferencesProvider);
    // Store as 32-bit ARGB integer
    await prefs.setInt(appThemeSeedColorPreferenceKey, color.toARGB32());
  }
}

final appThemeColorProvider = NotifierProvider<AppThemeColorNotifier, Color>(
  AppThemeColorNotifier.new,
);
