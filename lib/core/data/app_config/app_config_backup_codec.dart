import 'dart:convert';
import 'dart:typed_data';

import 'app_config_backup.dart';

enum AppConfigFormatError {
  fileTooLarge,
  invalidJson,
  invalidFormat,
  unsupportedVersion,
  invalidData,
}

final class AppConfigFormatException implements Exception {
  const AppConfigFormatException(this.kind);

  final AppConfigFormatError kind;

  @override
  String toString() => 'AppConfigFormatException(${kind.name})';
}

/// Encodes and validates the public configuration-backup format.
final class AppConfigBackupCodec {
  const AppConfigBackupCodec();

  static const maxBytes = 1024 * 1024;

  Uint8List encode(AppConfigBackup backup) {
    _validate(backup);
    final profiles = [...backup.serverProfiles]
      ..sort((a, b) => a.id.compareTo(b.id));
    final settings = Map<String, Object>.fromEntries(
      backup.settings.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final root = <String, Object?>{
      'format': AppConfigBackup.format,
      'schemaVersion': backup.schemaVersion,
      'createdAt': backup.createdAt.toUtc().toIso8601String(),
      'appVersion': backup.appVersion,
      'settings': settings,
      'serverProfiles': profiles.map(_profileToJson).toList(),
      'activeServerProfileId': backup.activeServerProfileId,
    };
    final secrets = backup.credentials;
    if (secrets != null) root['credentials'] = _secretsToJson(secrets);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(root)));
    if (bytes.length > maxBytes) {
      throw const AppConfigFormatException(AppConfigFormatError.fileTooLarge);
    }
    return bytes;
  }

  AppConfigBackup decode(Uint8List bytes) {
    if (bytes.length > maxBytes) {
      throw const AppConfigFormatException(AppConfigFormatError.fileTooLarge);
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
      if (decoded is! Map<String, dynamic>) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
      if (decoded['format'] != AppConfigBackup.format) {
        throw const AppConfigFormatException(
          AppConfigFormatError.invalidFormat,
        );
      }
      final version = decoded['schemaVersion'];
      if (version is! int) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
      if (version != AppConfigBackup.currentSchemaVersion) {
        throw const AppConfigFormatException(
          AppConfigFormatError.unsupportedVersion,
        );
      }
      final settingsJson = _map(decoded['settings']);
      final settings = <String, Object>{};
      for (final entry in settingsJson.entries) {
        if (!_isSettingValue(entry.value)) {
          throw const AppConfigFormatException(
            AppConfigFormatError.invalidData,
          );
        }
        settings[entry.key] = _copySettingValue(entry.value);
      }
      final profileList = decoded['serverProfiles'];
      if (profileList is! List) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
      final profiles = profileList
          .map((value) => _profileFromJson(_map(value)))
          .toList(growable: false);
      final createdAt = DateTime.tryParse(_string(decoded['createdAt']));
      if (createdAt == null) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
      final active = decoded['activeServerProfileId'];
      if (active != null && active is! String) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
      final backup = AppConfigBackup(
        schemaVersion: version,
        createdAt: createdAt.toUtc(),
        appVersion: _string(decoded['appVersion']),
        settings: Map.unmodifiable(settings),
        serverProfiles: List.unmodifiable(profiles),
        activeServerProfileId: active as String?,
        credentials: decoded.containsKey('credentials')
            ? _secretsFromJson(_map(decoded['credentials']))
            : null,
      );
      _validate(backup);
      return backup;
    } on AppConfigFormatException {
      rethrow;
    } on FormatException {
      throw const AppConfigFormatException(AppConfigFormatError.invalidJson);
    } catch (_) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
  }

  static Map<String, Object?> _profileToJson(AppConfigProfile profile) => {
    'id': profile.id,
    if (profile.name != null) 'name': profile.name,
    'baseUrl': profile.baseUrl,
    'authMode': profile.authMode,
    'allowWebPasswordLogin': profile.allowWebPasswordLogin,
  };

  static AppConfigProfile _profileFromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name != null && name is! String) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    final allow = json['allowWebPasswordLogin'];
    if (allow is! bool) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    return AppConfigProfile(
      id: _string(json['id']),
      name: name as String?,
      baseUrl: _string(json['baseUrl']),
      authMode: _string(json['authMode']),
      allowWebPasswordLogin: allow,
    );
  }

  static Map<String, Object?> _secretsToJson(AppConfigSecrets secrets) {
    final ids = secrets.profiles.keys.toList()..sort();
    return {
      'profiles': {
        for (final id in ids)
          id: _profileCredentialsToJson(secrets.profiles[id]!),
      },
      if ((secrets.appLockPasscode ?? '').isNotEmpty)
        'appLockPasscode': secrets.appLockPasscode,
    };
  }

  static Map<String, Object?> _profileCredentialsToJson(
    AppConfigProfileCredentials value,
  ) => {
    if ((value.apiKey ?? '').isNotEmpty) 'apiKey': value.apiKey,
    if ((value.username ?? '').isNotEmpty) 'username': value.username,
    if ((value.password ?? '').isNotEmpty) 'password': value.password,
    if ((value.cookieHeader ?? '').isNotEmpty)
      'cookieHeader': value.cookieHeader,
  };

  static AppConfigSecrets _secretsFromJson(Map<String, dynamic> json) {
    final profilesJson = json.containsKey('profiles')
        ? _map(json['profiles'])
        : <String, dynamic>{};
    final profiles = <String, AppConfigProfileCredentials>{};
    for (final entry in profilesJson.entries) {
      final value = _map(entry.value);
      profiles[entry.key] = AppConfigProfileCredentials(
        apiKey: _optionalString(value['apiKey']),
        username: _optionalString(value['username']),
        password: _optionalString(value['password']),
        cookieHeader: _optionalString(value['cookieHeader']),
      );
    }
    return AppConfigSecrets(
      profiles: Map.unmodifiable(profiles),
      appLockPasscode: _optionalString(json['appLockPasscode']),
    );
  }

  static void _validate(AppConfigBackup backup) {
    if (backup.schemaVersion != AppConfigBackup.currentSchemaVersion ||
        backup.appVersion.trim().isEmpty) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    final ids = <String>{};
    for (final profile in backup.serverProfiles) {
      final uri = Uri.tryParse(profile.baseUrl);
      if (profile.id.trim().isEmpty ||
          !ids.add(profile.id) ||
          uri == null ||
          !const {'http', 'https'}.contains(uri.scheme) ||
          uri.host.isEmpty ||
          profile.authMode.trim().isEmpty) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
    }
    final active = backup.activeServerProfileId;
    if (active != null && !ids.contains(active)) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    final credentialIds = backup.credentials?.profiles.keys ?? const <String>[];
    if (credentialIds.any((id) => !ids.contains(id))) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    for (final entry in backup.settings.entries) {
      if (entry.key.isEmpty || !_isSettingValue(entry.value)) {
        throw const AppConfigFormatException(AppConfigFormatError.invalidData);
      }
    }
  }

  static bool _isSettingValue(Object? value) =>
      value is bool ||
      value is int ||
      value is String ||
      (value is double && value.isFinite) ||
      (value is List && value.every((element) => element is String));

  static Object _copySettingValue(Object? value) =>
      value is List ? List<String>.unmodifiable(value.cast<String>()) : value!;

  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    try {
      return value.cast<String, dynamic>();
    } catch (_) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
  }

  static String _string(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    return value;
  }

  static String? _optionalString(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
    return value.isEmpty ? null : value;
  }
}
