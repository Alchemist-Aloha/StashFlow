import '../../../../core/domain/entities/saved_filter_config.dart';
import 'studio_filter.dart';

class StudioSavedFilterConfig extends SavedFilterConfig<StudioFilter> {
  const StudioSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'STUDIOS');

  factory StudioSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required StudioFilter filter,
    int? perPage,
  }) {
    return StudioSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
      perPage: perPage,
    );
  }

  factory StudioSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = savedFilterAsMap(findFilter);
    final objectFilterMap = savedFilterAsMap(objectFilter);
    final direction = findFilterMap['direction'];

    return StudioSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      filter: objectFilterMap.isEmpty
          ? StudioFilter.empty()
          : StudioFilter.fromJson(
              savedFilterFromServerObjectFilter(
                objectFilter: objectFilterMap,
                serverToLocalKeys: _serverToLocalKeys,
                normalizeValue: _normalizeServerValue,
              ),
            ),
    );
  }

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
      objectFilter: savedFilterToServerObjectFilter(
        localJson: filter.toJson(),
        localToServerKeys: _localToServerKeys,
      ),
    );
  }

  static Object? _normalizeServerValue(String localKey, Object? value) {
    if (_booleanFields.contains(localKey)) {
      return savedFilterReadBooleanCriterionValue(value) ?? savedFilterSkipValue;
    }
    if (localKey == 'isMissing') return savedFilterSkipValue;
    return value;
  }

  static const _localToServerKeys = {
    'parentStudios': 'parents',
    'isMissing': 'is_missing',
    'sceneCount': 'scene_count',
    'imageCount': 'image_count',
    'galleryCount': 'gallery_count',
    'groupCount': 'group_count',
    'tagCount': 'tag_count',
    'ignoreAutoTag': 'ignore_auto_tag',
    'childCount': 'child_count',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };

  static const _booleanFields = {
    'favorite',
    'ignoreAutoTag',
    'organized',
    'isMissing',
  };
}
