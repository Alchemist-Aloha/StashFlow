import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_saved_filter_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_saved_filter_config.dart';

void main() {
  group('GraphQLSceneSavedFilterRepository', () {
    test('findAll returns scene saved filter configs from server', () async {
      final client = _FakeGraphQLClient(
        queryData: {
          '__typename': 'Query',
          'findSavedFilters': [
            {
              '__typename': 'SavedFilter',
              'id': '1',
              'mode': 'SCENES',
              'name': 'Favorites',
              'find_filter': {
                '__typename': 'SavedFindFilterType',
                'q': 'fav',
                'page': 1,
                'per_page': 40,
                'sort': 'rating',
                'direction': 'DESC',
              },
              'object_filter':
                  '{"organized":true,"tags":{"value":["2"],"modifier":"INCLUDES"}}',
              'ui_options': '{}',
            },
          ],
        },
      );

      final repository = GraphQLSceneSavedFilterRepository(client);

      final result = await repository.findAll();

      expect(result, hasLength(1));
      expect(result.single.id, '1');
      expect(result.single.name, 'Favorites');
      expect(result.single.searchQuery, 'fav');
      expect(result.single.sort, 'rating');
      expect(result.single.descending, true);
      expect(result.single.filter.organized, true);
      expect(result.single.filter.tags?.value, ['2']);
    });

    test(
      'findAll accepts object_filter returned as a GraphQL Map scalar',
      () async {
        final client = _FakeGraphQLClient(
          queryData: {
            '__typename': 'Query',
            'findSavedFilters': [
              {
                '__typename': 'SavedFilter',
                'id': '2',
                'mode': 'SCENES',
                'name': 'Map payload',
                'find_filter': {
                  '__typename': 'SavedFindFilterType',
                  'q': null,
                  'page': 1,
                  'per_page': 40,
                  'sort': 'date',
                  'direction': 'DESC',
                },
                'object_filter': {
                  'organized': false,
                  'o_counter': {'value': 3, 'modifier': 'GREATER_THAN'},
                },
                'ui_options': {},
              },
            ],
          },
        );

        final repository = GraphQLSceneSavedFilterRepository(client);

        final result = await repository.findAll();

        expect(result.single.name, 'Map payload');
        expect(result.single.filter.organized, false);
        expect(result.single.filter.oCounter?.value, 3);
      },
    );

    test('save sends current scene config to server', () async {
      final client = _FakeGraphQLClient(
        mutationData: {
          '__typename': 'Mutation',
          'saveFilter': {
            '__typename': 'SavedFilter',
            'id': '9',
            'mode': 'SCENES',
            'name': 'By path',
            'find_filter': {
              '__typename': 'SavedFindFilterType',
              'q': 'clip',
              'page': 1,
              'per_page': 25,
              'sort': 'path',
              'direction': 'ASC',
            },
            'object_filter':
                '{"path":{"value":"/stash","modifier":"INCLUDES"}}',
            'ui_options': '{}',
          },
        },
      );

      final repository = GraphQLSceneSavedFilterRepository(client);
      final saved = await repository.save(
        SceneSavedFilterConfig.current(
          name: 'By path',
          searchQuery: 'clip',
          sort: 'path',
          descending: false,
          filter: const SceneFilter(path: StringCriterion(value: '/stash')),
          perPage: 25,
        ),
      );

      expect(saved.id, '9');
      final input =
          client.lastMutationVariables!['input'] as Map<String, dynamic>;
      expect(input['mode'], 'SCENES');
      expect(input['name'], 'By path');
      expect(input['find_filter']['sort'], 'path');
      expect(input['find_filter']['direction'], 'ASC');
      expect(input['object_filter'], contains('/stash'));
    });
  });
}

class _FakeGraphQLClient extends GraphQLClient {
  _FakeGraphQLClient({this.queryData, this.mutationData})
    : super(
        cache: GraphQLCache(),
        link: Link.function((request, [forward]) => const Stream.empty()),
      );

  final Map<String, dynamic>? queryData;
  final Map<String, dynamic>? mutationData;
  Map<String, dynamic>? lastMutationVariables;

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: queryData,
      options: options,
    );
  }

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) async {
    lastMutationVariables = options.variables;
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: mutationData,
      options: options,
    );
  }
}
