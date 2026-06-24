# Entity Gallery Images via Gallery Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make entity-gallery image navigation filter images through the matching galleries rather than image metadata.

**Architecture:** Add an optional nested `GalleryFilter` to `ImageFilter` and serialize the three relationship fields needed by entity navigation as Stash's native `ImageFilterType.galleries_filter` input. The existing shared `EntityGalleryGrid` action then creates only the nested relation filter. This deliberately avoids touching the user's currently uncommitted gallery-repository cache-policy changes.

**Tech Stack:** Flutter, Riverpod, Freezed/json_serializable, graphql_codegen, GraphQL, flutter_test, Mockito.

---

## File structure

- Modify: `lib/features/images/domain/entities/image_filter.dart` — retain an optional nested `GalleryFilter` for relation filtering.
- Modify: generated `lib/features/images/domain/entities/image_filter.freezed.dart` and `image_filter.g.dart` — generated serialization/equality for the added field.
- Modify: `lib/features/images/data/repositories/graphql_image_repository.dart` — write `ImageFilter.galleriesFilter` to `galleries_filter`.
- Modify: `lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart` — create nested gallery criteria for the All Images action.
- Modify: `test/features/images/data/repositories/graphql_image_repository_test.dart` — assert the nested GraphQL payload.
- Modify: `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart` — assert the action resets direct image metadata criteria and sets nested gallery criteria.

### Task 1: Nested image gallery-filter state and query serialization

**Files:**
- Modify: `lib/features/images/domain/entities/image_filter.dart:7-38`
- Modify: generated `lib/features/images/domain/entities/image_filter.freezed.dart`
- Modify: generated `lib/features/images/domain/entities/image_filter.g.dart`
- Modify: `lib/features/images/data/repositories/graphql_image_repository.dart:24-74`
- Test: `test/features/images/data/repositories/graphql_image_repository_test.dart`

- [ ] **Step 1: Write the failing repository test**

Add a test that calls `GraphQLImageRepository.findImages` with:

```dart
const ImageFilter(
  galleriesFilter: GalleryFilter(
    performers: MultiCriterion(value: ['performer-1']),
  ),
)
```

Capture the `Options$Query$FindImages` request and assert:

```dart
final imageFilter = request.variables['image_filter'] as Map<String, dynamic>;
expect(imageFilter['galleries_filter'], {
  'performers': {
    'value': ['performer-1'],
    'modifier': 'INCLUDES',
  },
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `rtk flutter test test/features/images/data/repositories/graphql_image_repository_test.dart`

Expected: FAIL because `ImageFilter` has no `galleriesFilter` field.

- [ ] **Step 3: Add and generate the nested filter field**

Import `GalleryFilter` into `image_filter.dart` and add this field immediately after `galleries`:

```dart
GalleryFilter? galleriesFilter,
```

Run:

```bash
rtk dart run build_runner build --delete-conflicting-outputs
```

In `graphql_image_repository.dart`, import `GalleryFilter` and pass the nested relationship input:

```dart
galleries_filter: imageFilter?.galleriesFilter == null
    ? null
    : Input$GalleryFilterType(
        performers: mapMultiCriterion(
          imageFilter!.galleriesFilter!.performers,
        ),
        studios: mapHierarchicalMultiCriterion(
          imageFilter.galleriesFilter!.studios,
        ),
        tags: mapHierarchicalMultiCriterion(
          imageFilter.galleriesFilter!.tags,
        ),
      ),
```

- [ ] **Step 4: Run the repository test to verify it passes**

Run: `rtk flutter test test/features/images/data/repositories/graphql_image_repository_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit nested filtering support**

```bash
rtk git add lib/features/images/domain/entities/image_filter.dart lib/features/images/domain/entities/image_filter.freezed.dart lib/features/images/domain/entities/image_filter.g.dart lib/features/images/data/repositories/graphql_image_repository.dart test/features/images/data/repositories/graphql_image_repository_test.dart
rtk git commit -m "feat: filter images through matching galleries"
```

### Task 2: Route entity gallery actions through related galleries

**Files:**
- Modify: `lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart:30-45`
- Test: `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

- [ ] **Step 1: Update the failing widget expectations**

Replace the existing direct image-metadata assertions in `entity_gallery_grid_test.dart` with nested gallery assertions. For the performer case:

```dart
expect(state.filter.performers, isNull);
expect(state.filter.galleriesFilter?.performers?.value, ['performer-1']);
```

For studio and tag, assert `galleriesFilter?.studios?.value` and `galleriesFilter?.tags?.value` respectively, and assert the other nested relation fields are null.

- [ ] **Step 2: Run the test to verify it fails**

Run: `rtk flutter test test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: FAIL because `imageFilterForEntityGalleries` still puts criteria on the image itself.

- [ ] **Step 3: Change the shared helper**

Import `GalleryFilter` and change the helper to return:

```dart
ImageFilter imageFilterForEntityGalleries({
  required EntityGalleryFilterKind kind,
  required String entityId,
}) => ImageFilter(
  galleriesFilter: switch (kind) {
    EntityGalleryFilterKind.performer =>
      GalleryFilter(performers: MultiCriterion(value: [entityId])),
    EntityGalleryFilterKind.studio =>
      GalleryFilter(studios: HierarchicalMultiCriterion(value: [entityId])),
    EntityGalleryFilterKind.tag =>
      GalleryFilter(tags: HierarchicalMultiCriterion(value: [entityId])),
  },
);
```

- [ ] **Step 4: Run the widget test to verify it passes**

Run: `rtk flutter test test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: PASS.

- [ ] **Step 5: Run focused regression coverage and analysis**

Run:

```bash
rtk flutter test test/features/galleries/data/repositories/graphql_gallery_repository_test.dart test/features/images/data/repositories/graphql_image_repository_test.dart test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart
rtk flutter analyze lib/features/images/domain/entities/image_filter.dart lib/features/images/data/repositories/graphql_image_repository.dart lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart
```

Expected: all focused tests pass and analysis reports `No issues found!`.

- [ ] **Step 6: Commit the entity action update**

```bash
rtk git add lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart
rtk git commit -m "fix: scope entity images through galleries"
```
