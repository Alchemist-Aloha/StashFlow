import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performer_details_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';

import '../../../../helpers/test_helpers.dart';

const _performer = Performer(
  id: 'performer-1',
  name: 'Performer One',
  urls: [],
  birthdate: null,
  aliasList: [],
  favorite: false,
  imagePath: null,
  sceneCount: 0,
  imageCount: 0,
  galleryCount: 0,
  groupCount: 0,
  tagIds: [],
  tagNames: [],
  country: 'France',
);

class _RatingPerformerRepository extends MockGraphQLPerformerRepository {
  _RatingPerformerRepository() {
    data = [_performer];
  }
  bool failRating = false;
  final ratings = <int>[];
  final refreshes = <bool>[];

  @override
  Future<Performer> getPerformerById(String id, {bool refresh = false}) async {
    refreshes.add(refresh);
    return super.getPerformerById(id, refresh: refresh);
  }

  @override
  Future<void> updatePerformer({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    if (failRating) throw Exception('rating failed');
    final rating = input['rating100'] as int;
    ratings.add(rating);
    data = [data.first.copyWith(rating100: rating)];
  }
}

void main() {
  testWidgets(
    'performer rating confirms, clears, and retains value on failure',
    (tester) async {
      final repository = _RatingPerformerRepository();
      await pumpTestWidget(
        tester,
        overrides: [
          performerRepositoryProvider.overrideWithValue(repository),
          entityMediaPreviewProvider(
            EntityMediaFilterKind.performer,
            'performer-1',
          ).overrideWith((ref) => []),
          entityGalleryPreviewProvider(
            EntityGalleryFilterKind.performer,
            'performer-1',
          ).overrideWith((ref) => []),
        ],
        child: const PerformerDetailsPage(performerId: 'performer-1'),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PerformerDetailsPage)),
      );
      await container.read(performerListProvider.future);
      final button = find.byKey(const Key('performer_action_rating'));
      expect(tester.widget<RatingButton>(button).rating100, isNull);
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('4 Stars'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.ratings, isEmpty);
      Future<void> rate({bool clear = false}) async {
        await tester.tap(button);
        await tester.pumpAndSettle();
        await tester.tap(
          clear ? find.text('Clear Rating') : find.byTooltip('4 Stars'),
        );
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
      }

      await rate();
      expect(repository.ratings, [80]);
      expect(repository.refreshes, contains(true));
      expect(tester.widget<RatingButton>(button).rating100, 80);
      expect(
        (await container.read(performerListProvider.future)).first.rating100,
        80,
      );
      await rate(clear: true);
      expect(repository.ratings, [80, 0]);
      repository.failRating = true;
      await rate();
      expect(tester.widget<RatingButton>(button).rating100, 0);
      expect(find.textContaining('Failed to update rating'), findsOneWidget);
    },
  );

  for (final width in [320.0, 1100.0]) {
    for (final scale in [0.8, 1.5]) {
      testWidgets('performer controls fit $width at scale $scale below chips', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pumpTestWidget(
          tester,
          overrides: [
            performerDetailsProvider(
              'performer-1',
            ).overrideWith((ref) => _performer.copyWith(rating100: 55)),
            entityMediaPreviewProvider(
              EntityMediaFilterKind.performer,
              'performer-1',
            ).overrideWith((ref) => []),
            entityGalleryPreviewProvider(
              EntityGalleryFilterKind.performer,
              'performer-1',
            ).overrideWith((ref) => []),
          ],
          child: Theme(
            data: AppTheme.buildTheme(
              Brightness.dark,
              const Color(0xFF0F766E),
              fontSizeFactor: scale,
            ),
            child: const PerformerDetailsPage(performerId: 'performer-1'),
          ),
        );
        await tester.pumpAndSettle();
        final actions = find.byKey(const Key('performer_actions'));
        expect(
          tester.getTopLeft(actions).dy,
          greaterThan(tester.getBottomLeft(find.text('France')).dy),
        );
        final favorite = find.byKey(const Key('performer_action_favorite'));
        final rating = find.byKey(const Key('performer_action_rating'));
        final edit = find.byKey(const Key('performer_action_edit'));
        expect(tester.getCenter(favorite).dy, tester.getCenter(rating).dy);
        expect(tester.getCenter(edit).dy, tester.getCenter(rating).dy);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byIcon(Icons.edit_outlined),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('performer details has no app bar title', (tester) async {
    const performer = Performer(
      id: 'performer-1',
      name: 'Performer One',
      urls: [],
      birthdate: null,
      aliasList: [],
      favorite: false,
      imagePath: null,
      sceneCount: 0,
      imageCount: 0,
      galleryCount: 0,
      groupCount: 0,
      tagIds: [],
      tagNames: [],
    );

    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider(
          'performer-1',
        ).overrideWith((ref) => performer),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
      ],
      child: const PerformerDetailsPage(performerId: 'performer-1'),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<AppBar>(find.byType(AppBar)).title, isNull);
  });
}
