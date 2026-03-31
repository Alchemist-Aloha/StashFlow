// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryFilter _$GalleryFilterFromJson(Map<String, dynamic> json) =>
    _GalleryFilter(
      searchQuery: json['searchQuery'] as String?,
      minRating: (json['minRating'] as num?)?.toInt(),
      organized: json['organized'] as bool?,
      minImageCount: (json['minImageCount'] as num?)?.toInt(),
      maxImageCount: (json['maxImageCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GalleryFilterToJson(_GalleryFilter instance) =>
    <String, dynamic>{
      'searchQuery': instance.searchQuery,
      'minRating': instance.minRating,
      'organized': instance.organized,
      'minImageCount': instance.minImageCount,
      'maxImageCount': instance.maxImageCount,
    };
