import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/group_list_provider.dart';
import '../../domain/entities/group.dart';

enum _GroupSortOption { name }

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  _GroupSortOption _sortOption = _GroupSortOption.name;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(groupSortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
          'name' => _GroupSortOption.name,
          _ => _GroupSortOption.name,
        };
      });
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(groupSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_GroupSortOption option) {
    switch (option) {
      case _GroupSortOption.name:
        ref
            .read(groupListProvider.notifier)
            .setSort(sort: 'name', descending: false);
        break;
    }
  }

  Widget _buildSortBar() {
    final options = [(_GroupSortOption.name, context.l10n.common_name)];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option.$2),
              selected: _sortOption == option.$1,
              onSelected: (selected) {
                if (!selected) return;
                setState(() => _sortOption = option.$1);
                _applyServerSort(option.$1);
              },
            ),
            const SizedBox(width: AppTheme.spacingSmall),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupListProvider);

    return ListPageScaffold<Group>(
      title: context.l10n.groups_title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: groupsAsync,
      onRefresh: () => ref.read(groupListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(groupListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      itemBuilder: (context, group, memCacheWidth, memCacheHeight) => Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: 4,
        ),
        child: ListTile(
          leading: const Icon(Icons.group_work),
          title: Text(
            group.name.isEmpty ? context.l10n.groups_unnamed : group.name,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(context.l10n.common_id(group.id.toString())),
          onTap: () => context.push('/group/${group.id}'),
        ),
      ),
    );
  }
}
