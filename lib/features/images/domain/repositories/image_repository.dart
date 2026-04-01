import '../entities/image.dart';
import '../entities/image_filter.dart';

abstract class ImageRepository {
  /// Finds images using optional paging, sorting, and filter criteria.
  ///
  /// This is the primary entry point for image list/grid views and supports
  /// both global image browsing and gallery-scoped browsing via [galleryId].
  Future<List<Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
    ImageFilter? imageFilter,
  });

  /// Fetches a single image by [id].
  ///
  /// When [refresh] is true, implementations should bypass stale cache where
  /// possible and fetch a fresh copy from the server.
  Future<Image> getImageById(String id, {bool refresh = false});

  /// Updates an image's `rating100` value in the backing data source.
  ///
  /// [rating100] is expected in the inclusive range `0..100` where:
  /// - `0` means unrated / cleared
  /// - `100` means maximum rating
  Future<void> updateImageRating(String id, int rating100);
}
