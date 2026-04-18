import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

part 'scene_filter.freezed.dart';
part 'scene_filter.g.dart';

@freezed
abstract class SceneFilter with _$SceneFilter {
  const factory SceneFilter({
    String? searchQuery,
    IntCriterion? rating100,
    HierarchicalMultiCriterion? studios,
    MultiCriterion? performers,
    HierarchicalMultiCriterion? tags,
    bool? organized,
    DateCriterion? date,
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
    StringCriterion? phash,
    bool? hasMarkers,
    bool? isMissing,
    IntCriterion? fileCount,
    IntCriterion? playCount,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
  }) = _SceneFilter;

  factory SceneFilter.empty() => const SceneFilter();

  factory SceneFilter.fromJson(Map<String, dynamic> json) =>
      _$SceneFilterFromJson(json);
}
