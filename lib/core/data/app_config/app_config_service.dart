import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_mode.dart';
import '../preferences/secure_storage_provider.dart';
import 'app_config_backup.dart';
import 'app_config_backup_codec.dart';
import 'app_config_settings_registry.dart';

final class AppConfigReplaceException implements Exception {
  const AppConfigReplaceException({required this.rolledBack});

  final bool rolledBack;

  @override
  String toString() => 'AppConfigReplaceException(rolledBack: $rolledBack)';
}

/// Creates and transactionally restores portable configuration snapshots.
final class AppConfigService {
  AppConfigService({
    required this.preferences,
    required AppSecureStorageStore secureStorage,
    required this.appVersion,
    required DateTime Function() now,
    AppConfigSettingsRegistry settingsRegistry =
        const AppConfigSettingsRegistry(),
    AppConfigBackupCodec codec = const AppConfigBackupCodec(),
  }) : _secureStorage = secureStorage,
       _now = now,
       _settingsRegistry = settingsRegistry,
       _codec = codec;

  static const _profilesKey = 'server_profiles';
  static const _activeProfileKey = 'active_server_profile_id';
  static const _appLockPasscodeKey = 'app_lock_passcode';
  static const _credentialSuffixes = <String>[
    'api_key',
    'username',
    'password',
    'cookie_header',
  ];

  final SharedPreferences preferences;
  final AppSecureStorageStore _secureStorage;
  final String appVersion;
  final DateTime Function() _now;
  final AppConfigSettingsRegistry _settingsRegistry;
  final AppConfigBackupCodec _codec;

  Future<Uint8List> export({required bool includeCredentials}) async {
    final profiles = _readProfiles();
    final active = preferences.getString(_activeProfileKey);
    final credentials = includeCredentials
        ? await _readCredentials(profiles.map((profile) => profile.id))
        : null;
    return _codec.encode(
      AppConfigBackup(
        schemaVersion: AppConfigBackup.currentSchemaVersion,
        createdAt: _now().toUtc(),
        appVersion: appVersion,
        settings: await _settingsRegistry.read(preferences),
        serverProfiles: profiles,
        activeServerProfileId: (active == null || active.isEmpty)
            ? null
            : active,
        credentials: credentials,
      ),
    );
  }

  AppConfigBackup preview(Uint8List bytes) => _codec.decode(bytes);

  Future<void> replace(AppConfigBackup backup) async {
    // Validate the entire document before changing persistent state.
    _codec.encode(backup);
    _settingsRegistry.validate(backup.settings);
    _validateAuthModes(backup.serverProfiles);

    final oldProfiles = _readProfiles();
    final profileIds = <String>{
      ...oldProfiles.map((profile) => profile.id),
      ...backup.serverProfiles.map((profile) => profile.id),
    };
    final oldSettings = await _settingsRegistry.read(preferences);
    final oldProfilesJson = preferences.getString(_profilesKey);
    final oldActiveId = preferences.getString(_activeProfileKey);
    final oldSecrets = await _snapshotSecrets(profileIds);

    try {
      final settings = Map<String, Object>.of(backup.settings);
      if ((backup.credentials?.appLockPasscode ?? '').isEmpty) {
        settings['app_lock_enabled'] = false;
      }
      await _settingsRegistry.replace(preferences, settings);
      await _setString(
        _profilesKey,
        jsonEncode(backup.serverProfiles.map(_profileToJson).toList()),
      );
      await _setOptionalString(_activeProfileKey, backup.activeServerProfileId);
      await _clearSecrets(profileIds);
      await _writeCredentials(backup.credentials);
    } catch (_) {
      var rolledBack = true;
      try {
        await _settingsRegistry.replace(preferences, oldSettings);
        await _setOptionalString(_profilesKey, oldProfilesJson);
        await _setOptionalString(_activeProfileKey, oldActiveId);
        await _restoreSecrets(oldSecrets);
      } catch (_) {
        rolledBack = false;
      }
      throw AppConfigReplaceException(rolledBack: rolledBack);
    }
  }

  List<AppConfigProfile> _readProfiles() {
    final raw = preferences.getString(_profilesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException();
      return decoded
          .map((value) {
            if (value is! Map) throw const FormatException();
            final json = value.cast<String, dynamic>();
            return AppConfigProfile(
              id: json['id'] as String,
              name: json['name'] as String?,
              baseUrl: json['baseUrl'] as String,
              authMode: json['authMode'] as String,
              allowWebPasswordLogin:
                  json['allowWebPasswordLogin'] as bool? ?? false,
            );
          })
          .toList(growable: false);
    } catch (_) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
  }

  Future<AppConfigSecrets> _readCredentials(Iterable<String> ids) async {
    final profiles = <String, AppConfigProfileCredentials>{};
    for (final id in ids) {
      final value = AppConfigProfileCredentials(
        apiKey: await _secureStorage.read(key: _credentialKey(id, 'api_key')),
        username: await _secureStorage.read(
          key: _credentialKey(id, 'username'),
        ),
        password: await _secureStorage.read(
          key: _credentialKey(id, 'password'),
        ),
        cookieHeader: await _secureStorage.read(
          key: _credentialKey(id, 'cookie_header'),
        ),
      );
      if (!value.isEmpty) profiles[id] = value;
    }
    return AppConfigSecrets(
      profiles: Map.unmodifiable(profiles),
      appLockPasscode: await _secureStorage.read(key: _appLockPasscodeKey),
    );
  }

  Future<Map<String, String?>> _snapshotSecrets(Iterable<String> ids) async {
    final keys = <String>{
      _appLockPasscodeKey,
      for (final id in ids)
        for (final suffix in _credentialSuffixes) _credentialKey(id, suffix),
    };
    return {for (final key in keys) key: await _secureStorage.read(key: key)};
  }

  Future<void> _clearSecrets(Iterable<String> ids) async {
    await _secureStorage.delete(key: _appLockPasscodeKey);
    for (final id in ids) {
      for (final suffix in _credentialSuffixes) {
        await _secureStorage.delete(key: _credentialKey(id, suffix));
      }
    }
  }

  Future<void> _writeCredentials(AppConfigSecrets? credentials) async {
    if (credentials == null) return;
    await _secureStorage.write(
      key: _appLockPasscodeKey,
      value: credentials.appLockPasscode,
    );
    for (final entry in credentials.profiles.entries) {
      final value = entry.value;
      await _secureStorage.write(
        key: _credentialKey(entry.key, 'api_key'),
        value: value.apiKey,
      );
      await _secureStorage.write(
        key: _credentialKey(entry.key, 'username'),
        value: value.username,
      );
      await _secureStorage.write(
        key: _credentialKey(entry.key, 'password'),
        value: value.password,
      );
      await _secureStorage.write(
        key: _credentialKey(entry.key, 'cookie_header'),
        value: value.cookieHeader,
      );
    }
  }

  Future<void> _restoreSecrets(Map<String, String?> snapshot) async {
    for (final entry in snapshot.entries) {
      await _secureStorage.write(key: entry.key, value: entry.value);
    }
  }

  Future<void> _setOptionalString(String key, String? value) async {
    if (value == null || value.isEmpty) {
      if (!await preferences.remove(key)) throw StateError('write failed');
    } else {
      await _setString(key, value);
    }
  }

  Future<void> _setString(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('write failed');
    }
  }

  static void _validateAuthModes(Iterable<AppConfigProfile> profiles) {
    final allowed = AuthMode.values.map((mode) => mode.name).toSet();
    if (profiles.any((profile) => !allowed.contains(profile.authMode))) {
      throw const AppConfigFormatException(AppConfigFormatError.invalidData);
    }
  }

  static Map<String, Object?> _profileToJson(AppConfigProfile profile) => {
    'id': profile.id,
    'name': profile.name,
    'baseUrl': profile.baseUrl,
    'authMode': profile.authMode,
    'allowWebPasswordLogin': profile.allowWebPasswordLogin,
  };

  static String _credentialKey(String id, String suffix) =>
      'profile_${id}_$suffix';
}
