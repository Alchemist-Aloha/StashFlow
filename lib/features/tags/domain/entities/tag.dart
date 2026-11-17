import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
abstract class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'scene_count') required int sceneCount,
    @JsonKey(name: 'image_count') required int imageCount,
    @JsonKey(name: 'gallery_count') required int galleryCount,
    @JsonKey(name: 'performer_count') required int performerCount,
    required bool favorite,
    // Details-only relations; list queries leave these empty.
    @Default([]) List<String> aliases,
    @Default([]) List<TagRelation> parents,
    @Default([]) List<TagRelation> children,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

/// A parent or child tag in the tag hierarchy.
@freezed
abstract class TagRelation with _$TagRelation {
  const factory TagRelation({required String id, required String name}) =
      _TagRelation;

  factory TagRelation.fromJson(Map<String, dynamic> json) =>
      _$TagRelationFromJson(json);
}
