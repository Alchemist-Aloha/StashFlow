import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../domain/entities/performer.dart';
import 'performer_list_provider.dart';

final performerRandomNavigationControllerProvider =
    Provider<PerformerRandomNavigationController>(
      (ref) => PerformerRandomNavigationController(ref),
    );

class PerformerRandomNavigationController {
  const PerformerRandomNavigationController(this.ref);

  final Ref ref;

  Future<Performer?> getRandomPerformer({String? excludePerformerId}) {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    return ref
        .read(performerListProvider.notifier)
        .getRandomPerformer(
          useCurrentFilter: useCurrentFilter,
          excludePerformerId: excludePerformerId,
        );
  }
}
