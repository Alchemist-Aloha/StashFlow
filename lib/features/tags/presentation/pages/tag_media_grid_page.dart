import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../scenes/presentation/widgets/scene_card.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/tag_media_provider.dart';

/// A grid page showing all media (scenes) for a specific tag.
///
/// Uses [ListPageScaffold] for consistent layout and [SceneCard] for
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

    return ListPageScaffold<Scene>(
      title: context.l10n.studios_media_title, // Assuming tag media uses similar title or check l10n
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: (_) {},
      provider: mediaAsync,
      imageUrlBuilder: (item) => item.paths.screenshot,
      onRefresh: () => ref.refresh(tagMediaGridProvider(tagId).future),
      onFetchNextPage: () =>
          ref.read(tagMediaGridProvider(tagId).notifier).fetchNextPage(),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(crossAxisCount: gridColumns ?? 2)
          : null,
      useMasonry: isGridView,
      padding: isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      itemBuilder: (context, item, memCacheWidth, memCacheHeight) {
        return SceneCard(
          scene: item,
          isGrid: isGridView,
          useMasonry: isGridView,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          onTap: () => context.push('/scenes/scene/${item.id}'),
        );
      },
    );
  }
}
