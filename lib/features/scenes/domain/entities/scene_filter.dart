import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene_filter.freezed.dart';

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
  }) = _SceneFilter;

  factory SceneFilter.empty() => const SceneFilter();
}
