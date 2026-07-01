import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import 'package:stash_app_flutter/core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_filter.dart';
import '../graphql/groups.graphql.dart';

class GraphQLGroupRepository {
  final GraphQLClient _client;

  GraphQLGroupRepository(this._client);
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
        fetchPolicy: FetchPolicy.cacheAndNetwork,
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
            is_missing: groupFilter?.isMissingField,
            sub_group_count: mapIntCriterion(groupFilter?.subGroupCount),
            scene_count: mapIntCriterion(groupFilter?.sceneCount),
          ),
        ),
      ),
    );

    validateGraphQLResult(result);

    return result.parsedData!.findGroups.groups
        .map((g) => Group.fromJson(g.toJson()))
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

    return Group.fromJson(data.toJson());
  }
}
