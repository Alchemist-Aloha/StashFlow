import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../domain/entities/performer.dart';
import '../../domain/repositories/performer_repository.dart';
import '../../data/repositories/graphql_performer_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'performer_list_provider.g.dart';

class PerformerFilterState {
  final bool favoritesOnly;
  final List<String> genders;

  const PerformerFilterState({
    this.favoritesOnly = false,
    this.genders = const <String>[],
  });

  static const empty = PerformerFilterState();

  bool get hasActiveFilters => favoritesOnly || genders.isNotEmpty;
}

// Provider for Repository interface
final performerRepositoryProvider = Provider<PerformerRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLPerformerRepository(client);
});

@riverpod
class PerformerSort extends _$PerformerSort {
  static const _sortKey = 'performer_sort_field';
  static const _descKey = 'performer_sort_descending';

  @override
  ({String? sort, bool descending}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;
    return (sort: sort, descending: descending);
  }

  void setSort({String? sort, bool descending = true}) {
    state = (sort: sort, descending: descending);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@riverpod
class PerformerSearchQuery extends _$PerformerSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final performerFilterProvider =
    NotifierProvider<PerformerFilterNotifier, PerformerFilterState>(
      PerformerFilterNotifier.new,
    );

class PerformerFilterNotifier extends Notifier<PerformerFilterState> {
  static const _favoritesKey = 'performer_filter_favorites_only';
  static const _genderKey = 'performer_filter_gender';

  @override
  PerformerFilterState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedGenders = prefs.getStringList(_genderKey);
    final legacyGender = prefs.getString(_genderKey);
    return PerformerFilterState(
      favoritesOnly: prefs.getBool(_favoritesKey) ?? false,
      genders:
          savedGenders ??
          (legacyGender == null ? const <String>[] : <String>[legacyGender]),
    );
  }

  void set({bool favoritesOnly = false, List<String> genders = const []}) {
    state = PerformerFilterState(
      favoritesOnly: favoritesOnly,
      genders: List<String>.unmodifiable(genders),
    );
  }

  void clear() {
    state = PerformerFilterState.empty;
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_favoritesKey, state.favoritesOnly);

    if (state.genders.isEmpty) {
      await prefs.remove(_genderKey);
    } else {
      await prefs.setStringList(_genderKey, state.genders);
    }
  }
}

final performerFavoritesOnlyProvider =
    NotifierProvider<PerformerFavoritesOnlyNotifier, bool>(
      PerformerFavoritesOnlyNotifier.new,
    );

class PerformerFavoritesOnlyNotifier extends Notifier<bool> {
  static const _storageKey = 'performer_favorites_only';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? false;
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, state);
  }
}

@riverpod
class PerformerList extends _$PerformerList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Performer>> build() async {
    ref.keepAlive();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(performerSearchQueryProvider);
    final sortConfig = ref.watch(performerSortProvider);
    final filterState = ref.watch(performerFilterProvider);
    final repository = ref.read(performerRepositoryProvider);
    return repository.findPerformers(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      favoritesOnly: filterState.favoritesOnly,
      genders: filterState.genders,
    );
  }

  void setSort({String? sort, bool descending = true}) {
    ref
        .read(performerSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool enabled) {
    ref.read(performerFavoritesOnlyProvider.notifier).state = enabled;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(performerRepositoryProvider);
    final query = ref.read(performerSearchQueryProvider);
    final sortConfig = ref.read(performerSortProvider);
    final filterState = ref.read(performerFilterProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextPerformers = await repository.findPerformers(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        favoritesOnly: filterState.favoritesOnly,
        genders: filterState.genders,
      );

      if (nextPerformers.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextPerformers]);
      }
    } catch (e) {
      // In a real app, you might want to show a snackbar for error during pagination
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<Performer?> getRandomPerformer({
    bool useCurrentFilter = false,
    String? excludePerformerId,
  }) async {
    final repository = ref.read(performerRepositoryProvider);
    final query = useCurrentFilter
        ? ref.read(performerSearchQueryProvider)
        : '';
    final filterState = useCurrentFilter
        ? ref.read(performerFilterProvider)
        : PerformerFilterState.empty;

    final attempts = excludePerformerId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findPerformers(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        favoritesOnly: filterState.favoritesOnly,
        genders: filterState.genders,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludePerformerId == null || candidate.id != excludePerformerId) {
        return candidate;
      }
    }

    final loaded = state.asData?.value;
    if (loaded != null && loaded.isNotEmpty) {
      final candidates = excludePerformerId == null
          ? loaded
          : loaded
                .where((performer) => performer.id != excludePerformerId)
                .toList();
      if (candidates.isEmpty) return null;
      final random = Random();
      return candidates[random.nextInt(candidates.length)];
    }

    return null;
  }
}
