import 'package:graphql/client.dart';

import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../domain/entities/scene_saved_filter_config.dart';

class GraphQLSceneSavedFilterRepository {
  GraphQLSceneSavedFilterRepository(GraphQLClient client)
    : _repository = GraphQLSavedFilterRepository(client);

  GraphQLSceneSavedFilterRepository.repository(this._repository);

  final GraphQLSavedFilterRepository _repository;

  Future<List<SceneSavedFilterConfig>> findAll() async {
    return _repository.findAll(
      mode: 'SCENES',
      fromRaw: _fromRawSavedFilter,
    );
  }

  Future<SceneSavedFilterConfig> save(SceneSavedFilterConfig config) async {
    return _repository.save(
      input: config.toSaveInput(),
      fromRaw: _fromRawSavedFilter,
    );
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
