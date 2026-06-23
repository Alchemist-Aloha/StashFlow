# Entity Gallery All-Images Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bottom-pill image action to performer, studio, and tag gallery lists that opens the existing Images page scoped to the current entity.

**Architecture:** Keep entity-to-image filtering at the existing entity-gallery filter-scope boundary. `EntityGalleryGrid` calls that helper after clearing global image state, then uses the current Images route; no new page, route, or provider family is introduced. The shared widget gives all three entity pages the same action and visuals.

**Tech Stack:** Flutter, Riverpod, GoRouter, Freezed image filters, flutter_test.

---

## File structure

- Modify: `lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart` — map an entity gallery kind and ID to a fresh `ImageFilter`.
- Modify: `lib/features/galleries/presentation/widgets/entity_gallery_grid.dart` — add the existing gallery-list image action to the shared bottom pill and navigate with the mapped filter.
- Create: `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart` — exercise the pill action against the performer route and assert image state and navigation.

### Task 1: Shared gallery-pill action

**Files:**
- Modify: `lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart:1-31`
- Modify: `lib/features/galleries/presentation/widgets/entity_gallery_grid.dart:34-382`
- Test: `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart` with a parameterized widget test. Use `UncontrolledProviderScope` so assertions read the same `ProviderContainer` that the grid updates.

```dart
testWidgets('all-images action resets image state and scopes every entity kind', (
  tester,
) async {
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
    container.read(imageFilterStateProvider.notifier).setGalleryId('old-gallery');
    container.read(imageFilterStateProvider.notifier).updateFilter(
      const ImageFilter(tags: HierarchicalMultiCriterion(value: ['old-tag'])),
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
        expect(state.filter.performers?.value, [testCase.id]);
        expect(state.filter.studios, isNull);
        break;
      case EntityGalleryFilterKind.studio:
        expect(state.filter.studios?.value, [testCase.id]);
        expect(state.filter.performers, isNull);
        break;
      case EntityGalleryFilterKind.tag:
        expect(state.filter.tags?.value, [testCase.id]);
        expect(state.filter.performers, isNull);
        break;
    }
    expect(state.filter.tags?.value, testCase.kind == EntityGalleryFilterKind.tag
        ? [testCase.id]
        : isNull);
  }
});
```

Import `flutter_riverpod`, `flutter_test`, `go_router`, `shared_preferences`, `AppTheme`, `criterion.dart`, `shared_preferences_provider.dart`, `ImageFilter`, `image_list_provider.dart`, `AppLocalizations`, `EntityGalleryGrid`, and `entity_gallery_filter_scope.dart`.

- [ ] **Step 2: Run the widget test to verify it fails**

Run: `rtk flutter test test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: FAIL because the shared grid has no `All Images` action.

- [ ] **Step 3: Add the action and navigation**

In `entity_gallery_filter_scope.dart`, add:

```dart
import '../../../images/domain/entities/image_filter.dart';
```

After `galleryFilterForEntityGalleries`, add:

```dart
ImageFilter imageFilterForEntityGalleries({
  required EntityGalleryFilterKind kind,
  required String entityId,
}) => switch (kind) {
  EntityGalleryFilterKind.performer =>
    ImageFilter(performers: MultiCriterion(value: [entityId])),
  EntityGalleryFilterKind.studio =>
    ImageFilter(studios: HierarchicalMultiCriterion(value: [entityId])),
  EntityGalleryFilterKind.tag =>
    ImageFilter(tags: HierarchicalMultiCriterion(value: [entityId])),
};
```

In `_EntityGalleryGridState`, add:

```dart
void _openAllEntityImages() {
  ref.read(imageFilterStateProvider.notifier).clear();
  ref.read(imageFilterStateProvider.notifier).updateFilter(
    imageFilterForEntityGalleries(
      kind: widget.filterKind,
      entityId: widget.entityId,
    ),
  );
  context.push('/galleries/images');
}
```

Append this action to the existing `actions` list passed to `ListPageScaffold`:

```dart
IconButton(
  icon: const Icon(Icons.image),
  tooltip: context.l10n.galleries_all_images,
  onPressed: _openAllEntityImages,
),
```

Do not change the individual `GalleryCard.onTap`; it must continue to set only `galleryId` and open that single gallery's images.

- [ ] **Step 4: Run the widget test to verify it passes**

Run: `rtk flutter test test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: PASS.

- [ ] **Step 5: Run focused regression coverage**

Run: `rtk flutter test test/features/galleries/presentation/providers/entity_galleries_grid_filter_test.dart test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: PASS.

- [ ] **Step 6: Run static analysis on touched production files**

Run: `rtk flutter analyze lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart lib/features/galleries/presentation/widgets/entity_gallery_grid.dart`

Expected: `No issues found!`

- [ ] **Step 7: Commit the action and test**

```bash
rtk git add lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart lib/features/galleries/presentation/widgets/entity_gallery_grid.dart test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart
rtk git commit -m "feat: show entity images from gallery lists"
```
