import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../data/android_update_installer.dart';
import '../../domain/entities/update_info.dart';
import '../../../../core/utils/app_log_store.dart';

part 'update_provider.g.dart';

/// A release APK selected for this device.
///
/// [sha256] is the lowercase hex digest from GitHub's `digest` asset field, or
/// null when the release does not publish one.
typedef AndroidApkAsset = ({String url, String? sha256});

/// Finds the Android APK matching [primaryAbi], regardless of release label.
@visibleForTesting
AndroidApkAsset? resolveAndroidApkAssetForAbi(
  List<dynamic> assets,
  String primaryAbi,
) {
  final normalizedAbi = primaryAbi.toLowerCase();
  final abiToken = switch (normalizedAbi) {
    final abi when abi.contains('arm64') => 'arm64-v8a',
    final abi when abi.contains('armeabi') || abi.contains('armv7') =>
      'armeabi-v7a',
    final abi when abi.contains('x86_64') => 'x86_64',
    _ => null,
  };
  if (abiToken == null) return null;

  for (final asset in assets) {
    if (asset is! Map<String, dynamic>) continue;
    final name = (asset['name'] as String?)?.toLowerCase() ?? '';
    final downloadUrl = asset['browser_download_url'] as String?;
    if (name.endsWith('.apk') &&
        name.contains(abiToken) &&
        downloadUrl != null) {
      final digest = (asset['digest'] as String?)?.toLowerCase();
      final sha256 =
          digest != null && RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(digest)
          ? digest.substring('sha256:'.length)
          : null;
      return (url: downloadUrl, sha256: sha256);
    }
  }
  return null;
}

/// Commit the running build was compiled from; empty for local builds.
const appBuildCommit = String.fromEnvironment('STASHFLOW_COMMIT');

/// Extracts the commit SHA the rolling nightly release body records.
@visibleForTesting
String? nightlyReleaseCommit(String? body) =>
    RegExp(r'Commit:\s*([0-9a-f]{7,40})').firstMatch(body ?? '')?.group(1);

/// Whether the built-in update check follows the rolling nightly release
/// instead of the latest stable release.
@riverpod
class NightlyUpdateChannel extends _$NightlyUpdateChannel {
  static const key = 'update_channel_nightly';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(key) ?? false;

  Future<void> set(bool nightly) async {
    state = nightly;
    await ref.read(sharedPreferencesProvider).setBool(key, nightly);
  }
}

/// Returns the current application version.
@riverpod
Future<String> appVersion(Ref ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

@riverpod
class AppUpdate extends _$AppUpdate {
  static const MethodChannel _platformChannel = MethodChannel(
    'stash_app_flutter/pip',
  );

  @override
  Future<UpdateInfo?> build() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;
      final currentVersion = Version.parse(currentVersionStr);
      final nightly = ref.watch(nightlyUpdateChannelProvider);

      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/Alchemist-Aloha/StashFlow/releases/'
          '${nightly ? 'tags/nightly' : 'latest'}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestTag = data['tag_name'] as String;

        if (nightly) {
          final commit = nightlyReleaseCommit(data['body'] as String?);
          if (commit == null) return null;
          // Builds without a commit (local/dev) always see nightly as newer.
          final isUpdateAvailable =
              appBuildCommit.isEmpty ||
              !(appBuildCommit.startsWith(commit) ||
                  commit.startsWith(appBuildCommit));
          if (!isUpdateAvailable) {
            unawaited(
              ref.read(androidUpdateInstallerProvider).deleteDownloads(),
            );
          }
          final apk = await _resolveAndroidApk(data);
          return UpdateInfo(
            isUpdateAvailable: isUpdateAvailable,
            latestVersion: '$latestTag (${commit.substring(0, 7)})',
            currentVersion: appBuildCommit.isEmpty
                ? currentVersionStr
                : '$currentVersionStr (${appBuildCommit.substring(0, 7)})',
            releaseUrl: data['html_url'] as String,
            releaseNotes: data['body'] as String?,
            androidApkUrl: apk?.url,
            androidApkSha256: apk?.sha256,
          );
        }

        String cleanLatestTag = latestTag;
        if (latestTag.startsWith('v')) {
          cleanLatestTag = latestTag.substring(1);
        }

        bool? isUpdateAvailable;
        try {
          isUpdateAvailable = Version.parse(cleanLatestTag) > currentVersion;
        } on FormatException catch (error, stackTrace) {
          AppLogStore.instance.addError(
            'build',
            error,
            stackTrace,
            source: 'update_provider',
          );
          if (cleanLatestTag != currentVersionStr) isUpdateAvailable = true;
        }

        if (isUpdateAvailable == false) {
          // The installed build is current, so any downloaded APK is stale.
          unawaited(ref.read(androidUpdateInstallerProvider).deleteDownloads());
        }
        if (isUpdateAvailable != null) {
          final apk = await _resolveAndroidApk(data);
          return UpdateInfo(
            isUpdateAvailable: isUpdateAvailable,
            latestVersion: latestTag,
            currentVersion: currentVersionStr,
            releaseUrl: data['html_url'] as String,
            releaseNotes: data['body'] as String?,
            androidApkUrl: apk?.url,
            androidApkSha256: apk?.sha256,
          );
        }
      } else {
        AppLogStore.instance.addError(
          'build',
          'GitHub release check failed: HTTP ${response.statusCode}',
          StackTrace.current,
          source: 'update_provider',
        );
      }
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'build',
        error,
        stackTrace,
        source: 'update_provider',
      );
      // Malformed release metadata can also fail with a cast error.
      return null;
    }
    return null;
  }

  Future<AndroidApkAsset?> _resolveAndroidApk(
    Map<String, dynamic> releaseData,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      final primaryAbi = await _platformChannel.invokeMethod<String>(
        'getPrimaryAbi',
      );
      if (primaryAbi == null || primaryAbi.isEmpty) return null;

      final assets = releaseData['assets'];
      if (assets is! List) return null;

      return resolveAndroidApkAssetForAbi(assets, primaryAbi);
    } on Exception catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'resolveAndroidApkUrl',
        error,
        stackTrace,
        source: 'update_provider',
      );
    }

    return null;
  }
}

/// A provider that handles the logic for the initial app update check.
/// It ensures that the update check is performed at most once per day, unless
/// the developer setting [forceKey] shows the dialog on every startup.
@riverpod
class StartupUpdateCheck extends _$StartupUpdateCheck {
  static const _lastCheckKey = 'last_app_update_check_timestamp';

  /// Developer setting: show the update dialog at every startup, even when
  /// the installed build is current.
  static const forceKey = 'force_update_dialog_at_startup';

  @override
  FutureOr<UpdateInfo?> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    if (prefs.getBool(forceKey) ?? false) {
      final updateInfo = await ref.watch(appUpdateProvider.future);
      if (updateInfo != null) {
        return updateInfo.copyWith(isUpdateAvailable: true);
      }
      // The check failed (offline or GitHub rate limit); still show the dialog
      // for the selected channel.
      final version = await ref.watch(appVersionProvider.future);
      final nightly = ref.watch(nightlyUpdateChannelProvider);
      return UpdateInfo(
        isUpdateAvailable: true,
        latestVersion: nightly ? 'nightly' : version,
        currentVersion: version,
        releaseUrl: nightly
            ? 'https://github.com/Alchemist-Aloha/StashFlow/releases/tag/nightly'
            : 'https://github.com/Alchemist-Aloha/StashFlow/releases',
      );
    }
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Only check once every 24 hours
    if (now - lastCheck < const Duration(hours: 24).inMilliseconds) {
      return null;
    }

    final updateInfo = await ref.watch(appUpdateProvider.future);
    return updateInfo;
  }

  /// Marks the update check as performed.
  void markChecked() {
    final prefs = ref.read(sharedPreferencesProvider);
    unawaited(
      prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch),
    );
  }
}
