import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';

import '../graphql/graphql_exception.dart';
import '../graphql/graphql_client.dart';

const _findSavedFiltersDocument = r'''
  query FindSavedFiltersByMode($mode: FilterMode) {
    findSavedFilters(mode: $mode) {
      id
      mode
      name
      find_filter {
        q
        page
        per_page
        sort
        direction
      }
      object_filter
      ui_options
    }
  }
''';

const _saveFilterDocument = r'''
  mutation SaveSavedFilter($input: SaveFilterInput!) {
    saveFilter(input: $input) {
      id
      mode
      name
      find_filter {
        q
        page
        per_page
        sort
        direction
      }
      object_filter
      ui_options
    }
  }
''';

const _deleteFilterDocument = r'''
  mutation DestroySavedFilter($input: DestroyFilterInput!) {
    destroySavedFilter(input: $input)
  }
''';

final savedFilterRepositoryProvider = Provider<GraphQLSavedFilterRepository>((
  ref,
) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLSavedFilterRepository(client);
});

class GraphQLSavedFilterRepository {
  GraphQLSavedFilterRepository(this.client);

  final GraphQLClient client;

  Future<List<T>> findAll<T>({
    required String mode,
    required T Function(Map<String, dynamic>) fromRaw,
  }) async {
    final result = await client.query<Map<String, dynamic>>(
      QueryOptions<Map<String, dynamic>>(
        document: gql(_findSavedFiltersDocument),
        variables: {'mode': mode},
        fetchPolicy: FetchPolicy.networkOnly,
        parserFn: (data) => data,
      ),
    );
    validateGraphQLResult(result);

    final filters = result.data?['findSavedFilters'] as List<dynamic>? ?? [];
    return filters
        .whereType<Map<String, dynamic>>()
        .map(fromRaw)
        .toList(growable: false);
  }

  Future<T> save<T>({
    required Map<String, dynamic> input,
    required T Function(Map<String, dynamic>) fromRaw,
  }) async {
    final result = await client.mutate<Map<String, dynamic>>(
      MutationOptions<Map<String, dynamic>>(
        document: gql(_saveFilterDocument),
        variables: {'input': input},
        parserFn: (data) => data,
      ),
    );
    validateGraphQLResult(result);

    final saved = result.data?['saveFilter'];
    if (saved is! Map<String, dynamic>) {
      throw StateError('saveFilter returned an invalid payload');
    }

    return fromRaw(saved);
  }

  Future<bool> delete({required String id}) async {
    final result = await client.mutate<Map<String, dynamic>>(
      MutationOptions<Map<String, dynamic>>(
        document: gql(_deleteFilterDocument),
        variables: {
          'input': {'id': id},
        },
        parserFn: (data) => data,
      ),
    );
    validateGraphQLResult(result);

    final deleted = result.data?['destroySavedFilter'];
    if (deleted is! bool) {
      throw StateError('destroySavedFilter returned an invalid payload');
    }

    return deleted;
  }
}
