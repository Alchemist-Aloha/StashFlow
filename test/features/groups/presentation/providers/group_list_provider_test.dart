import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';
import 'package:stash_app_flutter/features/groups/data/repositories/graphql_group_repository.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';

class RecordingGraphQLGroupRepository implements GraphQLGroupRepository {
  GroupFilter? lastGroupFilter;
  String? lastFilter;
  String? lastSort;
  bool? lastDescending;

  @override
  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GroupFilter? groupFilter,
  }) async {
    lastFilter = filter;
    lastSort = sort;
    lastDescending = descending;
    lastGroupFilter = groupFilter;
    return const [];
  }

  @override
  Future<Group> getGroupById(String id, {bool refresh = false}) async {
    throw UnimplementedError();
  }
}

void main() {
  test('GroupList passes structured group filters to repository', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = RecordingGraphQLGroupRepository();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        groupRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(groupSearchQueryProvider.notifier).update('query');
    container
        .read(groupListFilterProvider.notifier)
        .set(
          const GroupFilter(
            isMissingField: 'director',
            subGroupCount: IntCriterion(
              value: 1,
              modifier: CriterionModifier.greaterThan,
            ),
          ),
        );
    container
        .read(groupSortProvider.notifier)
        .setSort(sort: 'sub_group_count', descending: true);

    await container.read(groupListProvider.future);

    expect(repository.lastFilter, 'query');
    expect(repository.lastSort, 'sub_group_count');
    expect(repository.lastDescending, isTrue);
    expect(repository.lastGroupFilter?.isMissingField, 'director');
    expect(repository.lastGroupFilter?.subGroupCount?.value, 1);
  });
}
