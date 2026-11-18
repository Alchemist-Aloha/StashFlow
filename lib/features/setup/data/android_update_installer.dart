import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'android_update_installer.g.dart';

/// Outcome of handing a downloaded APK to the Android package installer.
enum ApkInstallResult {
  /// The system installer opened; Android owns the rest of the install.
  started,

  /// The "install unknown apps" settings screen opened because StashFlow lacks
  /// that permission. Retry after the user returns.
  permissionRequired,

  /// The installer could not be opened.
  failed,
}

/// Thrown when a downloaded APK does not match the release's SHA-256 digest.
class ApkVerificationException implements Exception {
  const ApkVerificationException();

  @override
  String toString() => 'ApkVerificationException: digest mismatch';
}

/// Downloads release APKs into the app cache and opens the system installer.
///
/// Downloads live in `<cache>/[updateDirectoryName]/`, the only directory the
/// native `AppUpdateFileProvider` exposes. Each new download replaces earlier
/// ones, and [deleteDownloads] removes leftovers once the app is current.
class AndroidUpdateInstaller {
  AndroidUpdateInstaller({
    Dio? dio,
    Future<Directory> Function()? cacheDirectory,
    MethodChannel? channel,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 60),
             ),
           ),
       _cacheDirectory = cacheDirectory ?? getTemporaryDirectory,
       _channel =
           channel ?? const MethodChannel('stash_app_flutter/app_update');

  /// Must match `android/app/src/main/res/xml/app_update_paths.xml`.
  static const updateDirectoryName = 'app_update';

  final Dio _dio;
  final Future<Directory> Function() _cacheDirectory;
  final MethodChannel _channel;

  Future<Directory> _updateDirectory() async =>
      Directory(p.join((await _cacheDirectory()).path, updateDirectoryName));

  /// Downloads [url] and returns the completed APK file.
  ///
  /// When [sha256] is provided the file must match it, otherwise
  /// [ApkVerificationException] is thrown and the partial file is removed.
  /// [onProgress] receives received and total bytes; total is -1 when the
  /// server does not report a length.
  Future<File> download({
    required String url,
    required String version,
    String? sha256,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final directory = await _updateDirectory();
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);

    final safeVersion = version.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final target = File(p.join(directory.path, 'StashFlow-$safeVersion.apk'));
    final partial = File('${target.path}.part');

    try {
      await _dio.download(
        url,
        partial.path,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        deleteOnError: true,
      );
      if (sha256 != null) {
        final digest = await sha256Digest(partial);
        if (digest != sha256.toLowerCase()) {
          throw const ApkVerificationException();
        }
      }
      return await partial.rename(target.path);
    } on Object {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  /// Opens the system installer for [apk].
  Future<ApkInstallResult> install(File apk) async {
    final result = await _channel.invokeMethod<String>('installApk', {
      'path': apk.path,
    });
    return switch (result) {
      'started' => ApkInstallResult.started,
      'permission_required' => ApkInstallResult.permissionRequired,
      _ => ApkInstallResult.failed,
    };
  }

  /// Whether Android currently allows StashFlow to request package installs.
  Future<bool> canRequestPackageInstalls() async =>
      await _channel.invokeMethod<bool>('canRequestPackageInstalls') ?? false;

  /// Removes downloaded update APKs. Safe to call on any platform.
  Future<void> deleteDownloads() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final directory = await _updateDirectory();
      if (await directory.exists()) await directory.delete(recursive: true);
    } on FileSystemException {
      // A later download recreates the directory from scratch.
    }
  }
}

/// Lowercase hex SHA-256 of [file], streamed to avoid loading it in memory.
@visibleForTesting
Future<String> sha256Digest(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

@Riverpod(keepAlive: true)
AndroidUpdateInstaller androidUpdateInstaller(Ref ref) =>
    AndroidUpdateInstaller();
