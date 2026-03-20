// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SceneFilter _$SceneFilterFromJson(Map<String, dynamic> json) => _SceneFilter(
  searchQuery: json['searchQuery'] as String?,
  minRating: (json['minRating'] as num?)?.toInt(),
  studioId: json['studioId'] as String?,
  performerIds: (json['performerIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  includeTags: (json['includeTags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  excludeTags: (json['excludeTags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isWatched: json['isWatched'] as bool?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  resolutions: (json['resolutions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  orientations: (json['orientations'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  minDuration: (json['minDuration'] as num?)?.toInt(),
  maxDuration: (json['maxDuration'] as num?)?.toInt(),
);

Map<String, dynamic> _$SceneFilterToJson(_SceneFilter instance) =>
    <String, dynamic>{
      'searchQuery': instance.searchQuery,
      'minRating': instance.minRating,
      'studioId': instance.studioId,
      'performerIds': instance.performerIds,
      'includeTags': instance.includeTags,
      'excludeTags': instance.excludeTags,
      'isWatched': instance.isWatched,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'resolutions': instance.resolutions,
      'orientations': instance.orientations,
      'minDuration': instance.minDuration,
      'maxDuration': instance.maxDuration,
    };
