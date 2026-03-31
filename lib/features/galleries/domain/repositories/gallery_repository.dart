import '../entities/gallery.dart';
import '../entities/gallery_filter.dart';

abstract class GalleryRepository {
  Future<List<Gallery>> findGalleries({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GalleryFilter? galleryFilter,
    String? performerId,
  });
  Future<Gallery> getGalleryById(String id, {bool refresh = false});
}
