import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/playback_media.dart';

void main() {
  test('web omits HTTP headers and preserves authenticated URL and resume', () {
    const url = 'https://stash.test/scene/1/stream?apikey=test-key';
    const start = Duration(seconds: 12);
    final media = createPlaybackMedia(
      url,
      httpHeaders: {'ApiKey': 'test-key'},
      start: start,
      isWeb: true,
    );
    expect(media.httpHeaders, isNull);
    expect(media.uri, url);
    expect(media.start, start);
  });

  test('native playback retains HTTP headers', () {
    final media = createPlaybackMedia(
      'https://stash.test/scene/2/stream',
      httpHeaders: {'Authorization': 'Bearer test-key'},
      isWeb: false,
    );
    expect(media.httpHeaders, {'Authorization': 'Bearer test-key'});
  });
}
