import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/app_config/app_config_backup.dart';
import 'package:stash_app_flutter/core/data/app_config/app_config_backup_codec.dart';

void main() {
  const codec = AppConfigBackupCodec();

  AppConfigBackup fixture({AppConfigSecrets? credentials}) => AppConfigBackup(
    schemaVersion: 1,
    createdAt: DateTime.utc(2026, 7, 15, 12),
    appVersion: '1.25.0',
    settings: const {'app_theme_mode': 'dark', 'show_random_navigation': true},
    serverProfiles: const [
      AppConfigProfile(
        id: 'primary',
        name: 'Home',
        baseUrl: 'https://stash.example',
        authMode: 'apiKey',
        allowWebPasswordLogin: false,
      ),
    ],
    activeServerProfileId: 'primary',
    credentials: credentials,
  );

  test('round trips a deterministic credential-free backup', () {
    final first = codec.encode(fixture());
    final second = codec.encode(codec.decode(first));
    expect(second, first);
    expect(codec.decode(first).credentials, isNull);
  });

  test('round trips profile credentials and app lock passcode', () {
    final decoded = codec.decode(
      codec.encode(
        fixture(
          credentials: const AppConfigSecrets(
            profiles: {
              'primary': AppConfigProfileCredentials(apiKey: 'secret'),
            },
            appLockPasscode: '1234',
          ),
        ),
      ),
    );
    expect(decoded.credentials!.profiles['primary']!.apiKey, 'secret');
    expect(decoded.credentials!.appLockPasscode, '1234');
  });

  test('rejects invalid and unsupported documents without leaking input', () {
    for (final value in <Object>[
      'not json super-secret-value',
      {'format': 'other', 'schemaVersion': 1},
      {'format': AppConfigBackup.format, 'schemaVersion': 99},
    ]) {
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(value)));
      expect(
        () => codec.decode(bytes),
        throwsA(
          isA<AppConfigFormatException>().having(
            (error) => error.toString(),
            'message',
            isNot(contains('super-secret-value')),
          ),
        ),
      );
    }
  });

  test('rejects invalid profile relationships', () {
    final base =
        jsonDecode(utf8.decode(codec.encode(fixture())))
            as Map<String, dynamic>;
    final cases = <Map<String, dynamic>>[
      {...base, 'activeServerProfileId': 'missing'},
      {
        ...base,
        'serverProfiles': [
          ...(base['serverProfiles'] as List),
          (base['serverProfiles'] as List).first,
        ],
      },
      {
        ...base,
        'serverProfiles': [
          {...(base['serverProfiles'] as List).first, 'baseUrl': 'file:///tmp'},
        ],
      },
      {
        ...base,
        'credentials': {
          'profiles': {
            'missing': {'apiKey': 'secret'},
          },
        },
      },
    ];
    for (final document in cases) {
      expect(
        () =>
            codec.decode(Uint8List.fromList(utf8.encode(jsonEncode(document)))),
        throwsA(isA<AppConfigFormatException>()),
      );
    }
  });

  test('ignores unknown fields in the current schema', () {
    final json =
        jsonDecode(utf8.decode(codec.encode(fixture())))
            as Map<String, dynamic>;
    json['futureField'] = {'ignored': true};
    expect(
      codec
          .decode(Uint8List.fromList(utf8.encode(jsonEncode(json))))
          .appVersion,
      '1.25.0',
    );
  });

  test('rejects documents above the size limit', () {
    expect(
      () => codec.decode(Uint8List(AppConfigBackupCodec.maxBytes + 1)),
      throwsA(
        isA<AppConfigFormatException>().having(
          (error) => error.kind,
          'kind',
          AppConfigFormatError.fileTooLarge,
        ),
      ),
    );
  });
}
