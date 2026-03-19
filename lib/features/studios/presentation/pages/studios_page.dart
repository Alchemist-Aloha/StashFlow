import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/studio_list_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/studio.dart';

enum _StudioSortOption { name, sceneCount, rating }

class StudiosPage extends ConsumerStatefulWidget {
  const StudiosPage({super.key});

  @override
  ConsumerState<StudiosPage> createState() => _StudiosPageState();
}

class _StudiosPageState extends ConsumerState<StudiosPage> {
  _StudioSortOption _sortOption = _StudioSortOption.name;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(studioSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_StudioSortOption option) {
    switch (option) {
      case _StudioSortOption.name:
        ref.read(studioListProvider.notifier).setSort(sort: 'name', descending: false);
        break;
      case _StudioSortOption.sceneCount:
        ref.read(studioListProvider.notifier).setSort(sort: 'scene_count', descending: true);
        break;
      case _StudioSortOption.rating:
        ref.read(studioListProvider.notifier).setSort(sort: 'rating100', descending: true);
        break;
    }
  }

  Widget _buildSortBar() {
    const options = [
      (_StudioSortOption.name, 'Name'),
      (_StudioSortOption.sceneCount, 'Scene Count'),
      (_StudioSortOption.rating, 'Rating'),
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
    final studiosAsync = ref.watch(studioListProvider);

    return ListPageScaffold<Studio>(
      title: 'Studios',
      searchHint: 'Search studios...',
      onSearchChanged: _onSearchChanged,
      provider: studiosAsync,
      onRefresh: () => ref.refresh(studioListProvider.future),
      onFetchNextPage: () => ref.read(studioListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingMedium,
        mainAxisSpacing: AppTheme.spacingMedium,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, studio) => InkWell(
        onTap: () => context.push('/studio/${studio.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studio.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${studio.sceneCount} scenes',
                      style: context.textTheme.bodySmall,
                    ),
                    if (studio.rating100 != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: context.colors.ratingColor),
                          const SizedBox(width: 2),
                          Text(
                            (studio.rating100! / 20).toStringAsFixed(1),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
