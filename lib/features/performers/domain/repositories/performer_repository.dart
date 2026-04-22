import '../entities/performer.dart';

import '../entities/performer_filter.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_performer.dart';

abstract class PerformerRepository {
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    PerformerFilter? performerFilter,
    @Deprecated('Use performerFilter instead') bool favoritesOnly = false,
    @Deprecated('Use performerFilter instead') List<String>? genders,
  });
  Future<Performer> getPerformerById(String id, {bool refresh = false});
  Future<void> setPerformerFavorite(String id, bool favorite);
  Future<List<ScrapedPerformer>> scrapePerformer({
    String? scraperId,
    String? stashBoxEndpoint,
    String? performerId,
    String? query,
  });
  Future<ScrapedPerformer?> scrapePerformerURL(String url);
  Future<void> updatePerformer({
    required String id,
    required Map<String, dynamic> input,
  });
}
