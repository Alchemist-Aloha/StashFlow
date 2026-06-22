import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../../scenes/presentation/widgets/entity_scene_media_grid.dart';
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

    return EntitySceneMediaGrid(
      title: context.l10n.performers_media_title,
      entityId: performerId,
      filterKind: EntityMediaFilterKind.performer,
      mediaAsync: mediaAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      queueId: PlaybackQueueIds.performerMedia(performerId),
      onRefresh: () =>
          ref.refresh(performerMediaGridProvider(performerId).future),
      onFetchNextPage: () => ref
          .read(performerMediaGridProvider(performerId).notifier)
          .fetchNextPage(),
    );
  }
}
