import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/features/scenes/data/utils/scrape_normalizer.dart';

void main() {
  group('buildSceneUpdateInputFromScraped', () {
    test('trims title/details and normalizes date', () {
      final scene = ScrapedScene(
        title: '  Title  ',
        details: '  Details  ',
        date: DateTime(2024, 5, 9, 23, 59),
      );

      final input = buildSceneUpdateInputFromScraped(scene);

      expect(input['title'], 'Title');
      expect(input['details'], 'Details');
      expect(input['date'], '2024-05-09');
    });

    test('drops blank title/details fields', () {
      final scene = ScrapedScene(title: '   ', details: '\n\t');
      final input = buildSceneUpdateInputFromScraped(scene);
      expect(input.containsKey('title'), isFalse);
      expect(input.containsKey('details'), isFalse);
    });

    test('normalizes urls and removes empty values', () {
      final scene = ScrapedScene(
        urls: const [
          'example.com/scene',
          ' https://ok.example/path ',
          '',
          '   ',
        ],
      );

      final input = buildSceneUpdateInputFromScraped(scene);

      expect(input['urls'], [
        'http://example.com/scene',
        'https://ok.example/path',
      ]);
    });

    test('adds data url prefix for raw image base64', () {
      final scene = ScrapedScene(image: 'abc123');
      final input = buildSceneUpdateInputFromScraped(scene);
      expect(input['cover_image'], 'data:image/jpeg;base64,abc123');
    });

    test('preserves existing data url for image', () {
      const dataUrl = 'data:image/png;base64,zzz';
      final scene = ScrapedScene(image: dataUrl);
      final input = buildSceneUpdateInputFromScraped(scene);
      expect(input['cover_image'], dataUrl);
    });

    test('does not map remote image urls to cover_image', () {
      final scene = ScrapedScene(image: 'https://images.test/cover.jpg');
      final input = buildSceneUpdateInputFromScraped(scene);
      expect(input.containsKey('cover_image'), isFalse);
    });

    test('includes studio_id when present', () {
      final scene = ScrapedScene(studioId: 'studio-1');
      final input = buildSceneUpdateInputFromScraped(scene);
      expect(input['studio_id'], 'studio-1');
    });
  });

  group('validateSceneUpdateInput', () {
    test('throws when no allowed keys are present', () {
      expect(
        () => validateSceneUpdateInput({'unknown': 1}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts minimal valid title update', () {
      expect(
        () => validateSceneUpdateInput({'title': 'Valid'}),
        returnsNormally,
      );
    });

    test('throws for invalid date format', () {
      expect(
        () => validateSceneUpdateInput({'date': '05-09-2024'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for non-string date', () {
      expect(
        () => validateSceneUpdateInput({'date': 12345}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when urls list is empty', () {
      expect(
        () => validateSceneUpdateInput({'urls': <String>[]}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for non-http(s) url schemes', () {
      expect(
        () => validateSceneUpdateInput({
          'urls': ['ftp://example.com/file'],
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts mixed valid http and https urls', () {
      expect(
        () => validateSceneUpdateInput({
          'urls': ['http://a.test', 'https://b.test/x'],
        }),
        returnsNormally,
      );
    });
  });
}
