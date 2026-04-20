import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/filter_options.dart';

void main() {
  group('OrganizedFilter', () {
    test('toBool() should return correct values', () {
      expect(OrganizedFilter.all.toBool(), isNull);
      expect(OrganizedFilter.organized.toBool(), isTrue);
      expect(OrganizedFilter.unorganized.toBool(), isFalse);
    });

    test('fromBool() should return correct values', () {
      expect(OrganizedFilter.fromBool(null), OrganizedFilter.all);
      expect(OrganizedFilter.fromBool(true), OrganizedFilter.organized);
      expect(OrganizedFilter.fromBool(false), OrganizedFilter.unorganized);
    });
  });
}
