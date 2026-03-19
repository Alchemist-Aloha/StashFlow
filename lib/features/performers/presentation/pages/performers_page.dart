import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/performer.dart';
import '../providers/performer_list_provider.dart';
import '../widgets/performer_card.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';

enum _PerformerSortOption { name, sceneCount, lastUpdated, random }

class PerformersPage extends ConsumerStatefulWidget {
  const PerformersPage({super.key});

  @override
  ConsumerState<PerformersPage> createState() => _PerformersPageState();
}

class _PerformersPageState extends ConsumerState<PerformersPage> {
  _PerformerSortOption _sortOption = _PerformerSortOption.name;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(performerSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_PerformerSortOption option) {
    switch (option) {
      case _PerformerSortOption.name:
        ref.read(performerListProvider.notifier).setSort(sort: 'name', descending: false);
        break;
      case _PerformerSortOption.sceneCount:
        ref.read(performerListProvider.notifier).setSort(sort: 'scene_count', descending: true);
        break;
      case _PerformerSortOption.lastUpdated:
        ref.read(performerListProvider.notifier).setSort(sort: 'updated_at', descending: true);
        break;
      case _PerformerSortOption.random:
        ref.read(performerListProvider.notifier).setSort(sort: 'random', descending: true);
        break;
    }
  }

  Future<void> _openRandomPerformer() async {
    final random = await ref.read(performerListProvider.notifier).getRandomPerformer();
    if (!mounted) return;

    if (random == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No performers available for random navigation')),
      );
      return;
    }

    context.push('/performer/${random.id}');
  }

  Widget _buildSortBar() {
    const options = [
      (_PerformerSortOption.name, 'Name'),
      (_PerformerSortOption.sceneCount, 'Scene Count'),
      (_PerformerSortOption.lastUpdated, 'Last Updated'),
      (_PerformerSortOption.random, 'Random'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option.$2),
              selected: _sortOption == option.$1,
              onSelected: (selected) {
                if (!selected) return;
                setState(() => _sortOption = option.$1);
                _applyServerSort(option.$1);
              },
            ),
            const SizedBox(width: AppTheme.spacingSmall),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final performersAsync = ref.watch(performerListProvider);

    return ListPageScaffold<Performer>(
      title: 'Performers',
      searchHint: 'Search performers...',
      onSearchChanged: _onSearchChanged,
      provider: performersAsync,
      onRefresh: () => ref.refresh(performerListProvider.future),
      onFetchNextPage: () => ref.read(performerListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppTheme.spacingMedium,
        mainAxisSpacing: AppTheme.spacingMedium,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, performer) => PerformerCard(
        performer: performer,
        onTap: () => context.push('/performer/${performer.id}'),
      ),
      floatingActionButton: performersAsync.maybeWhen(
        data: (performers) => FloatingActionButton.small(
          onPressed: _openRandomPerformer,
          tooltip: 'Random performer',
          child: const Icon(Icons.casino_outlined),
        ),
        orElse: () => null,
      ),
    );
  }
}
