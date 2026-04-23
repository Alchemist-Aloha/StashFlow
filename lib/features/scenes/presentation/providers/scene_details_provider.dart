import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import 'scene_list_provider.dart';

part 'scene_details_provider.g.dart';

@riverpod
class SceneDetails extends _$SceneDetails {
  @override
  FutureOr<Scene> build(String id) async {
    ref.keepAlive();
    final repository = ref.read(sceneRepositoryProvider);
    return repository.getSceneById(id);
  }

  void updateState(Scene scene) {
    state = AsyncData(scene);
  }
}
