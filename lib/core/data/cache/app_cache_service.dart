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
  AppCacheService();

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
    final tempPath = (await getTemporaryDirectory()).path;
    
    final cacheDirs = {
      'cache': Directory(p.join(tempPath, 'cache')),
      'stashImageCache': Directory(p.join(tempPath, 'stashImageCache')),
      'libCachedImageData': Directory(p.join(tempPath, 'libCachedImageData')),
    };

    for (final entry in cacheDirs.entries) {
      final size = await _calculateDirSize(entry.value);
      if (size > 0) {
        debugPrint('AppCacheService: Directory ${entry.key} size: $size bytes');
      }
      totalBytes += size;
    }

    debugPrint('AppCacheService: Image cache total size: $totalBytes bytes in $tempPath');
    return totalBytes ~/ (1024 * 1024);
  }

  Future<int> getVideoCacheSizeMb() async {
    final tempDir = await getTemporaryDirectory();
    final appDir = await getApplicationDocumentsDirectory();
    
    int bytes = 0;
    final videoExtensions = {'.mkv', '.mp4', '.webm', '.avi', '.mov', '.part'};
    
    Future<void> scan(Directory dir) async {
      try {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (videoExtensions.contains(ext)) {
              bytes += await entity.length();
            }
          }
        }
      } catch (_) {}
    }

    await scan(tempDir);
    await scan(appDir);
    
    debugPrint('AppCacheService: Video cache size: $bytes bytes');
    return bytes ~/ (1024 * 1024);
  }

  Future<int> getDatabaseCacheSizeMb() async {
    final appDir = await getApplicationDocumentsDirectory();
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
    try {
      // 1. Library methods
      final results = await Future.wait([
        StashImage.cacheManager.emptyCache(),
        DefaultCacheManager().emptyCache(),
        extended_image.clearDiskCachedImages(),
      ]);
      debugPrint('AppCacheService: Library clear calls finished: $results');
      
      extended_image.clearMemoryImageCache();

      // 2. Manual brute force for the directories we scan
      final tempPath = (await getTemporaryDirectory()).path;
      final dirsToClear = [
        p.join(tempPath, 'cache'),
        p.join(tempPath, 'stashImageCache'),
        p.join(tempPath, 'libCachedImageData'),
      ];

      for (final path in dirsToClear) {
        final dir = Directory(path);
        if (await dir.exists()) {
          debugPrint('AppCacheService: Manually clearing directory: $path');
          try {
            await for (final entity in dir.list()) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            debugPrint('AppCacheService: Manual clear failed for $path: $e');
          }
        }
      }
      
      debugPrint('AppCacheService: Image cache clearing completed');
    } catch (e) {
      debugPrint('AppCacheService: Error clearing image cache: $e');
    }
  }

  Future<void> clearVideoCache() async {
    debugPrint('AppCacheService: Clearing video cache...');
    final tempDir = await getTemporaryDirectory();
    final appDir = await getApplicationDocumentsDirectory();
    final videoExtensions = {'.mkv', '.mp4', '.webm', '.avi', '.mov', '.part'};

    Future<void> deleteVideos(Directory dir) async {
      try {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (videoExtensions.contains(ext)) {
              await entity.delete();
            }
          }
        }
      } catch (_) {}
    }

    await deleteVideos(tempDir);
    await deleteVideos(appDir);
    debugPrint('AppCacheService: Video cache cleared');
  }

  Future<void> clearDatabaseCache() async {
    debugPrint('AppCacheService: Clearing database cache...');
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    
    if (await hiveDir.exists()) {
      try {
        await hiveDir.delete(recursive: true);
        debugPrint('AppCacheService: stash_hive deleted');
      } catch (e) {
        debugPrint('AppCacheService: Error deleting stash_hive: $e');
      }
    }
    
    // Also delete root hive files (excluding essential ones if any, but hive files are usually safe to clear for cache)
    try {
      await for (final entity in appDir.list(recursive: false)) {
        final path = entity.path;
        if (entity is File && (path.endsWith('.hive') || path.endsWith('.lock'))) {
          // Don't delete shared_preferences if it's there (though usually it's in a different spot)
          if (!path.contains('shared_preferences')) {
            await entity.delete();
          }
        }
      }
      debugPrint('AppCacheService: Root hive files deleted');
    } catch (e) {
      debugPrint('AppCacheService: Error deleting root hive files: $e');
    }
  }
}
