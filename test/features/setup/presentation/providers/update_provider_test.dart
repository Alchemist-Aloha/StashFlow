import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/domain/entities/update_info.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/update_provider.dart';

void main() {
  test('resolves versioned, RC, and nightly APK names by ABI', () {
    for (final label in ['1.29.0', 'rc', 'nightly']) {
      final url = 'https://example.test/StashFlow-$label-android-arm64-v8a.apk';
      expect(
        resolveAndroidApkAssetForAbi([
          {'name': url.split('/').last, 'browser_download_url': url},
        ], 'arm64-v8a'),
        (url: url, sha256: null),
      );
    }
  });

  test('reads the GitHub SHA-256 digest and ignores malformed digests', () {
    const url = 'https://example.test/StashFlow-android-armeabi-v7a.apk';
    final digest = 'AB' * 32;
    List<Map<String, dynamic>> assets(String value) => [
      {
        'name': 'StashFlow-android-armeabi-v7a.apk',
        'browser_download_url': url,
        'digest': value,
      },
    ];

    expect(
      resolveAndroidApkAssetForAbi(assets('sha256:$digest'), 'armeabi-v7a'),
      (url: url, sha256: digest.toLowerCase()),
    );
    expect(
      resolveAndroidApkAssetForAbi(assets('md5:1234'), 'armeabi-v7a')?.sha256,
      isNull,
    );
  });

  test('reads the commit from the nightly release body', () {
    final sha = 'a1b2c3d' * 5 + 'e' * 5;
    expect(nightlyReleaseCommit('Latest development build. Commit: $sha'), sha);
    expect(nightlyReleaseCommit('no commit here'), isNull);
    expect(nightlyReleaseCommit(null), isNull);
  });

  for (final nightly in [false, true]) {
    test('forced startup check still shows the dialog when the check fails '
        '(nightly: $nightly)', () async {
      PackageInfo.setMockInitialValues(
        appName: 'StashFlow',
        packageName: 'stashflow',
        version: '1.42.0',
        buildNumber: '1',
        buildSignature: '',
      );
      SharedPreferences.setMockInitialValues({
        StartupUpdateCheck.forceKey: true,
        NightlyUpdateChannel.key: nightly,
        'last_app_update_check_timestamp':
            DateTime.now().millisecondsSinceEpoch,
      });
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          appUpdateProvider.overrideWith(_FailedUpdate.new),
        ],
      );
      addTearDown(container.dispose);

      final info = await container.read(startupUpdateCheckProvider.future);
      expect(info?.isUpdateAvailable, isTrue);
      expect(info?.currentVersion, '1.42.0');
      expect(info?.latestVersion, nightly ? 'nightly' : '1.42.0');
      expect(info?.releaseUrl.endsWith('/tag/nightly'), nightly);
    });
  }
}

class _FailedUpdate extends AppUpdate {
  @override
  Future<UpdateInfo?> build() async => null;
}
