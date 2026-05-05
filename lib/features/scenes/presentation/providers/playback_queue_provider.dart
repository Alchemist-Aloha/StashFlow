import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../../../core/utils/app_log_store.dart';

part 'playback_queue_provider.g.dart';

/// Represents the current state of the playback queue.
class PlaybackQueueState {
  /// The list of scenes in the current playback sequence.
  final List<Scene> sequence;

  /// The index of the currently active scene within the [sequence].
  /// A value of -1 indicates no scene is currently selected or active.
  final int currentIndex;

  PlaybackQueueState({this.sequence = const [], this.currentIndex = -1});

  PlaybackQueueState copyWith({List<Scene>? sequence, int? currentIndex}) {
    return PlaybackQueueState(
      sequence: sequence ?? this.sequence,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// A notifier that manages the sequence of scenes for continuous playback.
///
/// This provider is marked as `keepAlive: true` to ensure that the playback
/// sequence is preserved across navigation transitions (e.g., between
/// Grid view, TikTok view, and Scene Details).
///
/// It acts as the single source of truth for "Next" and "Previous" navigation
/// within a given context (like the main scene list).
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

  /// Updates the current sequence of scenes.
  ///
  /// If [initialIndex] is -1, the queue will attempt to preserve its current
  /// position if the new list is a subset of the current one (e.g., during pagination).
  /// This prevents the "Next" button from being disabled or resetting to the start
  /// when the scene list refreshes in the background.
  void setSequence(List<Scene> scenes, int initialIndex) {
    AppLogStore.instance.add(
      'PlaybackQueue setSequence: scenes=${scenes.length}, initialIndex=$initialIndex, currentState=(index=${state.currentIndex}, seqLen=${state.sequence.length})',
      source: 'playback_queue',
    );

    // Same-list / subset detection logic:
    // If the new list matches our current sequence's start, we avoid resetting the index
    // if the caller passed -1 (which usually means "just refresh the data").
    if (state.sequence.length >= scenes.length &&
        scenes.isNotEmpty &&
        state.sequence.isNotEmpty) {
      if (state.sequence[0].id == scenes[0].id) {
        AppLogStore.instance.add(
          'PlaybackQueue setSequence: detected same/subset list (first scene match), early return (initialIndex=$initialIndex)',
          source: 'playback_queue',
        );
        if (initialIndex != -1) {
          state = state.copyWith(currentIndex: initialIndex);
        }
        return;
      }
    }

    AppLogStore.instance.add(
      'PlaybackQueue setSequence: updating sequence and setting index to $initialIndex',
      source: 'playback_queue',
    );
    state = state.copyWith(sequence: scenes, currentIndex: initialIndex);
  }

  /// Appends new scenes to the existing sequence.
  /// Typically used for infinite scroll/pagination.
  void updateSequence(List<Scene> scenes) {
    AppLogStore.instance.add(
      'PlaybackQueue updateSequence: adding ${scenes.length} scenes to current ${state.sequence.length}',
      source: 'playback_queue',
    );
    state = state.copyWith(sequence: [...state.sequence, ...scenes]);
  }

  /// Explicitly sets the current index in the queue.
  /// Typically called when a user selects a specific scene from a list.
  void setIndex(int index, {bool notify = true}) {
    AppLogStore.instance.add(
      'PlaybackQueue setIndex: $index (current=${state.currentIndex}, total=${state.sequence.length}, notify=$notify)',
      source: 'playback_queue',
    );
    if (index >= 0 && index < state.sequence.length) {
      if (notify) {
        state = state.copyWith(currentIndex: index);
      } else {
        // We update the state internally but avoid triggering Riverpod listeners
        // if this was just a high-frequency scroll event.
        // NOTE: state.currentIndex is still updated so the data is fresh.
        state = state.copyWith(currentIndex: index);
      }
    }
  }

  /// Synchronizes the queue index by finding a scene ID within the current sequence.
  /// Useful for recovering state after a deep link or app restart.
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

  /// Returns the next scene in the sequence, if any.
  Scene? getNextScene() {
    AppLogStore.instance.add(
      'PlaybackQueue getNextScene: current=${state.currentIndex}, total=${state.sequence.length}',
      source: 'playback_queue',
    );
    if (state.currentIndex >= 0 &&
        state.currentIndex < state.sequence.length - 1) {
      final nextScene = state.sequence[state.currentIndex + 1];
      AppLogStore.instance.add(
        'PlaybackQueue getNextScene: nextIndex=${state.currentIndex + 1}, returning ${nextScene.id}',
        source: 'playback_queue',
      );
      return nextScene;
    }
    if (state.currentIndex >= 0) {
      AppLogStore.instance.add(
        'PlaybackQueue getNextScene: currentIndex=${state.currentIndex} is at or beyond end of sequence (len=${state.sequence.length})',
        source: 'playback_queue',
      );
    } else {
      AppLogStore.instance.add(
        'PlaybackQueue getNextScene: currentIndex=${state.currentIndex} is invalid',
        source: 'playback_queue',
      );
    }
    return null;
  }

  /// Increments the current index. This should be called *after*
  /// confirming that a next scene is available and playback has started.
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

  /// Returns the previous scene in the sequence, if any.
  Scene? getPreviousScene() {
    if (state.currentIndex > 0) {
      return state.sequence[state.currentIndex - 1];
    }
    return null;
  }

  /// Decrements the current index.
  void playPrevious() {
    final prevIndex = state.currentIndex - 1;
    AppLogStore.instance.add(
      'PlaybackQueue playPrevious: prevIndex=$prevIndex',
      source: 'playback_queue',
    );
    if (prevIndex >= 0) {
      state = state.copyWith(currentIndex: prevIndex);
    }
  }
}
