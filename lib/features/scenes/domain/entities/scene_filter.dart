import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene_filter.freezed.dart';
part 'scene_filter.g.dart';

@freezed
abstract class SceneFilter with _$SceneFilter {
  const factory SceneFilter({
    String? searchQuery,
    int? minRating,
    String? studioId,
    List<String>? performerIds,
    List<String>? includeTags,
    List<String>? excludeTags,
    bool? isWatched,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? resolutions,
    List<String>? orientations,
    int? minDuration,
    int? maxDuration,
  }) = _SceneFilter;

  factory SceneFilter.empty() => const SceneFilter();

  factory SceneFilter.fromJson(Map<String, dynamic> json) =>
      _$SceneFilterFromJson(json);
}
