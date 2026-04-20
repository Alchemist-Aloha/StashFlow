import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../scenes/domain/models/scraped_scene.dart';
import '../../../scenes/domain/models/scraper.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';
import '../providers/performer_list_provider.dart';

class PerformerScrapeNotifier {
  final Ref ref;
  PerformerScrapeNotifier(this.ref);

  Future<List<Scraper>> listAvailableScrapers() async {
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

  Future<ScrapedPerformer?> scrapePerformerURL(String url) async {
    final repo = ref.read(performerRepositoryProvider);
    return repo.scrapePerformerURL(url);
  }

  Future<void> updatePerformer({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    final repo = ref.read(performerRepositoryProvider);
    await repo.updatePerformer(id: id, input: input);
  }
}

final performerScrapeProvider = Provider<PerformerScrapeNotifier>((ref) {
  return PerformerScrapeNotifier(ref);
});
