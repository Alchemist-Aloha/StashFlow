import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';

void main() {
  group('Gallery Entity Tests', () {
    test('displayName returns title if available and not empty', () {
      const gallery = Gallery(id: '1', title: 'Test Gallery');
      expect(gallery.displayName, 'Test Gallery');
    });

    test('displayName trims title', () {
      const gallery = Gallery(id: '2', title: '  Trimmed Title  ');
      expect(gallery.displayName, 'Trimmed Title');
    });

    test('displayName returns cleaned filename from path if title is empty', () {
      const gallery = Gallery(
        id: '3',
        title: '',
        path: '/some/path/to/my_cool_gallery_123.zip',
      );
      // Tests regex substitution for underscores and dots
      expect(gallery.displayName, 'my cool gallery 123');
    });

    test('displayName returns "Untitled gallery" if title and path are empty', () {
      const gallery = Gallery(id: '4', title: '', path: '');
      expect(gallery.displayName, 'Untitled gallery');
    });

    test('fromJson correctly parses valid JSON mapping', () {
      final json = {
        'id': '10',
        'title': 'JSON Gallery',
        'date': '2023-10-01',
        'rating100': 85,
        'image_count': 15,
        'details': 'Some details',
        'files': [
          {'path': '/path/file1.zip'}
        ],
        'paths': {
          'cover': 'http://cover.path'
        },
        'cover': {
          'visual_files': [
            {'width': 800, 'height': 600}
          ]
        }
      };

      final gallery = Gallery.fromJson(json);

      expect(gallery.id, '10');
      expect(gallery.title, 'JSON Gallery');
      expect(gallery.date, '2023-10-01');
      expect(gallery.rating100, 85);
      expect(gallery.imageCount, 15);
      expect(gallery.details, 'Some details');
      expect(gallery.path, '/path/file1.zip');
      expect(gallery.coverPath, 'http://cover.path');
      expect(gallery.coverWidth, 800);
      expect(gallery.coverHeight, 600);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final json = {'id': '11'};
      final gallery = Gallery.fromJson(json);

      expect(gallery.id, '11');
      expect(gallery.title, '');
      expect(gallery.date, isNull);
      expect(gallery.rating100, isNull);
      expect(gallery.imageCount, isNull);
      expect(gallery.details, isNull);
      expect(gallery.path, isNull);
      expect(gallery.coverPath, isNull);
      expect(gallery.coverWidth, isNull);
      expect(gallery.coverHeight, isNull);
    });
  });
}
