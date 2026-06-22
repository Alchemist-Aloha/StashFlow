import 'package:graphql/client.dart';

import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../domain/entities/scene_marker_saved_filter_config.dart';

class GraphQLSceneMarkerSavedFilterRepository {
  GraphQLSceneMarkerSavedFilterRepository(GraphQLClient client)
    : _repository = GraphQLSavedFilterRepository(client);

  GraphQLSceneMarkerSavedFilterRepository.repository(this._repository);

  final GraphQLSavedFilterRepository _repository;

  Future<List<SceneMarkerSavedFilterConfig>> findAll() async {
    return _repository.findAll(
      mode: 'SCENE_MARKERS',
      fromRaw: _fromRawSavedFilter,
    );
  }

  Future<SceneMarkerSavedFilterConfig> save(
    SceneMarkerSavedFilterConfig config,
  ) async {
    return _repository.save(
      input: config.toSaveInput(),
      fromRaw: _fromRawSavedFilter,
    );
  }

  Future<bool> delete(String id) async {
    return _repository.delete(id: id);
  }

  SceneMarkerSavedFilterConfig _fromRawSavedFilter(
    Map<String, dynamic> filter,
  ) {
    return SceneMarkerSavedFilterConfig.fromServerPayload(
      id: filter['id'] as String,
      name: filter['name'] as String,
      findFilter: filter['find_filter'],
      objectFilter: filter['object_filter'],
    );
  }
}
