import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';

part 'navigation_customization_provider.g.dart';

@riverpod
class RandomNavigationEnabled extends _$RandomNavigationEnabled {
  static const _storageKey = 'show_random_navigation';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  void set(bool value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_storageKey, value);
  }
}
