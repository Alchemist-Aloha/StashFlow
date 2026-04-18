import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'gallery_filter.freezed.dart';
part 'gallery_filter.g.dart';

@freezed
abstract class GalleryFilter with _$GalleryFilter {
  const factory GalleryFilter({
    String? searchQuery,
    StringCriterion? title,
    StringCriterion? details,
    StringCriterion? url,
    DateCriterion? date,
    IntCriterion? rating100,
    bool? organized,
    IntCriterion? imageCount,
    HierarchicalMultiCriterion? studios,
    MultiCriterion? performers,
    HierarchicalMultiCriterion? tags,
    bool? isMissing,
    IntCriterion? fileCount,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
    @Deprecated('Use rating100 instead') int? minRating,
    @Deprecated('Use imageCount instead') int? minImageCount,
    @Deprecated('Use imageCount instead') int? maxImageCount,
  }) = _GalleryFilter;

  factory GalleryFilter.empty() => const GalleryFilter();

  factory GalleryFilter.fromJson(Map<String, dynamic> json) =>
      _$GalleryFilterFromJson(json);
}
