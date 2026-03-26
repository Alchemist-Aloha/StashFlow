import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/performer.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../providers/performer_list_provider.dart';
import '../widgets/performer_card.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

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
        return 'Name';
      case _PerformerSortOption.sceneCount:
        return 'Scene Count';
      case _PerformerSortOption.playCount:
        return 'Play Count';
      case _PerformerSortOption.oCounter:
        return 'O-Counter';
      case _PerformerSortOption.rating:
        return 'Rating';
      case _PerformerSortOption.lastUpdated:
        return 'Updated At';
      case _PerformerSortOption.createdAt:
        return 'Created At';
      case _PerformerSortOption.random:
        return 'Random';
    }
  }

  Future<void> _openRandomPerformer() async {
    final random = await ref
        .read(performerListProvider.notifier)
        .getRandomPerformer(excludePerformerId: _lastRandomPerformerId);
    if (!mounted) return;

    if (random == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No performers available for random navigation'),
        ),
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
                      'Sort Performers',
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
                      await ref
                          .read(performerSortProvider.notifier)
                          .saveAsDefault();
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
    final currentFilter = ref.read(performerFilterProvider);
    bool tempFavoritesOnly = currentFilter.favoritesOnly;
    final tempGenders = <String>[...currentFilter.genders];

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
                      'Filter Performers',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempFavoritesOnly = false;
                          tempGenders.clear();
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
                Text('Gender', style: context.textTheme.labelLarge),
                const SizedBox(height: AppTheme.spacingSmall),
                Wrap(
                  spacing: AppTheme.spacingSmall,
                  runSpacing: AppTheme.spacingSmall,
                  children: [
                    ChoiceChip(
                      label: const Text('Any'),
                      selected: tempGenders.isEmpty,
                      onSelected: (_) =>
                          setModalState(() => tempGenders.clear()),
                    ),
                    for (final option in const [
                      ('FEMALE', 'Female'),
                      ('MALE', 'Male'),
                      ('TRANSGENDER_FEMALE', 'Trans Female'),
                      ('TRANSGENDER_MALE', 'Trans Male'),
                      ('NON_BINARY', 'Non-binary'),
                      ('INTERSEX', 'Intersex'),
                    ])
                      ChoiceChip(
                        label: Text(option.$2),
                        selected: tempGenders.contains(option.$1),
                        onSelected: (selected) => setModalState(() {
                          if (selected) {
                            if (!tempGenders.contains(option.$1)) {
                              tempGenders.add(option.$1);
                            }
                          } else {
                            tempGenders.remove(option.$1);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(performerFilterProvider.notifier)
                          .set(
                            favoritesOnly: tempFavoritesOnly,
                            genders: tempGenders,
                          );
                      ref.invalidate(performerListProvider);
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
                          .read(performerFilterProvider.notifier)
                          .set(
                            favoritesOnly: tempFavoritesOnly,
                            genders: tempGenders,
                          );
                      await ref
                          .read(performerFilterProvider.notifier)
                          .saveAsDefault();
                      ref.invalidate(performerListProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Filter preferences saved as default',
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

  @override
  Widget build(BuildContext context) {
    final performersAsync = ref.watch(performerListProvider);
    final filterState = ref.watch(performerFilterProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrollController = ref.watch(performerScrollControllerProvider);
    final hasSortOverride =
        _sortOption != _PerformerSortOption.name || _sortDescending;

    return ListPageScaffold<Performer>(
      title: 'Performers',
      searchHint: 'Search performers...',
      onSearchChanged: _onSearchChanged,
      provider: performersAsync,
      scrollController: scrollController,
      onRefresh: () => ref.refresh(performerListProvider.future),
      onFetchNextPage: () =>
          ref.read(performerListProvider.notifier).fetchNextPage(),
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
            if (filterState.hasActiveFilters)
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppTheme.spacingSmall,
        mainAxisSpacing: AppTheme.spacingSmall,
        childAspectRatio: 0.85,
      ),
      mobileCrossAxisCount: 3,
      tabletCrossAxisCount: 5,
      itemBuilder: (context, performer) {
        return PerformerCard(
          performer: performer,
          onTap: () => context.push('/performers/performer/${performer.id}'),
        );
      },
      floatingActionButton: randomNavigationEnabled
          ? performersAsync.maybeWhen(
              data: (performers) => FloatingActionButton.small(
                onPressed: _openRandomPerformer,
                tooltip: 'Random performer',
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
