import '../entities/performer.dart';

abstract class PerformerRepository {
  Future<List<Performer>> findPerformers({int? page, int? perPage, String? filter});
  Future<Performer> getPerformerById(String id);
}
