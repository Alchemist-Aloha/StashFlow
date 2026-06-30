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

  factory TagSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final payload = savedFilterReadPayload(
      findFilter: findFilter,
      objectFilter: objectFilter,
      emptyFilter: false,
      fromJson: (json) =>
          savedFilterReadBooleanCriterionValue(json['favorite']) ?? false,
    );

    return TagSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: payload.searchQuery,
      sort: payload.sort,
      descending: payload.descending,
      perPage: payload.perPage,
      favorite: payload.filter,
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
