// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => _UpdateInfo(
  isUpdateAvailable: json['isUpdateAvailable'] as bool,
  latestVersion: json['latestVersion'] as String,
  currentVersion: json['currentVersion'] as String,
  releaseUrl: json['releaseUrl'] as String,
  releaseNotes: json['releaseNotes'] as String?,
);

Map<String, dynamic> _$UpdateInfoToJson(_UpdateInfo instance) =>
    <String, dynamic>{
      'isUpdateAvailable': instance.isUpdateAvailable,
      'latestVersion': instance.latestVersion,
      'currentVersion': instance.currentVersion,
      'releaseUrl': instance.releaseUrl,
      'releaseNotes': instance.releaseNotes,
    };
