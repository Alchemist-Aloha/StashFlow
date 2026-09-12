import '../../domain/entities/scene.dart';
import 'playback_queue_provider.dart';

({Scene scene, int targetIndex})? findQueuePlaybackTarget({
  required PlaybackQueueState queueState,
  required int delta,
  String? activeSceneId,
}) {
  var currentIndex = queueState.currentIndex;
  if (currentIndex < 0 || currentIndex >= queueState.sequence.length) {
    if (activeSceneId == null || activeSceneId.isEmpty) return null;
    currentIndex = queueState.sequence.indexWhere((s) => s.id == activeSceneId);
    if (currentIndex == -1) return null;
  }

  final targetIndex = currentIndex + delta;
  if (targetIndex < 0 || targetIndex >= queueState.sequence.length) return null;
  return (scene: queueState.sequence[targetIndex], targetIndex: targetIndex);
}
