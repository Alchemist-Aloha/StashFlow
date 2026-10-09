import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/groups/data/graphql/groups.graphql.dart';
import 'package:stash_app_flutter/features/groups/data/repositories/graphql_group_repository.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';

class CapturingGraphQLClient implements GraphQLClient {
  CapturingGraphQLClient(this.response);

  final QueryResult<Query$FindGroups> response;
  QueryOptions<Query$FindGroups>? lastOptions;

  @override
  Link get link => HttpLink('http://localhost:9999/graphql');

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    lastOptions = options as QueryOptions<Query$FindGroups>;
    return response as QueryResult<TParsed>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late GraphQLGroupRepository repository;
  late CapturingGraphQLClient mockClient;

  setUp(() {
    final data = {
      'findGroups': {
        'count': 1,
        'groups': [
          {
            'id': '1',
            'name': 'Test Group',
            'date': '2024-01-01',
            'rating100': 80,
            'director': 'Director',
            'synopsis': 'Synopsis',
            'scene_count': 5,
            'sub_group_count': 1,
            '__typename': 'Group',
          },
        ],
        '__typename': 'GroupQueryResult',
      },
      '__typename': 'Query',
    };

    mockClient = CapturingGraphQLClient(
      QueryResult<Query$FindGroups>(
        source: QueryResultSource.network,
        data: data,
        options: Options$Query$FindGroups(
          variables: Variables$Query$FindGroups(
            filter: Input$FindFilterType(
              page: 1,
              per_page: 20,
              sort: 'scenes_count',
              direction: Enum$SortDirectionEnum.DESC,
            ),
          ),
        ),
      ),
    );
    repository = GraphQLGroupRepository(mockClient);
  });

  group('GraphQLGroupRepository', () {
    test('findGroups maps official group filter and sort keys', () async {
      await repository.findGroups(
        page: 1,
        perPage: 20,
        filter: 'query',
        sort: 'scenes_count',
        descending: true,
        groupFilter: const GroupFilter(
          name: StringCriterion(value: 'group'),
          studios: HierarchicalMultiCriterion(
            value: ['studio-1'],
            excludes: ['studio-2'],
            depth: 2,
          ),
          performers: MultiCriterion(
            value: ['performer-1'],
            excludes: ['performer-2'],
          ),
          tags: HierarchicalMultiCriterion(value: ['tag-1']),
          date: DateCriterion(value: '2024-01-01'),
          oCounter: IntCriterion(value: 2),
          containingGroups: HierarchicalMultiCriterion(value: ['group-2']),
          isMissingField: 'director',
          subGroupCount: IntCriterion(
            value: 1,
            modifier: CriterionModifier.greaterThan,
          ),
          sceneCount: IntCriterion(
            value: 5,
            modifier: CriterionModifier.greaterThan,
          ),
          customFields: [
            CustomFieldCriterion(field: 'source', value: ['archive']),
          ],
        ),
      );

      final captured = mockClient.lastOptions!;
      final variables = captured.variables;
      final filterVariables = variables['filter'] as Map<String, dynamic>?;
      final groupFilterVariables =
          variables['group_filter'] as Map<String, dynamic>?;

      expect(filterVariables?['q'], 'query');
      expect(filterVariables?['sort'], 'scenes_count');
      expect(filterVariables?['direction'], 'DESC');
      expect(groupFilterVariables?['is_missing'], 'director');
      expect(
        ((groupFilterVariables?['custom_fields'] as List).single
            as Map<String, dynamic>)['field'],
        'source',
      );
      expect(
        (groupFilterVariables?['name'] as Map<String, dynamic>?)?['value'],
        'group',
      );
      expect(
        (groupFilterVariables?['studios'] as Map<String, dynamic>?)?['value'],
        ['studio-1'],
      );
      expect(
        (groupFilterVariables?['studios']
            as Map<String, dynamic>?)?['excludes'],
        ['studio-2'],
      );
      expect(
        (groupFilterVariables?['studios'] as Map<String, dynamic>?)?['depth'],
        2,
      );
      expect(
        (groupFilterVariables?['performers']
            as Map<String, dynamic>?)?['value'],
        ['performer-1'],
      );
      expect(
        (groupFilterVariables?['performers']
            as Map<String, dynamic>?)?['excludes'],
        ['performer-2'],
      );
      expect(
        (groupFilterVariables?['tags'] as Map<String, dynamic>?)?['value'],
        ['tag-1'],
      );
      expect(
        (groupFilterVariables?['date'] as Map<String, dynamic>?)?['value'],
        '2024-01-01',
      );
      expect(
        (groupFilterVariables?['o_counter'] as Map<String, dynamic>?)?['value'],
        2,
      );
      expect(
        (groupFilterVariables?['containing_groups']
            as Map<String, dynamic>?)?['value'],
        ['group-2'],
      );
      expect(
        (groupFilterVariables?['sub_group_count']
            as Map<String, dynamic>?)?['value'],
        1,
      );
      expect(
        (groupFilterVariables?['sub_group_count']
            as Map<String, dynamic>?)?['modifier'],
        'GREATER_THAN',
      );
      expect(
        (groupFilterVariables?['scene_count']
            as Map<String, dynamic>?)?['value'],
        5,
      );
    });
  });
}
