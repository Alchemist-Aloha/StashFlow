import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_title_utils.dart';

Scene _sceneWith({String title = 'Title', String? path, String? streamPath}) {
  return Scene(
    id: 'scene-1',
    title: title,
    details: null,
    path: path,
    date: DateTime(2024, 1, 1),
    rating100: null,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: null,
    files: const [],
    paths: ScenePaths(
      screenshot: null,
      preview: null,
      stream: streamPath,
      caption: null,
      vtt: null,
      sprite: null,
    ),
    captions: const [],
    urls: const [],
    studioId: null,
    studioName: null,
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

void main() {
  group('getFilestem', () {
    test('returns null for null/blank inputs', () {
      expect(getFilestem(null), isNull);
      expect(getFilestem('   '), isNull);
    });

    test('extracts and cleans from normal filename', () {
      expect(getFilestem('/media/My_Cool.Scene.mp4'), 'My Cool Scene');
    });

    test('handles windows path separators', () {
      expect(getFilestem(r'C:\stash\My_File.avi'), 'My File');
    });

    test('decodes URL-encoded names', () {
      expect(
        getFilestem('https://host/media/My%20Encoded%20Name.mkv'),
        'My Encoded Name',
      );
    });

    test('does not crash on bad percent encoding', () {
      expect(getFilestem('/media/%E0%A4%A.mp4'), '%E0%A4%A');
    });

    test('returns null for generic fallback names', () {
      expect(getFilestem('/x/stream.mp4'), isNull);
      expect(getFilestem('/x/video.mkv'), isNull);
      expect(getFilestem('/x/preview.mov'), isNull);
    });

    test('returns null when final path segment is empty', () {
      expect(getFilestem('https://host/media/'), isNull);
    });
  });

  group('buildSceneDisplayTitle', () {
    test('prefers non-empty trimmed title', () {
      final title = buildSceneDisplayTitle(
        title: '  A Real Title  ',
        filePath: '/media/ignored.mp4',
      );
      expect(title, 'A Real Title');
    });

    test('falls back to file path stem when title is blank', () {
      final title = buildSceneDisplayTitle(
        title: '  ',
        filePath: '/media/Fallback_Name.mp4',
      );
      expect(title, 'Fallback Name');
    });

    test('falls back to stream path when file path is absent', () {
      final title = buildSceneDisplayTitle(
        title: null,
        filePath: null,
        streamPath: '/stream/From_Stream.webm',
      );
      expect(title, 'From Stream');
    });

    test('returns provided fallback when no usable title source exists', () {
      final title = buildSceneDisplayTitle(
        title: '',
        filePath: '/media/stream.mp4',
        streamPath: '/stream/video.mp4',
        fallback: 'Custom Fallback',
      );
      expect(title, 'Custom Fallback');
    });
  });

  group('SceneDisplayTitleX.displayTitle', () {
    test('uses extension logic for path fallback', () {
      final scene = _sceneWith(title: '', path: '/library/Display_Title.mp4');

      expect(scene.displayTitle, 'Display Title');
    });

    test('uses default fallback when no title/path/stream available', () {
      final scene = _sceneWith(title: ' ', path: null, streamPath: null);
      expect(scene.displayTitle, 'Untitled Scene');
    });
  });
}
