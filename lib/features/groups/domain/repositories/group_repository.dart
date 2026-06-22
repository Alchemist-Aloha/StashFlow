import '../entities/group.dart';
import '../entities/group_filter.dart';

abstract class GroupRepository {
  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GroupFilter? groupFilter,
  });
  Future<Group> getGroupById(String id, {bool refresh = false});
}
