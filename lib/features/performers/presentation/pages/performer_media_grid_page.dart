import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../providers/performer_media_provider.dart';

/// A grid page showing all media (scenes) for a specific performer.
///
/// Uses [ListPageScaffold] for consistent layout and [GridCard] for
/// unified item representation.
class PerformerMediaGridPage extends ConsumerWidget {
  const PerformerMediaGridPage({required this.performerId, super.key});

  /// The ID of the performer whose media to display.
  final String performerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(performerMediaGridProvider(performerId));

    return ListPageScaffold<PerformerMediaItem>(
      title: 'All Performer Media',
      searchHint: 'Search media...',
      // Currently, search is not implemented on the provider for this specific view.
      onSearchChanged: (_) {},
      provider: mediaAsync,
      onRefresh: () => ref.refresh(performerMediaGridProvider(performerId).future),
      onFetchNextPage: () =>
          ref.read(performerMediaGridProvider(performerId).notifier).fetchNextPage(),
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
