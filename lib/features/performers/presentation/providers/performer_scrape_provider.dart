import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../scenes/domain/models/scraped_scene.dart';
import '../../../scenes/domain/models/scraper.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';
import '../providers/performer_list_provider.dart';

class PerformerScrapeNotifier {
  final Ref ref;
  PerformerScrapeNotifier(this.ref);

  Future<List<Scraper>> listAvailableScrapers() async {
    final repo = ref.read(performerRepositoryProvider);
    //listScrapers is in SceneRepository, so we might need a common scraper repository or just use SceneRepository for now
    // Actually, SceneRepository.listScrapers takes types.
    // For now, let's use SceneRepository since it handles all scraper types.
    final sceneRepo = ref.read(sceneRepositoryProvider);
    return sceneRepo.listScrapers(types: ['PERFORMER']);
  }

  Future<List<ScrapedPerformer>> scrapePerformer({
    String? scraperId,
    String? stashBoxEndpoint,
    String? performerId,
    String? query,
  }) async {
    final repo = ref.read(performerRepositoryProvider);
    return repo.scrapePerformer(
      scraperId: scraperId,
      stashBoxEndpoint: stashBoxEndpoint,
      performerId: performerId,
      query: query,
    );
  }
}

final performerScrapeProvider = Provider<PerformerScrapeNotifier>((ref) {
  return PerformerScrapeNotifier(ref);
});
