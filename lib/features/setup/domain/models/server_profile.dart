import '../../../../core/data/auth/auth_mode.dart';

class ServerProfile {
  final String id;
  final String? name;
  final String baseUrl;
  final AuthMode authMode;
  final bool allowWebPasswordLogin;

  ServerProfile({
    required this.id,
    this.name,
    required this.baseUrl,
    required this.authMode,
    this.allowWebPasswordLogin = false,
  });

  factory ServerProfile.fromJson(Map<String, dynamic> json) => ServerProfile(
        id: json['id'] as String,
        name: json['name'] as String?,
        baseUrl: json['baseUrl'] as String,
        authMode: AuthMode.values.firstWhere(
          (e) => e.name == json['authMode'],
          orElse: () => AuthMode.apiKey,
        ),
        allowWebPasswordLogin: json['allowWebPasswordLogin'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseUrl': baseUrl,
        'authMode': authMode.name,
        'allowWebPasswordLogin': allowWebPasswordLogin,
      };

  ServerProfile copyWith({
    String? name,
    String? baseUrl,
    AuthMode? authMode,
    bool? allowWebPasswordLogin,
  }) {
    return ServerProfile(
      id: id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      authMode: authMode ?? this.authMode,
      allowWebPasswordLogin: allowWebPasswordLogin ?? this.allowWebPasswordLogin,
    );
  }
}
