import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../domain/entities/scene.dart';
import 'scene_list_provider.dart';

final sceneRandomNavigationControllerProvider =
    Provider<SceneRandomNavigationController>(
      (ref) => SceneRandomNavigationController(ref),
    );

class SceneRandomNavigationController {
  const SceneRandomNavigationController(this.ref);

  final Ref ref;

  Future<Scene?> getRandomScene({String? excludeSceneId}) {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    return ref
        .read(sceneListProvider.notifier)
        .getRandomScene(
          useCurrentFilter: useCurrentFilter,
          excludeSceneId: excludeSceneId,
        );
  }
}
