import '../../../../core/domain/entities/criterion.dart';

class SceneMarkerSummary {
  const SceneMarkerSummary({
    required this.id,
    required this.title,
    required this.seconds,
    required this.endSeconds,
    required this.screenshot,
    required this.preview,
    required this.stream,
    required this.primaryTagName,
    required this.tagNames,
    required this.sceneId,
    required this.sceneTitle,
    required this.performerNames,
  });

  final String id;
  final String title;
  final double seconds;
  final double? endSeconds;
  final String? screenshot;
  final String? preview;
  final String? stream;
  final String? primaryTagName;
  final List<String> tagNames;
  final String sceneId;
  final String sceneTitle;
  final List<String> performerNames;
}

class SceneMarkerFilter {
  const SceneMarkerFilter({
    this.tags,
    this.sceneTags,
    this.performers,
    this.scenes,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.sceneDate,
    this.sceneCreatedAt,
    this.sceneUpdatedAt,
  });

  final HierarchicalMultiCriterion? tags;
  final HierarchicalMultiCriterion? sceneTags;
  final MultiCriterion? performers;
  final MultiCriterion? scenes;
  final IntCriterion? duration;
  final DateCriterion? createdAt;
  final DateCriterion? updatedAt;
  final DateCriterion? sceneDate;
  final DateCriterion? sceneCreatedAt;
  final DateCriterion? sceneUpdatedAt;

  factory SceneMarkerFilter.fromJson(Map<String, dynamic> json) {
    return SceneMarkerFilter(
      tags: _hierarchicalCriterionFromJson(json['tags']),
      sceneTags: _hierarchicalCriterionFromJson(json['sceneTags']),
      performers: _multiCriterionFromJson(json['performers']),
      scenes: _multiCriterionFromJson(json['scenes']),
      duration: _intCriterionFromJson(json['duration']),
      createdAt: _dateCriterionFromJson(json['createdAt']),
      updatedAt: _dateCriterionFromJson(json['updatedAt']),
      sceneDate: _dateCriterionFromJson(json['sceneDate']),
      sceneCreatedAt: _dateCriterionFromJson(json['sceneCreatedAt']),
      sceneUpdatedAt: _dateCriterionFromJson(json['sceneUpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': tags?.toJson(),
      'sceneTags': sceneTags?.toJson(),
      'performers': performers?.toJson(),
      'scenes': scenes?.toJson(),
      'duration': duration?.toJson(),
      'createdAt': createdAt?.toJson(),
      'updatedAt': updatedAt?.toJson(),
      'sceneDate': sceneDate?.toJson(),
      'sceneCreatedAt': sceneCreatedAt?.toJson(),
      'sceneUpdatedAt': sceneUpdatedAt?.toJson(),
    };
  }

  bool get isEmpty =>
      tags == null &&
      sceneTags == null &&
      performers == null &&
      scenes == null &&
      duration == null &&
      createdAt == null &&
      updatedAt == null &&
      sceneDate == null &&
      sceneCreatedAt == null &&
      sceneUpdatedAt == null;

  SceneMarkerFilter copyWith({
    HierarchicalMultiCriterion? tags,
    HierarchicalMultiCriterion? sceneTags,
    MultiCriterion? performers,
    MultiCriterion? scenes,
    IntCriterion? duration,
    DateCriterion? createdAt,
    DateCriterion? updatedAt,
    DateCriterion? sceneDate,
    DateCriterion? sceneCreatedAt,
    DateCriterion? sceneUpdatedAt,
    bool clearTags = false,
    bool clearSceneTags = false,
    bool clearPerformers = false,
    bool clearScenes = false,
    bool clearDuration = false,
    bool clearCreatedAt = false,
    bool clearUpdatedAt = false,
    bool clearSceneDate = false,
    bool clearSceneCreatedAt = false,
    bool clearSceneUpdatedAt = false,
  }) {
    return SceneMarkerFilter(
      tags: clearTags ? null : (tags ?? this.tags),
      sceneTags: clearSceneTags ? null : (sceneTags ?? this.sceneTags),
      performers: clearPerformers ? null : (performers ?? this.performers),
      scenes: clearScenes ? null : (scenes ?? this.scenes),
      duration: clearDuration ? null : (duration ?? this.duration),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      sceneDate: clearSceneDate ? null : (sceneDate ?? this.sceneDate),
      sceneCreatedAt: clearSceneCreatedAt
          ? null
          : (sceneCreatedAt ?? this.sceneCreatedAt),
      sceneUpdatedAt: clearSceneUpdatedAt
          ? null
          : (sceneUpdatedAt ?? this.sceneUpdatedAt),
    );
  }
}

Map<String, dynamic>? _asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

HierarchicalMultiCriterion? _hierarchicalCriterionFromJson(Object? value) {
  final map = _asJsonMap(value);
  return map == null ? null : HierarchicalMultiCriterion.fromJson(map);
}

MultiCriterion? _multiCriterionFromJson(Object? value) {
  final map = _asJsonMap(value);
  return map == null ? null : MultiCriterion.fromJson(map);
}

IntCriterion? _intCriterionFromJson(Object? value) {
  final map = _asJsonMap(value);
  return map == null ? null : IntCriterion.fromJson(map);
}

DateCriterion? _dateCriterionFromJson(Object? value) {
  final map = _asJsonMap(value);
  return map == null ? null : DateCriterion.fromJson(map);
}
