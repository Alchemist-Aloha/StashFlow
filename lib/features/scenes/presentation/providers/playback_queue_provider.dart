import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import 'video_player_provider.dart';

part 'playback_queue_provider.g.dart';

class PlaybackQueueState {
  final List<Scene> manualQueue;
  final List<Scene> currentSequence;

  PlaybackQueueState({
    this.manualQueue = const [],
    this.currentSequence = const [],
  });

  PlaybackQueueState copyWith({
    List<Scene>? manualQueue,
    List<Scene>? currentSequence,
  }) {
    return PlaybackQueueState(
      manualQueue: manualQueue ?? this.manualQueue,
      currentSequence: currentSequence ?? this.currentSequence,
    );
  }
}

@riverpod
class PlaybackQueue extends _$PlaybackQueue {
  @override
  PlaybackQueueState build() {
    return PlaybackQueueState();
  }

  void add(Scene scene) {
    if (!state.manualQueue.any((s) => s.id == scene.id)) {
      state = state.copyWith(manualQueue: [...state.manualQueue, scene]);
    }
  }

  void remove(String sceneId) {
    state = state.copyWith(
      manualQueue: state.manualQueue.where((s) => s.id != sceneId).toList(),
    );
  }

  void clear() {
    state = state.copyWith(manualQueue: []);
  }

  void setCurrentSequence(List<Scene> scenes) {
    state = state.copyWith(currentSequence: scenes);
  }

  Scene? getNextScene() {
    final activeScene = ref.read(playerStateProvider).activeScene;
    if (activeScene == null) return null;

    // 1. Check manual queue first
    final manualIndex = state.manualQueue.indexWhere((s) => s.id == activeScene.id);
    if (manualIndex != -1 && manualIndex < state.manualQueue.length - 1) {
      return state.manualQueue[manualIndex + 1];
    }

    // 2. Fallback to current sequence (query list)
    final seqIndex = state.currentSequence.indexWhere((s) => s.id == activeScene.id);
    if (seqIndex != -1 && seqIndex < state.currentSequence.length - 1) {
      return state.currentSequence[seqIndex + 1];
    }
    
    return null;
  }

  void fillFromList(List<Scene> scenes) {
    state = state.copyWith(manualQueue: scenes);
  }
}
