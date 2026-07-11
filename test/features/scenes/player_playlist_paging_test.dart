import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_playlist_paging.dart';

void main() {
  group('playlistPagingTargetForQueueId', () {
    test('detects main queue paging', () {
      final target = playlistPagingTargetForQueueId(PlaybackQueueIds.main);

      expect(target.kind, PlaylistPagingKind.main);
      expect(target.supportsPaging, isTrue);
      expect(target.entityId, isNull);
    });

    test('detects entity media queues', () {
      expect(
        playlistPagingTargetForQueueId(
          PlaybackQueueIds.performerMedia('p1'),
        ).kind,
        PlaylistPagingKind.performerMedia,
      );
      expect(
        playlistPagingTargetForQueueId(PlaybackQueueIds.studioMedia('s1')).kind,
        PlaylistPagingKind.studioMedia,
      );
      expect(
        playlistPagingTargetForQueueId(PlaybackQueueIds.tagMedia('t1')).kind,
        PlaylistPagingKind.tagMedia,
      );
      expect(
        playlistPagingTargetForQueueId(PlaybackQueueIds.groupMedia('g1')).kind,
        PlaylistPagingKind.groupMedia,
      );
    });

    test('ignores fixed strip queues', () {
      final target = playlistPagingTargetForQueueId(
        PlaybackQueueIds.performerStrip('p1'),
      );

      expect(target.kind, PlaylistPagingKind.none);
      expect(target.supportsPaging, isFalse);
    });
  });
}
