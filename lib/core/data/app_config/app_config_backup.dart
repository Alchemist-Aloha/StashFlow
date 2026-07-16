/// A portable, versioned snapshot of StashFlow's managed configuration.
final class AppConfigBackup {
  const AppConfigBackup({
    required this.schemaVersion,
    required this.createdAt,
    required this.appVersion,
    required this.settings,
    required this.serverProfiles,
    required this.activeServerProfileId,
    required this.credentials,
  });

  static const format = 'stashflow-app-config';
  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime createdAt;
  final String appVersion;
  final Map<String, Object> settings;
  final List<AppConfigProfile> serverProfiles;
  final String? activeServerProfileId;
  final AppConfigSecrets? credentials;
}

/// Server metadata stored in a configuration backup.
final class AppConfigProfile {
  const AppConfigProfile({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.authMode,
    required this.allowWebPasswordLogin,
  });

  final String id;
  final String? name;
  final String baseUrl;
  final String authMode;
  final bool allowWebPasswordLogin;
}

/// Secrets included only when the user explicitly opts in.
final class AppConfigSecrets {
  const AppConfigSecrets({this.profiles = const {}, this.appLockPasscode});

  final Map<String, AppConfigProfileCredentials> profiles;
  final String? appLockPasscode;

  bool get isEmpty => profiles.isEmpty && (appLockPasscode ?? '').isEmpty;
}

/// Authentication values for one server profile.
final class AppConfigProfileCredentials {
  const AppConfigProfileCredentials({
    this.apiKey,
    this.username,
    this.password,
    this.cookieHeader,
  });

  final String? apiKey;
  final String? username;
  final String? password;
  final String? cookieHeader;

  bool get isEmpty =>
      (apiKey ?? '').isEmpty &&
      (username ?? '').isEmpty &&
      (password ?? '').isEmpty &&
      (cookieHeader ?? '').isEmpty;
}
