import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stash_app_flutter/core/data/cache/app_cache_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  String? tempPath;
  String? appPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => appPath;
}

void main() {
  late AppCacheService appCacheService;
  late MockPathProviderPlatform mockPathProvider;
  late Directory tempDir;
  late Directory appDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('stash_test_temp');
    appDir = Directory.systemTemp.createTempSync('stash_test_app');

    mockPathProvider = MockPathProviderPlatform();
    mockPathProvider.tempPath = tempDir.path;
    mockPathProvider.appPath = appDir.path;
    PathProviderPlatform.instance = mockPathProvider;

    appCacheService = AppCacheService();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    if (appDir.existsSync()) appDir.deleteSync(recursive: true);
  });

  test('getImageCacheSizeMb returns correct size', async {
    final cacheDir = Directory(p.join(tempDir.path, 'cache'))..createSync();
    File(p.join(cacheDir.path, 'test.jpg')).writeAsBytesSync(List.filled(1024 * 1024 * 2, 0)); // 2MB

    final size = await appCacheService.getImageCacheSizeMb();
    expect(size, 2);
  });

  test('getVideoCacheSizeMb returns correct size', async {
    final videoFile = File(p.join(tempDir.path, 'test.mp4'))
      ..writeAsBytesSync(List.filled(1024 * 1024 * 5, 0)); // 5MB

    final size = await appCacheService.getVideoCacheSizeMb();
    expect(size, 5);
  });

  test('clearImageCache deletes files in manual directories', async {
    final cacheDir = Directory(p.join(tempDir.path, 'cache'))..createSync();
    final file = File(p.join(cacheDir.path, 'test.jpg'))..writeAsStringSync('dummy');

    // We expect clearImageCache to call library methods which might fail in test env,
    // but we mainly care about the manual brute force part.
    // Library methods like DefaultCacheManager().emptyCache() might throw if not mocked,
    // but they are wrapped in try-catch in the implementation.

    await appCacheService.clearImageCache();

    expect(file.existsSync(), isFalse);
  });

  test('clearVideoCache deletes video files', async {
    final videoFile = File(p.join(tempDir.path, 'test.mp4'))..writeAsStringSync('dummy');
    final nonVideoFile = File(p.join(tempDir.path, 'test.txt'))..writeAsStringSync('dummy');

    await appCacheService.clearVideoCache();

    expect(videoFile.existsSync(), isFalse);
    expect(nonVideoFile.existsSync(), isTrue);
  });

  test('clearDatabaseCache deletes hive files', async {
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'))..createSync();
    final hiveFile = File(p.join(hiveDir.path, 'test.hive'))..writeAsStringSync('dummy');
    final rootHiveFile = File(p.join(appDir.path, 'root.hive'))..writeAsStringSync('dummy');

    await appCacheService.clearDatabaseCache();

    expect(hiveDir.existsSync(), isFalse);
    expect(rootHiveFile.existsSync(), isFalse);
  });
}
