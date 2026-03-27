import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';

part 'scrape_customization_provider.g.dart';

@riverpod
class ScrapeEnabled extends _$ScrapeEnabled {
  static const _storageKey = 'show_scrape_button';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Default to false as it is WIP
    return prefs.getBool(_storageKey) ?? false;
  }

  void set(bool value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_storageKey, value);
  }
}
