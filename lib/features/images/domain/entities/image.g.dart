// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Image _$ImageFromJson(Map<String, dynamic> json) => _Image(
  id: json['id'] as String,
  title: json['title'] as String?,
  rating100: (json['rating100'] as num?)?.toInt(),
  date: json['date'] as String?,
  urls:
      (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  files: (json['files'] as List<dynamic>)
      .map((e) => ImageFile.fromJson(e as Map<String, dynamic>))
      .toList(),
  paths: ImagePaths.fromJson(json['paths'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ImageToJson(_Image instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'rating100': instance.rating100,
  'date': instance.date,
  'urls': instance.urls,
  'files': instance.files,
  'paths': instance.paths,
};

_ImageFile _$ImageFileFromJson(Map<String, dynamic> json) => _ImageFile(
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  path: json['path'] as String,
);

Map<String, dynamic> _$ImageFileToJson(_ImageFile instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'path': instance.path,
    };

_ImagePaths _$ImagePathsFromJson(Map<String, dynamic> json) => _ImagePaths(
  thumbnail: json['thumbnail'] as String?,
  preview: json['preview'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$ImagePathsToJson(_ImagePaths instance) =>
    <String, dynamic>{
      'thumbnail': instance.thumbnail,
      'preview': instance.preview,
      'image': instance.image,
    };
