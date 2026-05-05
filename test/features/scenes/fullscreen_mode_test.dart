import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/global_fullscreen_overlay.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

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

  testWidgets('GlobalFullscreenOverlay visibility toggles with player state', (tester) async {
    final mockRepo = MockSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const GlobalFullscreenOverlay(),
    );

    // Trigger fullscreen
    final container = tester.element(find.byType(GlobalFullscreenOverlay));
    final containerRef = ProviderScope.containerOf(container);
    
    // We need an active scene and controller for the overlay to show content
    // but we can at least test the visibility toggle of the SlideTransition.
    
    containerRef.read(playerStateProvider.notifier).setFullScreen(true);
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('global_fullscreen_overlay_slide')), findsOneWidget);

    // Test exit
    containerRef.read(playerStateProvider.notifier).setFullScreen(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('global_fullscreen_overlay_slide')), findsNothing);
  });
}
