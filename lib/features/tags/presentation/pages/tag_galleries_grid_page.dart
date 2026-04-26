import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/tag_galleries_provider.dart';
import '../../../performers/presentation/providers/performer_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

/// A grid page showing all galleries for a specific tag.
class TagGalleriesGridPage extends ConsumerWidget {
  const TagGalleriesGridPage({required this.tagId, super.key});

  final String tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(tagGalleriesGridProvider(tagId));
    final isGridView = ref.watch(tagGalleriesGridLayoutProvider);
    final gridColumns = ref.watch(tagGridColumnsProvider);

    return ListPageScaffold<PerformerGalleryItem>(
      title: context.l10n.details_galleries,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: (_) {},
      provider: galleriesAsync,
      imageUrlBuilder: (item) => item.thumbnailUrl,
      onRefresh: () => ref.refresh(tagGalleriesGridProvider(tagId).future),
      onFetchNextPage: () =>
          ref.read(tagGalleriesGridProvider(tagId).notifier).fetchNextPage(),
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
