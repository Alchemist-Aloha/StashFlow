import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/presentation/pages/studio_details_page.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_details_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('studio rating is shared, cancellable, and saved on Apply', (
    tester,
  ) async {
    final repository = _RatingStudioRepository();
    const studio = Studio(
      id: 'studio-1',
      name: 'Studio One',
      sceneCount: 0,
      imageCount: 0,
      galleryCount: 0,
      performerCount: 0,
      favorite: false,
      rating100: 40,
    );
    repository.setData([studio]);

    await pumpTestWidget(
      tester,
      overrides: [
        studioRepositoryProvider.overrideWithValue(repository),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.studio,
          'studio-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.studio,
          'studio-1',
        ).overrideWith((ref) => []),
      ],
      child: const StudioDetailsPage(studioId: 'studio-1'),
    );
    await tester.pumpAndSettle();

    final ratingButton = find.byKey(const Key('studio_action_rating'));
    expect(ratingButton, findsOneWidget);
    expect(tester.widget<RatingButton>(ratingButton).rating100, 40);
    expect(find.byTooltip('Add favorite'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isNull);

    await tester.tap(ratingButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('5 Stars'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.updatedRatings, isEmpty);

    await tester.tap(ratingButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('5 Stars'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(repository.updatedRatings, [100]);
    expect(repository.refreshValues, contains(true));
    expect(tester.widget<RatingButton>(ratingButton).rating100, 100);

    await tester.tap(ratingButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear Rating'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(repository.updatedRatings, [100, 0]);
    expect(tester.widget<RatingButton>(ratingButton).rating100, 0);

    repository.failRating = true;
    await tester.tap(ratingButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('3 Stars'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(tester.widget<RatingButton>(ratingButton).rating100, 0);
    expect(find.textContaining('Failed to update rating'), findsOneWidget);
  });

  testWidgets('studio action row fits phones and tablets at scaled text', (
    tester,
  ) async {
    const studio = Studio(
      id: 'studio-1',
      name: 'Studio One',
      sceneCount: 0,
      imageCount: 0,
      galleryCount: 0,
      performerCount: 0,
      favorite: false,
      rating100: 60,
    );

    for (final (width, scale) in [
      (320.0, 0.8),
      (320.0, 1.5),
      (1100.0, 0.8),
      (1100.0, 1.5),
    ]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      await pumpTestWidget(
        tester,
        overrides: [
          studioDetailsProvider('studio-1').overrideWith((ref) => studio),
          entityMediaPreviewProvider(
            EntityMediaFilterKind.studio,
            'studio-1',
          ).overrideWith((ref) => []),
          entityGalleryPreviewProvider(
            EntityGalleryFilterKind.studio,
            'studio-1',
          ).overrideWith((ref) => []),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const StudioDetailsPage(studioId: 'studio-1'),
        ),
      );
      await tester.pumpAndSettle();

      final nameRect = tester.getRect(find.text('Studio One'));
      final actionsRect = tester.getRect(
        find.byKey(const Key('studio_actions')),
      );
      expect(actionsRect.top, greaterThanOrEqualTo(nameRect.bottom));
      expect(actionsRect.left, greaterThanOrEqualTo(0));
      expect(actionsRect.right, lessThanOrEqualTo(width));
      expect(tester.takeException(), isNull);
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('studio details keeps the original layout with hierarchy', (
    tester,
  ) async {
    const studio = Studio(
      id: 'studio-1',
      name: 'Studio One',
      sceneCount: 2,
      imageCount: 3,
      galleryCount: 1,
      performerCount: 4,
      favorite: false,
      parentStudio: StudioRelationship(id: 'parent-1', name: 'Parent Studio'),
      childStudios: [StudioRelationship(id: 'child-1', name: 'Child Studio')],
    );

    await pumpTestWidget(
      tester,
      overrides: [
        studioDetailsProvider('studio-1').overrideWith((ref) => studio),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.studio,
          'studio-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.studio,
          'studio-1',
        ).overrideWith((ref) => []),
      ],
      child: const StudioDetailsPage(studioId: 'studio-1'),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<AppBar>(find.byType(AppBar)).title, isNull);
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Hierarchy'), findsOneWidget);
    expect(find.text('Parent Studio'), findsOneWidget);
    expect(find.text('Child Studio'), findsOneWidget);
  });
}

class _RatingStudioRepository extends MockGraphQLStudioRepository {
  final updatedRatings = <int>[];
  final refreshValues = <bool>[];
  bool failRating = false;

  @override
  Future<Studio> getStudioById(String id, {bool refresh = false}) async {
    refreshValues.add(refresh);
    return data.firstWhere((studio) => studio.id == id);
  }

  @override
  Future<void> updateStudio({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    if (failRating) throw Exception('Failed to update rating');
    final rating = input['rating100']! as int;
    updatedRatings.add(rating);
    data = [
      for (final studio in data)
        if (studio.id == id) studio.copyWith(rating100: rating) else studio,
    ];
  }
}
