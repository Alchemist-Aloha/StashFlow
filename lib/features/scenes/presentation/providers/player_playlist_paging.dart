import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entity_media_filter_scope.dart';
import 'playback_queue_provider.dart';
import 'scene_list_provider.dart';

enum PlaylistPagingKind {
  none,
  main,
  performerMedia,
  studioMedia,
  tagMedia,
  groupMedia,
}

class PlaylistPagingTarget {
  const PlaylistPagingTarget(this.kind, {this.entityId});

  const PlaylistPagingTarget.none() : this(PlaylistPagingKind.none);

  final PlaylistPagingKind kind;
  final String? entityId;

  bool get supportsPaging => kind != PlaylistPagingKind.none;
}

PlaylistPagingTarget playlistPagingTargetForQueueId(String queueId) {
  if (queueId == PlaybackQueueIds.main) {
    return const PlaylistPagingTarget(PlaylistPagingKind.main);
  }

  final parts = queueId.split(':');
  if (parts.length != 3 || parts[2] != 'media') {
    return const PlaylistPagingTarget.none();
  }

  return switch (parts[0]) {
    'performer' => PlaylistPagingTarget(
      PlaylistPagingKind.performerMedia,
      entityId: parts[1],
    ),
    'studio' => PlaylistPagingTarget(
      PlaylistPagingKind.studioMedia,
      entityId: parts[1],
    ),
    'tag' => PlaylistPagingTarget(
      PlaylistPagingKind.tagMedia,
      entityId: parts[1],
    ),
    'group' => PlaylistPagingTarget(
      PlaylistPagingKind.groupMedia,
      entityId: parts[1],
    ),
    _ => const PlaylistPagingTarget.none(),
  };
}

Future<bool> maybeLoadNextPlaylistPage(WidgetRef ref, String queueId) async {
  final target = playlistPagingTargetForQueueId(queueId);
  if (!target.supportsPaging) return false;

  switch (target.kind) {
    case PlaylistPagingKind.none:
      return false;
    case PlaylistPagingKind.main:
      final notifier = ref.read(sceneListProvider.notifier);
      if (!notifier.hasMore || notifier.isLoadingMore) return false;
      await notifier.fetchNextPage();
      return true;
    case PlaylistPagingKind.performerMedia:
      return _loadEntityNextPage(
        ref,
        EntityMediaFilterKind.performer,
        target.entityId,
      );
    case PlaylistPagingKind.studioMedia:
      return _loadEntityNextPage(
        ref,
        EntityMediaFilterKind.studio,
        target.entityId,
      );
    case PlaylistPagingKind.tagMedia:
      return _loadEntityNextPage(
        ref,
        EntityMediaFilterKind.tag,
        target.entityId,
      );
    case PlaylistPagingKind.groupMedia:
      return _loadEntityNextPage(
        ref,
        EntityMediaFilterKind.group,
        target.entityId,
      );
  }
}

Future<bool> _loadEntityNextPage(
  WidgetRef ref,
  EntityMediaFilterKind kind,
  String? entityId,
) async {
  if (entityId == null || entityId.isEmpty) return false;
  final notifier = ref.read(entityMediaGridProvider(kind, entityId).notifier);
  if (!notifier.hasMore || notifier.isLoadingMore) return false;
  await notifier.fetchNextPage();
  return true;
}
