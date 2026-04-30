import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/performer.dart';
import '../../domain/entities/performer_filter.dart';
import '../providers/performer_list_provider.dart';
import '../widgets/performer_filter_panel.dart';
import '../widgets/performer_card.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';

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
      final sortConfig = ref.read(performerSortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
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
          _ => _PerformerSortOption.name,
        };
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
    };

    ref
        .read(performerListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
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
    }
  }

  Future<void> _openRandomPerformer() async {
    final random = await ref
        .read(performerListProvider.notifier)
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
                      context.l10n.performers_sort_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempOption = _PerformerSortOption.name;
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
                      maxHeight: MediaQuery.sizeOf(context).height * 0.35,
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
                          children: _PerformerSortOption.values
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
                          .read(performerSortProvider.notifier)
                          .saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.tags_sort_saved)),
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
      builder: (context) => const PerformerFilterPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final performersAsync = ref.watch(performerListProvider);
    final gridColumns = ref.watch(performerGridColumnsProvider);
    final filterState = ref.watch(performerFilterStateProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrollController = ref.watch(performerScrollControllerProvider);
    final hasSortOverride =
        _sortOption != _PerformerSortOption.name || _sortDescending;

    return ListPageScaffold<Performer>(
      title: context.l10n.performers_title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: performersAsync,
      scrollController: scrollController,
      imageUrlBuilder: (performer) => performer.imagePath,
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
      ],
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns ?? 3,
        crossAxisSpacing: context.dimensions.spacingSmall,
        mainAxisSpacing: context.dimensions.spacingSmall,
        childAspectRatio: 0.85,
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
      loadingItemBuilder: (context, isGrid, index) => PerformerCard.skeleton(
        memCacheWidth: 300,
      ),

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
