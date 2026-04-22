import 'package:freezed_annotation/freezed_annotation.dart';
import 'scraped_tag.dart';

part 'scraped_studio.freezed.dart';
part 'scraped_studio.g.dart';

@freezed
abstract class ScrapedStudio with _$ScrapedStudio {
  const factory ScrapedStudio({
    @JsonKey(name: 'stored_id') String? storedId,
    required String name,
    @JsonKey(name: 'remote_site_id') String? remoteSiteId,
    String? image,
    String? url,
    String? details,
    @Default([]) List<String> urls,
    ScrapedStudio? parent,
    String? aliases,
    @Default([]) List<ScrapedTag> tags,
  }) = _ScrapedStudio;

  factory ScrapedStudio.fromJson(Map<String, dynamic> json) => _$ScrapedStudioFromJson(json);
}
