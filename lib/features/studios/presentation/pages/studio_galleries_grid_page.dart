import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../providers/studio_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

/// A grid page showing all galleries for a specific studio.
class StudioGalleriesGridPage extends ConsumerWidget {
  const StudioGalleriesGridPage({required this.studioId, super.key});

  final String studioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(studioGalleriesGridProvider(studioId));

    return ListPageScaffold(
      title: 'Studio Galleries',
      searchHint: 'Search galleries...',
      onSearchChanged: (_) {},
      provider: galleriesAsync,
      onRefresh: () =>
          ref.refresh(studioGalleriesGridProvider(studioId).future),
      onFetchNextPage: () => ref
          .read(studioGalleriesGridProvider(studioId).notifier)
          .fetchNextPage(),
      gridDelegate: GridUtils.createDelegate(),
      padding: GridUtils.defaultPadding,
      itemBuilder: (context, item) => GridCard(
        title: item.title,
        imageUrl: item.thumbnailUrl,
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
