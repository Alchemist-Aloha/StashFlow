import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';

void main() {
  test('uses the scene direct stream without querying sceneStreams', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final choice = await container
        .read(streamResolverProvider.notifier)
        .resolvePreferredStream(_scene('https://stash.test/scene/1/stream'));

    expect(choice?.url, 'https://stash.test/scene/1/stream');
    expect(choice?.label, 'Direct');
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
