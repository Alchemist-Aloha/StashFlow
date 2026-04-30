import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../scenes/presentation/widgets/scene_card.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/performer_media_provider.dart';

/// A grid page showing all media (scenes) for a specific performer.
///
/// Uses [ListPageScaffold] for consistent layout and [SceneCard] for
/// unified item representation.
class PerformerMediaGridPage extends ConsumerWidget {
  const PerformerMediaGridPage({required this.performerId, super.key});

  /// The ID of the performer whose media to display.
  final String performerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(performerMediaGridProvider(performerId));
    final isGridView = ref.watch(performerMediaGridLayoutProvider);
    final gridColumns = ref.watch(performerGridColumnsProvider);

    return ListPageScaffold<Scene>(
      title: context.l10n.performers_media_title,
      searchHint: context.l10n.common_search_placeholder,
      // Currently, search is not implemented on the provider for this specific view.
      onSearchChanged: (_) {},
      provider: mediaAsync,
      imageUrlBuilder: (item) => item.paths.screenshot,
      onRefresh: () =>
          ref.refresh(performerMediaGridProvider(performerId).future),
      onFetchNextPage: () => ref
          .read(performerMediaGridProvider(performerId).notifier)
          .fetchNextPage(),
      loadingItemBuilder: (context, isGrid, index) =>
          SceneCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
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
