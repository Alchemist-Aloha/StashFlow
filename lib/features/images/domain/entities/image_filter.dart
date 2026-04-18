import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'image_filter.freezed.dart';
part 'image_filter.g.dart';

@freezed
abstract class ImageFilter with _$ImageFilter {
  const factory ImageFilter({
    String? searchQuery,
    StringCriterion? title,
    StringCriterion? details,
    StringCriterion? url,
    DateCriterion? date,
    IntCriterion? rating100,
    bool? organized,
    IntCriterion? oCounter,
    MultiCriterion? resolutions,
    MultiCriterion? orientations,
    StringCriterion? photographer,
    MultiCriterion? galleries,
    HierarchicalMultiCriterion? studios,
    MultiCriterion? performers,
    HierarchicalMultiCriterion? tags,
    bool? isMissing,
    IntCriterion? fileCount,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
    @Deprecated('Use rating100 instead') int? minRating,
  }) = _ImageFilter;

  factory ImageFilter.empty() => const ImageFilter();

  factory ImageFilter.fromJson(Map<String, dynamic> json) =>
      _$ImageFilterFromJson(json);
}
