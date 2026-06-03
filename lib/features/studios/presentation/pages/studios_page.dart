import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/studio_filter.dart';
import '../providers/studio_list_provider.dart';
import '../widgets/studio_filter_panel.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/studio.dart';
import '../../domain/entities/studio_saved_filter_config.dart';

enum _StudioSortOption {
  name,
  tagCount,
  random,
  rating,
  scenesDuration,
  scenesSize,
  latestScene,
  galleryCount,
  imageCount,
  sceneCount,
  childCount,
}

class StudiosPage extends ConsumerStatefulWidget {
  const StudiosPage({super.key});

  @override
  ConsumerState<StudiosPage> createState() => _StudiosPageState();
}

class _StudiosPageState extends ConsumerState<StudiosPage> {
  _StudioSortOption _sortOption = _StudioSortOption.name;
  bool _sortDescending = false;
  String? _lastRandomStudioId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(studioSortProvider);
      setState(() {
        _sortOption = _sortOptionForKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(studioSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_StudioSortOption option) {
    final sortKey = switch (option) {
      _StudioSortOption.name => 'name',
      _StudioSortOption.tagCount => 'tag_count',
      _StudioSortOption.random => 'random',
      _StudioSortOption.rating => 'rating',
      _StudioSortOption.scenesDuration => 'scenes_duration',
      _StudioSortOption.scenesSize => 'scenes_size',
      _StudioSortOption.latestScene => 'latest_scene',
      _StudioSortOption.galleryCount => 'gallery_count',
      _StudioSortOption.imageCount => 'image_count',
      _StudioSortOption.sceneCount => 'scenes_count',
      _StudioSortOption.childCount => 'child_count',
    };

    ref
        .read(studioListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  _StudioSortOption _sortOptionForKey(String? sort) {
    return switch (sort) {
      'name' => _StudioSortOption.name,
      'tag_count' => _StudioSortOption.tagCount,
      'random' => _StudioSortOption.random,
      'rating' => _StudioSortOption.rating,
      'scenes_duration' => _StudioSortOption.scenesDuration,
      'scenes_size' => _StudioSortOption.scenesSize,
      'latest_scene' => _StudioSortOption.latestScene,
      'gallery_count' => _StudioSortOption.galleryCount,
      'image_count' => _StudioSortOption.imageCount,
      'scenes_count' => _StudioSortOption.sceneCount,
      'child_count' => _StudioSortOption.childCount,
      _ => _StudioSortOption.name,
    };
  }

  String _sortLabel(_StudioSortOption option) {
    switch (option) {
      case _StudioSortOption.name:
        return context.l10n.sort_name;
      case _StudioSortOption.tagCount:
        return context.l10n.sort_tag_count;
      case _StudioSortOption.random:
        return context.l10n.sort_random;
      case _StudioSortOption.rating:
        return context.l10n.sort_rating;
      case _StudioSortOption.scenesDuration:
        return context.l10n.sort_scenes_duration;
      case _StudioSortOption.scenesSize:
        return context.l10n.sort_scenes_size;
      case _StudioSortOption.latestScene:
        return context.l10n.sort_latest_scene;
      case _StudioSortOption.galleryCount:
        return context.l10n.sort_galleries_count;
      case _StudioSortOption.imageCount:
        return context.l10n.sort_images_count;
      case _StudioSortOption.sceneCount:
        return context.l10n.sort_scene_count;
      case _StudioSortOption.childCount:
        return context.l10n.sort_child_count;
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
            padding: EdgeInsets.all(context.dimensions.spacingMedium),
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
                      context.l10n.studios_sort_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempOption = _StudioSortOption.name;
                          tempDescending = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
                SizedBox(height: context.dimensions.spacingMedium),
                Text(
                  context.l10n.common_sort_method,
                  style: context.textTheme.labelLarge,
                ),
                SizedBox(height: context.dimensions.spacingSmall),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
                      // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
                      maxHeight: MediaQuery.sizeOf(context).height * 0.22,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          vertical: context.dimensions.spacingSmall,
                        ),
                        child: Wrap(
                          spacing: context.dimensions.spacingSmall,
                          runSpacing: context.dimensions.spacingSmall,
                          children: _StudioSortOption.values
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
                SizedBox(height: context.dimensions.spacingMedium),
                Text(
                  context.l10n.common_direction,
                  style: context.textTheme.labelLarge,
                ),
                SizedBox(height: context.dimensions.spacingSmall),
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
                SizedBox(height: context.dimensions.spacingLarge),
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
                      padding: EdgeInsets.symmetric(
                        vertical: context.dimensions.spacingMedium,
                      ),
                    ),
                    child: Text(context.l10n.common_apply_sort),
                  ),
                ),
                SizedBox(height: context.dimensions.spacingSmall),
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
                          .read(studioSortProvider.notifier)
                          .saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.studios_sort_saved),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: context.dimensions.spacingMedium,
                      ),
                    ),
                    child: Text(context.l10n.common_save_default),
                  ),
                ),
                SizedBox(height: context.dimensions.spacingMedium),
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
      builder: (context) => const StudioFilterPanel(),
    );
  }

  int _activeFilterCount(StudioFilter filter) {
    return filter.toJson().values.where((value) => value != null).length;
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(studioSortProvider);
    final filter = ref.read(studioFilterStateProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SavedFilterDialog<StudioSavedFilterConfig>(
        searchQuery: ref.read(studioSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        activeFilterCount: _activeFilterCount(filter),
        defaultSortLabel: 'name',
        saveSuccessMessage: 'Studio filter saved to server',
        loadPresets: () => ref
            .read(savedFilterRepositoryProvider)
            .findAll(
              mode: 'STUDIOS',
              fromRaw: (raw) => StudioSavedFilterConfig.fromServerPayload(
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
                input: StudioSavedFilterConfig.current(
                  id: existingId,
                  name: name,
                  searchQuery: ref.read(studioSearchQueryProvider),
                  sort: sortConfig.sort,
                  descending: sortConfig.descending,
                  filter: ref.read(studioFilterStateProvider),
                ).toSaveInput(),
                fromRaw: (raw) => StudioSavedFilterConfig.fromServerPayload(
                  id: raw['id'] as String,
                  name: raw['name'] as String,
                  findFilter: raw['find_filter'],
                  objectFilter: raw['object_filter'],
                ),
              );
        },
        onLoad: _applySavedFilterConfig,
      ),
    );
  }

  void _applySavedFilterConfig(StudioSavedFilterConfig config) {
    setState(() {
      _sortOption = _sortOptionForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(studioSearchQueryProvider.notifier).update(config.searchQuery);
    ref.read(studioFilterStateProvider.notifier).update(config.filter);
    ref
        .read(studioSortProvider.notifier)
        .setSort(sort: config.sort ?? 'name', descending: config.descending);
    ref.invalidate(studioListProvider);
  }

  Future<void> _openRandomStudio() async {
    final randomStudio = await ref
        .read(studioListProvider.notifier)
        .getRandomStudio(
          useCurrentFilter: true,
          excludeStudioId: _lastRandomStudioId,
        );
    if (!mounted) return;

    if (randomStudio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.studios_no_random)));
      return;
    }

    _lastRandomStudioId = randomStudio.id;
    context.push('/studios/studio/${randomStudio.id}');
  }

  @override
  Widget build(BuildContext context) {
    final studiosAsync = ref.watch(studioListProvider);
    final filterState = ref.watch(studioFilterStateProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    final scrollController = ref.watch(studioScrollControllerProvider);
    final hasSortOverride =
        _sortOption != _StudioSortOption.name || _sortDescending;

    return ListPageScaffold<Studio>(
      title: context.l10n.studios_title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: studiosAsync,
      scrollController: scrollController,
      imageUrlBuilder: (studio) => studio.imagePath,
      onRefresh: () => ref.read(studioListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(studioListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(studioListProvider.notifier).setPerPage(pageSize),
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
            if (filterState != StudioFilter.empty())
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
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      itemBuilder: (context, studio, memCacheWidth, memCacheHeight) => Card(
        margin: EdgeInsets.symmetric(
          horizontal: context.dimensions.spacingMedium,
          vertical: 4,
        ),
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: ListTile(
          onTap: () => context.push('/studios/studio/${studio.id}'),
          title: Text(
            studio.name,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            context.l10n.nScenes(studio.sceneCount),
            style: context.textTheme.bodySmall,
          ),
        ),
      ),
      loadingItemBuilder: (context, isGrid, index) => Skeletonizer(
        enabled: true,
        effect: const ShimmerEffect(duration: Duration(seconds: 2)),
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: context.dimensions.spacingMedium,
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
          ? studiosAsync.maybeWhen(
              data: (studios) => FloatingActionButton.small(
                onPressed: _openRandomStudio,
                tooltip: context.l10n.random_studio,
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
