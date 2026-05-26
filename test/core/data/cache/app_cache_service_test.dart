import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/cache/app_cache_service.dart';

void main() {
  group('AppCacheService cache limit enforcement', () {
    late Directory tempRoot;
    late Directory appCacheRoot;
    late Directory docsRoot;
    late AppCacheService service;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('stashflow-temp-');
      appCacheRoot = await Directory.systemTemp.createTemp(
        'stashflow-appcache-',
      );
      docsRoot = await Directory.systemTemp.createTemp('stashflow-docs-');

      service = AppCacheService(
        temporaryDirectoryProvider: () async => tempRoot,
        applicationCacheDirectoryProvider: () async => appCacheRoot,
        applicationDocumentsDirectoryProvider: () async => docsRoot,
      );
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
      if (await appCacheRoot.exists()) {
        await appCacheRoot.delete(recursive: true);
      }
      if (await docsRoot.exists()) {
        await docsRoot.delete(recursive: true);
      }
    });

    test('enforceImageCacheLimit trims oldest files when over max', () async {
      final cacheDir = Directory('${tempRoot.path}/cache')
        ..createSync(recursive: true);
      final oldFile = File('${cacheDir.path}/old.bin')
        ..writeAsBytesSync(List<int>.filled(1024 * 1024, 1));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final newFile = File('${cacheDir.path}/new.bin')
        ..writeAsBytesSync(List<int>.filled(1024 * 1024, 2));

      expect(await oldFile.exists(), isTrue);
      expect(await newFile.exists(), isTrue);

      await service.enforceImageCacheLimit(1);

      // Keep newest file when trimming to 1MB.
      expect(await oldFile.exists(), isFalse);
      expect(await newFile.exists(), isTrue);
    });

    test('enforceVideoCacheLimit only targets video extensions', () async {
      final videoDir = Directory('${tempRoot.path}/video')
        ..createSync(recursive: true);
      final videoFile = File('${videoDir.path}/clip.mp4')
        ..writeAsBytesSync(List<int>.filled(128 * 1024, 9));
      final nonVideoFile = File('${videoDir.path}/notes.txt')
        ..writeAsStringSync('keep me');

      await service.enforceVideoCacheLimit(0); // ignored by guard
      expect(await videoFile.exists(), isTrue);

      await service.enforceVideoCacheLimit(1);

      expect(await videoFile.exists(), isTrue);
      expect(await nonVideoFile.exists(), isTrue);

      // Add another video to exceed 1MB so trimming occurs.
      final oldVideo = File('${videoDir.path}/old.webm')
        ..writeAsBytesSync(List<int>.filled(1024 * 1024, 3));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await service.enforceVideoCacheLimit(1);

      expect(await videoFile.exists(), isFalse);
      expect(await oldVideo.exists(), isTrue);
      expect(await nonVideoFile.exists(), isTrue);
    });

    test(
      'getVideoCacheSizeMb ignores media files outside explicit video caches',
      () async {
        File(
          '${tempRoot.path}/unowned.mp4',
        ).writeAsBytesSync(List<int>.filled(1024 * 1024, 1));
        final videoDir = Directory('${tempRoot.path}/video')..createSync();
        File(
          '${videoDir.path}/owned.mp4',
        ).writeAsBytesSync(List<int>.filled(1024 * 1024, 1));

        expect(await service.getVideoCacheSizeMb(), 1);
      },
    );

    test(
      'clearVideoCache does not delete media files outside explicit video caches',
      () async {
        final unownedFile = File('${tempRoot.path}/unowned.mp4')
          ..writeAsBytesSync(List<int>.filled(1024, 1));
        final videoDir = Directory('${tempRoot.path}/video')..createSync();
        final ownedFile = File('${videoDir.path}/owned.mp4')
          ..writeAsBytesSync(List<int>.filled(1024, 1));

        await service.clearVideoCache();

        expect(await unownedFile.exists(), isTrue);
        expect(await ownedFile.exists(), isFalse);
      },
    );
  });
}
