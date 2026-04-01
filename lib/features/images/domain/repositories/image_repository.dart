import '../entities/image.dart';
import '../entities/image_filter.dart';

abstract class ImageRepository {
  Future<List<Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
    ImageFilter? imageFilter,
  });
  Future<Image> getImageById(String id, {bool refresh = false});
  Future<void> updateImageRating(String id, int rating100);
}
