import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';

void main() {
  group('ImageFilter Entity', () {
    test('should parse from full JSON', () {
      final json = {
        'searchQuery': 'test search',
        'minRating': 4,
        'organized': true,
        'resolutions': ['1080p', '4k'],
        'orientations': ['landscape'],
      };

      final filter = ImageFilter.fromJson(json);

      expect(filter.searchQuery, 'test search');
      expect(filter.minRating, 4);
      expect(filter.organized, true);
      expect(filter.resolutions, ['1080p', '4k']);
      expect(filter.orientations, ['landscape']);
    });

    test('should parse from empty JSON', () {
      final json = <String, dynamic>{};

      final filter = ImageFilter.fromJson(json);

      expect(filter.searchQuery, isNull);
      expect(filter.minRating, isNull);
      expect(filter.organized, isNull);
      expect(filter.resolutions, isNull);
      expect(filter.orientations, isNull);
    });

    test('should handle explicit nulls in JSON', () {
      final json = {
        'searchQuery': null,
        'minRating': null,
        'organized': null,
        'resolutions': null,
        'orientations': null,
      };

      final filter = ImageFilter.fromJson(json);

      expect(filter.searchQuery, isNull);
      expect(filter.minRating, isNull);
      expect(filter.organized, isNull);
      expect(filter.resolutions, isNull);
      expect(filter.orientations, isNull);
    });

    test('ImageFilter.empty() should create an empty filter', () {
      final filter = ImageFilter.empty();

      expect(filter.searchQuery, isNull);
      expect(filter.minRating, isNull);
      expect(filter.organized, isNull);
      expect(filter.resolutions, isNull);
      expect(filter.orientations, isNull);
    });

    test('should support value equality', () {
      final filter1 = ImageFilter(
        searchQuery: 'query',
        minRating: 3,
        organized: false,
        resolutions: const ['720p'],
        orientations: const ['portrait'],
      );
      final filter2 = ImageFilter(
        searchQuery: 'query',
        minRating: 3,
        organized: false,
        resolutions: const ['720p'],
        orientations: const ['portrait'],
      );
      final filter3 = ImageFilter(
        searchQuery: 'different',
      );

      expect(filter1, equals(filter2));
      expect(filter1, isNot(equals(filter3)));
      expect(filter1.hashCode, equals(filter2.hashCode));
    });

    test('should convert to JSON correctly', () {
      final filter = ImageFilter(
        searchQuery: 'test',
        minRating: 5,
        organized: true,
        resolutions: const ['1080p'],
        orientations: const ['square'],
      );

      final json = filter.toJson();

      expect(json['searchQuery'], 'test');
      expect(json['minRating'], 5);
      expect(json['organized'], true);
      expect(json['resolutions'], ['1080p']);
      expect(json['orientations'], ['square']);
    });
  });
}
