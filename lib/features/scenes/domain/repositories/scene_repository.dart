import '../entities/scene.dart';
import '../entities/scene_filter.dart';
import '../models/scraper.dart';
import '../models/scraped_scene.dart';

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
  Future<Scene> getSceneById(String id, {bool refresh = false});
  Future<List<Scraper>> listScrapers({required List<String> types});
  Future<List<ScrapedScene>> scrapeSingleScene({
    String? scraperId,
    String? stashBoxEndpoint,
    String? sceneId,
    String? query,
  });
  Future<void> generatePhash(String sceneId);
  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
    String? studioId,
  });

  /// For each scraped performer (by name/url) return a list of candidate performers
  /// from the server. The key is the query string (name or url) and the value is
  /// a list of raw performer maps as returned by GraphQL.
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> queries,
  );

  /// For each tag name return a list of candidate tag maps. Key is the tag name.
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  );
  Future<void> updateSceneRating(String id, int rating100);
  Future<void> incrementSceneOCounter(String id);
  Future<void> incrementScenePlayCount(String id);
}
