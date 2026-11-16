import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import 'package:stash_app_flutter/core/data/graphql/criterion_mapping.dart';

import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_filter.dart';
import '../graphql/groups.graphql.dart';

class GraphQLGroupRepository {
  final GraphQLClient _client;

  GraphQLGroupRepository(this._client);

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');

  String? _resolve(Object? rawUrl) => resolveGraphqlMediaUrl(
    rawUrl: rawUrl?.toString(),
    graphqlEndpoint: _graphqlEndpoint,
  );

  /// Maps a group payload, resolving every image URL against the configured
  /// server so relative or loopback paths load on remote devices.
  Group _mapGroup(Map<String, dynamic> json) {
    List<dynamic>? relations(Object? raw) =>
        (raw as List<dynamic>?)?.map((entry) {
          final link = Map<String, dynamic>.from(entry as Map<String, dynamic>);
          final group = link['group'];
          if (group is Map<String, dynamic>) {
            link['group'] = {
              ...group,
              'front_image_path': _resolve(group['front_image_path']),
            };
          }
          return link;
        }).toList();

    final studio = json['studio'];
    return Group.fromJson({
      ...json,
      'front_image_path': _resolve(json['front_image_path']),
      'back_image_path': _resolve(json['back_image_path']),
      if (studio is Map<String, dynamic>)
        'studio': {...studio, 'image_path': _resolve(studio['image_path'])},
      'containing_groups': relations(json['containing_groups']),
      'sub_groups': relations(json['sub_groups']),
    });
  }

  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GroupFilter? groupFilter,
  }) async {
    final result = await _client.query$FindGroups(
      Options$Query$FindGroups(
        fetchPolicy: FetchPolicy.networkOnly,
        variables: Variables$Query$FindGroups(
          filter: Input$FindFilterType(
            q: filter,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          group_filter: Input$GroupFilterType(
            name: mapStringCriterion(groupFilter?.name),
            director: mapStringCriterion(groupFilter?.director),
            synopsis: mapStringCriterion(groupFilter?.synopsis),
            duration: mapIntCriterion(groupFilter?.duration),
            rating100: mapIntCriterion(groupFilter?.rating100),
            studios: mapHierarchicalMultiCriterion(groupFilter?.studios),
            is_missing: groupFilter?.isMissingField,
            url: mapStringCriterion(groupFilter?.url),
            performers: mapMultiCriterion(groupFilter?.performers),
            tags: mapHierarchicalMultiCriterion(groupFilter?.tags),
            tag_count: mapIntCriterion(groupFilter?.tagCount),
            date: mapDateCriterion(groupFilter?.date),
            created_at: mapTimestampCriterion(groupFilter?.createdAt),
            updated_at: mapTimestampCriterion(groupFilter?.updatedAt),
            o_counter: mapIntCriterion(groupFilter?.oCounter),
            containing_groups: mapHierarchicalMultiCriterion(
              groupFilter?.containingGroups,
            ),
            sub_groups: mapHierarchicalMultiCriterion(groupFilter?.subGroups),
            containing_group_count: mapIntCriterion(
              groupFilter?.containingGroupCount,
            ),
            sub_group_count: mapIntCriterion(groupFilter?.subGroupCount),
            scene_count: mapIntCriterion(groupFilter?.sceneCount),
            custom_fields: mapCustomFieldCriteria(
              groupFilter?.customFields ?? const [],
            ),
          ),
        ),
      ),
    );

    validateGraphQLResult(result);

    return result.parsedData!.findGroups.groups
        .map((g) => _mapGroup(g.toJson()))
        .toList();
  }

  Future<Group> getGroupById(String id, {bool refresh = false}) async {
    final result = await _client.query$FindGroup(
      Options$Query$FindGroup(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindGroup(id: id),
      ),
    );

    validateGraphQLResult(result);
    final data = result.parsedData!.findGroup;
    if (data == null) throw Exception('Group not found');

    return _mapGroup(data.toJson());
  }
}
