import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/providers/list_scroll_controller_provider.dart';
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
          ],
          child: Consumer(
            builder: (context, ref, _) => MaterialApp.router(
              routerConfig: ref.watch(routerProvider),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        int selectedIndex() => width < 600
            ? tester.widget<NavigationBar>(navigation).selectedIndex
            : tester.widget<NavigationRail>(navigation).selectedIndex!;
        // Images is second when enabled; otherwise Galleries is second.
        expect(selectedIndex(), 1);
        await tester.tap(find.byType(ImageCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(ImageFullscreenPage), findsOneWidget);
        expect(
          GoRouterState.of(
            tester.element(find.byType(ImageFullscreenPage)),
          ).uri.path,
          '/galleries/images/image-0',
        );
        router.pop();
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
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
