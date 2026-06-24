import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/entity_gallery_grid.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'all-images action resets image state and scopes every entity kind',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

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
        final router = GoRouter(
          initialLocation: '/galleries',
          routes: [
            GoRoute(
              path: '/galleries',
              builder: (_, __) => EntityGalleryGrid(
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
              path: '/galleries/images',
              builder: (_, __) => const Text('images destination'),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        final state = container.read(imageFilterStateProvider);
        expect(state.galleryId, isNull);

        switch (testCase.kind) {
          case EntityGalleryFilterKind.performer:
            expect(state.filter.performers, isNull);
            expect(state.filter.galleriesFilter?.performers?.value, [
              testCase.id,
            ]);
            expect(state.filter.galleriesFilter?.studios, isNull);
            expect(state.filter.galleriesFilter?.tags, isNull);
            break;
          case EntityGalleryFilterKind.studio:
            expect(state.filter.studios, isNull);
            expect(state.filter.galleriesFilter?.studios?.value, [testCase.id]);
            expect(state.filter.galleriesFilter?.performers, isNull);
            expect(state.filter.galleriesFilter?.tags, isNull);
            break;
          case EntityGalleryFilterKind.tag:
            expect(state.filter.tags, isNull);
            expect(state.filter.galleriesFilter?.tags?.value, [testCase.id]);
            expect(state.filter.galleriesFilter?.performers, isNull);
            expect(state.filter.galleriesFilter?.studios, isNull);
            break;
        }
      }
    },
  );
}
