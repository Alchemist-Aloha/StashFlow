import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';

Future<ProviderContainer> _container(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('uses the scene direct stream without querying sceneStreams', () async {
    final container = await _container({});

    final choice = await container.read(streamResolverProvider)(
      _scene('https://stash.test/scene/1/stream'),
    );

    expect(choice?.url, 'https://stash.test/scene/1/stream');
    expect(choice?.label, 'Direct');
  });

  test('falls back to direct when sceneStreams cannot be fetched', () async {
    // No server is configured, so the preferred HLS lookup fails.
    final container = await _container({defaultStreamSourceKey: 'hls'});

    final choice = await container.read(streamResolverProvider)(
      _scene('https://stash.test/scene/1/stream'),
    );

    expect(choice?.url, 'https://stash.test/scene/1/stream');
  });

  test('classifies Stash stream URLs by source kind', () {
    const base = 'http://h:9999/scene/7';
    expect(streamSourceKind('$base/stream'), 'direct');
    expect(streamSourceKind('$base/stream.mp4?resolution=LOW'), 'mp4');
    expect(streamSourceKind('$base/stream.webm'), 'webm');
    expect(streamSourceKind('$base/stream.m3u8?apikey=x'), 'hls');
    expect(streamSourceKind('$base/stream.mpd'), 'dash');
  });

  group('pickStreamResolution', () {
    const base = 'http://h:9999/scene/7/stream.mp4';
    StreamChoice mp4(String? res) => StreamChoice(
      url: res == null ? base : '$base?resolution=$res',
      mimeType: 'video/mp4',
    );
    // A 720p file: Stash offers the original plus lower transcodes.
    final options = [
      mp4(null),
      mp4('STANDARD_HD'),
      mp4('STANDARD'),
      mp4('LOW'),
    ];
    String? pick(String preferred, {int? sourceHeight = 720}) =>
        streamResolution(
          pickStreamResolution(
            options,
            preferred,
            sourceHeight: sourceHeight,
          )!.url,
        );

    test('uses an exact match', () {
      expect(pick('STANDARD'), 'STANDARD');
      expect(pick('ORIGINAL'), 'ORIGINAL');
    });

    test('prefers the original over an equal-height transcode', () {
      expect(pick('STANDARD_HD'), 'ORIGINAL');
      expect(pick('FULL_HD'), 'ORIGINAL');
    });

    test('falls back to the next lower resolution', () {
      expect(pick('FULL_HD', sourceHeight: 2160), 'STANDARD_HD');
    });

    test('uses the lowest when every option is higher', () {
      expect(
        streamResolution(
          pickStreamResolution([
            mp4('STANDARD_HD'),
            mp4('STANDARD'),
          ], 'LOW')!.url,
        ),
        'STANDARD',
      );
      expect(pickStreamResolution(const [], 'LOW'), isNull);
    });
  });
}

Scene _scene(String stream) => Scene(
  id: '1',
  title: 'Scene',
  date: DateTime(2026),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: null,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: ScenePaths(screenshot: null, preview: null, stream: stream),
  urls: const [],
  studioId: null,
  studioName: null,
  studioImagePath: null,
  performerIds: const [],
  performerNames: const [],
  performerImagePaths: const [],
  tagIds: const [],
  tagNames: const [],
);
