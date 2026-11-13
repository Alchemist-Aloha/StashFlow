import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart'
    show
        EntityGalleryFilterKind,
        EntityImageFilterMethod,
        entityImageFilterMethodSettingProvider;
import 'package:stash_app_flutter/features/galleries/presentation/widgets/entity_gallery_grid.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_browser_context.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_browser_scope.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  Future<void> expectEntityImageFilter({
    required WidgetTester tester,
    required ProviderContainer container,
    required EntityImageFilterMethod method,
  }) async {
    await container
        .read(entityImageFilterMethodSettingProvider.notifier)
        .set(method);

    for (final testCase in [
      (kind: EntityGalleryFilterKind.performer, id: 'performer-1'),
      (kind: EntityGalleryFilterKind.studio, id: 'studio-1'),
      (kind: EntityGalleryFilterKind.tag, id: 'tag-1'),
    ]) {
      container.read(imageFilterStateProvider.notifier).clear();
      container
          .read(imageFilterStateProvider.notifier)
          .setGalleryId('old-gallery');
      container
          .read(imageFilterStateProvider.notifier)
          .updateFilter(
            const ImageFilter(
              tags: HierarchicalMultiCriterion(value: ['old-tag']),
            ),
          );
      late ProviderContainer scoped;
      final router = GoRouter(
        initialLocation: '/galleries',
        routes: [
          GoRoute(
            path: '/galleries',
            builder: (_, _) => EntityGalleryGrid(
              title: 'Galleries',
              entityId: testCase.id,
              filterKind: testCase.kind,
              galleriesAsync: const AsyncData<List<Gallery>>([]),
              isGridView: true,
              gridColumns: 2,
              onRefresh: () async {},
              onFetchNextPage: () {},
            ),
          ),
          GoRoute(
            path: '/entity-images/${testCase.kind.name}/${testCase.id}',
            builder: (_, _) => ImageBrowserScope(
              browser: ImageBrowserContext.entity(
                testCase.kind,
                testCase.id,
                path: '/entity-images/${testCase.kind.name}/${testCase.id}',
              ),
              child: Consumer(
                builder: (context, ref, _) {
                  scoped = ProviderScope.containerOf(context);
                  return const Text('images destination');
                },
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('All Images'));
      await tester.pumpAndSettle();

      expect(find.text('images destination'), findsOneWidget);
      expect(container.read(imageFilterStateProvider).galleryId, 'old-gallery');
      expect(container.read(imageFilterStateProvider).filter.tags?.value, [
        'old-tag',
      ]);
      final state = (
        galleryId: scoped.read(imageFilterStateProvider).galleryId,
        filter: scoped.read(imageEffectiveFilterProvider),
      );
      expect(state.galleryId, isNull);

      if (method == EntityImageFilterMethod.directEntity) {
        expect(state.filter.galleriesFilter, isNull);
        switch (testCase.kind) {
          case EntityGalleryFilterKind.performer:
            expect(state.filter.performers?.value, [testCase.id]);
            break;
          case EntityGalleryFilterKind.studio:
            expect(state.filter.studios?.value, [testCase.id]);
            break;
          case EntityGalleryFilterKind.tag:
            expect(state.filter.tags?.value, [testCase.id]);
            break;
        }
      } else {
        expect(state.filter.performers, isNull);
        expect(state.filter.studios, isNull);
        expect(state.filter.tags, isNull);
        switch (testCase.kind) {
          case EntityGalleryFilterKind.performer:
            expect(state.filter.galleriesFilter?.performers?.value, [
              testCase.id,
            ]);
            break;
          case EntityGalleryFilterKind.studio:
            expect(state.filter.galleriesFilter?.studios?.value, [testCase.id]);
            break;
          case EntityGalleryFilterKind.tag:
            expect(state.filter.galleriesFilter?.tags?.value, [testCase.id]);
            break;
        }
      }
    }
  }

  testWidgets('all-images action defaults to direct entity filtering', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await expectEntityImageFilter(
      tester: tester,
      container: container,
      method: EntityImageFilterMethod.directEntity,
    );
  });

  testWidgets('all-images action uses related galleries when selected', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await expectEntityImageFilter(
      tester: tester,
      container: container,
      method: EntityImageFilterMethod.relatedGalleries,
    );
  });
}
