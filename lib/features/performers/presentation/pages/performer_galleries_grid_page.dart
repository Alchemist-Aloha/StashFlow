import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/performer_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

/// A grid page showing all galleries for a specific performer.
///
/// Uses [ListPageScaffold] for consistent layout and [GridCard] for
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

    return ListPageScaffold<PerformerGalleryItem>(
      title: context.l10n.performers_galleries_title,
      searchHint: context.l10n.common_search_placeholder,
      // Currently, search is not implemented on the provider for this specific view.
      onSearchChanged: (_) {},
      provider: galleriesAsync,
      imageUrlBuilder: (item) => item.thumbnailUrl,
      onRefresh: () =>
          ref.refresh(performerGalleriesGridProvider(performerId).future),
      onFetchNextPage: () => ref
          .read(performerGalleriesGridProvider(performerId).notifier)
          .fetchNextPage(),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(crossAxisCount: gridColumns ?? 2)
          : null,
      padding: isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      itemBuilder: (context, item, memCacheWidth, memCacheHeight) => GridCard(
        title: item.title,
        imageUrl: item.thumbnailUrl,
        isGrid: isGridView,
        memCacheWidth: memCacheWidth,
        onTap: () {
          ref
              .read(imageFilterStateProvider.notifier)
              .setGalleryId(item.galleryId);
          context.push('/galleries/images');
        },
      ),
    );
  }
}
