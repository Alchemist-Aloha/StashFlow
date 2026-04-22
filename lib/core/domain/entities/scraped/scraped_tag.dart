import 'package:freezed_annotation/freezed_annotation.dart';

part 'scraped_tag.freezed.dart';
part 'scraped_tag.g.dart';

@freezed
abstract class ScrapedTag with _$ScrapedTag {
  const factory ScrapedTag({
    @JsonKey(name: 'stored_id') String? storedId,
    required String name,
  }) = _ScrapedTag;

  factory ScrapedTag.fromJson(Map<String, dynamic> json) => _$ScrapedTagFromJson(json);
}
