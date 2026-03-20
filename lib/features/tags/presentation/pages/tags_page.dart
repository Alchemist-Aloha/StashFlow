import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tag_list_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/tag.dart';

enum _TagSortOption { name, sceneCount, imageCount }

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
          'image_count' => _TagSortOption.imageCount,
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
      _TagSortOption.imageCount => 'image_count',
    };

    ref
        .read(tagListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  String _sortLabel(_TagSortOption option) {
    switch (option) {
      case _TagSortOption.name:
        return 'Name';
      case _TagSortOption.sceneCount:
        return 'Scene Count';
      case _TagSortOption.imageCount:
        return 'Image Count';
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
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text('Sort Method', style: context.textTheme.labelLarge),
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
                Text('Direction', style: context.textTheme.labelLarge),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Descending'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Ascending'),
                        icon: Icon(Icons.arrow_upward),
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
                    child: const Text('Apply Sort'),
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
                          const SnackBar(
                            content: Text('Sort preferences saved as default'),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: const Text('Save as Default'),
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
                      'Filter Tags',
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
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SwitchListTile.adaptive(
                  value: tempFavoritesOnly,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Favorites only'),
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
                    child: const Text('Apply Filters'),
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
                          const SnackBar(
                            content:
                                Text('Filter preferences saved as default'),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: const Text('Save as Default'),
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
        const SnackBar(
          content: Text('No tags available for random navigation'),
        ),
      );
      return;
    }

    _lastRandomTagId = randomTag.id;
    context.push('/tag/${randomTag.id}');
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagListProvider);
    final favoritesOnly = ref.watch(tagFavoritesOnlyProvider);
    final hasSortOverride =
        _sortOption != _TagSortOption.name || _sortDescending;

    return ListPageScaffold<Tag>(
      title: 'Tags',
      searchHint: 'Search tags...',
      onSearchChanged: _onSearchChanged,
      provider: tagsAsync,
      onRefresh: () => ref.refresh(tagListProvider.future),
      onFetchNextPage: () => ref.read(tagListProvider.notifier).fetchNextPage(),
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
      itemBuilder: (context, tag) => Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: 4,
        ),
        child: ListTile(
          onTap: () => context.push('/tag/${tag.id}'),
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
      floatingActionButton: tagsAsync.maybeWhen(
        data: (tags) => FloatingActionButton.small(
          onPressed: _openRandomTag,
          tooltip: 'Random tag',
          child: const Icon(Icons.casino_outlined),
        ),
        orElse: () => null,
      ),
    );
  }
}
