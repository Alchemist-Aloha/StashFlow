import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/providers/list_scroll_controller_provider.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/pages/gallery_details_page.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_filter_panel.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_details_bottom_sheet.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/images/presentation/pages/images_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  for (final width in [500.0, 1200.0]) {
    for (final imagesVisible in [false, true]) {
      testWidgets('Images navigation at width $width, visible $imagesVisible', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({
          'navigation_tabs_config': jsonEncode([
            const NavigationTab(type: NavigationTabType.performers).toJson(),
            NavigationTab(
              type: NavigationTabType.images,
              visible: imagesVisible,
            ).toJson(),
            const NavigationTab(type: NavigationTabType.galleries).toJson(),
            const NavigationTab(
              type: NavigationTabType.scenes,
              visible: false,
            ).toJson(),
            const NavigationTab(
              type: NavigationTabType.studios,
              visible: false,
            ).toJson(),
            const NavigationTab(
              type: NavigationTabType.tags,
              visible: false,
            ).toJson(),
            const NavigationTab(
              type: NavigationTabType.groups,
              visible: false,
            ).toJson(),
          ]),
        });
        final prefs = await SharedPreferences.getInstance();
        final images = MockGraphQLImageRepository()
          ..withData(
            List.generate(
              40,
              (index) => entity.Image(
                id: 'image-$index',
                title: 'Image $index',
                files: const [
                  entity.ImageFile(width: 100, height: 100, path: ''),
                ],
                paths: const entity.ImagePaths(image: '', thumbnail: ''),
              ),
            ),
          );
        await pumpTestWidget(
          tester,
          prefs: prefs,
          overrides: [
            sceneRepositoryProvider.overrideWithValue(
              MockGraphQLSceneRepository(),
            ),
            imageRepositoryProvider.overrideWithValue(images),
            galleryListProvider.overrideWith(_EmptyGalleries.new),
            galleryDetailsProvider('gallery-1').overrideWith(
              (ref) => const Gallery(
                id: 'gallery-1',
                title: 'Gallery One',
                imageCount: 40,
              ),
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
        final navigation = width < 600
            ? find.byType(NavigationBar)
            : find.byType(NavigationRail);
        final container = ProviderScope.containerOf(tester.element(navigation));
        final router = container.read(routerProvider);
        if (imagesVisible) {
          await tester.tap(
            find.descendant(of: navigation, matching: find.byIcon(Icons.image)),
          );
        } else {
          router.go('/galleries/images');
        }
        await tester.pumpAndSettle();
        expect(find.byType(ImagesPage), findsOneWidget);
        // Subsequent pagination requests have reached the end of the fixture.
        images.withEmpty();
        expect(
          router.routeInformationProvider.value.uri.path,
          '/galleries/images',
        );
        final backButton = find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(BackButton),
        );
        expect(backButton, imagesVisible ? findsNothing : findsOneWidget);
        final tabs = container.read(navigationTabsProvider.notifier);
        await tabs.toggleTab(NavigationTabType.images, !imagesVisible);
        await tester.pumpAndSettle();
        expect(backButton, imagesVisible ? findsOneWidget : findsNothing);
        await tabs.toggleTab(NavigationTabType.images, imagesVisible);
        await tester.pumpAndSettle();
        expect(backButton, imagesVisible ? findsNothing : findsOneWidget);
        int selectedIndex() => width < 600
            ? tester.widget<NavigationBar>(navigation).selectedIndex
            : tester.widget<NavigationRail>(navigation).selectedIndex!;
        // Images is second when enabled; otherwise Galleries is second.
        expect(selectedIndex(), 1);
        await tester.tap(find.byType(ImageCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(ImageFullscreenPage), findsOneWidget);
        expect(
          GoRouterState.of(tester.element(find.byType(ImageFullscreenPage)))
              .uri
              .path,
          '/galleries/images/image-0',
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(ImageFullscreenPage), findsNothing);
        expect(selectedIndex(), 1);
        if (imagesVisible) {
          final controller = container.read(
            listScrollControllerProvider(ListScrollTarget.image),
          );
          controller.jumpTo(100);
          await tester.pump();
          await tester.tap(
            find.descendant(of: navigation, matching: find.byIcon(Icons.image)),
          );
          await tester.pumpAndSettle();
          expect(controller.offset, 0);
          expect(await router.routerDelegate.popRoute(), isFalse);
          expect(
            router.routeInformationProvider.value.uri.path,
            '/galleries/images',
          );
        } else {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/galleries');
          router.go('/galleries/images');
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/galleries');
        }
        // A gallery browser owns its query and viewer even with Images hidden.
        images.withData(
          List.generate(
            40,
            (index) => entity.Image(
              id: 'gallery-image-$index',
              title: 'Gallery Image $index',
              files: const [
                entity.ImageFile(width: 100, height: 100, path: ''),
              ],
              paths: const entity.ImagePaths(image: '', thumbnail: ''),
            ),
          ),
        );
        router.go('/galleries/images');
        container
            .read(imageSearchQueryProvider.notifier)
            .update('library search');
        await container.read(imageListProvider.notifier).refresh();
        await tester.pumpAndSettle();
        container
            .read(imageFullscreenCurrentIdProvider.notifier)
            .setCurrent('library selection');
        final libraryScroll = container.read(
          listScrollControllerProvider(ListScrollTarget.image),
        );
        libraryScroll.jumpTo(100);
        await tester.pump();
        final callCount = images.findImageCalls.length;
        unawaited(router.push<void>('/galleries/gallery/gallery-1'));
        await tester.pumpAndSettle();
        expect(find.byType(GalleryDetailsPage), findsOneWidget);
        expect(backButton, findsOneWidget);
        final scoped = ProviderScope.containerOf(
          tester.element(find.byType(GalleryDetailsPage)),
        );
        expect(scoped, isNot(same(container)));
        expect(scoped.read(imageSearchQueryProvider), '');
        expect(scoped.read(imageFilterStateProvider).galleryId, 'gallery-1');
        expect(
          images.findImageCalls
              .skip(callCount)
              .every((call) => call.galleryId == 'gallery-1'),
          isTrue,
        );
        scoped.read(imageSearchQueryProvider.notifier).update('gallery search');
        scoped
            .read(imageSortProvider.notifier)
            .setSort(sort: 'rating', descending: true);
        await tester.pumpAndSettle();
        final galleryState = tester.state(find.byType(GalleryDetailsPage));
        await tester.longPress(find.byType(ImageCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(ImageDetailsBottomSheet), findsOneWidget);
        await _backGesture(tester);
        expect(find.byType(ImageDetailsBottomSheet), findsNothing);
        expect(find.byType(GalleryDetailsPage), findsOneWidget);
        expect(
          tester.state(find.byType(GalleryDetailsPage)),
          same(galleryState),
        );
        expect(router.state.uri.path, '/galleries/gallery/gallery-1');
        expect(scoped.read(imageSearchQueryProvider), 'gallery search');
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();
        expect(
          ProviderScope.containerOf(
            tester.element(find.byType(ImageFilterPanel)),
          ),
          same(scoped),
        );
        await _backGesture(tester);
        expect(find.byType(ImageFilterPanel), findsNothing);
        expect(
          tester.state(find.byType(GalleryDetailsPage)),
          same(galleryState),
        );
        expect(scoped.read(imageSearchQueryProvider), 'gallery search');
        await tester.tap(find.byType(ImageCard).first);
        await tester.pumpAndSettle();
        expect(
          ProviderScope.containerOf(
            tester.element(find.byType(ImageFullscreenPage)),
          ),
          same(scoped),
        );
        expect(
          GoRouterState.of(tester.element(find.byType(ImageFullscreenPage)))
              .uri
              .path,
          '/galleries/gallery/gallery-1/image/gallery-image-0',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(
          scoped.read(imageFullscreenCurrentIdProvider),
          'gallery-image-1',
        );
        await _backGesture(tester);
        expect(find.byType(GalleryDetailsPage), findsOneWidget);
        expect(scoped.read(imageSearchQueryProvider), 'gallery search');
        expect(scoped.read(imageSortProvider).sort, 'rating');
        expect(container.read(imageSearchQueryProvider), 'library search');
        expect(
          container.read(imageFullscreenCurrentIdProvider),
          'library selection',
        );
        expect(libraryScroll.offset, 100);
        // Changing servers replaces the session instead of reusing its query.
        await container
            .read(activeServerProfileIdProvider.notifier)
            .set('other-server');
        await tester.pumpAndSettle();
        final reset = ProviderScope.containerOf(
          tester.element(find.byType(GalleryDetailsPage)),
        );
        expect(reset, isNot(same(scoped)));
        expect(reset.read(imageSearchQueryProvider), '');
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(find.byType(GalleryDetailsPage), findsNothing);
        expect(container.read(imageSearchQueryProvider), 'library search');
        expect(libraryScroll.offset, 100);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final path in [
    '/galleries/gallery/gallery-1',
    '/gallery/gallery-1',
    'push:/galleries/gallery/gallery-1',
    '/entity-images/performer/entity-1',
    '/entity-images/studio/entity-1',
    '/entity-images/tag/entity-1',
  ]) {
    testWidgets('Scoped browser sheet Back works at $path', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [
          sceneRepositoryProvider.overrideWithValue(
            MockGraphQLSceneRepository(),
          ),
          imageRepositoryProvider.overrideWithValue(
            MockGraphQLImageRepository()..withData([
              const entity.Image(
                id: 'image-1',
                title: 'Image One',
                files: [entity.ImageFile(width: 100, height: 100, path: '')],
                paths: entity.ImagePaths(image: '', thumbnail: ''),
              ),
            ]),
          ),
          galleryListProvider.overrideWith(_EmptyGalleries.new),
          galleryDetailsProvider('gallery-1').overrideWith(
            (ref) => const Gallery(id: 'gallery-1', title: 'Gallery One'),
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
      final container = ProviderScope.containerOf(
        tester.element(
          find.byWidgetPredicate(
            (widget) => widget is NavigationBar || widget is NavigationRail,
          ),
        ),
      );
      final router = container.read(routerProvider);
      if (path.startsWith('/entity-images/') || path.startsWith('push:')) {
        router.go('/galleries');
        await tester.pumpAndSettle();
        unawaited(router.push<void>(path.replaceFirst('push:', '')));
      } else {
        // Direct gallery links must offer a way back even without push history.
        router.go(path);
      }
      await tester.pumpAndSettle();
      final browserState = tester.state(find.byType(ImagesPage));
      await tester.longPress(find.byType(ImageCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(ImageDetailsBottomSheet), findsOneWidget);
      await _backGesture(tester, cancel: true);
      expect(find.byType(ImageDetailsBottomSheet), findsOneWidget);
      expect(tester.state(find.byType(ImagesPage)), same(browserState));
      await _backGesture(tester);
      expect(find.byType(ImageDetailsBottomSheet), findsNothing);
      expect(find.byType(ImagesPage), findsOneWidget);
      expect(tester.state(find.byType(ImagesPage)), same(browserState));
      expect(router.state.uri.path, path.replaceFirst('push:', ''));
      await tester.longPress(find.byType(ImageCard).first);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ImageDetailsBottomSheet), findsNothing);
      expect(tester.state(find.byType(ImagesPage)), same(browserState));
      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(BackButton),
      );
      expect(backButton, findsOneWidget);
      // Once the sheet is gone, Back can leave the gallery as usual.
      if (path.contains('/galleries/gallery/')) {
        await _backGesture(tester);
      } else {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
      expect(router.routeInformationProvider.value.uri.path, '/galleries');
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _backGesture(WidgetTester tester, {bool cancel = false}) async {
  for (final call in [
    const MethodCall('startBackGesture', {
      'touchOffset': [5.0, 300.0],
      'progress': 0.0,
      'swipeEdge': 0,
    }),
    const MethodCall('updateBackGestureProgress', {
      'touchOffset': [100.0, 300.0],
      'progress': 0.35,
      'swipeEdge': 0,
    }),
    MethodCall(cancel ? 'cancelBackGesture' : 'commitBackGesture'),
  ]) {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/backgesture',
      const StandardMethodCodec().encodeMethodCall(call),
      (_) {},
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

class _EmptyGalleries extends GalleryList {
  @override
  Future<List<Gallery>> build() async => [];
}
