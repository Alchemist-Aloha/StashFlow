import 'package:freezed_annotation/freezed_annotation.dart';
import 'scraped_tag.dart';
import 'scraped_performer.dart';
import 'scraped_studio.dart';

part 'scraped_scene.freezed.dart';
part 'scraped_scene.g.dart';

@freezed
class ScrapedScene with _$ScrapedScene {
  const factory ScrapedScene({
    @JsonKey(name: 'remote_site_id') String? remoteSiteId,
    String? title,
    String? details,
    @Default([]) List<String> urls,
    DateTime? date,
    @Default([]) List<ScrapedTag> tags,
    @Default([]) List<ScrapedPerformer> performers,
    String? image,
    @JsonKey(name: 'studio_id') String? studioId,
    ScrapedStudio? studio,
  }) = _ScrapedScene;

  factory ScrapedScene.fromJson(Map<String, dynamic> json) => _$ScrapedSceneFromJson(json);
}
