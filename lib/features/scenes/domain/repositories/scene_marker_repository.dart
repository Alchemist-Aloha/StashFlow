import '../entities/scene_marker.dart';

abstract class SceneMarkerRepository {
  Future<List<SceneMarkerSummary>> findSceneMarkers({
    int? page,
    int? perPage,
    String? searchQuery,
    String? sort,
    bool descending = true,
    SceneMarkerFilter filter = const SceneMarkerFilter(),
  });
}
