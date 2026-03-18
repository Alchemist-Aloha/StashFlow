import '../entities/scene.dart';

abstract class SceneRepository {
  Future<List<Scene>> findScenes({int? page, int? perPage, String? filter});
  Future<Scene> getSceneById(String id);
}
