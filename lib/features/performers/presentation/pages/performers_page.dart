import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/performer.dart';
import '../../domain/entities/performer_filter.dart';
import '../providers/performer_list_provider.dart';
import '../providers/performer_random_navigation_provider.dart';
import '../widgets/performer_filter_panel.dart';
import '../widgets/performer_card.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/providers/list_scroll_controller_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/performer_saved_filter_config.dart';

enum _PerformerSortOption {
  name,
  height,
  birthdate,
  tagCount,
  random,
  rating,
  penisLength,
  playCount,
  lastPlayedAt,
  latestScene,
  careerStart,
  careerEnd,
  weight,
  measurements,
  scenesDuration,
  scenesSize,
  sceneCount,
  imageCount,
  galleryCount,
  oCounter,
  lastOAt,
  createdAt,
}

class PerformersPage extends ConsumerStatefulWidget {
  const PerformersPage({super.key});

  @override
  ConsumerState<PerformersPage> createState() => _PerformersPageState();
}

class _PerformersPageState extends ConsumerState<PerformersPage> {
  _PerformerSortOption _sortOption = _PerformerSortOption.name;
  bool _sortDescending = false;
  String? _lastRandomPerformerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(performerSortProvider);
      setState(() {
        _sortOption = _sortOptionForKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(performerSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_PerformerSortOption option) {
    final sortKey = switch (option) {
      _PerformerSortOption.name => 'name',
      _PerformerSortOption.height => 'height',
      _PerformerSortOption.birthdate => 'birthdate',
      _PerformerSortOption.tagCount => 'tag_count',
      _PerformerSortOption.random => 'random',
      _PerformerSortOption.rating => 'rating',
      _PerformerSortOption.penisLength => 'penis_length',
      _PerformerSortOption.playCount => 'play_count',
      _PerformerSortOption.lastPlayedAt => 'last_played_at',
      _PerformerSortOption.latestScene => 'latest_scene',
      _PerformerSortOption.careerStart => 'career_start',
      _PerformerSortOption.careerEnd => 'career_end',
      _PerformerSortOption.weight => 'weight',
      _PerformerSortOption.measurements => 'measurements',
      _PerformerSortOption.scenesDuration => 'scenes_duration',
      _PerformerSortOption.scenesSize => 'scenes_size',
      _PerformerSortOption.sceneCount => 'scenes_count',
      _PerformerSortOption.imageCount => 'images_count',
      _PerformerSortOption.galleryCount => 'galleries_count',
      _PerformerSortOption.oCounter => 'o_counter',
      _PerformerSortOption.lastOAt => 'last_o_at',
      _PerformerSortOption.createdAt => 'created_at',
    };

    ref
        .read(performerListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  _PerformerSortOption _sortOptionForKey(String? sort) {
    return switch (sort) {
      'name' => _PerformerSortOption.name,
      'height' => _PerformerSortOption.height,
      'birthdate' => _PerformerSortOption.birthdate,
      'tag_count' => _PerformerSortOption.tagCount,
      'random' => _PerformerSortOption.random,
      'rating' => _PerformerSortOption.rating,
      'penis_length' => _PerformerSortOption.penisLength,
      'play_count' => _PerformerSortOption.playCount,
      'last_played_at' => _PerformerSortOption.lastPlayedAt,
      'latest_scene' => _PerformerSortOption.latestScene,
      'career_start' => _PerformerSortOption.careerStart,
      'career_end' => _PerformerSortOption.careerEnd,
      'weight' => _PerformerSortOption.weight,
      'measurements' => _PerformerSortOption.measurements,
      'scenes_duration' => _PerformerSortOption.scenesDuration,
      'scenes_size' => _PerformerSortOption.scenesSize,
      'scenes_count' => _PerformerSortOption.sceneCount,
      'images_count' => _PerformerSortOption.imageCount,
      'galleries_count' => _PerformerSortOption.galleryCount,
      'o_counter' => _PerformerSortOption.oCounter,
      'last_o_at' => _PerformerSortOption.lastOAt,
      'created_at' => _PerformerSortOption.createdAt,
      _ => _PerformerSortOption.name,
    };
  }

  String _sortLabel(_PerformerSortOption option) {
    switch (option) {
      case _PerformerSortOption.name:
        return context.l10n.sort_name;
      case _PerformerSortOption.height:
        return context.l10n.sort_height;
      case _PerformerSortOption.birthdate:
        return context.l10n.sort_birthdate;
      case _PerformerSortOption.tagCount:
        return context.l10n.sort_tag_count;
      case _PerformerSortOption.random:
        return context.l10n.sort_random;
      case _PerformerSortOption.rating:
        return context.l10n.sort_rating;
      case _PerformerSortOption.penisLength:
        return context.l10n.sort_penis_length;
      case _PerformerSortOption.playCount:
        return context.l10n.sort_play_count;
      case _PerformerSortOption.lastPlayedAt:
        return context.l10n.sort_last_played_at;
      case _PerformerSortOption.latestScene:
        return context.l10n.sort_latest_scene;
      case _PerformerSortOption.careerStart:
        return context.l10n.sort_career_start;
      case _PerformerSortOption.careerEnd:
        return context.l10n.sort_career_end;
      case _PerformerSortOption.weight:
        return context.l10n.sort_weight;
      case _PerformerSortOption.measurements:
        return context.l10n.sort_measurements;
      case _PerformerSortOption.scenesDuration:
        return context.l10n.sort_scenes_duration;
      case _PerformerSortOption.scenesSize:
        return context.l10n.sort_scenes_size;
      case _PerformerSortOption.sceneCount:
        return context.l10n.sort_scene_count;
      case _PerformerSortOption.imageCount:
        return context.l10n.sort_images_count;
      case _PerformerSortOption.galleryCount:
        return context.l10n.sort_galleries_count;
      case _PerformerSortOption.oCounter:
        return context.l10n.sort_o_counter;
      case _PerformerSortOption.lastOAt:
        return context.l10n.sort_last_o_at;
      case _PerformerSortOption.createdAt:
        return context.l10n.sort_created_at;
    }
  }

  Future<void> _openRandomPerformer() async {
    final random = await ref
        .read(performerRandomNavigationControllerProvider)
        .getRandomPerformer(excludePerformerId: _lastRandomPerformerId);
    if (!mounted) return;

    if (random == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.performers_no_random)),
      );
      return;
    }

    _lastRandomPerformerId = random.id;
    context.push('/performers/performer/${random.id}');
  }

  void _showSortPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => ListSortBottomSheet<_PerformerSortOption>(
        title: context.l10n.performers_sort_title,
        options: _PerformerSortOption.values,
        initialOption: _sortOption,
        initialDescending: _sortDescending,
        resetOption: _PerformerSortOption.name,
        resetDescending: false,
        optionLabel: _sortLabel,
        onApply: (option, descending) {
          setState(() {
            _sortOption = option;
            _sortDescending = descending;
          });
          _applyServerSort(option);
        },
        onSaveDefault: () =>
            ref.read(performerSortProvider.notifier).saveAsDefault(),
        saveDefaultSuccessMessage: context.l10n.tags_sort_saved,
      ),
    );
  }

  void _showFilterPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => const PerformerFilterPanel(),
    );
  }

  int _activeFilterCount(PerformerFilter filter) {
    return activeFilterCount(filter.toJson());
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(performerSortProvider);
    final filter = ref.read(performerFilterStateProvider);

    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => SavedFilterDialog<PerformerSavedFilterConfig>(
        searchQuery: ref.read(performerSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        activeFilterCount: _activeFilterCount(filter),
        defaultSortLabel: 'name',
        saveSuccessMessage: context.l10n.saved_item('Performer filter'),
        loadPresets: () => ref
            .read(savedFilterRepositoryProvider)
            .findAll(
              mode: 'PERFORMERS',
              fromRaw: (raw) => PerformerSavedFilterConfig.fromServerPayload(
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
                input: PerformerSavedFilterConfig(
                  id: existingId,
                  name: name,
                  searchQuery: ref.read(performerSearchQueryProvider),
                  sort: sortConfig.sort,
                  descending: sortConfig.descending,
                  filter: ref.read(performerFilterStateProvider),
                ).toSaveInput(),
                fromRaw: (raw) => PerformerSavedFilterConfig.fromServerPayload(
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

  void _applySavedFilterConfig(PerformerSavedFilterConfig config) {
    setState(() {
      _sortOption = _sortOptionForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(performerSearchQueryProvider.notifier).update(config.searchQuery);
    ref.read(performerFilterStateProvider.notifier).update(config.filter);
    ref
        .read(performerSortProvider.notifier)
        .setSort(sort: config.sort ?? 'name', descending: config.descending);
    ref.invalidate(performerListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final performersAsync = ref.watch(performerListProvider);
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.performer),
    );
    final filterState = ref.watch(performerFilterStateProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrollController = ref.watch(
      listScrollControllerProvider(ListScrollTarget.performer),
    );
    final hasSortOverride =
        _sortOption != _PerformerSortOption.name || _sortDescending;

    return ListPageScaffold<Performer>(
      title: context.l10n.performers_title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: performersAsync,
      scrollController: scrollController,
      onRefresh: () => ref.read(performerListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(performerListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(performerListProvider.notifier).setPerPage(pageSize),
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
            if (filterState != PerformerFilter.empty())
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns ?? 3,
        crossAxisSpacing: context.dimensions.spacingSmall,
        mainAxisSpacing: context.dimensions.spacingSmall,
        childAspectRatio: 0.56,
      ),
      mobileCrossAxisCount: gridColumns ?? 3,
      tabletCrossAxisCount: gridColumns ?? 5,
      itemBuilder: (context, performer, memCacheWidth, memCacheHeight) {
        return PerformerCard(
          performer: performer,
          memCacheWidth: memCacheWidth,
          onTap: () => context.push('/performers/performer/${performer.id}'),
        );
      },
      loadingItemBuilder: (context, isGrid, index) =>
          PerformerCard.skeleton(memCacheWidth: 300),

      floatingActionButton: randomNavigationEnabled
          ? performersAsync.maybeWhen(
              data: (performers) => FloatingActionButton.small(
                onPressed: _openRandomPerformer,
                tooltip: context.l10n.random_performer,
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
