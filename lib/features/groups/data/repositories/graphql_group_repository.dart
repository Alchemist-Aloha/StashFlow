import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/base_repository.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../graphql/groups.graphql.dart';

class GraphQLGroupRepository implements GroupRepository {
  final GraphQLClient client;

  GraphQLGroupRepository(this.client);

  @override
  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  }) async {
    final result = await client.query$FindGroups(
      Options$Query$FindGroups(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindGroups(
          filter: Input$FindFilterType(
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          group_filter: filter != null
              ? Input$GroupFilterType(
                  name: Input$StringCriterionInput(
                    value: filter,
                    modifier: Enum$CriterionModifier.EQUALS,
                  ),
                )
              : null,
        ),
      ),
    );

    BaseRepository.validateResult(result);

    return result.parsedData!.findGroups.groups
        .map((g) => Group.fromJson(g.toJson()))
        .toList();
  }

  @override
  Future<Group> getGroupById(String id, {bool refresh = false}) async {
    final result = await client.query$FindGroup(
      Options$Query$FindGroup(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindGroup(id: id),
      ),
    );

    BaseRepository.validateResult(result);
    final data = result.parsedData!.findGroup;
    if (data == null) throw Exception('Group not found');

    return Group.fromJson(data.toJson());
  }
}
