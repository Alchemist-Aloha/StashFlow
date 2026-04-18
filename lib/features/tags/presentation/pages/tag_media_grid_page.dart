import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/tag_media_provider.dart';

/// A grid page showing all media (scenes) for a specific tag.
///
/// Uses [ListPageScaffold] for consistent layout and [GridCard] for
/// unified item representation.
class TagMediaGridPage extends ConsumerWidget {
  const TagMediaGridPage({required this.tagId, super.key});

  /// The ID of the tag whose media to display.
  final String tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(tagMediaGridProvider(tagId));
    final isGridView = ref.watch(tagMediaGridLayoutProvider);
    final gridColumns = ref.watch(tagGridColumnsProvider);

    return ListPageScaffold<TagMediaItem>(
      title: context.l10n.details_media,
      searchHint: context.l10n.common_search_placeholder,
      // Currently, search is not implemented on the provider for this specific view.
      onSearchChanged: (_) {},
      provider: mediaAsync,
      imageUrlBuilder: (item) => item.thumbnailUrl,
      onRefresh: () => ref.refresh(tagMediaGridProvider(tagId).future),
      onFetchNextPage: () =>
          ref.read(tagMediaGridProvider(tagId).notifier).fetchNextPage(),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(crossAxisCount: gridColumns ?? 2)
          : null,
      padding: isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      itemBuilder: (context, item, memCacheWidth, memCacheHeight) => GridCard(
        title: item.title,
        imageUrl: item.thumbnailUrl,
        isGrid: isGridView,
        memCacheWidth: memCacheWidth,
        onTap: () => context.push('/scenes/scene/${item.sceneId}'),
      ),
    );
  }
}
