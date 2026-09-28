import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import '../../../helpers/test_helpers.dart';

class _RatingRepository extends MockGraphQLSceneRepository {
  final ratings = <int>[];
  bool failRating = false;

  @override
  Future<void> updateSceneRating(String id, int rating100) async {
    if (failRating) throw Exception('rating failed');
    ratings.add(rating100);
    data = [
      for (final scene in data)
        scene.id == id ? scene.copyWith(rating100: rating100) : scene,
    ];
  }
}

void main() {
  testWidgets(
    'scene rating persists confirmed choices and retains state on failure',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _RatingRepository()
        ..withData([
          Scene(
            id: 'rating-scene',
            title: 'Rating Scene',
            date: DateTime(2024),
            rating100: 40,
            oCounter: 0,
            organized: false,
            interactive: false,
            resumeTime: null,
            playCount: 0,
            playDuration: 0,
            files: [],
            paths: ScenePaths(screenshot: null, preview: null, stream: null),
            urls: [],
            studioId: null,
            studioName: null,
            studioImagePath: null,
            performerIds: [],
            performerNames: [],
            performerImagePaths: [],
            tagIds: [],
            tagNames: [],
          ),
        ]);
      await pumpTestWidget(
        tester,
        overrides: [sceneRepositoryProvider.overrideWithValue(repo)],
        child: const SceneDetailsPage(sceneId: 'rating-scene'),
      );
      await tester.pumpAndSettle();
      Future<void> choose(int stars) async {
        await tester.tap(find.byKey(const Key('scene_rating_controls')));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('$stars Stars'));
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
      }

      await choose(4);
      expect(repo.ratings, [80]);
      expect(repo.getSceneByIdRefreshValues, contains(true));
      expect(
        tester.widget<RatingButton>(find.byType(RatingButton)).rating100,
        80,
      );
      repo.failRating = true;
      await choose(3);
      expect(repo.ratings, [80]);
      expect(
        tester.widget<RatingButton>(find.byType(RatingButton)).rating100,
        80,
      );
      expect(find.textContaining('Failed to update rating'), findsOneWidget);
    },
  );

  testWidgets(
    'single star edits only after Apply and supports Clear and Cancel',
    (tester) async {
      final selected = <int>[];
      await pumpTestWidget(
        tester,
        child: Scaffold(
          body: RatingButton(rating100: 65, onRatingSelected: selected.add),
        ),
      );
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byType(RatingPicker), findsNothing);
      await tester.tap(find.byType(RatingButton));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 65);
      await tester.tap(find.byTooltip('4 Stars'));
      await tester.pump();
      expect(selected, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(selected, isEmpty);
      await tester.tap(find.byType(RatingButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('4 Stars'));
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(selected, [80]);
      await tester.tap(find.byType(RatingButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear Rating'));
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(selected, [80, 0]);
    },
  );

  testWidgets('unrated star and popup fit a narrow screen at large scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'app_global_scale_factor': 1.5});
    final prefs = await SharedPreferences.getInstance();
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: Theme(
        data: AppTheme.buildTheme(
          Brightness.light,
          const Color(0xFF0F766E),
          fontSizeFactor: 1.5,
        ),
        child: Scaffold(body: RatingButton(onRatingSelected: (_) {})),
      ),
    );
    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    await tester.tap(find.byType(RatingButton));
    await tester.pumpAndSettle();
    expect(find.byType(RatingPicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
