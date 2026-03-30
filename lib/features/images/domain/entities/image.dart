import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';
part 'image.g.dart';

@freezed
abstract class Image with _$Image {
  const factory Image({
    required String id,
    String? title,
    @JsonKey(name: 'rating100') int? rating100,
    String? date,
    @Default([]) List<String> urls,
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
