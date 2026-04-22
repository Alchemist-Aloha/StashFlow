import 'package:freezed_annotation/freezed_annotation.dart';
import 'scraped_tag.dart';

part 'scraped_performer.freezed.dart';
part 'scraped_performer.g.dart';

@freezed
abstract class ScrapedPerformer with _$ScrapedPerformer {
  const factory ScrapedPerformer({
    @JsonKey(name: 'stored_id') String? storedId,
    @JsonKey(name: 'remote_site_id') String? remoteSiteId,
    String? name,
    String? disambiguation,
    String? gender,
    String? birthdate,
    String? ethnicity,
    String? country,
    @JsonKey(name: 'eye_color') String? eyeColor,
    String? height,
    String? measurements,
    @JsonKey(name: 'fake_tits') String? fakeTits,
    @JsonKey(name: 'penis_length') String? penisLength,
    String? circumcised,
    @JsonKey(name: 'career_start') String? careerStart,
    @JsonKey(name: 'career_end') String? careerEnd,
    String? tattoos,
    String? piercings,
    String? aliases,
    @Default([]) List<String> urls,
    @Default([]) List<String> images,
    String? image,
    String? details,
    @JsonKey(name: 'death_date') String? deathDate,
    @JsonKey(name: 'hair_color') String? hairColor,
    String? weight,
    @Default([]) List<ScrapedTag> tags,
  }) = _ScrapedPerformer;

  factory ScrapedPerformer.fromJson(Map<String, dynamic> json) => _$ScrapedPerformerFromJson(json);
}
