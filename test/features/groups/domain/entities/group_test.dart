import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';

void main() {
  group('Group Entity Tests', () {
    test('fromJson correctly parses valid JSON', () {
      final json = {
        'id': '1',
        'name': 'Test Group',
        'date': '2023-10-02',
        'rating100': 90,
        'director': 'John Doe',
        'synopsis': 'A thrilling synopsis',
      };

      final groupObj = Group.fromJson(json);

      expect(groupObj.id, '1');
      expect(groupObj.name, 'Test Group');
      expect(groupObj.date, '2023-10-02');
      expect(groupObj.rating100, 90);
      expect(groupObj.director, 'John Doe');
      expect(groupObj.synopsis, 'A thrilling synopsis');
    });

    test('fromJson handles missing optional fields gracefully', () {
      final json = {'id': '2'};
      final groupObj = Group.fromJson(json);

      expect(groupObj.id, '2');
      expect(groupObj.name, '');
      expect(groupObj.date, isNull);
      expect(groupObj.rating100, isNull);
      expect(groupObj.director, isNull);
      expect(groupObj.synopsis, isNull);
    });
  });
}
