import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../galleries/presentation/widgets/gallery_card.dart';
import '../../../galleries/domain/entities/gallery.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/performer_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

/// A grid page showing all galleries for a specific performer.
///
/// Uses [ListPageScaffold] for consistent layout and [GalleryCard] for
/// unified item representation.
class PerformerGalleriesGridPage extends ConsumerWidget {
  const PerformerGalleriesGridPage({required this.performerId, super.key});

  /// The ID of the performer whose galleries to display.
  final String performerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(
      performerGalleriesGridProvider(performerId),
    );
    final isGridView = ref.watch(performerGalleriesGridLayoutProvider);
    final gridColumns = ref.watch(performerGridColumnsProvider);

    return ListPageScaffold<Gallery>(
      title: context.l10n.performers_galleries_title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: (_) {},
      provider: galleriesAsync,
      imageUrlBuilder: (item) => item.coverPath,
      onRefresh: () =>
          ref.refresh(performerGalleriesGridProvider(performerId).future),
      onFetchNextPage: () => ref
          .read(performerGalleriesGridProvider(performerId).notifier)
          .fetchNextPage(),
      loadingItemBuilder: (context, isGrid, index) =>
          GalleryCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(crossAxisCount: gridColumns ?? 2)
          : null,
      useMasonry: isGridView,
      padding: isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      itemBuilder: (context, item, memCacheWidth, memCacheHeight) {
        return GalleryCard(
          gallery: item,
          isGrid: isGridView,
          useMasonry: isGridView,
          memCacheWidth: memCacheWidth,
          onTap: () {
            ref.read(imageFilterStateProvider.notifier).setGalleryId(item.id);
            context.push('/galleries/images');
          },
        );
      },
    );
  }
}
