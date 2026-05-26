import '../../domain/entities/scene.dart';
import 'playback_queue_provider.dart';

enum QueueAdvanceDirection { next, previous }

class QueuePlaybackTarget {
  const QueuePlaybackTarget({required this.scene, required this.targetIndex});

  final Scene scene;
  final int targetIndex;
}

class QueuePlaybackCoordinator {
  const QueuePlaybackCoordinator();

  QueuePlaybackTarget? findTarget({
    required PlaybackQueueState queueState,
    required QueueAdvanceDirection direction,
    String? activeSceneId,
  }) {
    final currentIndex = _resolveCurrentIndex(
      queueState: queueState,
      activeSceneId: activeSceneId,
    );
    if (currentIndex == null) return null;

    final delta = direction == QueueAdvanceDirection.next ? 1 : -1;
    final targetIndex = currentIndex + delta;
    if (targetIndex < 0 || targetIndex >= queueState.sequence.length) {
      return null;
    }

    return QueuePlaybackTarget(
      scene: queueState.sequence[targetIndex],
      targetIndex: targetIndex,
    );
  }

  int? _resolveCurrentIndex({
    required PlaybackQueueState queueState,
    String? activeSceneId,
  }) {
    final currentIndex = queueState.currentIndex;
    if (currentIndex >= 0 && currentIndex < queueState.sequence.length) {
      return currentIndex;
    }

    if (activeSceneId == null || activeSceneId.isEmpty) return null;
    final syncedIndex = queueState.sequence.indexWhere(
      (s) => s.id == activeSceneId,
    );
    if (syncedIndex == -1) return null;
    return syncedIndex;
  }
}
