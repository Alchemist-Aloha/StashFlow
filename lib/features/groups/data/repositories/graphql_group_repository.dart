import 'package:graphql/client.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

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
    const query = r'''
      query FindGroups($filter: FindFilterType, $group_filter: GroupFilterType) {
        findGroups(filter: $filter, group_filter: $group_filter) {
          groups {
            id
            name
            date
            rating100
            director
            synopsis
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          'filter': {
            'page': page,
            'per_page': perPage,
            'sort': sort,
            'direction': descending == true ? 'DESC' : 'ASC',
          },
          'group_filter': filter != null
              ? {
                  'name': {
                    'value': filter,
                    'modifier': 'EQUALS',
                  },
                }
              : null,
        },
      ),
    );

    if (result.hasException) throw result.exception!;

    final groupsJson =
        result.data?['findGroups']?['groups'] as List<dynamic>? ?? [];
    return groupsJson
        .map((g) => Group.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Group> getGroupById(String id) async {
    const query = r'''
      query FindGroup($id: ID!) {
        findGroup(id: $id) {
          id
          name
          date
          rating100
          director
          synopsis
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'id': id},
      ),
    );

    if (result.hasException) throw result.exception!;
    final data = result.data?['findGroup'];
    if (data == null) throw Exception('Group not found');
    
    return Group.fromJson(data as Map<String, dynamic>);
  }
}
