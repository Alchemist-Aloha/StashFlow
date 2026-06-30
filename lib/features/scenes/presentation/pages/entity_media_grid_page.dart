import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../providers/entity_media_filter_scope.dart';
import '../providers/playback_queue_provider.dart';
import '../widgets/entity_scene_media_grid.dart';

class EntityMediaGridPage extends ConsumerWidget {
  const EntityMediaGridPage({
    required this.entityId,
    required this.filterKind,
    super.key,
  });

  final String entityId;
  final EntityMediaFilterKind filterKind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(entityMediaGridProvider(filterKind, entityId));

    return EntitySceneMediaGrid(
      title: _title(context),
      entityId: entityId,
      filterKind: filterKind,
      mediaAsync: mediaAsync,
      isGridView: ref.watch(gridLayoutSettingProvider(_layoutSetting)),
      gridColumns: ref.watch(gridColumnSettingProvider(_columnSetting)),
      queueId: _queueId,
      onRefresh: () =>
          ref.refresh(entityMediaGridProvider(filterKind, entityId).future),
      onFetchNextPage: () => ref
          .read(entityMediaGridProvider(filterKind, entityId).notifier)
          .fetchNextPage(),
    );
  }

  GridLayoutSetting get _layoutSetting => switch (filterKind) {
    EntityMediaFilterKind.performer => GridLayoutSetting.performerMedia,
    EntityMediaFilterKind.studio => GridLayoutSetting.studioMedia,
    EntityMediaFilterKind.tag => GridLayoutSetting.tagMedia,
    EntityMediaFilterKind.group => GridLayoutSetting.groupMedia,
  };

  GridColumnSetting get _columnSetting => switch (filterKind) {
    EntityMediaFilterKind.performer => GridColumnSetting.performer,
    EntityMediaFilterKind.studio => GridColumnSetting.studio,
    EntityMediaFilterKind.tag => GridColumnSetting.tag,
    EntityMediaFilterKind.group => GridColumnSetting.group,
  };

  String get _queueId => switch (filterKind) {
    EntityMediaFilterKind.performer => PlaybackQueueIds.performerMedia(
      entityId,
    ),
    EntityMediaFilterKind.studio => PlaybackQueueIds.studioMedia(entityId),
    EntityMediaFilterKind.tag => PlaybackQueueIds.tagMedia(entityId),
    EntityMediaFilterKind.group => PlaybackQueueIds.groupMedia(entityId),
  };

  String _title(BuildContext context) => switch (filterKind) {
    EntityMediaFilterKind.performer => context.l10n.performers_media_title,
    EntityMediaFilterKind.studio => context.l10n.studios_media_title,
    EntityMediaFilterKind.tag => context.l10n.studios_media_title,
    EntityMediaFilterKind.group => context.l10n.studios_media_title,
  };
}
