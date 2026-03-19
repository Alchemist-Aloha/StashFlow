import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/url_resolver.dart';

void main() {
  final endpoint = Uri.parse('http://192.168.88.225:29999');

  test('keeps absolute urls unchanged', () {
    expect(
      resolveGraphqlMediaUrl(
        rawUrl: 'https://cdn.example.com/a.jpg',
        graphqlEndpoint: endpoint,
      ),
      'https://cdn.example.com/a.jpg',
    );
  });

  test('resolves root-relative urls against endpoint origin', () {
    expect(
      resolveGraphqlMediaUrl(
        rawUrl: '/image/abc.jpg',
        graphqlEndpoint: endpoint,
      ),
      'http://192.168.88.225:29999/image/abc.jpg',
    );
  });

  test('resolves scheme-less host urls using endpoint scheme', () {
    expect(
      resolveGraphqlMediaUrl(
        rawUrl: '//192.168.88.225:29999/image/abc.jpg',
        graphqlEndpoint: endpoint,
      ),
      'http://192.168.88.225:29999/image/abc.jpg',
    );
  });

  test('returns empty string for empty values', () {
    expect(resolveGraphqlMediaUrl(rawUrl: '', graphqlEndpoint: endpoint), '');
    expect(resolveGraphqlMediaUrl(rawUrl: null, graphqlEndpoint: endpoint), '');
  });
}
