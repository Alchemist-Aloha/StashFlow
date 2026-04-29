import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:extended_image/extended_image.dart' as extended_image;
import '../graphql/graphql_client.dart';
import '../../presentation/widgets/stash_image.dart';

final appCacheServiceProvider = Provider<AppCacheService>((ref) {
  return AppCacheService();
});

class AppCacheService {
  AppCacheService();

  Future<int> _calculateDirSize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (_) {}
    return size;
  }

  Future<int> getImageCacheSizeMb() async {
    int bytes = 0;
    // extended_image cache size
    final extCacheDir = Directory(p.join((await getTemporaryDirectory()).path, 'cache'));
    bytes += await _calculateDirSize(extCacheDir);
    
    // flutter_cache_manager (StashImage) size (approximate by looking at its default folder)
    final stashImageDir = Directory(p.join((await getTemporaryDirectory()).path, 'stashImageCache'));
    bytes += await _calculateDirSize(stashImageDir);

    return bytes ~/ (1024 * 1024);
  }

  Future<int> getVideoCacheSizeMb() async {
    final tempDir = await getTemporaryDirectory();
    // media_kit usually creates temp files in system temp dir
    int bytes = 0;
    try {
      await for (final entity in tempDir.list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.mkv')) { // Common media_kit extension or logic
          bytes += await entity.length();
        }
      }
    } catch (_) {}
    return bytes ~/ (1024 * 1024);
  }

  Future<int> getDatabaseCacheSizeMb() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    return (await _calculateDirSize(hiveDir)) ~/ (1024 * 1024);
  }

  Future<void> clearImageCache() async {
    await StashImage.cacheManager.emptyCache();
    extended_image.clearMemoryImageCache();
    await extended_image.clearDiskCachedImages();
  }

  Future<void> clearVideoCache() async {
    final tempDir = await getTemporaryDirectory();
    try {
      await for (final entity in tempDir.list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.mkv')) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> clearDatabaseCache() async {
    // Requires restarting GraphQL client or manual hive clear
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    if (await hiveDir.exists()) {
      try {
        await hiveDir.delete(recursive: true);
      } catch (_) {}
    }
  }
}
