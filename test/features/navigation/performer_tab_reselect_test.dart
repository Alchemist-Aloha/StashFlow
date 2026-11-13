import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/pages/gallery_details_page.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performer_details_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performers_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

import '../../helpers/test_helpers.dart';

const _performer = Performer(
  id: 'p1',
  name: 'Performer One',
  urls: [],
  birthdate: null,
  aliasList: [],
  favorite: false,
  imagePath: null,
  sceneCount: 0,
  imageCount: 0,
  galleryCount: 1,
  groupCount: 0,
  tagIds: [],
  tagNames: [],
);

final _scene = Scene(
  id: 's1',
  title: 'Scene One',
  date: DateTime(2024, 1, 1),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: 0,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(screenshot: null, preview: null, stream: null),
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

class _EmptyGalleries extends GalleryList {
  @override
  Future<List<Gallery>> build() async => const [];
}

class _ActivePlayerState extends PlayerState {
  @override
  GlobalPlayerState build() => GlobalPlayerState(activeScene: _scene);
}

void main() {
  Future<GoRouter> pumpPerformerDetails(
    WidgetTester tester, {
    List<dynamic> overrides = const [],
    double width = 500,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'navigation_tabs_config': jsonEncode([
        const NavigationTab(type: NavigationTabType.performers).toJson(),
        const NavigationTab(type: NavigationTabType.galleries).toJson(),
        for (final type in [
          NavigationTabType.scenes,
          NavigationTabType.studios,
          NavigationTabType.tags,
          NavigationTabType.groups,
        ])
          NavigationTab(type: type, visible: false).toJson(),
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    final images = MockGraphQLImageRepository()
      ..withData([
        for (var i = 0; i < 3; i++)
          entity.Image(
            id: 'image-$i',
            title: 'Image $i',
            files: const [entity.ImageFile(width: 100, height: 100, path: '')],
            paths: const entity.ImagePaths(image: '', thumbnail: ''),
          ),
      ]);
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(
          MockGraphQLSceneRepository()..withData([_scene]),
        ),
        ...overrides,
        performerRepositoryProvider.overrideWithValue(
          MockGraphQLPerformerRepository()..withData([_performer]),
        ),
        imageRepositoryProvider.overrideWithValue(images),
        galleryListProvider.overrideWith(_EmptyGalleries.new),
        performerDetailsProvider('p1').overrideWith((ref) => _performer),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.performer,
          'p1',
        ).overrideWith((ref) => []),
        entityGalleryPreviewProvider(
          EntityGalleryFilterKind.performer,
          'p1',
        ).overrideWith((ref) => []),
        galleryDetailsProvider('g1').overrideWith(
          (ref) => const Gallery(id: 'g1', title: 'Gallery One', imageCount: 3),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          routerConfig: ref.watch(routerProvider),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final router = ProviderScope.containerOf(
      tester.element(
        width < 600 ? find.byType(NavigationBar) : find.byType(NavigationRail),
      ),
    ).read(routerProvider);
    router.go('/performers');
    await tester.pumpAndSettle();
    await tester.tap(find.text(_performer.name));
    await tester.pumpAndSettle();
    return router;
  }

  for (final width in [500.0, 1200.0]) {
    for (final action in ['reselect', 'switch', 'viewer shortcut']) {
      testWidgets('performer return via $action at $width preserves state', (
        tester,
      ) async {
        final router = await pumpPerformerDetails(tester, width: width);
        final navigation = width < 600
            ? find.byType(NavigationBar)
            : find.byType(NavigationRail);
        final performersTab = find.descendant(
          of: navigation,
          matching: find.byIcon(Icons.people),
        );
        // Repeat the complete flow: stale shells must neither resurrect nor
        // leave the list unresponsive after returning from details.
        for (var cycle = 0; cycle < 2; cycle++) {
          final scrollable = find
              .descendant(
                of: find.byType(PerformerDetailsPage),
                matching: find.byType(Scrollable),
              )
              .first;
          final scrollState = tester.state<ScrollableState>(scrollable);
          final offset = scrollState.position.maxScrollExtent.clamp(0.0, 40.0);
          scrollState.position.jumpTo(offset);
          await tester.pumpAndSettle();
          final selectTab = width < 600
              ? tester.widget<NavigationBar>(navigation).onDestinationSelected!
              : tester
                    .widget<NavigationRail>(navigation)
                    .onDestinationSelected!;
          var galleryClosed = false;
          unawaited(
            router
                .push('/galleries/gallery/g1')
                .then((_) => galleryClosed = true),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ImageCard).first);
          await tester.pumpAndSettle();
          expect(find.byType(ImageFullscreenPage), findsOneWidget);
          if (action == 'viewer shortcut') {
            // Keyboard tab shortcuts work while fullscreen hides the tab bar.
            // A rapid repeat must not race the nested Navigator pops.
            selectTab(0);
            selectTab(0);
          } else {
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(find.byType(GalleryDetailsPage), findsOneWidget);
            if (action == 'switch') {
              await tester.tap(
                find.descendant(
                  of: navigation,
                  matching: find.byIcon(Icons.perm_media),
                ),
              );
              await tester.pumpAndSettle();
            }
            await tester.tap(performersTab);
          }
          await tester.pumpAndSettle();
          expect(router.state.uri.path, '/performers/performer/p1');
          expect(
            find.byType(GalleryDetailsPage, skipOffstage: false),
            findsNothing,
          );
          expect(
            find.byType(ImageFullscreenPage, skipOffstage: false),
            findsNothing,
          );
          expect(find.byType(PerformerDetailsPage), findsOneWidget);
          expect(tester.state<ScrollableState>(scrollable), same(scrollState));
          expect(scrollState.position.pixels, offset);
          expect(
            galleryClosed,
            isTrue,
            reason: 'Removed pushes must complete normally',
          );

          if (action == 'reselect') {
            // A second re-select keeps the existing reset-to-list behavior.
            await tester.tap(performersTab);
          } else {
            await tester.binding.handlePopRoute();
          }
          await tester.pumpAndSettle();
          expect(
            find.byType(PerformerDetailsPage, skipOffstage: false),
            findsNothing,
          );
          expect(find.byType(PerformersPage).hitTestable(), findsOneWidget);
          await tester.tap(find.text(_performer.name));
          await tester.pumpAndSettle();
          expect(find.byType(PerformerDetailsPage), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets(
    'fullscreen exit keeps a scene pushed from performer details in place',
    (tester) async {
      final router = await pumpPerformerDetails(
        tester,
        overrides: [playerStateProvider.overrideWith(_ActivePlayerState.new)],
      );
      // Scene details keeps a loading animation running.
      Future<void> settle() async {
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      unawaited(router.push('/scenes/scene/s1'));
      await settle();
      final details = find.byType(SceneDetailsPage);
      expect(details, findsOneWidget);

      ProviderScope.containerOf(tester.element(details))
          .read(playerStateProvider.notifier)
          .syncBackgroundToActiveScene(tester.element(details));
      await settle();
      expect(router.state.uri.path, '/scenes/scene/s1');

      await tester.binding.handlePopRoute();
      await settle();
      expect(find.byType(PerformerDetailsPage), findsOneWidget);
    },
  );
}
