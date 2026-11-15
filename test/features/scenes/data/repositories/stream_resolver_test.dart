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
