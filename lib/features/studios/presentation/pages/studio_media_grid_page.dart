import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
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

    return ListPageScaffold<StudioMediaItem>(
      title: 'Studio Media',
      searchHint: 'Search media...',
      // Currently, search is not implemented on the provider for this specific view.
      onSearchChanged: (_) {},
      provider: mediaAsync,
      imageUrlBuilder: (item) => item.thumbnailUrl,
      onRefresh: () => ref.refresh(studioMediaGridProvider(studioId).future),
      onFetchNextPage: () =>
          ref.read(studioMediaGridProvider(studioId).notifier).fetchNextPage(),
      gridDelegate: GridUtils.createDelegate(),
      padding: GridUtils.defaultPadding,
      itemBuilder: (context, item) => GridCard(
        title: item.title,
        imageUrl: item.thumbnailUrl,
        onTap: () => context.push('/scenes/scene/${item.sceneId}'),
      ),
    );
  }
}
