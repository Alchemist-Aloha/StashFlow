import 'package:graphql/client.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';

class GraphQLSceneRepository implements SceneRepository {
  final GraphQLClient client;
  GraphQLSceneRepository(this.client);

  @override
  Future<List<Scene>> findScenes({
    int? page,
    int? perPage,
    String? filter,
  }) async {
    const String findScenesQuery = r'''
      query FindScenes($page: Int, $perPage: Int) {
        findScenes(filter: { page: $page, per_page: $perPage }) {
          count
          scenes {
            id
            title
            date
            rating
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(findScenesQuery),
        variables: {'page': page, 'perPage': perPage},
      ),
    );

    if (result.hasException) throw result.exception!;

    final List scenesJson = result.data?['findScenes']?['scenes'] ?? [];

    return scenesJson
        .map(
          (s) => Scene(
            id: s['id'],
            title: s['title'] ?? '',
            date: DateTime.tryParse(s['date'] ?? '') ?? DateTime.now(),
            rating: (s['rating'] as num?)?.toDouble() ?? 0.0,
            tags: [],
            performers: [],
            studio: null,
            streamUrl: null,
            thumbUrl: null,
          ),
        )
        .toList();
  }

  @override
  Future<Scene> getSceneById(String id) async {
    const String findSceneQuery = r'''
      query FindScene($id: ID!) {
        findScene(id: $id) {
          id
          title
          date
          rating
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(document: gql(findSceneQuery), variables: {'id': id}),
    );

    if (result.hasException) throw result.exception!;

    final sceneJson = result.data?['findScene'];
    if (sceneJson == null) {
      throw StateError('Scene not found for id: $id');
    }

    return Scene(
      id: sceneJson['id'],
      title: sceneJson['title'] ?? '',
      date: DateTime.tryParse(sceneJson['date'] ?? '') ?? DateTime.now(),
      rating: (sceneJson['rating'] as num?)?.toDouble() ?? 0.0,
      tags: [],
      performers: [],
      studio: null,
      streamUrl: null,
      thumbUrl: null,
    );
  }
}
