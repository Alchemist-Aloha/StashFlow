import '../../../../core/domain/entities/saved_filter_config.dart';
import 'scene_filter.dart';

class SceneSavedFilterConfig extends SavedFilterConfig<SceneFilter> {
  const SceneSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'SCENES');

  factory SceneSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required SceneFilter filter,
    int? perPage,
  }) {
    return SceneSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
      perPage: perPage,
    );
  }

  factory SceneSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = _asMap(findFilter);
    final objectFilterMap = _asMap(objectFilter);
    final direction = findFilterMap['direction'];

    return SceneSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      filter: objectFilterMap.isEmpty
          ? SceneFilter.empty()
          : SceneFilter.fromJson(_fromServerObjectFilter(objectFilterMap)),
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
      objectFilter: _toServerObjectFilter(filter),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    return savedFilterAsMap(value);
  }

  static Map<String, dynamic> _withoutNulls(Map<String, dynamic> value) {
    return savedFilterWithoutNulls(value);
  }

  static Map<String, dynamic> _toServerObjectFilter(SceneFilter filter) {
    final localJson = _withoutNulls(filter.toJson());
    return {
      for (final entry in localJson.entries)
        _localToServerKeys[entry.key] ?? entry.key: entry.value,
    };
  }

  static Map<String, dynamic> _fromServerObjectFilter(
    Map<String, dynamic> objectFilter,
  ) {
    return savedFilterFromServerObjectFilter(
      objectFilter: objectFilter,
      serverToLocalKeys: _serverToLocalKeys,
      normalizeValue: _normalizeServerValue,
    );
  }

  static Object? _normalizeServerValue(String localKey, Object? value) {
    if (_booleanFields.contains(localKey)) {
      return savedFilterReadBooleanCriterionValue(value) ?? savedFilterSkipValue;
    }

    if (_multiValueFields.contains(localKey)) {
      return _normalizeMultiCriterionValue(value);
    }

    // Stash's is_missing value is a field name. StashFlow currently models it
    // as bool, so loading it would crash or lose meaning.
    if (localKey == 'isMissing') return savedFilterSkipValue;

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
    'oCounter': 'o_counter',
    'lastPlayedAt': 'last_played_at',
    'interactiveSpeed': 'interactive_speed',
    'performerAge': 'performer_age',
    'videoCodec': 'video_codec',
    'audioCodec': 'audio_codec',
    'hasMarkers': 'has_markers',
    'isMissing': 'is_missing',
    'fileCount': 'file_count',
    'playCount': 'play_count',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'phashDistance': 'phash_distance',
    'resumeTime': 'resume_time',
    'playDuration': 'play_duration',
    'tagCount': 'tag_count',
    'performerCount': 'performer_count',
    'stashIdCount': 'stash_id_count',
    'performerTags': 'performer_tags',
    'resolutions': 'resolution',
    'orientations': 'orientation',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };

  static const _booleanFields = {
    'organized',
    'interactive',
    'hasMarkers',
    'isMissing',
  };

  static const _multiValueFields = {
    'studios',
    'performers',
    'tags',
    'resolutions',
    'orientations',
    'groups',
    'galleries',
    'performerTags',
    'duplicated',
  };
}
