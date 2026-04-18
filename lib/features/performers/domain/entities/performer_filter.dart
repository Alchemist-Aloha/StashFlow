import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'performer_filter.freezed.dart';
part 'performer_filter.g.dart';

@freezed
abstract class PerformerFilter with _$PerformerFilter {
  const factory PerformerFilter({
    String? searchQuery,
    bool? favorite,
    String? gender,
    String? circumcised,
    bool? isMissing,
    HierarchicalMultiCriterion? tags,
    HierarchicalMultiCriterion? groups,
    HierarchicalMultiCriterion? studios,
    StringCriterion? url,
    IntCriterion? rating100,
    IntCriterion? tagCount,
    IntCriterion? sceneCount,
    IntCriterion? imageCount,
    IntCriterion? galleryCount,
    IntCriterion? playCount,
    IntCriterion? oCounter,
    bool? ignoreAutoTag,
    StringCriterion? country,
    IntCriterion? heightCm,
    IntCriterion? birthYear,
    IntCriterion? deathYear,
    IntCriterion? age,
    IntCriterion? weight,
    IntCriterion? penisLength,
    StringCriterion? name,
    StringCriterion? disambiguation,
    StringCriterion? details,
    StringCriterion? ethnicity,
    StringCriterion? hairColor,
    StringCriterion? eyeColor,
    StringCriterion? measurements,
    StringCriterion? fakeTits,
    StringCriterion? tattoos,
    StringCriterion? piercings,
    StringCriterion? aliases,
    DateCriterion? birthdate,
    DateCriterion? deathDate,
    DateCriterion? careerStart,
    DateCriterion? careerEnd,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
  }) = _PerformerFilter;

  factory PerformerFilter.empty() => const PerformerFilter();

  factory PerformerFilter.fromJson(Map<String, dynamic> json) =>
      _$PerformerFilterFromJson(json);
}
