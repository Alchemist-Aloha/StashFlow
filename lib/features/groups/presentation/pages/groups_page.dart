import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/group_saved_filter_config.dart';
import '../widgets/group_filter_panel.dart';
import '../providers/group_list_provider.dart';
import '../../domain/entities/group.dart';

enum _GroupSortOption {
  name,
  random,
  sceneCount,
  subGroupCount,
  rating,
  oCounter,
  createdAt,
  updatedAt,
}

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  _GroupSortOption _sortOption = _GroupSortOption.name;
  bool _sortDescending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(groupSortProvider);
      setState(() {
        _sortOption = _sortOptionForKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(groupSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_GroupSortOption option) {
    final sortKey = switch (option) {
      _GroupSortOption.name => 'name',
      _GroupSortOption.random => 'random',
      _GroupSortOption.sceneCount => 'scene_count',
      _GroupSortOption.subGroupCount => 'sub_group_count',
      _GroupSortOption.rating => 'rating100',
      _GroupSortOption.oCounter => 'o_counter',
      _GroupSortOption.createdAt => 'created_at',
      _GroupSortOption.updatedAt => 'updated_at',
    };

    ref
        .read(groupListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  _GroupSortOption _sortOptionForKey(String? sort) {
    return switch (sort) {
      'name' => _GroupSortOption.name,
      'random' => _GroupSortOption.random,
      'scene_count' => _GroupSortOption.sceneCount,
      'sub_group_count' || 'groups_count' => _GroupSortOption.subGroupCount,
      'rating100' || 'rating' => _GroupSortOption.rating,
      'o_counter' => _GroupSortOption.oCounter,
      'created_at' => _GroupSortOption.createdAt,
      'updated_at' => _GroupSortOption.updatedAt,
      _ => _GroupSortOption.name,
    };
  }

  String _sortLabel(_GroupSortOption option) {
    switch (option) {
      case _GroupSortOption.name:
        return context.l10n.sort_name;
      case _GroupSortOption.random:
        return context.l10n.sort_random;
      case _GroupSortOption.sceneCount:
        return context.l10n.sort_scene_count;
      case _GroupSortOption.subGroupCount:
        return context.l10n.sort_groups_count;
      case _GroupSortOption.rating:
        return context.l10n.sort_rating;
      case _GroupSortOption.oCounter:
        return context.l10n.sort_o_counter;
      case _GroupSortOption.createdAt:
        return context.l10n.sort_created_at;
      case _GroupSortOption.updatedAt:
        return context.l10n.sort_updated_at;
    }
  }

  void _showSortPanel() {
    var tempOption = _sortOption;
    var tempDescending = _sortDescending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusExtraLarge),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.common_sort,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempOption = _GroupSortOption.name;
                          tempDescending = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text(
                  context.l10n.common_sort_method,
                  style: context.textTheme.labelLarge,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: _GroupSortOption.values
                          .map(
                            (option) => ChoiceChip(
                              label: Text(_sortLabel(option)),
                              selected: tempOption == option,
                              onSelected: (selected) {
                                if (!selected) return;
                                setModalState(() => tempOption = option);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text(
                  context.l10n.common_direction,
                  style: context.textTheme.labelLarge,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(context.l10n.common_descending),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(context.l10n.common_ascending),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {tempDescending},
                    onSelectionChanged: (value) =>
                        setModalState(() => tempDescending = value.first),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sortOption = tempOption;
                        _sortDescending = tempDescending;
                      });
                      _applyServerSort(_sortOption);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: Text(context.l10n.common_apply_sort),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        _sortOption = tempOption;
                        _sortDescending = tempDescending;
                      });
                      _applyServerSort(_sortOption);
                      await ref
                          .read(groupSortProvider.notifier)
                          .saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(context.l10n.common_save_default),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GroupFilterPanel(),
    );
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(groupSortProvider);
    final currentFilter = ref.read(groupListFilterProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SavedFilterDialog<GroupSavedFilterConfig>(
        searchQuery: ref.read(groupSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        activeFilterCount: _activeFilterCount(),
        defaultSortLabel: 'name',
        saveSuccessMessage: 'Group filter saved to server',
        loadPresets: () => ref.read(savedFilterRepositoryProvider).findAll(
          mode: 'GROUPS',
          fromRaw: (raw) => GroupSavedFilterConfig.fromServerPayload(
            id: raw['id'] as String,
            name: raw['name'] as String,
            findFilter: raw['find_filter'],
            objectFilter: raw['object_filter'],
          ),
        ),
        savePreset: ({required String name, String? existingId}) {
          return ref.read(savedFilterRepositoryProvider).save(
            input: GroupSavedFilterConfig.current(
              id: existingId,
              name: name,
              searchQuery: ref.read(groupSearchQueryProvider),
              sort: sortConfig.sort,
              descending: sortConfig.descending,
              filter: currentFilter,
            ).toSaveInput(),
            fromRaw: (raw) => GroupSavedFilterConfig.fromServerPayload(
              id: raw['id'] as String,
              name: raw['name'] as String,
              findFilter: raw['find_filter'],
              objectFilter: raw['object_filter'],
            ),
          );
        },
        deletePreset: (id) =>
            ref.read(savedFilterRepositoryProvider).delete(id: id),
        onLoad: _applySavedFilterConfig,
      ),
    );
  }

  void _applySavedFilterConfig(GroupSavedFilterConfig config) {
    setState(() {
      _sortOption = _sortOptionForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(groupSearchQueryProvider.notifier).update(config.searchQuery);
    ref.read(groupListProvider.notifier).setFilter(config.filter);
    ref
        .read(groupSortProvider.notifier)
        .setSort(sort: config.sort ?? 'name', descending: config.descending);
    ref.invalidate(groupListProvider);
  }

  int _activeFilterCount() {
    final filter = ref.read(groupListFilterProvider);
    var count = 0;
    if (filter.isMissingField != null) count++;
    if (filter.subGroupCount != null) count++;
    if (filter.sceneCount != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupListProvider);
    final activeFilterCount = _activeFilterCount();
    final scrollController = ref.watch(groupScrollControllerProvider);
    final hasSortOverride =
        _sortOption != _GroupSortOption.name || _sortDescending;

    return ListPageScaffold<Group>(
      title: context.l10n.groups_title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: groupsAsync,
      scrollController: scrollController,
      onRefresh: () => ref.read(groupListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(groupListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(groupListProvider.notifier).setPerPage(pageSize),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.common_sort,
              onPressed: _showSortPanel,
            ),
            if (hasSortOverride)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: context.l10n.common_filter,
              onPressed: _showFilterPanel,
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
          ],
        ),
        IconButton(
          tooltip: context.l10n.common_saved_filters,
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showSavedFilterDialog,
        ),
      ],
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      itemBuilder: (context, group, memCacheWidth, memCacheHeight) => Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: 4,
        ),
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: ListTile(
          leading: const Icon(Icons.group_work),
          onTap: () => context.push('/group/${group.id}'),
          title: Text(
            group.name.isEmpty ? context.l10n.groups_unnamed : group.name,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(context.l10n.common_id(group.id.toString())),
          trailing: group.sceneCount != null
              ? Text(
                  context.l10n.nScenes(group.sceneCount!),
                  style: context.textTheme.bodySmall,
                )
              : null,
        ),
      ),
      loadingItemBuilder: (context, isGrid, index) => Skeletonizer(
        enabled: true,
        effect: const ShimmerEffect(duration: Duration(seconds: 2)),
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: 4,
          ),
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: ListTile(
            leading: const Icon(Icons.group_work),
            title: Text(
              context.l10n.loading,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
