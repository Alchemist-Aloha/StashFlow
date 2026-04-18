import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';

const mainPageGravityOrientationPreferenceKey = 'main_page_gravity_orientation';

class MainPageOrientationNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(mainPageGravityOrientationPreferenceKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(mainPageGravityOrientationPreferenceKey, value);
  }
}

final mainPageGravityOrientationProvider =
    NotifierProvider<MainPageOrientationNotifier, bool>(
      MainPageOrientationNotifier.new,
    );
