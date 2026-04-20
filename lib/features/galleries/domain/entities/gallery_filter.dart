import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'gallery_filter.freezed.dart';
part 'gallery_filter.g.dart';

@freezed
abstract class GalleryFilter with _$GalleryFilter {
  const factory GalleryFilter({
    String? searchQuery,
    IntCriterion? id,
    StringCriterion? title,
    StringCriterion? details,
    StringCriterion? checksum,
    StringCriterion? path,
    IntCriterion? fileCount,
    bool? isMissing,
    bool? isZip,
    IntCriterion? rating100,
    bool? organized,
    MultiCriterion? averageResolution,
    bool? hasChapters,
    MultiCriterion? scenes,
    HierarchicalMultiCriterion? studios,
    HierarchicalMultiCriterion? tags,
    IntCriterion? tagCount,
    HierarchicalMultiCriterion? performerTags,
    MultiCriterion? performers,
    IntCriterion? performerCount,
    bool? performerFavorite,
    IntCriterion? performerAge,
    IntCriterion? imageCount,
    StringCriterion? url,
    DateCriterion? date,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
  }) = _GalleryFilter;

  factory GalleryFilter.empty() => const GalleryFilter();

  factory GalleryFilter.fromJson(Map<String, dynamic> json) =>
      _$GalleryFilterFromJson(json);
}
