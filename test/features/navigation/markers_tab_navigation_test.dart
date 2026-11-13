import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/providers/list_scroll_controller_provider.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_marker.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_markers_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_marker_list_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  for (final width in [500.0, 1200.0]) {
    for (final visible in [false, true]) {
      testWidgets('Markers tab at width $width, visible $visible', (
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
              type: NavigationTabType.markers,
              visible: visible,
            ).toJson(),
            const NavigationTab(type: NavigationTabType.scenes).toJson(),
            for (final type in [
              NavigationTabType.studios,
              NavigationTabType.tags,
              NavigationTabType.galleries,
              NavigationTabType.groups,
              NavigationTabType.images,
            ])
              NavigationTab(type: type, visible: false).toJson(),
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
            sceneMarkerListProvider.overrideWith(_Markers.new),
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
        final markerTab = find.descendant(
          of: navigation,
          matching: find.byIcon(Icons.place_rounded),
        );
        if (visible) {
          await tester.tap(markerTab);
        } else {
          expect(markerTab, findsNothing);
          await tester.tap(find.byTooltip('Markers'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(SceneMarkersPage), findsOneWidget);
        expect(
          router.routeInformationProvider.value.uri.path,
          '/scenes/markers',
        );
        final backButton = find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(BackButton),
        );
        expect(backButton, visible ? findsNothing : findsOneWidget);
        final tabs = container.read(navigationTabsProvider.notifier);
        await tabs.toggleTab(NavigationTabType.markers, !visible);
        await tester.pumpAndSettle();
        expect(backButton, visible ? findsOneWidget : findsNothing);
        await tabs.toggleTab(NavigationTabType.markers, visible);
        await tester.pumpAndSettle();
        expect(backButton, visible ? findsNothing : findsOneWidget);
        final selected = width < 600
            ? tester.widget<NavigationBar>(navigation).selectedIndex
            : tester.widget<NavigationRail>(navigation).selectedIndex;
        expect(selected, 1);
        if (visible) {
          final controller = container.read(
            listScrollControllerProvider(ListScrollTarget.marker),
          );
          controller.jumpTo(100);
          await tester.pump();
          await tester.tap(
            find.descendant(
              of: navigation,
              matching: find.byIcon(Icons.video_library),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(markerTab);
          await tester.pumpAndSettle();
          expect(controller.offset, 100);
          await tester.tap(markerTab);
          await tester.pumpAndSettle();
          expect(controller.offset, 0);
          expect(await router.routerDelegate.popRoute(), isFalse);
          expect(
            router.routeInformationProvider.value.uri.path,
            '/scenes/markers',
          );
        } else {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/scenes');
          router.go('/scenes/markers');
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/scenes');
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _Markers extends SceneMarkerList {
  @override
  Future<List<SceneMarkerSummary>> build() async => List.generate(
    40,
    (index) => SceneMarkerSummary(
      id: '$index',
      title: 'Marker $index',
      seconds: index.toDouble(),
      endSeconds: null,
      screenshot: null,
      preview: null,
      stream: null,
      primaryTagName: null,
      tagNames: const [],
      sceneId: 's1',
      sceneTitle: 'Scene',
      performerNames: const [],
    ),
  );

  @override
  Future<void> fetchNextPage() async {}
}
