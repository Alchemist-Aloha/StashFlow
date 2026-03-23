import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../../../core/utils/app_log_store.dart';

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
    AppLogStore.instance.add(
      'PlaybackQueue build: initializing fresh state',
      source: 'playback_queue',
    );
    return PlaybackQueueState();
  }

  void setSequence(List<Scene> scenes, int initialIndex) {
    AppLogStore.instance.add(
      'PlaybackQueue setSequence: scenes=${scenes.length}, initialIndex=$initialIndex',
      source: 'playback_queue',
    );

    // If the new list is exactly the same as our current sequence (or a subset of it),
    // we don't want to reset our state.
    if (state.sequence.length >= scenes.length && scenes.isNotEmpty && state.sequence.isNotEmpty) {
      if (state.sequence[0].id == scenes[0].id) {
        AppLogStore.instance.add(
          'PlaybackQueue setSequence: detected same/subset list, checking index',
          source: 'playback_queue',
        );
        if (initialIndex != -1) {
          state = state.copyWith(currentIndex: initialIndex);
        }
        return;
      }
    }

    state = state.copyWith(
      sequence: scenes,
      currentIndex: initialIndex,
    );
  }

  void updateSequence(List<Scene> scenes) {
    AppLogStore.instance.add(
      'PlaybackQueue updateSequence: adding ${scenes.length} scenes to current ${state.sequence.length}',
      source: 'playback_queue',
    );
    state = state.copyWith(sequence: [...state.sequence, ...scenes]);
  }

  void setIndex(int index) {
    AppLogStore.instance.add(
      'PlaybackQueue setIndex: $index (current=${state.currentIndex}, total=${state.sequence.length})',
      source: 'playback_queue',
    );
    if (index >= 0 && index < state.sequence.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  void findAndSetIndex(String sceneId) {
    if (sceneId.isEmpty) return;
    final index = state.sequence.indexWhere((s) => s.id == sceneId);
    AppLogStore.instance.add(
      'PlaybackQueue findAndSetIndex: sceneId=$sceneId, found at index $index',
      source: 'playback_queue',
    );
    if (index != -1) {
      state = state.copyWith(currentIndex: index);
    }
  }

  Scene? getNextScene() {
    AppLogStore.instance.add(
      'PlaybackQueue getNextScene: current=${state.currentIndex}, total=${state.sequence.length}',
      source: 'playback_queue',
    );
    if (state.currentIndex >= 0 && state.currentIndex < state.sequence.length - 1) {
      final nextScene = state.sequence[state.currentIndex + 1];
      AppLogStore.instance.add(
        'PlaybackQueue getNextScene: returning ${nextScene.id}',
        source: 'playback_queue',
      );
      return nextScene;
    }
    AppLogStore.instance.add(
      'PlaybackQueue getNextScene: no next scene available',
      source: 'playback_queue',
    );
    return null;
  }

  void playNext() {
    final nextIndex = state.currentIndex + 1;
    AppLogStore.instance.add(
      'PlaybackQueue playNext: nextIndex=$nextIndex, total=${state.sequence.length}',
      source: 'playback_queue',
    );
    if (nextIndex < state.sequence.length) {
      state = state.copyWith(currentIndex: nextIndex);
    }
  }
}
