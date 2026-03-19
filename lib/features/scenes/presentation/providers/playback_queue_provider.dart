import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import 'video_player_provider.dart';

part 'playback_queue_provider.g.dart';

@riverpod
class PlaybackQueue extends _$PlaybackQueue {
  @override
  List<Scene> build() {
    return [];
  }

  void add(Scene scene) {
    if (!state.any((s) => s.id == scene.id)) {
      state = [...state, scene];
    }
  }

  void remove(String sceneId) {
    state = state.where((s) => s.id != sceneId).toList();
  }

  void clear() {
    state = [];
  }

  Scene? getNextScene() {
    final activeScene = ref.read(playerStateProvider).activeScene;
    if (activeScene == null || state.isEmpty) return null;

    final index = state.indexWhere((s) => s.id == activeScene.id);
    if (index != -1 && index < state.length - 1) {
      return state[index + 1];
    }
    return null;
  }

  void fillFromList(List<Scene> scenes) {
    state = scenes;
  }
}
