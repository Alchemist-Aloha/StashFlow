import '../../domain/entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  });
  Future<Tag> getTagById(String id);
}
