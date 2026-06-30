import '../../../../core/domain/entities/saved_filter_config.dart';
import 'gallery_filter.dart';

class GallerySavedFilterConfig extends SavedFilterConfig<GalleryFilter> {
  const GallerySavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'GALLERIES');

  factory GallerySavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final payload = savedFilterReadPayload(
      findFilter: findFilter,
      objectFilter: objectFilter,
      emptyFilter: GalleryFilter.empty(),
      fromJson: GalleryFilter.fromJson,
      serverToLocalKeys: _serverToLocalKeys,
      normalizeValue: _normalizeServerValue,
    );

    return GallerySavedFilterConfig(
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
    'fileCount': 'file_count',
    'isMissing': 'is_missing',
    'isZip': 'is_zip',
    'averageResolution': 'average_resolution',
    'hasChapters': 'has_chapters',
    'tagCount': 'tag_count',
    'performerTags': 'performer_tags',
    'performerCount': 'performer_count',
    'performerFavorite': 'performer_favorite',
    'performerAge': 'performer_age',
    'imageCount': 'image_count',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };

  static const _booleanFields = {
    'organized',
    'isMissing',
    'isZip',
    'hasChapters',
    'performerFavorite',
  };
}
