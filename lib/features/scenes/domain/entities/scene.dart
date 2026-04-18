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
    required List<SceneFile> files,
    required ScenePaths paths,
    @Default([]) List<VideoCaption> captions,
    @JsonKey(name: 'urls') required List<String> urls,
    @JsonKey(name: 'studio_id') required String? studioId,
    @JsonKey(name: 'studio_name') required String? studioName,
    @JsonKey(name: 'studio_image_path') required String? studioImagePath,
    @JsonKey(name: 'performer_ids') required List<String> performerIds,
    @JsonKey(name: 'performer_names') required List<String> performerNames,
    @JsonKey(name: 'performer_image_paths')
    required List<String?> performerImagePaths,
    @JsonKey(name: 'tag_ids') required List<String> tagIds,
    @JsonKey(name: 'tag_names') required List<String> tagNames,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
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
  const factory Fingerprint({
    required String type,
    required String value,
  }) = _Fingerprint;

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
  }) = _ScenePaths;

  factory ScenePaths.fromJson(Map<String, dynamic> json) =>
      _$ScenePathsFromJson(json);
}
