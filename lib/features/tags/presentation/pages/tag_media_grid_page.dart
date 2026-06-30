import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../../scenes/presentation/widgets/entity_scene_media_grid.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/tag_media_provider.dart';

/// A grid page showing all media (scenes) for a specific tag.
///
/// Uses [ListPageScaffold] for consistent layout and [SceneCard] for
/// unified item representation.
class TagMediaGridPage extends ConsumerWidget {
  const TagMediaGridPage({required this.tagId, super.key});

  /// The ID of the tag whose media to display.
  final String tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(tagMediaGridProvider(tagId));
    final isGridView = ref.watch(
      gridLayoutSettingProvider(GridLayoutSetting.tagMedia),
    );
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.tag),
    );

    return EntitySceneMediaGrid(
      title: context.l10n.studios_media_title,
      entityId: tagId,
      filterKind: EntityMediaFilterKind.tag,
      mediaAsync: mediaAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      queueId: PlaybackQueueIds.tagMedia(tagId),
      onRefresh: () => ref.refresh(tagMediaGridProvider(tagId).future),
      onFetchNextPage: () =>
          ref.read(tagMediaGridProvider(tagId).notifier).fetchNextPage(),
    );
  }
}
