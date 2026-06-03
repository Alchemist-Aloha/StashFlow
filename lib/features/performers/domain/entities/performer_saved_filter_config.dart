import '../../../../core/domain/entities/saved_filter_config.dart';
import 'performer_filter.dart';

class PerformerSavedFilterConfig extends SavedFilterConfig<PerformerFilter> {
  const PerformerSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'PERFORMERS');

  factory PerformerSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required PerformerFilter filter,
    int? perPage,
  }) {
    return PerformerSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
      perPage: perPage,
    );
  }

  factory PerformerSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = savedFilterAsMap(findFilter);
    final objectFilterMap = savedFilterAsMap(objectFilter);
    final direction = findFilterMap['direction'];

    return PerformerSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      filter: objectFilterMap.isEmpty
          ? PerformerFilter.empty()
          : PerformerFilter.fromJson(
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
    'favorite': 'filter_favorites',
    'isMissing': 'is_missing',
    'tagCount': 'tag_count',
    'sceneCount': 'scene_count',
    'imageCount': 'image_count',
    'galleryCount': 'gallery_count',
    'playCount': 'play_count',
    'oCounter': 'o_counter',
    'ignoreAutoTag': 'ignore_auto_tag',
    'heightCm': 'height_cm',
    'birthYear': 'birth_year',
    'deathYear': 'death_year',
    'penisLength': 'penis_length',
    'hairColor': 'hair_color',
    'eyeColor': 'eye_color',
    'fakeTits': 'fake_tits',
    'deathDate': 'death_date',
    'careerStart': 'career_start',
    'careerEnd': 'career_end',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };

  static const _booleanFields = {
    'favorite',
    'ignoreAutoTag',
    'isMissing',
  };
}
