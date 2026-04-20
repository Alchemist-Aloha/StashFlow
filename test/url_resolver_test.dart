import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
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

  test('preserves userInfo and queryParameters from endpoint', () {
    final ssoEndpoint = Uri.parse(
      'https://user:pass@stash.host.tld/graphql?token=secret',
    );
    final result = resolveGraphqlMediaUrl(
      rawUrl: '/image/abc.jpg',
      graphqlEndpoint: ssoEndpoint,
    );
    expect(
      result,
      'https://user:pass@stash.host.tld/image/abc.jpg?token=secret',
    );
  });

  test('merges endpoint queryParameters with relative path parameters', () {
    final ssoEndpoint = Uri.parse(
      'https://stash.host.tld/graphql?token=secret',
    );
    final result = resolveGraphqlMediaUrl(
      rawUrl: '/image/abc.jpg?id=123',
      graphqlEndpoint: ssoEndpoint,
    );
    expect(result, contains('token=secret'));
    expect(result, contains('id=123'));
  });

  group('appendApiKey', () {
    test('appends apikey to url without existing parameters', () {
      final url = 'http://example.com/image';
      final result = appendApiKey(url, 'mykey');
      expect(result, 'http://example.com/image?apikey=mykey');
    });

    test('appends apikey to url with existing parameters', () {
      final url = 'http://example.com/image?foo=bar';
      final result = appendApiKey(url, 'mykey');
      // order might depend on implementation, but Uri.replace usually appends
      expect(result, contains('apikey=mykey'));
      expect(result, contains('foo=bar'));
    });

    test('returns original url if api key is empty', () {
      final url = 'http://example.com/image';
      expect(appendApiKey(url, ''), url);
      expect(appendApiKey(url, '  '), url);
    });

    test('handles invalid urls gracefully', () {
      final url = 'not-a-url';
      final result = appendApiKey(url, 'key');
      expect(result, 'not-a-url?apikey=key');
    });
  });

  group('applyWebMediaAuthFallback', () {
    final endpoint = Uri.parse('https://stash.host.tld/graphql');

    test('keeps url unchanged for password mode', () {
      const url = 'https://stash.host.tld/image/1/thumbnail?t=123';
      final result = applyWebMediaAuthFallback(
        url: url,
        authMode: AuthMode.password,
        apiKey: '',
        username: 'user',
        password: 'pass',
        graphqlEndpoint: endpoint,
      );
      expect(result, url);
    });

    test('appends apikey for basic mode when apikey exists', () {
      const url = 'https://stash.host.tld/scene/5/stream.mp4?resolution=ORIGINAL';
      final result = applyWebMediaAuthFallback(
        url: url,
        authMode: AuthMode.basic,
        apiKey: 'key123',
        username: 'user',
        password: 'pass',
        graphqlEndpoint: endpoint,
      );
      expect(result, contains('apikey=key123'));
      expect(result, contains('resolution=ORIGINAL'));
    });

    test('DOES NOT inject basic userInfo for same-origin url when no apikey', () {
      const url = 'https://stash.host.tld/gallery/11/cover?t=1';
      final result = applyWebMediaAuthFallback(
        url: url,
        authMode: AuthMode.basic,
        apiKey: '',
        username: 'alice',
        password: 'secret',
        graphqlEndpoint: endpoint,
      );
      // New behavior: user:pass should NOT be injected
      expect(result, 'https://stash.host.tld/gallery/11/cover?t=1');
      expect(result, isNot(contains('alice:secret')));
    });

    test('does not inject userInfo for cross-origin url', () {
      const url = 'https://cdn.host.tld/gallery/11/cover?t=1';
      final result = applyWebMediaAuthFallback(
        url: url,
        authMode: AuthMode.basic,
        apiKey: '',
        username: 'alice',
        password: 'secret',
        graphqlEndpoint: endpoint,
      );
      expect(result, url);
    });
  });
}
