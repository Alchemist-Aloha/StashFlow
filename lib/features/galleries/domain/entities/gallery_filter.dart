import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_filter.freezed.dart';
part 'gallery_filter.g.dart';

@freezed
abstract class GalleryFilter with _$GalleryFilter {
  const factory GalleryFilter({
    String? searchQuery,
    int? minRating,
    bool? organized,
    int? minImageCount,
    int? maxImageCount,
  }) = _GalleryFilter;

  factory GalleryFilter.empty() => const GalleryFilter();

  factory GalleryFilter.fromJson(Map<String, dynamic> json) =>
      _$GalleryFilterFromJson(json);
}
