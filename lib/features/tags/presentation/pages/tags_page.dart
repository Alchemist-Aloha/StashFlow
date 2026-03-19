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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(tagSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_TagSortOption option) {
    switch (option) {
      case _TagSortOption.name:
        ref.read(tagListProvider.notifier).setSort(sort: 'name', descending: false);
        break;
      case _TagSortOption.sceneCount:
        ref.read(tagListProvider.notifier).setSort(sort: 'scenes_count', descending: true);
        break;
      case _TagSortOption.imageCount:
        ref.read(tagListProvider.notifier).setSort(sort: 'image_count', descending: true);
        break;
    }
  }

  Widget _buildSortBar() {
    const options = [
      (_TagSortOption.name, 'Name'),
      (_TagSortOption.sceneCount, 'Scene Count'),
      (_TagSortOption.imageCount, 'Image Count'),
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
    final tagsAsync = ref.watch(tagListProvider);

    return ListPageScaffold<Tag>(
      title: 'Tags',
      searchHint: 'Search tags...',
      onSearchChanged: _onSearchChanged,
      provider: tagsAsync,
      onRefresh: () => ref.refresh(tagListProvider.future),
      onFetchNextPage: () => ref.read(tagListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      itemBuilder: (context, tag) => Card(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 4),
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
    );
  }
}
