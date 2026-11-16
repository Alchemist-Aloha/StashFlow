import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/providers/related_entities_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/frosted_app_bar.dart';
import 'package:stash_app_flutter/core/presentation/widgets/meta_row.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import 'package:stash_app_flutter/core/presentation/widgets/section_header.dart';
import 'package:stash_app_flutter/core/presentation/widgets/related_entities.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_control.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performer_details_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';

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
  testWidgets('below-fold related sections wait until scrolling near them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var relatedRequests = 0;
    final performer = _performer.copyWith(
      tagIds: List.generate(40, (index) => 'tag-$index'),
      tagNames: List.generate(40, (index) => 'Descriptive tag $index'),
    );
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider(performer.id).overrideWith((ref) => performer),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          performer.id,
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          performer.id,
        ).overrideWith((ref) => []),
        relatedEntitiesProvider((
          kind: RelatedEntityKind.performers,
          owner: RelatedEntityOwner.performer,
          id: performer.id,
        )).overrideWith((ref) {
          relatedRequests++;
          return [
            (
              id: 'related',
              title: 'Related actor',
              subtitle: null,
              imagePath: null,
              route: '/performers/performer/related',
            ),
          ];
        }),
      ],
      child: PerformerDetailsPage(performerId: performer.id),
    );
    await tester.pumpAndSettle();

    expect(relatedRequests, 0);
    expect(find.byType(RelatedEntitiesSection), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Related actor'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(relatedRequests, 1);
    expect(find.text('Related actor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
            performerDetailsProvider('performer-1')
                .overrideWith((ref) => _performer.copyWith(rating100: 55)),
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
        performerDetailsProvider('performer-1')
            .overrideWith((ref) => performer),
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

  testWidgets('performer details scroll under a frosted app bar', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider('performer-1')
            .overrideWith((ref) => _performer),
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

    expect(find.byType(FrostedAppBar), findsOneWidget);
    final scrollView = find.byType(ListView).first;
    // The scroll view runs behind the bar; its content starts below it.
    expect(tester.getTopLeft(scrollView).dy, 0);
    final content = find
        .descendant(of: scrollView, matching: find.byType(StashImage))
        .first;
    expect(
      tester.getTopLeft(content).dy,
      tester.getBottomLeft(find.byType(FrostedAppBar)).dy,
    );
  });

  testWidgets('performer details list attributes and related sections', (
    tester,
  ) async {
    final performer = _performer.copyWith(
      careerStart: '2017',
      careerEnd: '2025',
      weight: 58,
      tattoos: 'Crescent',
      circumcised: 'CUT',
      oCounter: 3,
      customFields: const {'audit_field': 'teal'},
    );
    RelatedEntityQuery query(RelatedEntityKind kind) =>
        (kind: kind, owner: RelatedEntityOwner.performer, id: 'performer-1');

    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider('performer-1')
            .overrideWith((ref) => performer),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
        relatedEntitiesProvider(query(RelatedEntityKind.groups))
            .overrideWith((ref) => []),
        relatedEntitiesProvider(query(RelatedEntityKind.performers))
            .overrideWith(
              (ref) => [
                (
                  id: 'p2',
                  title: 'Co Star',
                  subtitle: null,
                  imagePath: null,
                  route: '/performers/performer/p2',
                ),
              ],
            ),
      ],
      child: const PerformerDetailsPage(performerId: 'performer-1'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MetaRow), findsNWidgets(5));
    expect(find.text('audit_field: teal', findRichText: true), findsNothing);
    final header = find.byKey(const Key('performer_details_header'));
    final toggle = find.descendant(
      of: header,
      matching: find.text('Show more'),
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    for (final text in [
      'Career Start',
      '2017',
      '2025',
      '58',
      'Crescent',
      'Cut',
      'audit_field: teal',
    ]) {
      final finder = find.text(text, findRichText: true);
      await tester.scrollUntilVisible(
        finder,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(finder, findsOneWidget, reason: text);
    }
    final coStar = find.widgetWithText(RelatedEntityTile, 'Co Star');
    await tester.scrollUntilVisible(
      coStar,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Appears With'), findsOneWidget);
    expect(find.text('Groups'), findsNothing);
    final collapse = find.descendant(
      of: header,
      matching: find.text('Show less'),
    );
    await tester.ensureVisible(collapse);
    await tester.tap(collapse);
    await tester.pumpAndSettle();
    expect(find.byType(MetaRow), findsNWidgets(5));
    expect(find.text('audit_field: teal', findRichText: true), findsNothing);
  });

  for (final scale in [0.5, 2.0]) {
    testWidgets('details biography uses remaining lines at scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // A single paragraph exercises wrapping rather than only explicit newlines.
      final biography = List.filled(
        20,
        'A long performer biography.',
      ).join(' ');
      await pumpTestWidget(
        tester,
        overrides: [
          performerDetailsProvider('performer-1').overrideWith(
            (ref) =>
                _performer.copyWith(careerStart: '2017', details: biography),
          ),
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
      final text = find.text(biography);
      expect(tester.widget<Text>(text).maxLines, 4);
      final header = find.byKey(const Key('performer_details_header'));
      final expand = find.descendant(
        of: header,
        matching: find.text('Show more'),
      );
      await tester.ensureVisible(expand);
      expect(
        tester.getCenter(expand).dx,
        greaterThan(tester.getCenter(header).dx),
      );
      await tester.tap(expand);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(text).maxLines, isNull);
      final collapse = find.descendant(
        of: header,
        matching: find.text('Show less'),
      );
      await Scrollable.ensureVisible(tester.element(collapse), alignment: 0.25);
      await tester.pumpAndSettle();
      await tester.tap(collapse);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(text).maxLines, 4);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('short details need no disclosure action', (tester) async {
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider('performer-1').overrideWith(
          (ref) => _performer.copyWith(details: 'Short biography.'),
        ),
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
    final header = tester.widget<SectionHeader>(
      find.byKey(const Key('performer_details_header')),
    );
    expect(header.onViewAll, isNull);
    expect(find.text('Short biography.'), findsOneWidget);
  });

  testWidgets('Appears With shows five rows and expands independently', (
    tester,
  ) async {
    RelatedEntityQuery query(RelatedEntityKind kind) =>
        (kind: kind, owner: RelatedEntityOwner.performer, id: 'performer-1');
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider('performer-1').overrideWith(
          (ref) => _performer.copyWith(
            careerStart: '2017',
            careerEnd: '2025',
            weight: 58,
            measurements: '90-60-90',
            tattoos: 'Crescent',
            oCounter: 3,
            details: 'Biography after the attributes.',
          ),
        ),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
        for (final kind in [
          RelatedEntityKind.groups,
          RelatedEntityKind.performers,
        ])
          relatedEntitiesProvider(query(kind)).overrideWith(
            (ref) => [
              for (var i = 1; i <= 7; i++)
                (
                  id: '$kind-$i',
                  title: kind == RelatedEntityKind.performers
                      ? 'Co Star $i'
                      : 'Group $i',
                  subtitle: null,
                  imagePath: null,
                  route: kind == RelatedEntityKind.performers
                      ? '/performers/performer/$i'
                      : '/groups/group/$i',
                ),
            ],
          ),
      ],
      child: const PerformerDetailsPage(performerId: 'performer-1'),
    );
    await tester.pumpAndSettle();
    final peers = find.widgetWithText(
      RelatedEntitiesSection,
      'Appears With',
      skipOffstage: false,
    );
    final groups = find.widgetWithText(
      RelatedEntitiesSection,
      'Groups',
      skipOffstage: false,
    );
    expect(find.byType(MetaRow), findsNWidgets(5));
    expect(find.text('Biography after the attributes.'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Groups'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Appears With'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final rows = find.descendant(
      of: peers,
      matching: find.byType(RelatedEntityTile),
    );
    expect(rows, findsNWidgets(5));
    expect(
      find.descendant(of: groups, matching: find.byType(RelatedEntityTile)),
      findsNWidgets(7),
    );
    expect(find.byType(MetaRow, skipOffstage: false), findsNWidgets(5));
    final expand = find.descendant(of: peers, matching: find.text('Show more'));
    await tester.ensureVisible(expand);
    expect(
      tester.getCenter(expand).dx,
      greaterThan(tester.getCenter(peers).dx),
    );
    await tester.tap(expand);
    await tester.pumpAndSettle();
    expect(rows, findsNWidgets(7));
    expect(find.byType(MetaRow, skipOffstage: false), findsNWidgets(5));
    final collapse = find.descendant(
      of: peers,
      matching: find.text('Show less'),
    );
    await tester.tap(collapse);
    await tester.pumpAndSettle();
    expect(rows, findsNWidgets(5));

    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    final detailsExpand = find.descendant(
      of: find.byKey(const Key('performer_details_header')),
      matching: find.text('Show more'),
    );
    await tester.scrollUntilVisible(
      detailsExpand,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(detailsExpand),
      alignment: 0.5,
    );
    await tester.tap(detailsExpand);
    await tester.pumpAndSettle();
    expect(find.byType(MetaRow), findsNWidgets(6));
    expect(find.text('Biography after the attributes.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Appears With'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(rows, findsNWidgets(5));
  });

  testWidgets('performer links collapse to five with a show more toggle', (
    tester,
  ) async {
    final urls = [for (var i = 0; i < 7; i++) 'https://example.com/$i'];
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider('performer-1')
            .overrideWith((ref) => _performer.copyWith(urls: urls)),
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
    final links = find.textContaining(
      'https://example.com/',
      skipOffstage: false,
    );
    expect(links, findsNWidgets(5));
    final toggle = find.descendant(
      of: find.byKey(const Key('entity_links_header')),
      matching: find.text('Show more'),
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(links, findsNWidgets(7));
    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('media strip keeps the View all sort order', (tester) async {
    // Shuffled ids catch any client-side reordering of the preview.
    final scenes = [
      for (final id in ['3', '1', '4', '2'])
        Scene(
          id: id,
          title: 'Scene $id',
          date: DateTime(2024, 1, 1),
          rating100: null,
          oCounter: 0,
          organized: false,
          interactive: false,
          resumeTime: 0,
          playCount: 0,
          playDuration: 0,
          files: const [],
          paths: const ScenePaths(
            screenshot: null,
            preview: null,
            stream: null,
          ),
          urls: const [],
          studioId: null,
          studioName: null,
          studioImagePath: null,
          performerIds: const [],
          performerNames: const [],
          performerImagePaths: const [],
          tagIds: const [],
          tagNames: const [],
        ),
    ];
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider('performer-1')
            .overrideWith((ref) => _performer),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => scenes),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          'performer-1',
        ).overrideWith((ref) => []),
      ],
      child: const PerformerDetailsPage(performerId: 'performer-1'),
    );
    await tester.pumpAndSettle();
    final strip = tester.widget<SceneStrip>(
      find.byType(SceneStrip, skipOffstage: false),
    );
    expect(strip.scenes.map((scene) => scene.id), ['3', '1', '4', '2']);
  });
}
