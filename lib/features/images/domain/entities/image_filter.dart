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
    IntCriterion? id,
    StringCriterion? checksum,
    StringCriterion? path,
    IntCriterion? fileCount,
    IntCriterion? rating100,
    DateCriterion? date,
    StringCriterion? url,
    bool? organized,
    IntCriterion? oCounter,
    MultiCriterion? resolution,
    MultiCriterion? orientation,
    bool? isMissing,
    HierarchicalMultiCriterion? studios,
    HierarchicalMultiCriterion? tags,
    IntCriterion? tagCount,
    HierarchicalMultiCriterion? performerTags,
    MultiCriterion? performers,
    IntCriterion? performerCount,
    bool? performerFavorite,
    IntCriterion? performerAge,
    MultiCriterion? galleries,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
  }) = _ImageFilter;

  factory ImageFilter.empty() => const ImageFilter();

  factory ImageFilter.fromJson(Map<String, dynamic> json) =>
      _$ImageFilterFromJson(json);
}
