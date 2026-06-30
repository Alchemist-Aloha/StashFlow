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

  factory StudioSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final payload = savedFilterReadPayload(
      findFilter: findFilter,
      objectFilter: objectFilter,
      emptyFilter: StudioFilter.empty(),
      fromJson: StudioFilter.fromJson,
      serverToLocalKeys: _serverToLocalKeys,
      normalizeValue: _normalizeServerValue,
    );

    return StudioSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: payload.searchQuery,
      sort: payload.sort,
      descending: payload.descending,
      perPage: payload.perPage,
      filter: payload.filter,
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
      return savedFilterReadBooleanCriterionValue(value) ??
          savedFilterSkipValue;
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
