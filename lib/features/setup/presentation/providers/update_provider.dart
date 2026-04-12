import 'dart:convert';
import 'package:http/http.dart' as http;
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

          return UpdateInfo(
            isUpdateAvailable: latestVersion > currentVersion,
            latestVersion: latestTag,
            currentVersion: currentVersionStr,
            releaseUrl: data['html_url'] as String,
            releaseNotes: data['body'] as String?,
          );
        } on FormatException {
          if (cleanLatestTag != currentVersionStr) {
            return UpdateInfo(
              isUpdateAvailable: true,
              latestVersion: latestTag,
              currentVersion: currentVersionStr,
              releaseUrl: data['html_url'] as String,
              releaseNotes: data['body'] as String?,
            );
          }
        }
      }
    } catch (e) {
      return null;
    }
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
