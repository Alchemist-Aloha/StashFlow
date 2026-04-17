import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tag_list_provider.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/tag.dart';

enum _TagSortOption { name, sceneCount, lastUpdated, createdAt, random }

class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends ConsumerState<TagsPage> {
  _TagSortOption _sortOption = _TagSortOption.name;
  bool _sortDescending = false;
  String? _lastRandomTagId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(tagSortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
          'name' => _TagSortOption.name,
          'scenes_count' => _TagSortOption.sceneCount,
          'parent_count' => _TagSortOption.name,
          'updated_at' => _TagSortOption.lastUpdated,
          'created_at' => _TagSortOption.createdAt,
          'random' => _TagSortOption.random,
          _ => _TagSortOption.name,
        };
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(tagSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_TagSortOption option) {
    final sortKey = switch (option) {
      _TagSortOption.name => 'name',
      _TagSortOption.sceneCount => 'scenes_count',
      _TagSortOption.lastUpdated => 'updated_at',
      _TagSortOption.createdAt => 'created_at',
      _TagSortOption.random => 'random',
    };

    ref
        .read(tagListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  String _sortLabel(_TagSortOption option) {
    switch (option) {
      case _TagSortOption.name:
        return context.l10n.sort_name;
      case _TagSortOption.sceneCount:
        return context.l10n.sort_scene_count;
      case _TagSortOption.lastUpdated:
        return context.l10n.sort_updated_at;
      case _TagSortOption.createdAt:
        return context.l10n.sort_created_at;
      case _TagSortOption.random:
        return context.l10n.sort_random;
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
                      'Sort Tags',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempOption = _TagSortOption.name;
                          tempDescending = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text(context.l10n.common_sort_method, style: context.textTheme.labelLarge),
                const SizedBox(height: AppTheme.spacingSmall),
                Wrap(
                  spacing: AppTheme.spacingSmall,
                  runSpacing: AppTheme.spacingSmall,
                  children: _TagSortOption.values
                      .map(
                        (option) => ChoiceChip(
                          label: Text(_sortLabel(option)),
                          selected: tempOption == option,
                          onSelected: (selected) {
                            if (!selected) return;
                            setModalState(() {
                              tempOption = option;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text(context.l10n.common_direction, style: context.textTheme.labelLarge),
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
                  child: OutlinedButton(
                    onPressed: () async {
                      setState(() {
                        _sortOption = tempOption;
                        _sortDescending = tempDescending;
                      });
                      _applyServerSort(_sortOption);
                      await ref.read(tagSortProvider.notifier).saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.tags_sort_saved),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: Text(context.l10n.common_save_default),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterPanel() {
    final currentFavoritesOnly = ref.read(tagFavoritesOnlyProvider);
    var tempFavoritesOnly = currentFavoritesOnly;

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
                      context.l10n.tags_filter_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempFavoritesOnly = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SwitchListTile.adaptive(
                  value: tempFavoritesOnly,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.common_favorites_only),
                  onChanged: (value) {
                    setModalState(() => tempFavoritesOnly = value);
                  },
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(tagListProvider.notifier)
                          .setFavoritesOnly(tempFavoritesOnly);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: Text(context.l10n.common_apply_filters),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      ref
                          .read(tagListProvider.notifier)
                          .setFavoritesOnly(tempFavoritesOnly);
                      await ref
                          .read(tagFavoritesOnlyProvider.notifier)
                          .saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.tags_filter_saved,
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: Text(context.l10n.common_save_default),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRandomTag() async {
    final randomTag = await ref
        .read(tagListProvider.notifier)
        .getRandomTag(useCurrentFilter: true, excludeTagId: _lastRandomTagId);
    if (!mounted) return;

    if (randomTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.tags_no_random),
        ),
      );
      return;
    }

    _lastRandomTagId = randomTag.id;
    context.push('/tags/tag/${randomTag.id}');
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagListProvider);
    final favoritesOnly = ref.watch(tagFavoritesOnlyProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrollController = ref.watch(tagScrollControllerProvider);
    final hasSortOverride =
        _sortOption != _TagSortOption.name || _sortDescending;

    return ListPageScaffold<Tag>(
      title: 'Tags',
      searchHint: 'Search tags...',
      onSearchChanged: _onSearchChanged,
      provider: tagsAsync,
      scrollController: scrollController,
      imageUrlBuilder: (tag) => tag.imagePath,
      onRefresh: () => ref.read(tagListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(tagListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(tagListProvider.notifier).setPerPage(pageSize),
      actions: [

        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort options',
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
              tooltip: 'Filter options',
              onPressed: _showFilterPanel,
            ),
            if (favoritesOnly)
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
      ],
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      itemBuilder: (context, tag, memCacheWidth, memCacheHeight) => Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: 4,
        ),
        child: ListTile(
          onTap: () => context.push('/tags/tag/${tag.id}'),
          title: Text(
            tag.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            '${tag.sceneCount} scenes',
            style: context.textTheme.bodySmall,
          ),
        ),
      ),
      floatingActionButton: randomNavigationEnabled
          ? tagsAsync.maybeWhen(
              data: (tags) => FloatingActionButton.small(
                onPressed: _openRandomTag,
                tooltip: context.l10n.random_tag,
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
