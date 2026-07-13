import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../domain/entities/gallery.dart';
import 'gallery_list_provider.dart';

final galleryRandomNavigationControllerProvider =
    Provider<GalleryRandomNavigationController>(
      (ref) => GalleryRandomNavigationController(ref),
    );

class GalleryRandomNavigationController {
  const GalleryRandomNavigationController(this.ref);

  final Ref ref;

  Future<Gallery?> getRandomGallery({
    String? performerId,
    String? studioId,
    String? tagId,
    String? excludeGalleryId,
  }) {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    return ref
        .read(galleryListProvider.notifier)
        .getRandomGallery(
          useCurrentFilter: useCurrentFilter,
          performerId: performerId,
          studioId: studioId,
          tagId: tagId,
          excludeGalleryId: excludeGalleryId,
        );
  }
}
