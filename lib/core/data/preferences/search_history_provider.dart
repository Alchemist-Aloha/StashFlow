import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences_provider.dart';

part 'search_history_provider.g.dart';

@riverpod
class SearchHistoryNotifier extends _$SearchHistoryNotifier {
  @override
  List<String> build(String storageKey) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(storageKey) ?? [];
  }

  Future<void> addQuery(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    final currentState = state.toList();
    
    currentState.remove(trimmedQuery);
    currentState.insert(0, trimmedQuery);
    
    if (currentState.length > 20) {
      currentState.removeRange(20, currentState.length);
    }
    
    state = currentState;
    
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(storageKey, currentState);
  }

  Future<void> removeQuery(String query) async {
    final currentState = state.toList();
    if (currentState.remove(query)) {
      state = currentState;
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setStringList(storageKey, currentState);
    }
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(storageKey);
  }
}
