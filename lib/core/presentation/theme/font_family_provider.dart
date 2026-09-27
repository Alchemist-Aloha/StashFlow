import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/preferences/shared_preferences_provider.dart';

const appFontFamilyPreferenceKey = 'app_font_family';

/// Bundled and platform font choices. Missing glyphs use platform fallback.
enum AppFontFamily {
  system('system', null),
  serif('serif', 'serif'),
  monospace('monospace', 'monospace'),
  manrope('manrope', 'Manrope'),
  outfit('outfit', 'Outfit'),
  spaceGrotesk('space_grotesk', 'SpaceGrotesk'),
  inter('inter', 'Inter'),
  lora('lora', 'Lora'),
  jetBrainsMono('jetbrains_mono', 'JetBrainsMono');

  const AppFontFamily(this.storageValue, this.fontFamily);

  final String storageValue;
  final String? fontFamily;

  static AppFontFamily fromStorageValue(String? value) {
    for (final family in values) {
      if (family.storageValue == value) return family;
    }
    return system;
  }
}

class AppFontFamilyNotifier extends Notifier<AppFontFamily> {
  @override
  AppFontFamily build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return AppFontFamily.fromStorageValue(
      prefs.getString(appFontFamilyPreferenceKey),
    );
  }

  Future<void> setFontFamily(AppFontFamily family) async {
    if (state == family) return;
    state = family;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(appFontFamilyPreferenceKey, family.storageValue);
  }
}

final appFontFamilyProvider =
    NotifierProvider<AppFontFamilyNotifier, AppFontFamily>(
      AppFontFamilyNotifier.new,
    );
