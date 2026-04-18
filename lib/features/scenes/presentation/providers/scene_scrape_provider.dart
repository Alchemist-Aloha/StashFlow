import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/scraped_scene.dart';
import '../../domain/models/scraper.dart';
import 'scene_list_provider.dart';

class SceneScrapeNotifier {
  final Ref ref;
  SceneScrapeNotifier(this.ref);

  Future<List<Scraper>> listAvailableScrapers({
    required List<String> types,
  }) async {
    final repo = ref.read(sceneRepositoryProvider);
    return repo.listScrapers(types: types);
  }

  Future<List<ScrapedScene>> scrapeScene({
    String? scraperId,
    String? stashBoxEndpoint,
    String? sceneId,
    String? query,
  }) async {
    final repo = ref.read(sceneRepositoryProvider);
    return repo.scrapeSingleScene(
      scraperId: scraperId,
      stashBoxEndpoint: stashBoxEndpoint,
      sceneId: sceneId,
      query: query,
    );
  }

  Future<ScrapedScene?> scrapeSceneURL(String url) async {
    final repo = ref.read(sceneRepositoryProvider);
    return repo.scrapeSceneURL(url);
  }

  Future<void> generatePhash(String sceneId) async {
    final repo = ref.read(sceneRepositoryProvider);
    await repo.generatePhash(sceneId);
  }

  Future<void> saveScraped({
    required String sceneId,
    required ScrapedScene scraped,
    bool merge = false,
    List<String>? performerIds,
    List<String>? tagIds,
  }) async {
    final repo = ref.read(sceneRepositoryProvider);
    await repo.saveScrapedScene(
      sceneId: sceneId,
      scraped: scraped,
      mergeValues: merge,
      performerIds: performerIds,
      tagIds: tagIds,
      studioId: scraped.studioId,
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> queries,
  ) async {
    final repo = ref.read(sceneRepositoryProvider);
    return repo.findPerformerCandidates(queries);
  }

  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async {
    final repo = ref.read(sceneRepositoryProvider);
    return repo.findTagCandidates(tags);
  }
}

final sceneScrapeProvider = Provider<SceneScrapeNotifier>((ref) {
  return SceneScrapeNotifier(ref);
});

final availableScrapersProvider =
    FutureProvider.family<List<Scraper>, List<String>>((ref, types) async {
      return ref.read(sceneScrapeProvider).listAvailableScrapers(types: types);
    });
