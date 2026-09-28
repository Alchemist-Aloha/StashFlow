import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../performers/presentation/providers/performer_details_provider.dart';
import '../../../studios/presentation/providers/studio_details_provider.dart';
import '../../../tags/presentation/providers/tag_details_provider.dart';
import '../../../groups/presentation/providers/group_details_provider.dart';
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
      title: _title(context, ref),
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

  String _title(BuildContext context, WidgetRef ref) {
    final name = switch (filterKind) {
      EntityMediaFilterKind.performer =>
        ref.watch(performerDetailsProvider(entityId)).value?.name,
      EntityMediaFilterKind.studio =>
        ref.watch(studioDetailsProvider(entityId)).value?.name,
      EntityMediaFilterKind.tag =>
        ref.watch(tagDetailsProvider(entityId)).value?.name,
      EntityMediaFilterKind.group =>
        ref.watch(groupDetailsProvider(entityId)).value?.name,
    };
    return name?.trim().isNotEmpty == true ? name! : context.l10n.details_media;
  }
}
