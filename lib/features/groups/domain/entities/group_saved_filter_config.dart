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

  factory GroupSavedFilterConfig.fromServerPayload({
    required String id,
    required String name,
    Object? findFilter,
    Object? objectFilter,
  }) {
    final payload = savedFilterReadPayload(
      findFilter: findFilter,
      objectFilter: objectFilter,
      emptyFilter: GroupFilter.empty(),
      fromJson: GroupFilter.fromJson,
      serverToLocalKeys: _serverToLocalKeys,
    );

    return GroupSavedFilterConfig(
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

  static const _localToServerKeys = {
    'isMissingField': 'is_missing',
    'subGroupCount': 'sub_group_count',
    'sceneCount': 'scene_count',
  };

  static final _serverToLocalKeys = {
    for (final entry in _localToServerKeys.entries) entry.value: entry.key,
  };
}
