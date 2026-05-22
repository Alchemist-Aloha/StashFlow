import 'dart:io';
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
            root,
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
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('AppCacheService: Error listing directory ${dir.path}: $e');
    }
    return size;
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
    int bytes = 0;
    final dirs = await _videoCacheDirs();
    
    Future<void> scan(Directory dir) async {
      try {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (_videoExtensions.contains(ext)) {
              bytes += await entity.length();
            }
          }
        }
      } catch (_) {}
    }

    for (final dir in dirs) {
      await scan(dir);
    }
    
    debugPrint('AppCacheService: Video cache size: $bytes bytes');
    return bytes ~/ (1024 * 1024);
  }

  Future<int> getDatabaseCacheSizeMb() async {
    final appDir = await _applicationDocumentsDirectoryProvider();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    
    int bytes = await _calculateDirSize(hiveDir);
    
    // Also check for root hive files
    try {
      await for (final entity in appDir.list(recursive: false)) {
        if (entity is File && (entity.path.endsWith('.hive') || entity.path.endsWith('.lock'))) {
          bytes += await entity.length();
        }
      }
    } catch (_) {}

    debugPrint('AppCacheService: Database cache size: $bytes bytes in ${appDir.path}');
    return bytes ~/ (1024 * 1024);
  }

  Future<void> clearImageCache() async {
    debugPrint('AppCacheService: Clearing image cache...');
    final errors = <Object>[];
    try {
      // 1. Library methods
      final results = await Future.wait<Object?>([
        StashImage.cacheManager.emptyCache(),
        DefaultCacheManager().emptyCache(),
        extended_image.clearDiskCachedImages(),
      ]);
      debugPrint('AppCacheService: Library clear calls finished: $results');
      
      extended_image.clearMemoryImageCache();

      // 2. Manual brute force for the directories we scan
      final dirsToClear = await _imageCacheDirs();

      for (final dir in dirsToClear) {
        if (await dir.exists()) {
          debugPrint('AppCacheService: Manually clearing directory: ${dir.path}');
          try {
            await for (final entity in dir.list()) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            debugPrint('AppCacheService: Manual clear failed for ${dir.path}: $e');
            errors.add(e);
          }
        }
      }
      
      debugPrint('AppCacheService: Image cache clearing completed');
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
    final errors = <Object>[];

    Future<void> deleteVideos(Directory dir) async {
      try {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (_videoExtensions.contains(ext)) {
              await entity.delete();
            }
          }
        }
      } catch (e) {
        errors.add(e);
      }
    }

    for (final dir in dirs) {
      await deleteVideos(dir);
    }
    debugPrint('AppCacheService: Video cache cleared');
    if (errors.isNotEmpty) {
      throw StateError(
        'Failed to fully clear video cache (${errors.length} errors)',
      );
    }
  }

  Future<void> clearDatabaseCache() async {
    debugPrint('AppCacheService: Clearing database cache...');
    final appDir = await _applicationDocumentsDirectoryProvider();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    
    final errors = <Object>[];
    if (await hiveDir.exists()) {
      try {
        await hiveDir.delete(recursive: true);
        debugPrint('AppCacheService: stash_hive deleted');
      } catch (e) {
        debugPrint('AppCacheService: Error deleting stash_hive: $e');
        errors.add(e);
      }
    }
    
    // Also delete root hive files (excluding essential ones if any, but hive files are usually safe to clear for cache)
    try {
      await for (final entity in appDir.list(recursive: false)) {
        final path = entity.path;
        if (entity is File && (path.endsWith('.hive') || path.endsWith('.lock'))) {
          // Don't delete shared_preferences if it's there (though usually it's in a different spot)
          if (!path.contains('shared_preferences') &&
              !path.contains('flutter_secure_storage')) {
            await entity.delete();
          }
        }
      }
      debugPrint('AppCacheService: Root hive files deleted');
    } catch (e) {
      debugPrint('AppCacheService: Error deleting root hive files: $e');
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
    if (maxMb <= 0 || maxMb >= 999999) return;

    final maxBytes = maxMb * 1024 * 1024;
    final files = <File>[];
    int totalBytes = 0;

    for (final dir in dirs) {
      try {
        if (!await dir.exists()) continue;
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is! File) continue;
          final ext = p.extension(entity.path).toLowerCase();
          if (extensions != null && !extensions.contains(ext)) continue;
          files.add(entity);
          totalBytes += await entity.length();
        }
      } catch (_) {
        // Best-effort trimming: continue with remaining directories.
      }
    }

    if (totalBytes <= maxBytes || files.isEmpty) return;

    files.sort((a, b) {
      final aMs = a.statSync().modified.millisecondsSinceEpoch;
      final bMs = b.statSync().modified.millisecondsSinceEpoch;
      return aMs.compareTo(bMs);
    });

    var deletedBytes = 0;
    for (final file in files) {
      if (totalBytes - deletedBytes <= maxBytes) break;
      try {
        final len = await file.length();
        await file.delete();
        deletedBytes += len;
      } catch (_) {
        // Ignore individual deletion failures and continue.
      }
    }

    debugPrint(
      'AppCacheService: enforce $label cache limit=${maxMb}MB '
      'deleted=${deletedBytes ~/ (1024 * 1024)}MB',
    );
  }
}
