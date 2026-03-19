import '../entities/gallery.dart';

abstract class GalleryRepository {
  Future<List<Gallery>> findGalleries({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  });
}
