import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

void main() {
  group('ImageFilter Entity', () {
    test('should parse from full JSON', () {
      final json = {
        'searchQuery': 'test search',
        'rating100': {'value': 80, 'modifier': 'EQUALS'},
        'organized': true,
        'resolution': {'value': ['1080p', '4k'], 'modifier': 'INCLUDES'},
        'orientation': {'value': ['LANDSCAPE'], 'modifier': 'INCLUDES'},
      };

      final filter = ImageFilter.fromJson(json);

      expect(filter.searchQuery, 'test search');
      expect(filter.rating100?.value, 80);
      expect(filter.rating100?.modifier, CriterionModifier.equals);
      expect(filter.organized, true);
      expect(filter.resolution?.value, ['1080p', '4k']);
      expect(filter.orientation?.value, ['LANDSCAPE']);
    });

    test('should parse from empty JSON', () {
      final json = <String, dynamic>{};

      final filter = ImageFilter.fromJson(json);

      expect(filter.searchQuery, isNull);
      expect(filter.rating100, isNull);
      expect(filter.organized, isNull);
      expect(filter.resolution, isNull);
      expect(filter.orientation, isNull);
    });

    test('ImageFilter.empty() should create an empty filter', () {
      final filter = ImageFilter.empty();

      expect(filter.searchQuery, isNull);
      expect(filter.rating100, isNull);
      expect(filter.organized, isNull);
    });

    test('should support value equality', () {
      final filter1 = ImageFilter(
        searchQuery: 'query',
        rating100: const IntCriterion(value: 60, modifier: CriterionModifier.equals),
        organized: false,
      );
      final filter2 = ImageFilter(
        searchQuery: 'query',
        rating100: const IntCriterion(value: 60, modifier: CriterionModifier.equals),
        organized: false,
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
        rating100: const IntCriterion(value: 100, modifier: CriterionModifier.equals),
        organized: true,
        resolution: const MultiCriterion(value: ['1080p']),
      );

      final json = filter.toJson();

      expect(json['searchQuery'], 'test');
      expect(json['rating100']['value'], 100);
      expect(json['organized'], true);
      expect(json['resolution']['value'], ['1080p']);
    });
  });
}
