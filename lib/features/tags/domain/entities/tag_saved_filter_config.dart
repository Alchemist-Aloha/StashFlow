import '../../../../core/domain/entities/saved_filter_config.dart';

class TagSavedFilterConfig extends SavedFilterConfig<bool> {
  const TagSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required bool favorite,
    super.perPage,
  }) : super(filterMode: 'TAGS', filter: favorite);

  factory TagSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required bool favorite,
    int? perPage,
  }) {
    return TagSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      favorite: favorite,
      perPage: perPage,
    );
  }

  factory TagSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = savedFilterAsMap(findFilter);
    final objectFilterMap = savedFilterAsMap(objectFilter);
    final direction = findFilterMap['direction'];

    return TagSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      favorite:
          savedFilterReadBooleanCriterionValue(objectFilterMap['favorite']) ??
          false,
    );
  }

  bool get favorite => filter;

  @override
  Map<String, dynamic> toSaveInput() {
    return savedFilterBuildInput(
      id: id,
      mode: filterMode,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      perPage: perPage,
      objectFilter: favorite ? {'favorite': true} : <String, dynamic>{},
    );
  }
}
