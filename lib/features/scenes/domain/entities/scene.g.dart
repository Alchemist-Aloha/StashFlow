// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Scene _$SceneFromJson(Map<String, dynamic> json) => _Scene(
  id: json['id'] as String,
  title: json['title'] as String,
  details: json['details'] as String?,
  path: json['path'] as String?,
  date: DateTime.parse(json['date'] as String),
  rating100: (json['rating100'] as num?)?.toInt(),
  oCounter: (json['o_counter'] as num).toInt(),
  organized: json['organized'] as bool,
  interactive: json['interactive'] as bool,
  resumeTime: (json['resume_time'] as num?)?.toDouble(),
  playCount: (json['play_count'] as num).toInt(),
  files: (json['files'] as List<dynamic>)
      .map((e) => SceneFile.fromJson(e as Map<String, dynamic>))
      .toList(),
  paths: ScenePaths.fromJson(json['paths'] as Map<String, dynamic>),
  studioId: json['studio_id'] as String?,
  studioName: json['studio_name'] as String?,
  performerIds: (json['performer_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performerNames: (json['performer_names'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tagIds: (json['tag_ids'] as List<dynamic>).map((e) => e as String).toList(),
  tagNames: (json['tag_names'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SceneToJson(_Scene instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'details': instance.details,
  'path': instance.path,
  'date': instance.date.toIso8601String(),
  'rating100': instance.rating100,
  'o_counter': instance.oCounter,
  'organized': instance.organized,
  'interactive': instance.interactive,
  'resume_time': instance.resumeTime,
  'play_count': instance.playCount,
  'files': instance.files,
  'paths': instance.paths,
  'studio_id': instance.studioId,
  'studio_name': instance.studioName,
  'performer_ids': instance.performerIds,
  'performer_names': instance.performerNames,
  'tag_ids': instance.tagIds,
  'tag_names': instance.tagNames,
};

_SceneFile _$SceneFileFromJson(Map<String, dynamic> json) => _SceneFile(
  format: json['format'] as String?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  videoCodec: json['video_codec'] as String?,
  audioCodec: json['audio_codec'] as String?,
  bitRate: (json['bit_rate'] as num?)?.toInt(),
  duration: (json['duration'] as num?)?.toDouble(),
  frameRate: (json['frame_rate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SceneFileToJson(_SceneFile instance) =>
    <String, dynamic>{
      'format': instance.format,
      'width': instance.width,
      'height': instance.height,
      'video_codec': instance.videoCodec,
      'audio_codec': instance.audioCodec,
      'bit_rate': instance.bitRate,
      'duration': instance.duration,
      'frame_rate': instance.frameRate,
    };

_ScenePaths _$ScenePathsFromJson(Map<String, dynamic> json) => _ScenePaths(
  screenshot: json['screenshot'] as String?,
  preview: json['preview'] as String?,
  stream: json['stream'] as String?,
);

Map<String, dynamic> _$ScenePathsToJson(_ScenePaths instance) =>
    <String, dynamic>{
      'screenshot': instance.screenshot,
      'preview': instance.preview,
      'stream': instance.stream,
    };
