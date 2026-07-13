import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../domain/entities/tag.dart';
import 'tag_list_provider.dart';

final tagRandomNavigationControllerProvider =
    Provider<TagRandomNavigationController>(
      (ref) => TagRandomNavigationController(ref),
    );

class TagRandomNavigationController {
  const TagRandomNavigationController(this.ref);

  final Ref ref;

  Future<Tag?> getRandomTag({String? excludeTagId}) {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    return ref
        .read(tagListProvider.notifier)
        .getRandomTag(
          useCurrentFilter: useCurrentFilter,
          excludeTagId: excludeTagId,
        );
  }
}
