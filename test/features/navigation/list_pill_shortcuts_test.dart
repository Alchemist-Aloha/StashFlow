import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/pages/galleries_page.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  for (final (page, tab, otherTab, tooltip) in [
    (
      const ScenesPage(),
      NavigationTabType.markers,
      NavigationTabType.images,
      'Markers',
    ),
    (
      const GalleriesPage(),
      NavigationTabType.images,
      NavigationTabType.markers,
      'All Images',
    ),
  ]) {
    for (final initiallyVisible in [false, true]) {
      testWidgets('$tooltip pill shortcut with tab visible $initiallyVisible', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          if (initiallyVisible)
            'navigation_tabs_config': jsonEncode([
              const NavigationTab(type: NavigationTabType.scenes).toJson(),
              NavigationTab(type: tab).toJson(),
            ]),
        });
        final prefs = await SharedPreferences.getInstance();
        await pumpTestWidget(
          tester,
          prefs: prefs,
          overrides: [
            sceneRepositoryProvider.overrideWithValue(
              MockGraphQLSceneRepository(),
            ),
            galleryListProvider.overrideWith(_EmptyGalleries.new),
          ],
          child: page,
        );
        await tester.pumpAndSettle();
        final shortcut = find.byTooltip(tooltip);
        expect(shortcut, initiallyVisible ? findsNothing : findsOneWidget);
        if (tab == NavigationTabType.markers && !initiallyVisible) {
          expect(
            find.descendant(
              of: shortcut,
              matching: find.byIcon(Icons.place_rounded),
            ),
            findsOneWidget,
          );
        }
        final tabs = ProviderScope.containerOf(
          tester.element(find.byWidget(page)),
        ).read(navigationTabsProvider.notifier);

        // The other optional tab must not affect this page's shortcut.
        await tabs.toggleTab(otherTab, true);
        await tester.pumpAndSettle();
        expect(shortcut, initiallyVisible ? findsNothing : findsOneWidget);

        await tabs.toggleTab(tab, !initiallyVisible);
        await tester.pumpAndSettle();
        expect(shortcut, initiallyVisible ? findsOneWidget : findsNothing);

        await tabs.toggleTab(tab, initiallyVisible);
        await tester.pumpAndSettle();
        expect(shortcut, initiallyVisible ? findsNothing : findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _EmptyGalleries extends GalleryList {
  @override
  Future<List<Gallery>> build() async => [];
}
