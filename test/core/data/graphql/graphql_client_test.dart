import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';

void main() {
  group('normalizeGraphqlServerUrl', () {
    test('returns empty string for empty or whitespace strings', () {
      expect(normalizeGraphqlServerUrl(''), '');
      expect(normalizeGraphqlServerUrl('   '), '');
    });

    test('adds /graphql to URLs with schemes and no path', () {
      expect(normalizeGraphqlServerUrl('http://example.com'), 'http://example.com/graphql');
      expect(normalizeGraphqlServerUrl('https://example.com'), 'https://example.com/graphql');
      expect(normalizeGraphqlServerUrl('http://192.168.1.1'), 'http://192.168.1.1/graphql');
    });

    test('preserves existing paths in URLs with schemes', () {
      expect(normalizeGraphqlServerUrl('http://example.com/api/graphql'), 'http://example.com/api/graphql');
      expect(normalizeGraphqlServerUrl('https://example.com/custom'), 'https://example.com/custom');
    });

    test('defaults to https:// and appends /graphql for domains without schemes', () {
      expect(normalizeGraphqlServerUrl('example.com'), 'https://example.com/graphql');
      expect(normalizeGraphqlServerUrl('stash.local'), 'https://stash.local/graphql');
    });

    test('defaults to https:// and adds /graphql for domains with ports', () {
      expect(normalizeGraphqlServerUrl('localhost:8080'), 'https://localhost:8080/graphql');
      expect(normalizeGraphqlServerUrl('192.168.1.2:9999'), 'https://192.168.1.2:9999/graphql');
    });

    test('defaults to https:// and preserves path for domains with paths and no scheme', () {
      expect(normalizeGraphqlServerUrl('example.com/api/graphql'), 'https://example.com/api/graphql');
      expect(normalizeGraphqlServerUrl('localhost:8080/stash'), 'https://localhost:8080/stash');
    });

    test('handles trailing slashes', () {
      expect(normalizeGraphqlServerUrl('http://example.com/'), 'http://example.com/graphql');
      expect(normalizeGraphqlServerUrl('example.com/'), 'https://example.com/graphql');
    });
  });
}
