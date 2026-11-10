import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';
part 'image.g.dart';

@freezed
abstract class Image with _$Image {
  const Image._();

  /// GIFs retain image decoding even when Stash reports them as VideoFile.
  bool get isGif =>
      files.isNotEmpty &&
      (files.first.format?.toLowerCase() == 'gif' ||
          files.first.path.toLowerCase().endsWith('.gif'));

  /// Stash serves the primary visual file through paths.image, including clips.
  bool get isClip =>
      files.isNotEmpty && files.first.typename == 'VideoFile' && !isGif;

  const factory Image({
    required String id,
    String? title,
    @JsonKey(name: 'rating100') int? rating100,
    String? date,
    @Default([]) List<String> urls,
    @JsonKey(name: 'studio_id') String? studioId,
    @JsonKey(name: 'studio_name') String? studioName,
    @JsonKey(name: 'performer_ids') @Default([]) List<String> performerIds,
    @JsonKey(name: 'performer_names') @Default([]) List<String> performerNames,
    @JsonKey(name: 'performer_image_paths')
    @Default([])
    List<String?> performerImagePaths,
    required List<ImageFile> files,
    required ImagePaths paths,
  }) = _Image;

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}

@freezed
abstract class ImageFile with _$ImageFile {
  const factory ImageFile({
    required int width,
    required int height,
    required String path,
    @JsonKey(name: '__typename') @Default('ImageFile') String typename,
    String? format,
    int? size,
  }) = _ImageFile;

  factory ImageFile.fromJson(Map<String, dynamic> json) =>
      _$ImageFileFromJson(json);
}

@freezed
abstract class ImagePaths with _$ImagePaths {
  const factory ImagePaths({
    String? thumbnail,
    String? preview,
    String? image,
  }) = _ImagePaths;

  factory ImagePaths.fromJson(Map<String, dynamic> json) =>
      _$ImagePathsFromJson(json);
}
