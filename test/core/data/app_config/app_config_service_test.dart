import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/app_config/app_config_backup.dart';
import 'package:stash_app_flutter/core/data/app_config/app_config_service.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export excludes secrets unless explicitly requested', () async {
    final service = await _service(
      preferences: {
        'app_theme_mode': 'dark',
        'server_profiles': jsonEncode([_profileJson('one')]),
        'active_server_profile_id': 'one',
      },
      secrets: {'profile_one_api_key': 'secret', 'app_lock_passcode': '1234'},
    );

    final safe = service.preview(
      await service.export(includeCredentials: false),
    );
    final unsafe = service.preview(
      await service.export(includeCredentials: true),
    );

    expect(safe.credentials, isNull);
    expect(unsafe.credentials!.profiles['one']!.apiKey, 'secret');
    expect(unsafe.credentials!.appLockPasscode, '1234');
  });

  test('import fully replaces settings, profiles, and credentials', () async {
    final store = MemorySecureStorage({
      'profile_old_api_key': 'old-secret',
      'app_lock_passcode': 'old-code',
    });
    final service = await _service(
      preferences: {
        'app_theme_mode': 'dark',
        'show_random_navigation': true,
        'scene_sort_field': 'rating',
        'scene_filter_state': '{"rating100":{"value":80}}',
        'server_profiles': jsonEncode([_profileJson('old')]),
        'active_server_profile_id': 'old',
        'search_history_scenes': <String>['keep'],
      },
      store: store,
    );
    final backup = AppConfigBackup(
      schemaVersion: 1,
      createdAt: DateTime.utc(2026, 7, 15),
      appVersion: '1.0.0',
      settings: const {
        'app_theme_mode': 'light',
        'image_sort_field': 'date',
        'image_sort_descending': true,
        'image_filter_state': '{"organized":false}',
      },
      serverProfiles: const [
        AppConfigProfile(
          id: 'new',
          name: 'New',
          baseUrl: 'https://stash.example',
          authMode: 'apiKey',
          allowWebPasswordLogin: false,
        ),
      ],
      activeServerProfileId: 'new',
      credentials: const AppConfigSecrets(
        profiles: {'new': AppConfigProfileCredentials(apiKey: 'new-secret')},
      ),
    );

    await service.replace(backup);

    expect(service.preferences.getString('app_theme_mode'), 'light');
    expect(service.preferences.containsKey('show_random_navigation'), isFalse);
    expect(service.preferences.containsKey('scene_sort_field'), isFalse);
    expect(service.preferences.containsKey('scene_filter_state'), isFalse);
    expect(service.preferences.getString('image_sort_field'), 'date');
    expect(service.preferences.getBool('image_sort_descending'), isTrue);
    expect(
      service.preferences.getString('image_filter_state'),
      '{"organized":false}',
    );
    expect(service.preferences.getStringList('search_history_scenes'), [
      'keep',
    ]);
    expect(service.preferences.getString('active_server_profile_id'), 'new');
    expect(store.values['profile_old_api_key'], isNull);
    expect(store.values['profile_new_api_key'], 'new-secret');
    expect(store.values['app_lock_passcode'], isNull);
  });

  test('failed import restores preferences and secure values', () async {
    final store = MemorySecureStorage({
      'profile_old_api_key': 'old-secret',
    }, 'profile_new_api_key');
    final service = await _service(
      preferences: {
        'app_theme_mode': 'dark',
        'server_profiles': jsonEncode([_profileJson('old')]),
        'active_server_profile_id': 'old',
      },
      store: store,
    );
    final backup = AppConfigBackup(
      schemaVersion: 1,
      createdAt: DateTime.utc(2026, 7, 15),
      appVersion: '1.0.0',
      settings: const {'app_theme_mode': 'light'},
      serverProfiles: const [
        AppConfigProfile(
          id: 'new',
          name: null,
          baseUrl: 'https://stash.example',
          authMode: 'apiKey',
          allowWebPasswordLogin: false,
        ),
      ],
      activeServerProfileId: 'new',
      credentials: const AppConfigSecrets(
        profiles: {'new': AppConfigProfileCredentials(apiKey: 'new-secret')},
      ),
    );

    await expectLater(
      service.replace(backup),
      throwsA(isA<AppConfigReplaceException>()),
    );
    expect(service.preferences.getString('app_theme_mode'), 'dark');
    expect(service.preferences.getString('active_server_profile_id'), 'old');
    expect(store.values['profile_old_api_key'], 'old-secret');
    expect(store.values['profile_new_api_key'], isNull);
  });
}

Map<String, Object?> _profileJson(String id) => {
  'id': id,
  'name': id,
  'baseUrl': 'https://$id.example',
  'authMode': 'apiKey',
  'allowWebPasswordLogin': false,
};

Future<AppConfigService> _service({
  Map<String, Object> preferences = const {},
  Map<String, String> secrets = const {},
  MemorySecureStorage? store,
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  return AppConfigService(
    preferences: await SharedPreferences.getInstance(),
    secureStorage: store ?? MemorySecureStorage(secrets),
    appVersion: '1.2.3',
    now: () => DateTime.utc(2026, 7, 15),
  );
}

final class MemorySecureStorage implements AppSecureStorageStore {
  MemorySecureStorage([
    Map<String, String> initial = const {},
    this.failOnceOnKey,
  ]) : values = Map.of(initial);

  final Map<String, String> values;
  final String? failOnceOnKey;
  bool _failed = false;

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (!_failed && key == failOnceOnKey) {
      _failed = true;
      throw StateError('simulated write failure');
    }
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({required String key}) async => values.remove(key);
}
