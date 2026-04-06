import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/preferences/shared_preferences_provider.dart';

/// Notifier to manage the "True Black" (AMOLED) theme setting.
///
/// When enabled, the dark theme uses pure black (#000000) for backgrounds
/// to save battery on OLED screens and provide higher contrast.
class TrueBlackNotifier extends Notifier<bool> {
  static const _key = 'use_true_black';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  /// Toggles the True Black setting and persists it to [SharedPreferences].
  ///
  /// Parameters:
  /// - `value` (bool): Whether True Black should be enabled.
  ///
  /// Example:
  /// ```dart
  /// ref.read(trueBlackEnabledProvider.notifier).set(true);
  /// ```
  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, value);
  }
}

/// Provider for the True Black theme setting.
final trueBlackEnabledProvider =
    NotifierProvider<TrueBlackNotifier, bool>(TrueBlackNotifier.new);
