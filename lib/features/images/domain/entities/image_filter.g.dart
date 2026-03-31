// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageFilter _$ImageFilterFromJson(Map<String, dynamic> json) => _ImageFilter(
  searchQuery: json['searchQuery'] as String?,
  minRating: (json['minRating'] as num?)?.toInt(),
  organized: json['organized'] as bool?,
  resolutions: (json['resolutions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  orientations: (json['orientations'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ImageFilterToJson(_ImageFilter instance) =>
    <String, dynamic>{
      'searchQuery': instance.searchQuery,
      'minRating': instance.minRating,
      'organized': instance.organized,
      'resolutions': instance.resolutions,
      'orientations': instance.orientations,
    };
