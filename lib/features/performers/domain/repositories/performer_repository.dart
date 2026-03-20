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
  Future<Performer> getPerformerById(String id);
  Future<void> setPerformerFavorite(String id, bool favorite);
}
