import 'dart:convert';

import '../../../../core/data/graphql/schema.graphql.dart';
import 'scene_filter.dart';

class SceneSavedFilterConfig {
  const SceneSavedFilterConfig({
    this.id,
    required this.name,
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.filter,
    this.perPage,
  });

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

  final String? id;
  final String name;
  final String searchQuery;
  final String? sort;
  final bool descending;
  final SceneFilter filter;
  final int? perPage;

  Input$SaveFilterInput toSaveInput() {
    return Input$SaveFilterInput(
      id: id,
      mode: Enum$FilterMode.SCENES,
      name: name,
      find_filter: Input$FindFilterType(
        q: searchQuery.isEmpty ? null : searchQuery,
        page: 1,
        per_page: perPage,
        sort: sort,
        direction: descending
            ? Enum$SortDirectionEnum.DESC
            : Enum$SortDirectionEnum.ASC,
      ),
      object_filter: jsonEncode(_toServerObjectFilter(filter)),
      ui_options: jsonEncode(<String, Object?>{}),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    if (value is String && value.trim().isNotEmpty) {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _withoutNulls(Map<String, dynamic> value) {
    return {
      for (final entry in value.entries)
        if (entry.value != null) entry.key: entry.value,
    };
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
    return {
      for (final entry in objectFilter.entries)
        _serverToLocalKeys[entry.key] ?? entry.key: entry.value,
    };
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
}
