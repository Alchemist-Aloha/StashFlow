import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/data/auth/auth_mode.dart';

part 'server_profile.freezed.dart';
part 'server_profile.g.dart';

@freezed
abstract class ServerProfile with _$ServerProfile {
  const ServerProfile._();

  const factory ServerProfile({
    required String id,
    String? name,
    required String baseUrl,
    required AuthMode authMode,
    @Default(false) bool allowWebPasswordLogin,
  }) = _ServerProfile;

  factory ServerProfile.fromJson(Map<String, dynamic> json) =>
      _$ServerProfileFromJson(json);
}
