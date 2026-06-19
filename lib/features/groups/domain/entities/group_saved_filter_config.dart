import '../../../../core/domain/entities/saved_filter_config.dart';
import 'group_filter.dart';

class GroupSavedFilterConfig extends SavedFilterConfig<GroupFilter> {
  const GroupSavedFilterConfig({
    super.id,
    required super.name,
    required super.searchQuery,
    required super.sort,
    required super.descending,
    required super.filter,
    super.perPage,
  }) : super(filterMode: 'GROUPS');

  factory GroupSavedFilterConfig.current({
    String? id,
    required String name,
    required String searchQuery,
    required String? sort,
    required bool descending,
    required GroupFilter filter,
    int? perPage,
  }) {
    return GroupSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
      perPage: perPage,
    );
  }

  factory GroupSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final findFilterMap = savedFilterAsMap(findFilter);
    final objectFilterMap = savedFilterAsMap(objectFilter);
    final direction = findFilterMap['direction'];

    return GroupSavedFilterConfig(
      id: id,
      name: name,
      searchQuery: findFilterMap['q'] as String? ?? '',
      sort: findFilterMap['sort'] as String?,
      descending: direction is String
          ? direction.toUpperCase() == 'DESC'
          : true,
      perPage: findFilterMap['per_page'] as int?,
      filter: objectFilterMap.isEmpty
          ? GroupFilter.empty()
          : GroupFilter.fromJson(
              savedFilterFromServerObjectFilter(
                objectFilter: objectFilterMap,
                serverToLocalKeys: _serverToLocalKeys,
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

  static const _localToServerKeys = {
    'isMissingField': 'is_missing',
    'subGroupCount': 'sub_group_count',
    'sceneCount': 'scene_count',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };
}
