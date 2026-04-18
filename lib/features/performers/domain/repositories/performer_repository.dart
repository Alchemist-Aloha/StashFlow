import '../../../scenes/domain/models/scraped_scene.dart';
import '../entities/performer.dart';

abstract class PerformerRepository {
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool favoritesOnly = false,
    List<String>? genders,
  });
  Future<Performer> getPerformerById(String id, {bool refresh = false});
  Future<void> setPerformerFavorite(String id, bool favorite);
  Future<List<ScrapedPerformer>> scrapePerformer({
    String? scraperId,
    String? stashBoxEndpoint,
    String? performerId,
    String? query,
  });
  Future<void> updatePerformer({
    required String id,
    required Map<String, dynamic> input,
  });
}
