import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';

part 'scene_list_provider.g.dart';

// Provider for Repository interface (implemented by data layer later)
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  throw UnimplementedError();
});

@riverpod
class SceneList extends _$SceneList {
  @override
  FutureOr<List<Scene>> build() async {
    final repository = ref.watch(sceneRepositoryProvider);
    return repository.findScenes();
  }
}
