# Entity Image Filter Method Setting Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users choose whether entity gallery pages open Images with direct entity metadata filtering or related-gallery filtering, defaulting to direct entity filtering.

**Architecture:** Store an `EntityImageFilterMethod` enum in the existing entity-gallery filter-scope provider file. The shared All Images action reads that provider and asks the existing helper to construct either direct `ImageFilter` criteria or a nested gallery criterion. The Interface settings page owns the control and writes the preference immediately.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, Material 3 segmented controls, flutter_test, gen-l10n.

---

## File structure

- Modify: `lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart` — define, persist, and apply the method enum.
- Modify: `lib/features/galleries/presentation/widgets/entity_gallery_grid.dart` — read the method before opening Images.
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart` — show and persist the Interface setting.
- Modify: `lib/l10n/app_en.arb` — add English title, subtitle, and two option labels.
- Modify: generated `lib/l10n/app_localizations*.dart` — generated localization accessors.
- Create: `test/features/galleries/presentation/providers/entity_image_filter_method_test.dart` — cover default and persistence.
- Modify: `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart` — cover direct default and related-gallery selection for every entity kind.
- Modify: `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart` — cover the Interface control and persisted value.

### Task 1: Persist the method and construct both filter forms

**Files:**
- Modify: `lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart:11-52`
- Create: `test/features/galleries/presentation/providers/entity_image_filter_method_test.dart`

- [ ] **Step 1: Write the failing preference tests**

Create `test/features/galleries/presentation/providers/entity_image_filter_method_test.dart` with tests that use mock SharedPreferences and a ProviderContainer:

```dart
test('defaults entity image filtering to direct entity metadata', () async {
  final container = await createContainer({});
  expect(
    container.read(entityImageFilterMethodSettingProvider),
    EntityImageFilterMethod.directEntity,
  );
});

test('persists the related galleries method', () async {
  final container = await createContainer({});
  await container
      .read(entityImageFilterMethodSettingProvider.notifier)
      .set(EntityImageFilterMethod.relatedGalleries);

  expect(
    prefs.getString(entityImageFilterMethodPreferenceKey),
    EntityImageFilterMethod.relatedGalleries.name,
  );
});
```

Add helper `createContainer(Map<String, Object> values)` that calls `SharedPreferences.setMockInitialValues`, overrides `sharedPreferencesProvider`, and disposes the created container with `addTearDown`.

- [ ] **Step 2: Run the preference test to verify it fails**

Run: `rtk flutter test test/features/galleries/presentation/providers/entity_image_filter_method_test.dart`

Expected: FAIL because the enum, provider, and preference key do not exist.

- [ ] **Step 3: Add the enum, provider, and method-aware helper**

In `entity_gallery_filter_scope.dart`, define:

```dart
enum EntityImageFilterMethod { directEntity, relatedGalleries }

const entityImageFilterMethodPreferenceKey =
    'entity_image_filter_method';

@Riverpod(keepAlive: true)
class EntityImageFilterMethodSetting
    extends _$EntityImageFilterMethodSetting {
  @override
  EntityImageFilterMethod build() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(entityImageFilterMethodPreferenceKey);
    return EntityImageFilterMethod.values.firstWhere(
      (method) => method.name == stored,
      orElse: () => EntityImageFilterMethod.directEntity,
    );
  }

  Future<void> set(EntityImageFilterMethod method) async {
    state = method;
    await ref
        .read(sharedPreferencesProvider)
        .setString(entityImageFilterMethodPreferenceKey, method.name);
  }
}
```

Add `required EntityImageFilterMethod method` to
`imageFilterForEntityGalleries`. Return the current direct image criterion for
`directEntity`; return the existing nested `GalleryFilter` criterion for
`relatedGalleries`.

- [ ] **Step 4: Run the preference test to verify it passes**

Run: `rtk flutter test test/features/galleries/presentation/providers/entity_image_filter_method_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the preference seam**

```bash
rtk git add lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart test/features/galleries/presentation/providers/entity_image_filter_method_test.dart
rtk git commit -m "feat: persist entity image filter method"
```

### Task 2: Apply the preference in entity gallery navigation

**Files:**
- Modify: `lib/features/galleries/presentation/widgets/entity_gallery_grid.dart:303-315`
- Modify: `test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

- [ ] **Step 1: Write failing direct-default and related-gallery assertions**

Split the current parameterized widget test into two cases. The default case must assert direct image metadata:

```dart
expect(state.filter.performers?.value, ['performer-1']);
expect(state.filter.galleriesFilter, isNull);
```

Before the related-gallery case pumps the widget, set:

```dart
await container
    .read(entityImageFilterMethodSettingProvider.notifier)
    .set(EntityImageFilterMethod.relatedGalleries);
```

Then assert `state.filter.performers` is null and
`state.filter.galleriesFilter?.performers?.value` equals `['performer-1']`.
Repeat the assertions for studio and tag variants.

- [ ] **Step 2: Run the widget test to verify it fails**

Run: `rtk flutter test test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: FAIL because the action currently always uses the related-gallery method.

- [ ] **Step 3: Read the method at the action boundary**

Change `_openAllEntityImages` to pass the stored method:

```dart
final method = ref.read(entityImageFilterMethodSettingProvider);
ref.read(imageFilterStateProvider.notifier).updateFilter(
  imageFilterForEntityGalleries(
    kind: widget.filterKind,
    entityId: widget.entityId,
    method: method,
  ),
);
```

- [ ] **Step 4: Run the widget test to verify it passes**

Run: `rtk flutter test test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the action behavior**

```bash
rtk git add lib/features/galleries/presentation/widgets/entity_gallery_grid.dart test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart
rtk git commit -m "feat: apply entity image filter preference"
```

### Task 3: Add the Interface setting

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart:24-150,180-260`
- Modify: `lib/l10n/app_en.arb`
- Modify: generated `lib/l10n/app_localizations*.dart`
- Modify: `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`

- [ ] **Step 1: Write the failing settings-widget test**

Add a widget test that finds `Entity image filtering`, asserts `Direct entity`
is selected by default, taps `Related galleries`, and expects:

```dart
expect(
  prefs.getString(entityImageFilterMethodPreferenceKey),
  EntityImageFilterMethod.relatedGalleries.name,
);
```

- [ ] **Step 2: Run the settings test to verify it fails**

Run: `rtk flutter test test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`

Expected: FAIL because the setting title and segmented control do not exist.

- [ ] **Step 3: Add localization and the segmented setting**

Add these English ARB keys:

```json
"settings_interface_entity_image_filtering": "Entity image filtering",
"settings_interface_entity_image_filtering_subtitle": "Choose whether entity image pages match image metadata or related galleries.",
"settings_interface_entity_image_filtering_direct": "Direct entity",
"settings_interface_entity_image_filtering_galleries": "Related galleries"
```

Run `rtk flutter gen-l10n`. In `InterfaceSettingsPage`, load the provider in
`_load`, retain its value in `_entityImageFilterMethod`, persist it in
`_saveSettings`, and add `_buildSegmentedSetting` to the Navigation section:

```dart
_buildSegmentedSetting(
  context: context,
  label: context.l10n.settings_interface_entity_image_filtering,
  description:
      context.l10n.settings_interface_entity_image_filtering_subtitle,
  segments: [
    ButtonSegment(
      value: EntityImageFilterMethod.directEntity,
      label: Text(
        context.l10n.settings_interface_entity_image_filtering_direct,
      ),
    ),
    ButtonSegment(
      value: EntityImageFilterMethod.relatedGalleries,
      label: Text(
        context.l10n.settings_interface_entity_image_filtering_galleries,
      ),
    ),
  ],
  selected: {_entityImageFilterMethod},
  onSelectionChanged: (selection) async {
    if (selection.isEmpty) return;
    setState(() => _entityImageFilterMethod = selection.first);
    await _saveSettings();
  },
),
```

- [ ] **Step 4: Run the settings test to verify it passes**

Run: `rtk flutter test test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`

Expected: PASS.

- [ ] **Step 5: Run focused regressions and analysis**

Run:

```bash
rtk flutter test test/features/galleries/presentation/providers/entity_image_filter_method_test.dart test/features/galleries/presentation/widgets/entity_gallery_grid_test.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart
rtk flutter analyze lib/features/galleries/presentation/providers/entity_gallery_filter_scope.dart lib/features/galleries/presentation/widgets/entity_gallery_grid.dart lib/features/setup/presentation/pages/settings/interface_settings_page.dart
```

Expected: all focused tests pass and analysis reports `No issues found!`.

- [ ] **Step 6: Commit the Interface setting**

```bash
rtk git add lib/features/setup/presentation/pages/settings/interface_settings_page.dart lib/l10n/app_en.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart
rtk git commit -m "feat: add entity image filter setting"
```
