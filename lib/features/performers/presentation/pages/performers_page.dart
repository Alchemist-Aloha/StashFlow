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
  sceneCount,
  playCount,
  oCounter,
  rating,
  lastUpdated,
  createdAt,
  random,
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
          'scenes_count' => _PerformerSortOption.sceneCount,
          'play_count' => _PerformerSortOption.playCount,
          'o_counter' => _PerformerSortOption.oCounter,
          'rating' => _PerformerSortOption.rating,
          'updated_at' => _PerformerSortOption.lastUpdated,
          'created_at' => _PerformerSortOption.createdAt,
          'random' => _PerformerSortOption.random,
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
      _PerformerSortOption.sceneCount => 'scenes_count',
      _PerformerSortOption.playCount => 'play_count',
      _PerformerSortOption.oCounter => 'o_counter',
      _PerformerSortOption.rating => 'rating',
      _PerformerSortOption.lastUpdated => 'updated_at',
      _PerformerSortOption.createdAt => 'created_at',
      _PerformerSortOption.random => 'random',
    };

    ref
        .read(performerListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  String _sortLabel(_PerformerSortOption option) {
    switch (option) {
      case _PerformerSortOption.name:
        return context.l10n.sort_name;
      case _PerformerSortOption.sceneCount:
        return context.l10n.sort_scene_count;
      case _PerformerSortOption.playCount:
        return context.l10n.performers_play_count;
      case _PerformerSortOption.oCounter:
        return 'O-Counter';
      case _PerformerSortOption.rating:
        return context.l10n.sort_rating;
      case _PerformerSortOption.lastUpdated:
        return context.l10n.sort_updated_at;
      case _PerformerSortOption.createdAt:
        return context.l10n.sort_created_at;
      case _PerformerSortOption.random:
        return context.l10n.sort_random;
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
                const SizedBox(height: AppTheme.spacingMedium),
                Text(
                  context.l10n.common_sort_method,
                  style: context.textTheme.labelLarge,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Wrap(
                  spacing: AppTheme.spacingSmall,
                  runSpacing: AppTheme.spacingSmall,
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
                  child: OutlinedButton(
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
        crossAxisSpacing: AppTheme.spacingSmall,
        mainAxisSpacing: AppTheme.spacingSmall,
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
