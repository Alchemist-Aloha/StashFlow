import 'package:freezed_annotation/freezed_annotation.dart';

part 'performer.freezed.dart';
part 'performer.g.dart';

@freezed
abstract class Performer with _$Performer {
  const factory Performer({
    required String id,
    required String name,
    String? disambiguation,
    required List<String> urls,
    String? gender,
    required String? birthdate,
    String? ethnicity,
    String? country,
    @JsonKey(name: 'eye_color') String? eyeColor,
    @JsonKey(name: 'height_cm') int? heightCm,
    String? measurements,
    @JsonKey(name: 'fake_tits') String? fakeTits,
    @JsonKey(name: 'penis_length') double? penisLength,
    String? circumcised,
    @JsonKey(name: 'career_start') String? careerStart,
    @JsonKey(name: 'career_end') String? careerEnd,
    String? tattoos,
    String? piercings,
    @JsonKey(name: 'alias_list') required List<String> aliasList,
    required bool favorite,
    @JsonKey(name: 'image_path') required String? imagePath,
    @JsonKey(name: 'scene_count') required int sceneCount,
    @JsonKey(name: 'image_count') required int imageCount,
    @JsonKey(name: 'gallery_count') required int galleryCount,
    @JsonKey(name: 'group_count') required int groupCount,
    int? rating100,
    String? details,
    @JsonKey(name: 'death_date') String? deathDate,
    @JsonKey(name: 'hair_color') String? hairColor,
    int? weight,
    @JsonKey(name: 'tag_ids') required List<String> tagIds,
    @JsonKey(name: 'tag_names') required List<String> tagNames,
    // Details-only metadata; list queries leave these at their defaults.
    @JsonKey(name: 'o_counter') int? oCounter,
    @JsonKey(name: 'custom_fields')
    @Default({})
    Map<String, dynamic> customFields,
    @JsonKey(name: 'stash_ids') @Default([]) List<PerformerStashId> stashIds,
  }) = _Performer;

  factory Performer.fromJson(Map<String, dynamic> json) =>
      _$PerformerFromJson(json);
}

/// A stash-box identifier linking this performer to a remote database entry.
@freezed
abstract class PerformerStashId with _$PerformerStashId {
  const factory PerformerStashId({
    required String endpoint,
    @JsonKey(name: 'stash_id') required String stashId,
  }) = _PerformerStashId;

  factory PerformerStashId.fromJson(Map<String, dynamic> json) =>
      _$PerformerStashIdFromJson(json);
}
