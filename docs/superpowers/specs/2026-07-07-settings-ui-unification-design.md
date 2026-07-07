# Design Spec: Settings UI Unification

**Date:** 2026-07-07
**Status:** Draft
**Topic:** Unify settings page presentation without changing routes or behavior

## 1. Problem Statement

The settings experience already has separate routes and a shared top-level shell, but the pages do not read as one system. Today they diverge in:

- Page padding and max-width usage
- Section spacing and header rhythm
- Card and panel treatment
- Divider usage inside grouped controls
- Loading and empty-state presentation
- Hub-card styling versus detail-page styling

This creates a fragmented UI even though the information architecture is already settled. The goal is to unify the visual system without reopening routing, settings semantics, or category structure.

## 2. Scope

### In scope

- Shared presentation primitives for settings pages
- Consistent layout rhythm across the settings hub and detail pages
- Consistent panel styling for grouped controls and action rows
- Shared loading and empty-state presentation for settings surfaces
- Light visual alignment for `ServerSettingsPage` while preserving its current list/FAB behavior

### Out of scope

- Route changes
- Settings category changes
- New settings behavior or persistence changes
- Reorganizing server settings into a form-style page
- New navigation patterns such as sidebars or split-view settings

## 3. Goals

1. Make the settings hub and detail pages feel like one UI family.
2. Centralize the presentation rules in shared widgets instead of repeating styling page by page.
3. Keep the diff focused on presentation, with minimal risk to behavior.

## 4. Non-Goals

- Replacing native Material controls with custom controls
- Refactoring providers, persistence, or routing
- Combining multiple settings pages into fewer screens

## 5. Proposed Solution

Strengthen the existing settings presentation seam in `lib/features/setup/presentation/widgets/settings_page_shell.dart` and migrate the settings pages onto the stronger shared layer.

The design keeps `SettingsPageShell` as the route frame and extends it with reusable layout primitives:

- `SettingsPageBody`
  - Owns standard page padding, scroll treatment, width constraint, and top-to-bottom section rhythm.
- `SettingsSectionHeader`
  - Owns title/subtitle spacing and typography for all settings sections.
- `SettingsPanelCard`
  - Owns the shared surface treatment for grouped controls and action content.
- `SettingsPanelGroup`
  - Owns vertical stacking and divider rhythm for settings rows inside a panel.
- `SettingsLoadingState`
  - Standard loading presentation for settings pages.
- `SettingsEmptyState`
  - Standard empty-state presentation for settings pages that need one.

`SettingsSectionCard` remains the section-level composition point, but it will be upgraded to render its content inside the shared panel surface by default. `SettingsActionCard` will be visually aligned to that same panel system so hub actions and detail content no longer feel unrelated.

## 6. Page-Level Migration Rules

### Hub page

- Keep the existing categories and routes.
- Use the shared page body and section panel treatment.
- Update `SettingsActionCard` styling to visually match detail-page panels.

### Detail pages

The following pages move to the shared body/panel/group rhythm:

- `AppearanceSettingsPage`
- `PlaybackSettingsPage`
- `InterfaceSettingsPage`
- `StorageSettingsPage`
- `SecuritySettingsPage`
- `DeveloperSettingsPage`
- `SupportSettingsPage`
- `KeybindSettingsPage`
- `NavigationCustomizationPage`

These pages will continue to use native controls such as `SwitchListTile`, `SegmentedButton`, `DropdownButton`, and `ListTile`, but those controls will sit inside consistent shared section containers.

### Server settings

- Keep the current profile list and floating action button flow.
- Keep the current bottom-sheet editing flow.
- Apply the shared page body spacing.
- Align the empty state with the shared settings visual language.
- Do not force the profile list into the same grouped-control panel structure as the other settings pages.

## 7. Data Flow and Behavior

No settings behavior changes are required.

- Existing providers remain the state seam.
- Existing routes remain unchanged.
- Existing save/load timing remains unchanged.
- Existing server-profile interactions remain unchanged.

This is intentionally a presentation refactor with no new settings model or controller layer.

## 8. Testing Strategy

Use a small TDD path centered on the new shared presentation seam.

1. Add a focused widget test for the shared settings primitives.
   - Verify a section renders a shared panel surface and header rhythm.
2. Migrate one representative settings page first.
   - Recommended representative page: `AppearanceSettingsPage` because it exercises grouped controls, sliders, and segmented controls.
3. Run the representative page test and confirm the failure is due to the expected structural change before finishing the implementation.
4. Migrate the remaining pages.
5. Adjust existing settings page tests only where the widget tree shape changes.

Verification ladder:

- Focused settings widget tests
- `flutter analyze`
- `git diff --check`

In this environment, prefer the existing `HOME=/tmp` workaround if Flutter tries to write outside the workspace.

## 9. Risks and Mitigations

### Risk: tree-shape churn breaks brittle widget tests

Mitigation:

- Keep existing semantics and labels unchanged.
- Limit new wrappers to the shared settings seam.
- Update only structure-sensitive tests.

### Risk: server settings gets over-normalized and loses its better list behavior

Mitigation:

- Treat `ServerSettingsPage` as the explicit exception.
- Align spacing and empty state only.

### Risk: helper widgets become another abstraction layer that pages bypass

Mitigation:

- Put the shared widgets next to the existing shell.
- Migrate all current settings pages in the same change.
- Keep the API small and presentation-only.

## 10. Success Criteria

- The settings hub and detail pages share the same spacing and panel language.
- Most settings page styling is owned by shared widgets, not page-local containers.
- `ServerSettingsPage` still behaves exactly as it does today.
- Existing settings behavior remains unchanged.

