import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/studio_media_provider.dart';

/// A grid page showing all media (scenes) for a specific studio.
///
/// Uses [ListPageScaffold] for consistent layout and [GridCard] for
/// unified item representation.
class StudioMediaGridPage extends ConsumerWidget {
  const StudioMediaGridPage({required this.studioId, super.key});

  /// The ID of the studio whose media to display.
  final String studioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(studioMediaGridProvider(studioId));
    final isGridView = ref.watch(studioMediaGridLayoutProvider);
    final gridColumns = ref.watch(studioGridColumnsProvider);

    return ListPageScaffold<StudioMediaItem>(
      title: context.l10n.studios_media_title,
      searchHint: context.l10n.common_search_placeholder,
      // Currently, search is not implemented on the provider for this specific view.
      onSearchChanged: (_) {},
      provider: mediaAsync,
      imageUrlBuilder: (item) => item.thumbnailUrl,
      onRefresh: () => ref.refresh(studioMediaGridProvider(studioId).future),
      onFetchNextPage: () =>
          ref.read(studioMediaGridProvider(studioId).notifier).fetchNextPage(),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(crossAxisCount: gridColumns ?? 2)
          : null,
      useMasonry: isGridView,
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
