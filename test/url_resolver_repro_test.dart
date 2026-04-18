import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/url_resolver.dart';

void main() {
  test('resolves root-relative urls and preserves userInfo', () {
    final endpoint = Uri.parse('https://user:pass@host/graphql');
    expect(
      resolveGraphqlMediaUrl(
        rawUrl: '/image/abc.jpg',
        graphqlEndpoint: endpoint,
      ),
      'https://user:pass@host/image/abc.jpg',
    );
  });

  test(
    'resolves root-relative urls and preserves queryParameters (Fails current impl)',
    () {
      final endpoint = Uri.parse('https://host/graphql?token=abc');
      expect(
        resolveGraphqlMediaUrl(
          rawUrl: '/image/abc.jpg',
          graphqlEndpoint: endpoint,
        ),
        'https://host/image/abc.jpg?token=abc',
      );
    },
  );
}
