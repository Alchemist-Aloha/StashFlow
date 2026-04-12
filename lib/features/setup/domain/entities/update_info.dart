import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_info.freezed.dart';
part 'update_info.g.dart';

/// Represents information about a software update.
///
/// Parameters:
/// - `isUpdateAvailable` (bool): Whether a newer version is available.
/// - `latestVersion` (String): The tag name of the latest release.
/// - `currentVersion` (String): The current version of the application.
/// - `releaseUrl` (String): The URL to the latest release on GitHub.
/// - `releaseNotes` (String?): Optional release notes for the update.
///
/// Example:
/// ```dart
/// final info = UpdateInfo(
///   isUpdateAvailable: true,
///   latestVersion: '1.9.0',
///   currentVersion: '1.8.1',
///   releaseUrl: 'https://github.com/Alchemist-Aloha/StashFlow/releases/tag/1.9.0',
/// );
/// ```
@freezed
abstract class UpdateInfo with _$UpdateInfo {
  const factory UpdateInfo({
    required bool isUpdateAvailable,
    required String latestVersion,
    required String currentVersion,
    required String releaseUrl,
    String? releaseNotes,
  }) = _UpdateInfo;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$UpdateInfoFromJson(json);
}
