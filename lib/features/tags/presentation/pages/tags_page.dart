import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../providers/tag_list_provider.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../widgets/tag_filter_panel.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/tag.dart';

enum _TagSortOption {
  name,
  random,
  scenesDuration,
  scenesSize,
  galleryCount,
  imageCount,
  performerCount,
  sceneCount,
  groupCount,
  markerCount,
  studioCount,
}

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
          'random' => _TagSortOption.random,
          'scenes_duration' => _TagSortOption.scenesDuration,
          'scenes_size' => _TagSortOption.scenesSize,
          'gallery_count' => _TagSortOption.galleryCount,
          'image_count' => _TagSortOption.imageCount,
          'performer_count' => _TagSortOption.performerCount,
          'scenes_count' => _TagSortOption.sceneCount,
          'group_count' => _TagSortOption.groupCount,
          'marker_count' => _TagSortOption.markerCount,
          'studio_count' => _TagSortOption.studioCount,
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
      _TagSortOption.random => 'random',
      _TagSortOption.scenesDuration => 'scenes_duration',
      _TagSortOption.scenesSize => 'scenes_size',
      _TagSortOption.galleryCount => 'galleries_count',
      _TagSortOption.imageCount => 'images_count',
      _TagSortOption.performerCount => 'performers_count',
      _TagSortOption.sceneCount => 'scenes_count',
      _TagSortOption.groupCount => 'groups_count',
      _TagSortOption.markerCount => 'scene_markers_count',
      _TagSortOption.studioCount => 'studios_count',
    };

    ref
        .read(tagListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  String _sortLabel(_TagSortOption option) {
    switch (option) {
      case _TagSortOption.name:
        return context.l10n.sort_name;
      case _TagSortOption.random:
        return context.l10n.sort_random;
      case _TagSortOption.scenesDuration:
        return context.l10n.sort_scenes_duration;
      case _TagSortOption.scenesSize:
        return context.l10n.sort_scenes_size;
      case _TagSortOption.galleryCount:
        return context.l10n.sort_galleries_count;
      case _TagSortOption.imageCount:
        return context.l10n.sort_images_count;
      case _TagSortOption.performerCount:
        return context.l10n.sort_performers_count;
      case _TagSortOption.sceneCount:
        return context.l10n.sort_scene_count;
      case _TagSortOption.groupCount:
        return context.l10n.sort_groups_count;
      case _TagSortOption.markerCount:
        return context.l10n.sort_marker_count;
      case _TagSortOption.studioCount:
        return context.l10n.sort_studios_count;
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
                      context.l10n.tags_sort_title,
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
                Text(
                  context.l10n.common_sort_method,
                  style: context.textTheme.labelLarge,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
                      // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
                      maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall,
                        ),
                        child: Wrap(
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
                      ),
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
                      await ref.read(tagSortProvider.notifier).saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.tags_sort_saved)),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TagFilterPanel(),
    );
  }

  Future<void> _openRandomTag() async {
    final randomTag = await ref
        .read(tagListProvider.notifier)
        .getRandomTag(useCurrentFilter: true, excludeTagId: _lastRandomTagId);
    if (!mounted) return;

    if (randomTag == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tags_no_random)));
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
      title: context.l10n.nav_tags,
      searchHint: context.l10n.tags_search_hint,
      onSearchChanged: _onSearchChanged,
      provider: tagsAsync,
      scrollController: scrollController,
      imageUrlBuilder: (tag) => tag.imagePath,
      onRefresh: () => ref.read(tagListProvider.notifier).refresh(),
      onFetchNextPage: () => ref.read(tagListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(tagListProvider.notifier).setPerPage(pageSize),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.tags_sort_tooltip,
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
              tooltip: context.l10n.tags_filter_tooltip,
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
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        child: ListTile(
          onTap: () => context.push('/tags/tag/${tag.id}'),
          title: Text(
            tag.name,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            context.l10n.nScenes(tag.sceneCount),
            style: context.textTheme.bodySmall,
          ),
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
          ).colorScheme.primaryContainer.withValues(alpha: 0.1),
          child: ListTile(
            title: Text(
              'Loading',
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text('0', style: context.textTheme.bodySmall),
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
