import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_filter.freezed.dart';
part 'image_filter.g.dart';

@freezed
abstract class ImageFilter with _$ImageFilter {
  const factory ImageFilter({
    String? searchQuery,
    int? minRating,
    bool? organized,
    List<String>? resolutions,
    List<String>? orientations,
  }) = _ImageFilter;

  factory ImageFilter.empty() => const ImageFilter();

  factory ImageFilter.fromJson(Map<String, dynamic> json) =>
      _$ImageFilterFromJson(json);
}
