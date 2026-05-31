import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../domain/entities/update_info.dart';

part 'update_provider.g.dart';

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

      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/Alchemist-Aloha/StashFlow/releases/latest',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestTag = data['tag_name'] as String;

        String cleanLatestTag = latestTag;
        if (latestTag.startsWith('v')) {
          cleanLatestTag = latestTag.substring(1);
        }

        try {
          final latestVersion = Version.parse(cleanLatestTag);
          final androidApkUrl = await _resolveAndroidApkUrl(data);

          return UpdateInfo(
            isUpdateAvailable: latestVersion > currentVersion,
            latestVersion: latestTag,
            currentVersion: currentVersionStr,
            releaseUrl: data['html_url'] as String,
            releaseNotes: data['body'] as String?,
            androidApkUrl: androidApkUrl,
          );
        } on FormatException {
          if (cleanLatestTag != currentVersionStr) {
            final androidApkUrl = await _resolveAndroidApkUrl(data);
            return UpdateInfo(
              isUpdateAvailable: true,
              latestVersion: latestTag,
              currentVersion: currentVersionStr,
              releaseUrl: data['html_url'] as String,
              releaseNotes: data['body'] as String?,
              androidApkUrl: androidApkUrl,
            );
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> _resolveAndroidApkUrl(
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

      final abiToken = _abiToken(primaryAbi);
      if (abiToken == null) return null;

      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = (asset['name'] as String?)?.toLowerCase() ?? '';
        final downloadUrl = asset['browser_download_url'] as String?;
        if (!name.endsWith('.apk') || downloadUrl == null) continue;
        if (name.contains(abiToken)) return downloadUrl;
      }
    } catch (_) {}

    return null;
  }

  String? _abiToken(String abi) {
    final normalized = abi.toLowerCase();
    if (normalized.contains('arm64')) return 'arm64-v8a';
    if (normalized.contains('armeabi') || normalized.contains('armv7')) {
      return 'armeabi-v7a';
    }
    if (normalized.contains('x86_64')) return 'x86_64';
    return null;
  }
}

/// A provider that handles the logic for the initial app update check.
/// It ensures that the update check is performed at most once per day.
@riverpod
class StartupUpdateCheck extends _$StartupUpdateCheck {
  static const _lastCheckKey = 'last_app_update_check_timestamp';

  @override
  FutureOr<UpdateInfo?> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
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
    prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
  }
}
