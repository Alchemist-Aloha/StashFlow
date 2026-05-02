import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_title_utils.dart';

void main() {
  group('getFilestem', () {
    test('returns null for null or empty input', () {
      expect(getFilestem(null), isNull);
      expect(getFilestem(''), isNull);
      expect(getFilestem('   '), isNull);
    });

    test('normalizes Windows paths', () {
      expect(getFilestem(r'C:\Videos\My_Scene.mp4'), 'My Scene');
    });

    test('handles URIs with schemes', () {
      expect(getFilestem('http://example.com/videos/Scene_Name.mp4?query=1'), 'Scene Name');
    });

    test('decodes URI components', () {
      expect(getFilestem('My%20Awesome%20Scene.mp4'), 'My Awesome Scene');
    });

    test('removes extension', () {
      expect(getFilestem('video_file.mkv'), 'video file');
      expect(getFilestem('no_extension'), 'no extension');
    });

    test('replaces separators with spaces', () {
      expect(getFilestem('Scene_with.multiple_separators.mp4'), 'Scene with multiple separators');
    });

    test('returns null for generic names', () {
      expect(getFilestem('preview.mp4'), isNull);
      expect(getFilestem('STREAM.MKV'), isNull);
      expect(getFilestem('screenshot.png'), isNull);
    });

    test('handles path segments correctly', () {
      expect(getFilestem('/path/to/my/video.mp4'), 'video');
      expect(getFilestem('relative/path/scene.mp4'), 'scene');
    });

    test('returns null if cleaned name is empty', () {
      expect(getFilestem('____.mp4'), isNull);
      expect(getFilestem('...mp4'), isNull);
    });
  });

  group('buildSceneDisplayTitle', () {
    test('uses title if provided', () {
      final result = buildSceneDisplayTitle(
        title: 'Manually Set Title',
        filePath: 'ignored.mp4',
      );
      expect(result, 'Manually Set Title');
    });

    test('uses filePath filestem if title is missing', () {
      final result = buildSceneDisplayTitle(
        title: '',
        filePath: 'path_to_video.mp4',
      );
      expect(result, 'path to video');
    });

    test('uses streamPath filestem if title and filePath are missing', () {
      final result = buildSceneDisplayTitle(
        title: null,
        filePath: null,
        streamPath: 'stream_video.mp4',
      );
      expect(result, 'stream video');
    });

    test('uses fallback if everything else is missing or generic', () {
      final result = buildSceneDisplayTitle(
        title: ' ',
        filePath: 'preview.mp4',
        streamPath: null,
        fallback: 'No Title',
      );
      expect(result, 'No Title');
    });

    test('uses default fallback if none provided', () {
      final result = buildSceneDisplayTitle(
        title: null,
        filePath: null,
      );
      expect(result, 'Untitled Scene');
    });
  });
}
