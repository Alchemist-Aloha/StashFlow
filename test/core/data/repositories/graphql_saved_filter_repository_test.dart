import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/repositories/graphql_saved_filter_repository.dart';

void main() {
  group('GraphQLSavedFilterRepository', () {
    test('findAll queries the requested filter mode', () async {
      final client = _FakeGraphQLClient(
        queryData: {
          '__typename': 'Query',
          'findSavedFilters': [
            {
              '__typename': 'SavedFilter',
              'id': '5',
              'mode': 'PERFORMERS',
              'name': 'Favorites',
              'find_filter': {
                '__typename': 'SavedFindFilterType',
                'q': 'alice',
                'page': 1,
                'sort': 'rating',
                'direction': 'DESC',
              },
              'object_filter': {'filter_favorites': true},
              'ui_options': {},
            },
          ],
        },
      );

      final repository = GraphQLSavedFilterRepository(client);
      final result = await repository.findAll<Map<String, dynamic>>(
        mode: 'PERFORMERS',
        fromRaw: (raw) => raw,
      );

      expect(result, hasLength(1));
      expect(client.lastQueryVariables, {'mode': 'PERFORMERS'});
      expect(result.single['name'], 'Favorites');
      expect(result.single['mode'], 'PERFORMERS');
    });

    test('save forwards the full saved filter input payload', () async {
      final client = _FakeGraphQLClient(
        mutationData: {
          '__typename': 'Mutation',
          'saveFilter': {
            '__typename': 'SavedFilter',
            'id': '6',
            'mode': 'TAGS',
            'name': 'Favorite tags',
            'find_filter': {
              '__typename': 'SavedFindFilterType',
              'q': 'fav',
              'page': 1,
              'sort': 'name',
              'direction': 'ASC',
            },
            'object_filter': {'favorite': true},
            'ui_options': {},
          },
        },
      );

      final repository = GraphQLSavedFilterRepository(client);
      final saved = await repository.save<Map<String, dynamic>>(
        input: {
          'mode': 'TAGS',
          'name': 'Favorite tags',
          'find_filter': {
            'q': 'fav',
            'page': 1,
            'sort': 'name',
            'direction': 'ASC',
          },
          'object_filter': {'favorite': true},
          'ui_options': <String, Object?>{},
        },
        fromRaw: (raw) => raw,
      );

      expect(saved['id'], '6');
      expect(client.lastMutationVariables!['input']['mode'], 'TAGS');
      expect(
        client.lastMutationVariables!['input']['object_filter']['favorite'],
        true,
      );
    });

    test('delete forwards the saved filter id to destroySavedFilter', () async {
      final client = _FakeGraphQLClient(
        mutationData: {'__typename': 'Mutation', 'destroySavedFilter': true},
      );

      final repository = GraphQLSavedFilterRepository(client);
      final deleted = await repository.delete(id: '42');

      expect(deleted, isTrue);
      expect(client.lastMutationVariables, {
        'input': {'id': '42'},
      });
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
  Map<String, dynamic>? lastQueryVariables;
  Map<String, dynamic>? lastMutationVariables;

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    lastQueryVariables = options.variables;
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
