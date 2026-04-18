import '../../../scenes/domain/models/scraped_scene.dart';
import '../../domain/entities/studio.dart';

abstract class StudioRepository {
  Future<List<Studio>> findStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
  });
  Future<Studio> getStudioById(String id, {bool refresh = false});
  Future<void> setStudioFavorite(String id, bool favorite);
  Future<List<ScrapedStudio>> scrapeStudio({
    String? scraperId,
    String? stashBoxEndpoint,
    String? studioId,
    String? query,
  });
}
