import 'package:graphql/client.dart';

import '../../../../core/data/graphql/base_repository.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../graphql/scenes.graphql.dart';

class GraphQLSceneSavedFilterRepository {
  GraphQLSceneSavedFilterRepository(this.client);

  final GraphQLClient client;

  Future<List<SceneSavedFilterConfig>> findAll() async {
    final result = await client.query$FindSceneSavedFilters(
      Options$Query$FindSceneSavedFilters(fetchPolicy: FetchPolicy.networkOnly),
    );
    BaseRepository.validateResult(result);

    final filters = result.data?['findSavedFilters'] as List<dynamic>? ?? [];
    return filters
        .whereType<Map<String, dynamic>>()
        .map(_fromRawSavedFilter)
        .toList(growable: false);
  }

  Future<SceneSavedFilterConfig> save(SceneSavedFilterConfig config) async {
    final result = await client.mutate$SaveSceneSavedFilter(
      Options$Mutation$SaveSceneSavedFilter(
        variables: Variables$Mutation$SaveSceneSavedFilter(
          input: config.toSaveInput(),
        ),
      ),
    );
    BaseRepository.validateResult(result);

    final saved = result.data?['saveFilter'];
    if (saved is! Map<String, dynamic>) {
      throw StateError('saveFilter returned an invalid payload');
    }

    return _fromRawSavedFilter(saved);
  }

  SceneSavedFilterConfig _fromRawSavedFilter(Map<String, dynamic> filter) {
    return SceneSavedFilterConfig.fromServerPayload(
      id: filter['id'] as String,
      name: filter['name'] as String,
      findFilter: filter['find_filter'],
      objectFilter: filter['object_filter'],
    );
  }
}
