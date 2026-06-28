import '../../../../core/domain/entities/saved_filter_config.dart';
import 'image_filter.dart';

class ImageSavedFilterConfig extends SavedFilterConfig<ImageFilter> {
  const ImageSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'IMAGES');

  factory ImageSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required ImageFilter filter,
    int? perPage,
  }) {
    return ImageSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
      perPage: perPage,
    );
  }

  factory ImageSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = savedFilterAsMap(findFilter);
    final objectFilterMap = savedFilterAsMap(objectFilter);
    final direction = findFilterMap['direction'];

    return ImageSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      filter: objectFilterMap.isEmpty
          ? ImageFilter.empty()
          : ImageFilter.fromJson(
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
      return savedFilterReadBooleanCriterionValue(value) ??
          savedFilterSkipValue;
    }
    if (localKey == 'isMissing') return savedFilterSkipValue;
    return value;
  }

  static const _localToServerKeys = {
    'fileCount': 'file_count',
    'oCounter': 'o_counter',
    'isMissing': 'is_missing',
    'tagCount': 'tag_count',
    'performerTags': 'performer_tags',
    'performerCount': 'performer_count',
    'performerFavorite': 'performer_favorite',
    'performerAge': 'performer_age',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };

  static const _booleanFields = {'organized', 'isMissing', 'performerFavorite'};
}
