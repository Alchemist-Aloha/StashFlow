import '../entities/group.dart';

abstract class GroupRepository {
  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  });
}
