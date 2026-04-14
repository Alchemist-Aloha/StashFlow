import 'package:freezed_annotation/freezed_annotation.dart';

part 'sprite_info.freezed.dart';

@freezed
abstract class SpriteInfo with _$SpriteInfo {
  const factory SpriteInfo({
    required String url,
    required double start,
    required double end,
    required double x,
    required double y,
    required double w,
    required double h,
  }) = _SpriteInfo;
}
