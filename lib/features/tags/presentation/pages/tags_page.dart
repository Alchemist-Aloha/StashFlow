import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../providers/tag_list_provider.dart';
import '../providers/tag_random_navigation_provider.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../widgets/tag_filter_panel.dart';

import '../../../../core/presentation/providers/list_scroll_controller_provider.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/tag_saved_filter_config.dart';

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
      if (!mounted) return;
      final sortConfig = ref.read(tagSortProvider);
      setState(() {
        _sortOption = _sortOptionForKey(sortConfig.sort);
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

  _TagSortOption _sortOptionForKey(String? sort) {
    return switch (sort) {
      'name' => _TagSortOption.name,
      'random' => _TagSortOption.random,
      'scenes_duration' => _TagSortOption.scenesDuration,
      'scenes_size' => _TagSortOption.scenesSize,
      'gallery_count' || 'galleries_count' => _TagSortOption.galleryCount,
      'image_count' || 'images_count' => _TagSortOption.imageCount,
      'performer_count' || 'performers_count' => _TagSortOption.performerCount,
      'scenes_count' => _TagSortOption.sceneCount,
      'group_count' || 'groups_count' => _TagSortOption.groupCount,
      'marker_count' || 'scene_markers_count' => _TagSortOption.markerCount,
      'studio_count' || 'studios_count' => _TagSortOption.studioCount,
      _ => _TagSortOption.name,
    };
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
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => ListSortBottomSheet<_TagSortOption>(
        title: context.l10n.tags_sort_title,
        options: _TagSortOption.values,
        initialOption: _sortOption,
        initialDescending: _sortDescending,
        resetOption: _TagSortOption.name,
        resetDescending: false,
        optionLabel: _sortLabel,
        onApply: (option, descending) {
          setState(() {
            _sortOption = option;
            _sortDescending = descending;
          });
          _applyServerSort(option);
        },
        onSaveDefault: () => ref.read(tagSortProvider.notifier).saveAsDefault(),
        saveDefaultSuccessMessage: context.l10n.tags_sort_saved,
      ),
    );
  }

  void _showFilterPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => const TagFilterPanel(),
    );
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(tagSortProvider);
    final favoritesOnly = ref.read(tagFavoritesOnlyProvider);

    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => SavedFilterDialog<TagSavedFilterConfig>(
        searchQuery: ref.read(tagSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        activeFilterCount: favoritesOnly ? 1 : 0,
        defaultSortLabel: 'name',
        saveSuccessMessage: context.l10n.saved_item('Tag filter'),
        loadPresets: () => ref
            .read(savedFilterRepositoryProvider)
            .findAll(
              mode: 'TAGS',
              fromRaw: (raw) => TagSavedFilterConfig.fromServerPayload(
                id: raw['id'] as String,
                name: raw['name'] as String,
                findFilter: raw['find_filter'],
                objectFilter: raw['object_filter'],
              ),
            ),
        savePreset: ({required String name, String? existingId}) {
          return ref
              .read(savedFilterRepositoryProvider)
              .save(
                input: TagSavedFilterConfig(
                  id: existingId,
                  name: name,
                  searchQuery: ref.read(tagSearchQueryProvider),
                  sort: sortConfig.sort,
                  descending: sortConfig.descending,
                  favorite: ref.read(tagFavoritesOnlyProvider),
                ).toSaveInput(),
                fromRaw: (raw) => TagSavedFilterConfig.fromServerPayload(
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

  void _applySavedFilterConfig(TagSavedFilterConfig config) {
    setState(() {
      _sortOption = _sortOptionForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(tagSearchQueryProvider.notifier).update(config.searchQuery);
    ref.read(tagListProvider.notifier).setFavoritesOnly(config.favorite);
    ref
        .read(tagSortProvider.notifier)
        .setSort(sort: config.sort ?? 'name', descending: config.descending);
    ref.invalidate(tagListProvider);
  }

  Future<void> _openRandomTag() async {
    final randomTag = await ref
        .read(tagRandomNavigationControllerProvider)
        .getRandomTag(excludeTagId: _lastRandomTagId);
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
    final scrollController = ref.watch(
      listScrollControllerProvider(ListScrollTarget.tag),
    );
    final hasSortOverride =
        _sortOption != _TagSortOption.name || _sortDescending;

    return ListPageScaffold<Tag>(
      title: context.l10n.nav_tags,
      searchHint: context.l10n.tags_search_hint,
      onSearchChanged: _onSearchChanged,
      provider: tagsAsync,
      scrollController: scrollController,
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
        IconButton(
          tooltip: context.l10n.common_saved_filters,
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showSavedFilterDialog,
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
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: ListTile(
            title: Text(
              context.l10n.loading,
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
