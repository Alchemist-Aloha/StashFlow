import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';

/// Notifier for managing gesture-related settings.
class GestureSettingsNotifier extends Notifier<bool> {
  static const _shakeToRandomKey = 'shake_to_random_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_shakeToRandomKey) ?? false;
  }

  /// Sets whether "Shake to Random" is enabled.
  Future<void> setShakeToRandom(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_shakeToRandomKey, value);
  }
}

/// Provider for the "Shake to Random" gesture setting.
final shakeToRandomEnabledProvider =
    NotifierProvider<GestureSettingsNotifier, bool>(
      GestureSettingsNotifier.new,
    );
