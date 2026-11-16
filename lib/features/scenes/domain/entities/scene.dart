import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

@freezed
abstract class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String title,
    String? details,
    String? path,
    required DateTime date,
    required int? rating100,
    @JsonKey(name: 'o_counter') required int oCounter,
    required bool organized,
    required bool interactive,
    @JsonKey(name: 'resume_time') required double? resumeTime,
    @JsonKey(name: 'play_count') required int playCount,
    @JsonKey(name: 'play_duration') required double? playDuration,
    required List<SceneFile> files,
    required ScenePaths paths,
    @Default([]) List<VideoCaption> captions,
    @JsonKey(name: 'urls') required List<String> urls,
    @JsonKey(name: 'studio_id') required String? studioId,
    @JsonKey(name: 'studio_name') required String? studioName,
    @JsonKey(name: 'studio_image_path') required String? studioImagePath,
    @JsonKey(name: 'performer_ids') required List<String> performerIds,
    @JsonKey(name: 'performer_names') required List<String> performerNames,
    @JsonKey(name: 'performer_birthdates')
    @Default([])
    List<String?> performerBirthdates,
    @JsonKey(name: 'performer_image_paths')
    required List<String?> performerImagePaths,
    @JsonKey(name: 'tag_ids') required List<String> tagIds,
    @JsonKey(name: 'tag_names') required List<String> tagNames,
    @Default([]) List<SceneMarker> markers,
    // Details-only metadata; list queries leave these at their defaults.
    String? code,
    String? director,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'last_played_at') String? lastPlayedAt,
    @JsonKey(name: 'custom_fields')
    @Default({})
    Map<String, dynamic> customFields,
    @JsonKey(name: 'stash_ids') @Default([]) List<SceneStashId> stashIds,
    @Default([]) List<SceneGroupMembership> groups,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
}

/// A group this scene belongs to, with its position in that group.
@freezed
abstract class SceneGroupMembership with _$SceneGroupMembership {
  const factory SceneGroupMembership({
    required String id,
    required String name,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'scene_index') int? sceneIndex,
  }) = _SceneGroupMembership;

  factory SceneGroupMembership.fromJson(Map<String, dynamic> json) =>
      _$SceneGroupMembershipFromJson(json);
}

/// A stash-box identifier linking this scene to a remote database entry.
@freezed
abstract class SceneStashId with _$SceneStashId {
  const factory SceneStashId({
    required String endpoint,
    @JsonKey(name: 'stash_id') required String stashId,
  }) = _SceneStashId;

  factory SceneStashId.fromJson(Map<String, dynamic> json) =>
      _$SceneStashIdFromJson(json);
}

@freezed
abstract class SceneMarker with _$SceneMarker {
  const factory SceneMarker({
    required String id,
    required String title,
    required double seconds,
    @JsonKey(name: 'end_seconds') required double? endSeconds,
    required String? screenshot,
    required String? preview,
    required String? stream,
    @JsonKey(name: 'primary_tag_id') required String? primaryTagId,
    @JsonKey(name: 'primary_tag_name') required String? primaryTagName,
    @JsonKey(name: 'tag_ids') required List<String> tagIds,
    @JsonKey(name: 'tag_names') required List<String> tagNames,
  }) = _SceneMarker;

  factory SceneMarker.fromJson(Map<String, dynamic> json) =>
      _$SceneMarkerFromJson(json);
}

@freezed
abstract class VideoCaption with _$VideoCaption {
  const factory VideoCaption({
    @JsonKey(name: 'language_code') required String languageCode,
    @JsonKey(name: 'caption_type') required String captionType,
  }) = _VideoCaption;

  factory VideoCaption.fromJson(Map<String, dynamic> json) =>
      _$VideoCaptionFromJson(json);
}

@freezed
abstract class SceneFile with _$SceneFile {
  const factory SceneFile({
    required String? format,
    int? size,
    required int? width,
    required int? height,
    @JsonKey(name: 'video_codec') required String? videoCodec,
    @JsonKey(name: 'audio_codec') required String? audioCodec,
    @JsonKey(name: 'bit_rate') required int? bitRate,
    required double? duration,
    @JsonKey(name: 'frame_rate') required double? frameRate,
    @Default([]) List<Fingerprint> fingerprints,
  }) = _SceneFile;

  factory SceneFile.fromJson(Map<String, dynamic> json) =>
      _$SceneFileFromJson(json);
}

@freezed
abstract class Fingerprint with _$Fingerprint {
  const factory Fingerprint({required String type, required String value}) =
      _Fingerprint;

  factory Fingerprint.fromJson(Map<String, dynamic> json) =>
      _$FingerprintFromJson(json);
}

@freezed
abstract class ScenePaths with _$ScenePaths {
  const factory ScenePaths({
    required String? screenshot,
    required String? preview,
    required String? stream,
    @Default(null) String? caption,
    @Default(null) String? vtt,
    @Default(null) String? sprite,
  }) = _ScenePaths;

  factory ScenePaths.fromJson(Map<String, dynamic> json) =>
      _$ScenePathsFromJson(json);
}
