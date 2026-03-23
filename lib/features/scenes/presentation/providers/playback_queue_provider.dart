import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';

part 'playback_queue_provider.g.dart';

class PlaybackQueueState {
  final List<Scene> sequence;
  final int currentIndex;

  PlaybackQueueState({
    this.sequence = const [],
    this.currentIndex = -1,
  });

  PlaybackQueueState copyWith({
    List<Scene>? sequence,
    int? currentIndex,
  }) {
    return PlaybackQueueState(
      sequence: sequence ?? this.sequence,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

@Riverpod(keepAlive: true)
class PlaybackQueue extends _$PlaybackQueue {
  @override
  PlaybackQueueState build() {
    return PlaybackQueueState();
  }

  void setSequence(List<Scene> scenes, int initialIndex) {
    state = state.copyWith(
      sequence: scenes,
      currentIndex: initialIndex,
    );
  }

  void updateSequence(List<Scene> scenes) {
    state = state.copyWith(sequence: [...state.sequence, ...scenes]);
  }

  void setIndex(int index) {
    if (index >= 0 && index < state.sequence.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  Scene? getNextScene() {
    if (state.currentIndex >= 0 && state.currentIndex < state.sequence.length - 1) {
      return state.sequence[state.currentIndex + 1];
    }
    return null;
  }

  void playNext() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.sequence.length) {
      state = state.copyWith(currentIndex: nextIndex);
    }
  }
}
