import '../../../../core/domain/entities/saved_filter_config.dart';
import 'scene_marker.dart';

class SceneMarkerSavedFilterConfig
    extends SavedFilterConfig<SceneMarkerFilter> {
  const SceneMarkerSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'SCENE_MARKERS');

  factory SceneMarkerSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required SceneMarkerFilter filter,
    int? perPage,
  }) {
    return SceneMarkerSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
      perPage: perPage,
    );
  }

  factory SceneMarkerSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = savedFilterAsMap(findFilter);
    final objectFilterMap = savedFilterAsMap(objectFilter);
    final direction = findFilterMap['direction'];

    return SceneMarkerSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      filter: objectFilterMap.isEmpty
          ? const SceneMarkerFilter()
          : SceneMarkerFilter.fromJson(
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
    if (_multiValueFields.contains(localKey)) {
      return _normalizeMultiCriterionValue(value);
    }
    return value;
  }

  static Object? _normalizeMultiCriterionValue(Object? value) {
    Object? rawValue;
    if (value is Map) {
      rawValue = value['value'];
    } else {
      rawValue = value;
    }

    final normalizedValue = switch (rawValue) {
      null => <String>[],
      List() => rawValue.map((item) => item.toString()).toList(),
      _ => <String>[rawValue.toString()],
    };

    if (value is Map) {
      return {
        for (final entry in value.entries) entry.key.toString(): entry.value,
        'value': normalizedValue,
      };
    }

    return {'value': normalizedValue};
  }

  static const _localToServerKeys = {
    'sceneTags': 'scene_tags',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'sceneDate': 'scene_date',
    'sceneCreatedAt': 'scene_created_at',
    'sceneUpdatedAt': 'scene_updated_at',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };

  static const _multiValueFields = {
    'tags',
    'sceneTags',
    'performers',
    'scenes',
  };
}
