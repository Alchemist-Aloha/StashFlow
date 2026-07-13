import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../domain/entities/studio.dart';
import 'studio_list_provider.dart';

final studioRandomNavigationControllerProvider =
    Provider<StudioRandomNavigationController>(
      (ref) => StudioRandomNavigationController(ref),
    );

class StudioRandomNavigationController {
  const StudioRandomNavigationController(this.ref);

  final Ref ref;

  Future<Studio?> getRandomStudio({String? excludeStudioId}) {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    return ref
        .read(studioListProvider.notifier)
        .getRandomStudio(
          useCurrentFilter: useCurrentFilter,
          excludeStudioId: excludeStudioId,
        );
  }
}
