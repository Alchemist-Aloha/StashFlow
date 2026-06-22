import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../../../core/utils/app_log_store.dart';

part 'playback_queue_provider.g.dart';

class PlaybackQueueIds {
  const PlaybackQueueIds._();

  static const main = 'main-scenes';

  static String sceneMoreFromStudio({
    required String sceneId,
    required String studioId,
  }) {
    return 'scene:$sceneId:more-from-studio:$studioId';
  }

  static String studioStrip(String studioId) => 'studio:$studioId:strip';

  static String performerStrip(String performerId) =>
      'performer:$performerId:strip';

  static String tagStrip(String tagId) => 'tag:$tagId:strip';

  static String groupStrip(String groupId) => 'group:$groupId:strip';

  static String studioMedia(String studioId) => 'studio:$studioId:media';

  static String performerMedia(String performerId) =>
      'performer:$performerId:media';

  static String tagMedia(String tagId) => 'tag:$tagId:media';

  static String groupMedia(String groupId) => 'group:$groupId:media';
}

class PlaybackQueueSnapshot {
  final List<Scene> sequence;
  final int currentIndex;

  const PlaybackQueueSnapshot({
    this.sequence = const [],
    this.currentIndex = -1,
  });

  PlaybackQueueSnapshot copyWith({List<Scene>? sequence, int? currentIndex}) {
    return PlaybackQueueSnapshot(
      sequence: sequence ?? this.sequence,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// Represents the current state of the playback queue.
class PlaybackQueueState {
  final String activeQueueId;

  final Map<String, PlaybackQueueSnapshot> queues;

  PlaybackQueueState({
    List<Scene> sequence = const [],
    int currentIndex = -1,
    this.activeQueueId = PlaybackQueueIds.main,
    Map<String, PlaybackQueueSnapshot>? queues,
  }) : queues =
           queues ??
           {
             activeQueueId: PlaybackQueueSnapshot(
               sequence: sequence,
               currentIndex: currentIndex,
             ),
           };

  PlaybackQueueSnapshot get activeQueue =>
      queues[activeQueueId] ?? const PlaybackQueueSnapshot();

  /// The list of scenes in the current active playback sequence.
  List<Scene> get sequence => activeQueue.sequence;

  /// The index of the currently active scene within [sequence].
  /// A value of -1 indicates no scene is currently selected or active.
  int get currentIndex => activeQueue.currentIndex;

  PlaybackQueueState copyWith({
    List<Scene>? sequence,
    int? currentIndex,
    String? activeQueueId,
    Map<String, PlaybackQueueSnapshot>? queues,
  }) {
    final nextActiveQueueId = activeQueueId ?? this.activeQueueId;
    final nextQueues = Map<String, PlaybackQueueSnapshot>.from(
      queues ?? this.queues,
    );

    if (sequence != null || currentIndex != null) {
      final existing =
          nextQueues[nextActiveQueueId] ?? const PlaybackQueueSnapshot();
      nextQueues[nextActiveQueueId] = existing.copyWith(
        sequence: sequence,
        currentIndex: currentIndex,
      );
    }

    return PlaybackQueueState(
      activeQueueId: nextActiveQueueId,
      queues: nextQueues,
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
  void setSequence(
    List<Scene> scenes,
    int initialIndex, {
    String? queueId,
    bool activate = true,
  }) {
    final targetQueueId = queueId ?? state.activeQueueId;
    final targetQueue =
        state.queues[targetQueueId] ?? const PlaybackQueueSnapshot();

    AppLogStore.instance.add(
      'PlaybackQueue setSequence: queue=$targetQueueId scenes=${scenes.length}, initialIndex=$initialIndex, currentState=(index=${targetQueue.currentIndex}, seqLen=${targetQueue.sequence.length}), activate=$activate',
      source: 'playback_queue',
    );

    // Same-list / subset detection logic:
    // If the new list matches our current sequence's start, we avoid resetting the index
    // if the caller passed -1 (which usually means "just refresh the data").
    if (targetQueue.sequence.length >= scenes.length &&
        scenes.isNotEmpty &&
        targetQueue.sequence.isNotEmpty) {
      if (targetQueue.sequence[0].id == scenes[0].id) {
        AppLogStore.instance.add(
          'PlaybackQueue setSequence: detected same/subset list for queue=$targetQueueId (first scene match), early return (initialIndex=$initialIndex)',
          source: 'playback_queue',
        );
        final nextQueues = Map<String, PlaybackQueueSnapshot>.from(
          state.queues,
        );
        if (initialIndex != -1) {
          nextQueues[targetQueueId] = targetQueue.copyWith(
            currentIndex: initialIndex,
          );
        }
        state = state.copyWith(
          activeQueueId: activate ? targetQueueId : null,
          queues: nextQueues,
        );
        return;
      }
    }

    final nextQueues = Map<String, PlaybackQueueSnapshot>.from(state.queues);
    nextQueues[targetQueueId] = PlaybackQueueSnapshot(
      sequence: scenes,
      currentIndex: initialIndex,
    );

    AppLogStore.instance.add(
      'PlaybackQueue setSequence: updating queue=$targetQueueId and setting index to $initialIndex',
      source: 'playback_queue',
    );
    state = state.copyWith(
      activeQueueId: activate ? targetQueueId : null,
      queues: nextQueues,
    );
  }

  /// Activates a retained queue without changing its sequence.
  void activateQueue(String queueId) {
    if (!state.queues.containsKey(queueId)) return;
    state = state.copyWith(activeQueueId: queueId);
  }

  void setSequenceForScene(String queueId, List<Scene> scenes, String sceneId) {
    final index = scenes.indexWhere((scene) => scene.id == sceneId);
    if (index == -1) return;
    setSequence(scenes, index, queueId: queueId);
  }

  /// Appends new scenes to the existing sequence.
  /// Typically used for infinite scroll/pagination.
  void updateSequence(List<Scene> scenes, {String? queueId}) {
    final targetQueueId = queueId ?? state.activeQueueId;
    final targetQueue =
        state.queues[targetQueueId] ?? const PlaybackQueueSnapshot();

    AppLogStore.instance.add(
      'PlaybackQueue updateSequence: queue=$targetQueueId adding ${scenes.length} scenes to current ${targetQueue.sequence.length}',
      source: 'playback_queue',
    );
    final nextQueues = Map<String, PlaybackQueueSnapshot>.from(state.queues);
    nextQueues[targetQueueId] = targetQueue.copyWith(
      sequence: [...targetQueue.sequence, ...scenes],
    );
    state = state.copyWith(queues: nextQueues);
  }

  /// Explicitly sets the current index in the queue.
  /// Typically called when a user selects a specific scene from a list.
  void setIndex(int index, {bool notify = true, String? queueId}) {
    final targetQueueId = queueId ?? state.activeQueueId;
    final targetQueue =
        state.queues[targetQueueId] ?? const PlaybackQueueSnapshot();

    AppLogStore.instance.add(
      'PlaybackQueue setIndex: queue=$targetQueueId $index (current=${targetQueue.currentIndex}, total=${targetQueue.sequence.length}, notify=$notify)',
      source: 'playback_queue',
    );
    if (index >= 0 && index < targetQueue.sequence.length) {
      final nextQueues = Map<String, PlaybackQueueSnapshot>.from(state.queues);
      nextQueues[targetQueueId] = targetQueue.copyWith(currentIndex: index);
      state = state.copyWith(activeQueueId: targetQueueId, queues: nextQueues);
    }
  }

  /// Synchronizes the queue index by finding a scene ID within the current sequence.
  /// Useful for recovering state after a deep link or app restart.
  void findAndSetIndex(String sceneId, {String? queueId}) {
    if (sceneId.isEmpty) return;
    final targetQueueId = queueId ?? state.activeQueueId;
    final targetQueue =
        state.queues[targetQueueId] ?? const PlaybackQueueSnapshot();
    final index = targetQueue.sequence.indexWhere((s) => s.id == sceneId);
    AppLogStore.instance.add(
      'PlaybackQueue findAndSetIndex: queue=$targetQueueId sceneId=$sceneId, found at index $index',
      source: 'playback_queue',
    );
    if (index != -1) {
      final nextQueues = Map<String, PlaybackQueueSnapshot>.from(state.queues);
      nextQueues[targetQueueId] = targetQueue.copyWith(currentIndex: index);
      state = state.copyWith(queues: nextQueues);
    }
  }

  /// Removes a scene from every retained playback queue.
  ///
  /// If the removed scene was the current item, prefer the previous item so
  /// back-navigation to the previous details page keeps queue state aligned.
  void removeScene(String sceneId) {
    if (sceneId.isEmpty) return;

    final nextQueues = <String, PlaybackQueueSnapshot>{};
    var changed = false;

    for (final entry in state.queues.entries) {
      final queue = entry.value;
      final removedIndex = queue.sequence.indexWhere((s) => s.id == sceneId);
      if (removedIndex == -1) {
        nextQueues[entry.key] = queue;
        continue;
      }

      changed = true;
      final nextSequence = queue.sequence
          .where((scene) => scene.id != sceneId)
          .toList(growable: false);

      var nextIndex = queue.currentIndex;
      if (nextSequence.isEmpty) {
        nextIndex = -1;
      } else if (queue.currentIndex < 0) {
        nextIndex = -1;
      } else {
        final currentSceneWasRemoved =
            queue.currentIndex < queue.sequence.length &&
            queue.sequence[queue.currentIndex].id == sceneId;
        final remainingBeforeCurrent = queue.sequence
            .take(queue.currentIndex)
            .where((scene) => scene.id != sceneId)
            .length;

        if (currentSceneWasRemoved) {
          nextIndex = (remainingBeforeCurrent - 1).clamp(
            0,
            nextSequence.length - 1,
          );
        } else {
          nextIndex = remainingBeforeCurrent.clamp(0, nextSequence.length - 1);
        }
      }

      AppLogStore.instance.add(
        'PlaybackQueue removeScene: queue=${entry.key} scene=$sceneId removedIndex=$removedIndex nextIndex=$nextIndex nextLen=${nextSequence.length}',
        source: 'playback_queue',
      );
      nextQueues[entry.key] = PlaybackQueueSnapshot(
        sequence: nextSequence,
        currentIndex: nextIndex,
      );
    }

    if (!changed) return;
    state = state.copyWith(queues: nextQueues);
  }

  /// Returns the next scene in the sequence, if any.
  Scene? getNextScene() {
    AppLogStore.instance.add(
      'PlaybackQueue getNextScene: queue=${state.activeQueueId} current=${state.currentIndex}, total=${state.sequence.length}',
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
      'PlaybackQueue playNext: queue=${state.activeQueueId} nextIndex=$nextIndex, total=${state.sequence.length}',
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
      'PlaybackQueue playPrevious: queue=${state.activeQueueId} prevIndex=$prevIndex',
      source: 'playback_queue',
    );
    if (prevIndex >= 0) {
      state = state.copyWith(currentIndex: prevIndex);
    }
  }
}
