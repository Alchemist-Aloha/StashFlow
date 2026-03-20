import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';

void main() {
  group('Scene Entity Parsing', () {
    test('should parse from valid JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Scene',
        'date': '2024-03-18',
        'rating100': 80,
        'o_counter': 5,
        'organized': true,
        'interactive': false,
        'resume_time': 120.5,
        'play_count': 10,
        'files': [
          {
            'format': 'mp4',
            'width': 1920,
            'height': 1080,
            'video_codec': 'h264',
            'audio_codec': 'aac',
            'bit_rate': 5000000,
            'duration': 300.0,
            'frame_rate': 24.0,
          },
        ],
        'paths': {
          'screenshot': 'https://example.com/thumb.jpg',
          'preview': 'https://example.com/preview.mp4',
          'stream': 'https://example.com/stream.m3u8',
        },
        'studio_id': 's1',
        'studio_name': 'Test Studio',
        'studio_image_path': null,
        'performer_ids': ['p1'],
        'performer_names': ['Performer 1'],
        'performer_image_paths': [null],
        'tag_ids': ['t1'],
        'tag_names': ['Tag 1'],
      };

      final scene = Scene.fromJson(json);

      expect(scene.id, '1');
      expect(scene.title, 'Test Scene');
      expect(scene.date, DateTime(2024, 3, 18));
      expect(scene.rating100, 80);
      expect(scene.files.first.width, 1920);
      expect(scene.paths.stream, 'https://example.com/stream.m3u8');
    });

    test('should handle null technical metadata gracefully', () {
      final json = {
        'id': '2',
        'title': 'Minimal Scene',
        'date': '2024-03-18',
        'rating100': null,
        'o_counter': 0,
        'organized': false,
        'interactive': false,
        'resume_time': null,
        'play_count': 0,
        'files': [],
        'paths': {'screenshot': null, 'preview': null, 'stream': null},
        'studio_id': null,
        'studio_name': null,
        'studio_image_path': null,
        'performer_ids': [],
        'performer_names': [],
        'performer_image_paths': [],
        'tag_ids': [],
        'tag_names': [],
      };

      final scene = Scene.fromJson(json);
      expect(scene.id, '2');
      expect(scene.rating100, isNull);
      expect(scene.studioName, isNull);
      expect(scene.paths.screenshot, isNull);
    });
  });
}
