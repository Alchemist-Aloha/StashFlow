import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';

void main() {
  group('normalizeGraphqlServerUrl', () {
    test('appends /graphql if missing', () {
      expect(normalizeGraphqlServerUrl('http://localhost:9999'), 'http://localhost:9999/graphql');
      expect(normalizeGraphqlServerUrl('192.168.1.100'), 'https://192.168.1.100/graphql');
    });

    test('preserves /graphql if already present (backward compatibility)', () {
      expect(normalizeGraphqlServerUrl('http://localhost:9999/graphql'), 'http://localhost:9999/graphql');
      expect(normalizeGraphqlServerUrl('http://localhost:9999/graphql/'), 'http://localhost:9999/graphql/');
    });

    test('handles path with trailing slash by appending graphql', () {
       expect(normalizeGraphqlServerUrl('http://localhost:9999/'), 'http://localhost:9999/graphql');
    });
  });
}
