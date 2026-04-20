import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../scenes/domain/models/scraped_scene.dart';
import '../../../scenes/domain/models/scraper.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';
import '../providers/studio_list_provider.dart';

class StudioScrapeNotifier {
  final Ref ref;
  StudioScrapeNotifier(this.ref);

  Future<List<Scraper>> listAvailableScrapers() async {
    final sceneRepo = ref.read(sceneRepositoryProvider);
    return sceneRepo.listScrapers(types: ['STUDIO']);
  }

  Future<List<ScrapedStudio>> scrapeStudio({
    String? scraperId,
    String? stashBoxEndpoint,
    String? studioId,
    String? query,
  }) async {
    final repo = ref.read(studioRepositoryProvider);
    return repo.scrapeStudio(
      scraperId: scraperId,
      stashBoxEndpoint: stashBoxEndpoint,
      studioId: studioId,
      query: query,
    );
  }

  Future<ScrapedStudio?> scrapeStudioURL(String url) async {
    final repo = ref.read(studioRepositoryProvider);
    return repo.scrapeStudioURL(url);
  }

  Future<void> updateStudio({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    final repo = ref.read(studioRepositoryProvider);
    await repo.updateStudio(id: id, input: input);
  }
}

final studioScrapeProvider = Provider<StudioScrapeNotifier>((ref) {
  return StudioScrapeNotifier(ref);
});
