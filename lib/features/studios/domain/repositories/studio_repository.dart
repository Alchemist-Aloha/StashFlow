import '../../domain/entities/studio.dart';

abstract class StudioRepository {
  Future<List<Studio>> findStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  });
  Future<Studio> getStudioById(String id);
}
