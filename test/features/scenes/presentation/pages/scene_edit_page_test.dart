import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_edit_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import '../../../../helpers/test_helpers.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';

class CallTrackingMockSceneRepository extends MockSceneRepository {
  bool saveCalled = false;
  ScrapedScene? lastScraped;

  @override
  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
    String? studioId,
  }) async {
    saveCalled = true;
    lastScraped = scraped;
  }
}

void main() {
  final testScene = Scene(
    id: 'scene-1',
    title: 'Original Title',
    details: 'Original Details',
    date: DateTime(2024, 1, 1),
    rating100: 0,
    oCounter: 0,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    files: [],
    paths: const ScenePaths(screenshot: null, preview: null, stream: null),
    urls: ['http://example.com'],
    studioId: null,
    studioName: null,
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  testWidgets('SceneEditPage updates fields and saves', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = CallTrackingMockSceneRepository();

    await pumpTestWidget(
      tester,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneEditPage(scene: testScene),
    );
    await tester.pumpAndSettle();

    // Verify initial values
    expect(find.text('Original Title'), findsOneWidget);
    expect(find.text('Original Details'), findsOneWidget);
    expect(find.text('http://example.com'), findsOneWidget);

    // Update Title
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'New Title',
    );

    // Update Details
    await tester.enterText(
      find.widgetWithText(TextField, 'Details'),
      'New Details',
    );

    // Tap Save (it's an IconButton in the AppBar now)
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump(); // Start saving
    await tester.pump(
      const Duration(seconds: 1),
    ); // Finish saving and show snackbar

    expect(mockRepo.saveCalled, isTrue);
    expect(mockRepo.lastScraped?.title, 'New Title');
    expect(mockRepo.lastScraped?.details, 'New Details');
  });

  testWidgets('SceneEditPage adds and removes URLs', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = CallTrackingMockSceneRepository();

    await pumpTestWidget(
      tester,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneEditPage(scene: testScene),
    );
    await tester.pumpAndSettle();

    // Add URL
    await tester.tap(find.byTooltip('Add URL'));
    await tester.pumpAndSettle();

    final urlFields = find.widgetWithText(TextField, 'URL');
    expect(urlFields, findsNWidgets(2));

    await tester.enterText(urlFields.at(1), 'http://newurl.com');
    await tester.pumpAndSettle();

    // Remove first URL (example.com)
    await tester.tap(find.byTooltip('Remove URL').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'URL'), findsNWidgets(1));
    expect(find.text('http://newurl.com'), findsOneWidget);
    expect(find.text('http://example.com'), findsNothing);

    // Tap Save
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(mockRepo.lastScraped?.urls, ['http://newurl.com']);
  });
}
