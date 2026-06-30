import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../../scenes/presentation/widgets/entity_scene_media_grid.dart';
import '../providers/group_media_provider.dart';

class GroupMediaGridPage extends ConsumerWidget {
  const GroupMediaGridPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(groupMediaGridProvider(groupId));
    final isGridView = ref.watch(
      gridLayoutSettingProvider(GridLayoutSetting.groupMedia),
    );
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.group),
    );

    return EntitySceneMediaGrid(
      title: context.l10n.studios_media_title,
      entityId: groupId,
      filterKind: EntityMediaFilterKind.group,
      mediaAsync: mediaAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      queueId: PlaybackQueueIds.groupMedia(groupId),
      onRefresh: () => ref.refresh(groupMediaGridProvider(groupId).future),
      onFetchNextPage: () =>
          ref.read(groupMediaGridProvider(groupId).notifier).fetchNextPage(),
    );
  }
}
