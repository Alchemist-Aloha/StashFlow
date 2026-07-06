import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:extended_image/extended_image.dart' as extended_image;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../presentation/widgets/stash_image.dart';

final appCacheServiceProvider = Provider<AppCacheService>((ref) {
  return AppCacheService();
});

class AppCacheService {
  AppCacheService({
    Future<Directory> Function()? temporaryDirectoryProvider,
    Future<Directory> Function()? applicationCacheDirectoryProvider,
    Future<Directory> Function()? applicationDocumentsDirectoryProvider,
  }) : _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory,
       _applicationCacheDirectoryProvider =
           applicationCacheDirectoryProvider ?? getApplicationCacheDirectory,
       _applicationDocumentsDirectoryProvider =
           applicationDocumentsDirectoryProvider ??
           getApplicationDocumentsDirectory;

  final Future<Directory> Function() _temporaryDirectoryProvider;
  final Future<Directory> Function() _applicationCacheDirectoryProvider;
  final Future<Directory> Function() _applicationDocumentsDirectoryProvider;

  static const Set<String> _videoExtensions = {
    '.mkv',
    '.mp4',
    '.webm',
    '.avi',
    '.mov',
    '.part',
  };

  Future<List<Directory>> _cacheRootDirs() async {
    final dirs = <Directory>{await _temporaryDirectoryProvider()};
    try {
      dirs.add(await _applicationCacheDirectoryProvider());
    } catch (_) {
      // Some platforms may not expose an application cache directory.
    }
    return dirs.toList();
  }

  Future<List<Directory>> _imageCacheDirs() async {
    final roots = await _cacheRootDirs();
    return roots
        .expand(
          (root) => [
            Directory(p.join(root.path, 'cache')),
            Directory(p.join(root.path, 'stashImageCache')),
            Directory(p.join(root.path, 'libCachedImageData')),
          ],
        )
        .toList();
  }

  Future<List<Directory>> _videoCacheDirs() async {
    final roots = await _cacheRootDirs();
    return roots
        .expand(
          (root) => [
            Directory(p.join(root.path, 'video')),
            Directory(p.join(root.path, 'videos')),
            Directory(p.join(root.path, 'video_cache')),
          ],
        )
        .toList();
  }

  Future<int> _calculateDirSize(Directory dir) async {
    if (!await dir.exists()) {
      debugPrint('AppCacheService: Directory does not exist: ${dir.path}');
      return 0;
    }
    return _calculateCacheSizeInBackground([dir.path]);
  }

  Future<int> getImageCacheSizeMb() async {
    int totalBytes = 0;
    final cacheDirs = await _imageCacheDirs();

    for (final dir in cacheDirs) {
      final size = await _calculateDirSize(dir);
      if (size > 0) {
        debugPrint('AppCacheService: Directory ${dir.path} size: $size bytes');
      }
      totalBytes += size;
    }

    debugPrint('AppCacheService: Image cache total size: $totalBytes bytes');
    return totalBytes ~/ (1024 * 1024);
  }

  Future<int> getVideoCacheSizeMb() async {
    final dirs = await _videoCacheDirs();
    final bytes = await _calculateCacheSizeInBackground(
      dirs.map((dir) => dir.path).toList(),
      extensions: _videoExtensions,
    );

    debugPrint('AppCacheService: Video cache size: $bytes bytes');
    return bytes ~/ (1024 * 1024);
  }

  Future<int> getDatabaseCacheSizeMb() async {
    final hiveDir = Directory(
      p.join((await _temporaryDirectoryProvider()).path, 'stash_graphql_cache'),
    );

    int bytes = await _calculateDirSize(hiveDir);

    // Also check for root hive files in the temp directory
    try {
      final tempDir = await _temporaryDirectoryProvider();
      await for (final entity in tempDir.list(recursive: false)) {
        if (entity is File &&
            (entity.path.endsWith('.hive') || entity.path.endsWith('.lock'))) {
          bytes += await entity.length();
        }
      }
    } catch (_) {}

    debugPrint(
      'AppCacheService: Database cache size: $bytes bytes in ${hiveDir.path}',
    );
    return bytes ~/ (1024 * 1024);
  }

  Future<void> clearImageCache() async {
    debugPrint('AppCacheService: Clearing image cache...');
    final errors = <Object>[];
    try {
      final dirsToClear = await _imageCacheDirs();
      debugPrint(
        'AppCacheService: Image cache clear dirs=${_formatDirs(dirsToClear)}',
      );
      final beforeBytes = await _calculateCacheSizeInBackground(
        dirsToClear.map((dir) => dir.path).toList(),
      );
      debugPrint(
        'AppCacheService: Image cache before clear=${_formatBytes(beforeBytes)}',
      );

      // 1. Library methods
      final results = await Future.wait<Object?>([
        StashImage.cacheManager.emptyCache(),
        DefaultCacheManager().emptyCache(),
        extended_image.clearDiskCachedImages(),
      ]);
      debugPrint('AppCacheService: Library clear calls finished: $results');

      extended_image.clearMemoryImageCache();

      // 2. Manual brute force for the directories we scan
      final manualErrors = await _clearDirectoriesInBackground(
        dirsToClear.map((dir) => dir.path).toList(),
      );
      errors.addAll(manualErrors);

      final afterBytes = await _calculateCacheSizeInBackground(
        dirsToClear.map((dir) => dir.path).toList(),
      );
      debugPrint(
        'AppCacheService: Image cache clearing completed '
        'after=${_formatBytes(afterBytes)} '
        'deleted=${_formatBytes(beforeBytes - afterBytes)} '
        'manualErrors=${manualErrors.length}',
      );
    } catch (e) {
      debugPrint('AppCacheService: Error clearing image cache: $e');
      errors.add(e);
    }
    if (errors.isNotEmpty) {
      throw StateError(
        'Failed to fully clear image cache (${errors.length} errors)',
      );
    }
  }

  Future<void> clearVideoCache() async {
    debugPrint('AppCacheService: Clearing video cache...');
    final dirs = await _videoCacheDirs();
    debugPrint(
      'AppCacheService: Video cache clear dirs=${_formatDirs(dirs)} '
      'extensions=${_videoExtensions.join(',')}',
    );
    final beforeBytes = await _calculateCacheSizeInBackground(
      dirs.map((dir) => dir.path).toList(),
      extensions: _videoExtensions,
    );
    debugPrint(
      'AppCacheService: Video cache before clear=${_formatBytes(beforeBytes)}',
    );
    final errors = await _deleteFilesInBackground(
      dirs.map((dir) => dir.path).toList(),
      extensions: _videoExtensions,
    );
    final afterBytes = await _calculateCacheSizeInBackground(
      dirs.map((dir) => dir.path).toList(),
      extensions: _videoExtensions,
    );
    debugPrint(
      'AppCacheService: Video cache cleared '
      'after=${_formatBytes(afterBytes)} '
      'deleted=${_formatBytes(beforeBytes - afterBytes)} '
      'errors=${errors.length}',
    );
    if (errors.isNotEmpty) {
      throw StateError(
        'Failed to fully clear video cache (${errors.length} errors)',
      );
    }
  }

  Future<void> clearDatabaseCache() async {
    debugPrint('AppCacheService: Clearing database cache...');
    final hiveDir = Directory(
      p.join((await _temporaryDirectoryProvider()).path, 'stash_graphql_cache'),
    );

    final errors = <Object>[];
    if (await hiveDir.exists()) {
      try {
        await hiveDir.delete(recursive: true);
        debugPrint('AppCacheService: stash_graphql_cache deleted');
      } catch (e) {
        debugPrint('AppCacheService: Error deleting stash_graphql_cache: $e');
        errors.add(e);
      }
    }

    // Also clean up any legacy hive files in the old app documents location
    try {
      final appDir = await _applicationDocumentsDirectoryProvider();
      await for (final entity in appDir.list(recursive: false)) {
        final path = entity.path;
        if (entity is File &&
            (path.endsWith('.hive') || path.endsWith('.lock'))) {
          if (!path.contains('shared_preferences') &&
              !path.contains('flutter_secure_storage')) {
            await entity.delete();
          }
        }
      }
      // Also try the old stash_hive directory if it still exists
      final oldHiveDir = Directory(p.join(appDir.path, 'stash_hive'));
      if (await oldHiveDir.exists()) {
        await oldHiveDir.delete(recursive: true);
        debugPrint('AppCacheService: legacy stash_hive deleted');
      }
    } catch (e) {
      debugPrint('AppCacheService: Error cleaning legacy hive files: $e');
      errors.add(e);
    }
    if (errors.isNotEmpty) {
      throw StateError(
        'Failed to fully clear database cache (${errors.length} errors)',
      );
    }
  }

  Future<void> enforceImageCacheLimit(int maxMb) async {
    await _enforceLimit(
      dirs: await _imageCacheDirs(),
      maxMb: maxMb,
      extensions: null,
      label: 'image',
    );
  }

  Future<void> enforceVideoCacheLimit(int maxMb) async {
    await _enforceLimit(
      dirs: await _videoCacheDirs(),
      maxMb: maxMb,
      extensions: _videoExtensions,
      label: 'video',
    );
  }

  Future<void> _enforceLimit({
    required List<Directory> dirs,
    required int maxMb,
    required Set<String>? extensions,
    required String label,
  }) async {
    // 999999 is "unlimited" in settings.
    debugPrint(
      'AppCacheService: enforce $label cache limit requested '
      'limit=${maxMb}MB dirs=${_formatDirs(dirs)} '
      'extensions=${extensions?.join(',') ?? 'all'}',
    );
    if (maxMb <= 0 || maxMb >= 999999) {
      debugPrint(
        'AppCacheService: enforce $label cache skipped for limit=${maxMb}MB',
      );
      return;
    }

    final maxBytes = maxMb * 1024 * 1024;
    final result = await _enforceCacheLimitInBackground(
      dirs.map((dir) => dir.path).toList(),
      maxBytes: maxBytes,
      extensions: extensions,
    );

    debugPrint(
      'AppCacheService: enforce $label cache limit=${maxMb}MB '
      'existing=${_formatBytes(result.totalBytes)} '
      'matchedFiles=${result.matchedFiles} '
      'deleted=${_formatBytes(result.deletedBytes)} '
      'deletedFiles=${result.deletedFiles} '
      'remaining=${_formatBytes(result.remainingBytes)} '
      'scanErrors=${result.scanErrors} '
      'deleteErrors=${result.deleteErrors}',
    );
  }
}

String _formatDirs(List<Directory> dirs) {
  return dirs.map((dir) => dir.path).join(', ');
}

String _formatBytes(int bytes) {
  final clamped = bytes < 0 ? 0 : bytes;
  final mb = clamped / (1024 * 1024);
  return '${clamped}B/${mb.toStringAsFixed(2)}MB';
}

Future<int> _calculateCacheSizeInBackground(
  List<String> dirPaths, {
  Set<String>? extensions,
}) {
  return Isolate.run(
    () => _calculateCacheSizeSync(dirPaths, extensions: extensions),
  );
}

Future<List<Object>> _clearDirectoriesInBackground(List<String> dirPaths) {
  return Isolate.run(() => _clearDirectoriesSync(dirPaths));
}

Future<List<Object>> _deleteFilesInBackground(
  List<String> dirPaths, {
  required Set<String> extensions,
}) {
  return Isolate.run(() => _deleteFilesSync(dirPaths, extensions: extensions));
}

Future<_CacheLimitEnforcementResult> _enforceCacheLimitInBackground(
  List<String> dirPaths, {
  required int maxBytes,
  required Set<String>? extensions,
}) {
  return Isolate.run(
    () => _enforceCacheLimitSync(
      dirPaths,
      maxBytes: maxBytes,
      extensions: extensions,
    ),
  );
}

int _calculateCacheSizeSync(List<String> dirPaths, {Set<String>? extensions}) {
  var size = 0;
  for (final dirPath in dirPaths) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        if (!_matchesExtension(entity.path, extensions)) continue;
        size += entity.lengthSync();
      }
    } catch (_) {
      // Best-effort cache accounting: continue with remaining directories.
    }
  }
  return size;
}

List<Object> _clearDirectoriesSync(List<String> dirPaths) {
  final errors = <Object>[];
  for (final dirPath in dirPaths) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(followLinks: false)) {
        entity.deleteSync(recursive: true);
      }
    } catch (e) {
      errors.add(e);
    }
  }
  return errors;
}

List<Object> _deleteFilesSync(
  List<String> dirPaths, {
  required Set<String> extensions,
}) {
  final errors = <Object>[];
  for (final dirPath in dirPaths) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is File && _matchesExtension(entity.path, extensions)) {
          entity.deleteSync();
        }
      }
    } catch (e) {
      errors.add(e);
    }
  }
  return errors;
}

_CacheLimitEnforcementResult _enforceCacheLimitSync(
  List<String> dirPaths, {
  required int maxBytes,
  required Set<String>? extensions,
}) {
  final files = <_CacheFile>[];
  var totalBytes = 0;
  var scanErrors = 0;

  for (final dirPath in dirPaths) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        if (!_matchesExtension(entity.path, extensions)) continue;
        final stat = entity.statSync();
        final length = stat.size;
        files.add(
          _CacheFile(
            path: entity.path,
            size: length,
            modifiedMs: stat.modified.millisecondsSinceEpoch,
          ),
        );
        totalBytes += length;
      }
    } catch (_) {
      // Best-effort trimming: continue with remaining directories.
      scanErrors++;
    }
  }

  if (totalBytes <= maxBytes || files.isEmpty) {
    return _CacheLimitEnforcementResult(
      totalBytes: totalBytes,
      matchedFiles: files.length,
      deletedBytes: 0,
      deletedFiles: 0,
      scanErrors: scanErrors,
      deleteErrors: 0,
    );
  }

  files.sort((a, b) => a.modifiedMs.compareTo(b.modifiedMs));

  var deletedBytes = 0;
  var deletedFiles = 0;
  var deleteErrors = 0;
  for (final file in files) {
    if (totalBytes - deletedBytes <= maxBytes) break;
    try {
      File(file.path).deleteSync();
      deletedBytes += file.size;
      deletedFiles++;
    } catch (_) {
      // Ignore individual deletion failures and continue.
      deleteErrors++;
    }
  }
  return _CacheLimitEnforcementResult(
    totalBytes: totalBytes,
    matchedFiles: files.length,
    deletedBytes: deletedBytes,
    deletedFiles: deletedFiles,
    scanErrors: scanErrors,
    deleteErrors: deleteErrors,
  );
}

bool _matchesExtension(String path, Set<String>? extensions) {
  if (extensions == null) return true;
  return extensions.contains(p.extension(path).toLowerCase());
}

class _CacheFile {
  const _CacheFile({
    required this.path,
    required this.size,
    required this.modifiedMs,
  });

  final String path;
  final int size;
  final int modifiedMs;
}

class _CacheLimitEnforcementResult {
  const _CacheLimitEnforcementResult({
    required this.totalBytes,
    required this.matchedFiles,
    required this.deletedBytes,
    required this.deletedFiles,
    required this.scanErrors,
    required this.deleteErrors,
  });

  final int totalBytes;
  final int matchedFiles;
  final int deletedBytes;
  final int deletedFiles;
  final int scanErrors;
  final int deleteErrors;

  int get remainingBytes => totalBytes - deletedBytes;
}
