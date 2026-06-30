import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../../scenes/presentation/widgets/entity_scene_media_grid.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/studio_media_provider.dart';

/// A grid page showing all media (scenes) for a specific studio.
///
/// Uses [ListPageScaffold] for consistent layout and [SceneCard] for
/// unified item representation.
class StudioMediaGridPage extends ConsumerWidget {
  const StudioMediaGridPage({required this.studioId, super.key});

  /// The ID of the studio whose media to display.
  final String studioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(studioMediaGridProvider(studioId));
    final isGridView = ref.watch(
      gridLayoutSettingProvider(GridLayoutSetting.studioMedia),
    );
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.studio),
    );

    return EntitySceneMediaGrid(
      title: context.l10n.studios_media_title,
      entityId: studioId,
      filterKind: EntityMediaFilterKind.studio,
      mediaAsync: mediaAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      queueId: PlaybackQueueIds.studioMedia(studioId),
      onRefresh: () => ref.refresh(studioMediaGridProvider(studioId).future),
      onFetchNextPage: () =>
          ref.read(studioMediaGridProvider(studioId).notifier).fetchNextPage(),
    );
  }
}
