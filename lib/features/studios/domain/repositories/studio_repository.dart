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
  Future<Studio> getStudioById(String id);
  Future<void> setStudioFavorite(String id, bool favorite);
}
