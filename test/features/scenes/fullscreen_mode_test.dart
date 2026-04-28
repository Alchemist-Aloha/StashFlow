import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_video_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'prefer_scene_streams': false});
    prefs = await SharedPreferences.getInstance();
  });

  final testScene = Scene(
    id: 's1',
    title: 'Test Scene',
    date: DateTime(2024, 1, 1),
    rating100: 40,
    oCounter: 5,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 10,
        playDuration: 0,
    files: [],
    paths: const ScenePaths(
      screenshot: null,
      preview: null,
      stream: 'http://test.com/stream.mp4',
    ),
    urls: [],
    studioId: 'st1',
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  testWidgets('FullscreenPlayerPage renders and pops', (tester) async {
    final mockRepo = MockSceneRepository()..withData([testScene]);

    // Pump a widget that has a navigator
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FullscreenPlayerPage(sceneId: testScene.id),
                ),
              );
            },
            child: const Text('Open'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FullscreenPlayerPage), findsOneWidget);

    // Test popping
    final context = tester.element(find.byType(FullscreenPlayerPage));
    Navigator.of(context).pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FullscreenPlayerPage), findsNothing);
  });
}
