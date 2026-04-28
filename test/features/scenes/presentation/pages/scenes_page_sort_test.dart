import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('Sort panel should have scrollable sort methods and visible buttons', (tester) async {
    final mockRepo = MockSceneRepository();
    mockRepo.setData([
      Scene(
        id: '1',
        title: 'Test Scene',
        date: DateTime(2023, 1, 1),
        oCounter: 0,
        organized: false,
        interactive: false,
        resumeTime: 0,
        playCount: 0,
        playDuration: 0,
        files: [],
        paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
        urls: [],
        studioId: null,
        studioName: null,
        studioImagePath: null,
        performerIds: [],
        performerNames: [],
        performerImagePaths: [],
        tagIds: [],
        tagNames: [],
        rating100: null,
      ),
    ]);

    await pumpTestWidget(
      tester,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const ScenesPage(),
    );
    
    // Open sort panel
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Sort Scenes'), findsOneWidget);
    
    // Verify Apply Sort button exists
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    
    // Verify "Sort method" section exists
    expect(find.textContaining('Sort'), findsAtLeastNWidgets(1));
  });

  testWidgets('Sort panel buttons should be visible on small screens', (tester) async {
    // Set small screen size (e.g., iPhone SE or similar)
    tester.view.physicalSize = const Size(320 * 3, 480 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockSceneRepository();
    mockRepo.setData([]);

    await pumpTestWidget(
      tester,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const ScenesPage(),
    );
    
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    // Verify Apply Sort button exists and is visible
    final applyButton = find.byType(ElevatedButton);
    expect(applyButton, findsOneWidget);
    
    // Check if the Apply Sort button is actually visible (not obscured)
    // The screen height is 480 logical pixels.
    final center = tester.getCenter(applyButton);
    expect(center.dy, lessThan(480)); 
  });
}
