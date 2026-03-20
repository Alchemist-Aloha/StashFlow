import '../entities/scene.dart';
import '../entities/scene_filter.dart';

abstract class SceneRepository {
  Future<List<Scene>> findScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool? organized,
    bool? performerFavorite,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  });
  Future<Scene> getSceneById(String id);
  Future<void> updateSceneRating(String id, int rating100);
  Future<void> incrementSceneOCounter(String id);
  Future<void> incrementScenePlayCount(String id);
}
