import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';

void main() {
  group('Group Entity Parsing', () {
    test('should parse group from valid JSON', () {
      final json = {
        'id': 'g1',
        'name': 'Group One',
        'date': '2023-01-01',
        'rating100': 90,
        'director': 'John Doe',
        'synopsis': 'A thrilling synopsis.',
      };

      final groupObj = Group.fromJson(json);

      expect(groupObj.id, 'g1');
      expect(groupObj.name, 'Group One');
      expect(groupObj.date, '2023-01-01');
      expect(groupObj.rating100, 90);
      expect(groupObj.director, 'John Doe');
      expect(groupObj.synopsis, 'A thrilling synopsis.');
    });

    test('should parse group from JSON with missing nullable fields', () {
      final json = {
        'id': 'g2',
        'name': 'Group Two',
      };

      final groupObj = Group.fromJson(json);

      expect(groupObj.id, 'g2');
      expect(groupObj.name, 'Group Two');
      expect(groupObj.date, isNull);
      expect(groupObj.rating100, isNull);
      expect(groupObj.director, isNull);
      expect(groupObj.synopsis, isNull);
    });

    test('should use fallback empty strings when id and name are missing', () {
      final json = <String, dynamic>{};

      final groupObj = Group.fromJson(json);

      expect(groupObj.id, '');
      expect(groupObj.name, '');
      expect(groupObj.date, isNull);
      expect(groupObj.rating100, isNull);
      expect(groupObj.director, isNull);
      expect(groupObj.synopsis, isNull);
    });

    test('should handle id and name correctly when they are numbers in JSON', () {
      final json = {
        'id': 123,
        'name': 456,
      };

      final groupObj = Group.fromJson(json);

      expect(groupObj.id, '123');
      expect(groupObj.name, '456');
    });

    test('should handle null values in fields gracefully', () {
      final json = {
        'id': null,
        'name': null,
        'date': null,
        'rating100': null,
        'director': null,
        'synopsis': null,
      };

      final groupObj = Group.fromJson(json);

      expect(groupObj.id, '');
      expect(groupObj.name, '');
      expect(groupObj.date, isNull);
      expect(groupObj.rating100, isNull);
      expect(groupObj.director, isNull);
      expect(groupObj.synopsis, isNull);
    });
  });
}
