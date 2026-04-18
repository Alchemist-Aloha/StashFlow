import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'studio_filter.freezed.dart';
part 'studio_filter.g.dart';

@freezed
abstract class StudioFilter with _$StudioFilter {
  const factory StudioFilter({
    String? searchQuery,
    bool? favorite,
    StringCriterion? name,
    StringCriterion? details,
    HierarchicalMultiCriterion? parentStudios,
    bool? isMissing,
    HierarchicalMultiCriterion? tags,
    IntCriterion? rating100,
    bool? ignoreAutoTag,
    bool? organized,
    IntCriterion? tagCount,
    IntCriterion? sceneCount,
    IntCriterion? imageCount,
    IntCriterion? galleryCount,
    StringCriterion? url,
    StringCriterion? aliases,
    IntCriterion? childCount,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
  }) = _StudioFilter;

  factory StudioFilter.empty() => const StudioFilter();

  factory StudioFilter.fromJson(Map<String, dynamic> json) =>
      _$StudioFilterFromJson(json);
}
