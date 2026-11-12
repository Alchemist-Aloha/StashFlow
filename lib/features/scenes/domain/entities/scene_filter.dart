import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'scene_filter.freezed.dart';
part 'scene_filter.g.dart';

@freezed
abstract class SceneFilter with _$SceneFilter {
  const factory SceneFilter({
    String? searchQuery,
    StringCriterion? title,
    IntCriterion? rating100,
    HierarchicalMultiCriterion? studios,
    MultiCriterion? performers,
    HierarchicalMultiCriterion? tags,
    bool? organized,
    DateCriterion? date,
    DateCriterion? productionDate,
    HierarchicalMultiCriterion? folder,
    MultiCriterion? resolutions,
    MultiCriterion? orientations,
    IntCriterion? duration,
    IntCriterion? oCounter,
    DateCriterion? lastPlayedAt,
    bool? interactive,
    IntCriterion? interactiveSpeed,
    IntCriterion? performerAge,
    IntCriterion? bitrate,
    IntCriterion? framerate,
    StringCriterion? videoCodec,
    StringCriterion? audioCodec,
    StringCriterion? oshash,
    StringCriterion? checksum,
    bool? hasMarkers,
    String? isMissing,
    IntCriterion? fileCount,
    IntCriterion? playCount,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
    // Additions matching GraphQL schema
    StringCriterion? code,
    StringCriterion? details,
    StringCriterion? director,
    PhashCriterion? phashDistance,
    bool? performerFavorite,
    StringCriterion? path,
    StringCriterion? url,
    StringCriterion? captions,
    IntCriterion? id,
    IntCriterion? resumeTime,
    IntCriterion? playDuration,
    IntCriterion? tagCount,
    IntCriterion? performerCount,
    IntCriterion? stashIdCount,
    StashIdCriterion? stashIdEndpoint,
    HierarchicalMultiCriterion? groups,
    MultiCriterion? galleries,
    HierarchicalMultiCriterion? performerTags,
    MultiCriterion? duplicated,
    @Default(<CustomFieldCriterion>[]) List<CustomFieldCriterion> customFields,
  }) = _SceneFilter;

  factory SceneFilter.empty() => const SceneFilter();

  factory SceneFilter.fromJson(Map<String, dynamic> json) =>
      _$SceneFilterFromJson(json);
}
