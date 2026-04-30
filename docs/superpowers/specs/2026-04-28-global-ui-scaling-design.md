# Design Spec: Global UI Scaling System

## 1. Problem Statement
The current application uses a mix of hardcoded literals and static constants for UI sizing (padding, spacing, component dimensions). While a font scaling factor exists, it does not affect the overall layout spacing or component sizes, leading to inconsistent UI density when font sizes are changed.

## 2. Goals
- Consolidate font and element scaling into a single "Global UI Scale" factor.
- Move all spacing and component dimensions into the `Theme` via a `ThemeExtension`.
- Provide a single slider in Appearance Settings to control this factor.
- Ensure the app layout remains proportional across different scale settings.

## 3. Proposed Changes

### 3.1 State Management
- **Provider:** Rename `AppFontSize` to `AppGlobalScale` in `lib/core/presentation/providers/layout_settings_provider.dart`.
- **Storage Key:** Change `app_font_size_factor` to `app_global_scale_factor` (with migration/fallback).
- **Range:** 0.8x to 1.5x (default 1.0x).

### 3.2 Theme System (`lib/core/presentation/theme/app_theme.dart`)
- **AppDimensions Extension:** Expand to include:
    - `spacingSmall`, `spacingMedium`, `spacingLarge`
    - `performerAvatarSize`
    - `buttonHeight`
    - `inputPadding`
- **Theme Builder:** Update `AppTheme.buildTheme` to:
    1. Accept `scaleFactor` (replacing `fontSizeFactor`).
    2. Apply `scaleFactor` to all `AppDimensions` fields.
    3. Update `FilledButtonThemeData`, `OutlinedButtonThemeData`, and `TextButtonThemeData` to use scaled padding and heights from `AppDimensions`.
    4. Update `InputDecorationThemeData` to use scaled `contentPadding`.
    5. Maintain fixed `borderRadius` and `borderSide` widths.

### 3.3 UI Components
- **Migration:** Systematically replace hardcoded `EdgeInsets.all(8)`, `SizedBox(height: 16)`, etc., with `context.dimensions.spacingSmall` and `context.dimensions.spacingMedium`.
- **Icons:** Ensure icons in major components (Buttons, ListTiles) scale using the global factor where appropriate.

### 3.4 Settings UI (`lib/features/setup/presentation/pages/settings/appearance_settings_page.dart`)
- Rename "Global Font Size" section to "Global UI Scale".
- Update the slider to watch and write to `appGlobalScaleProvider`.
- Update labels and tooltips to reflect that this scales the entire UI.

## 4. Implementation Plan (Summary)
1. **Infrastructure:** Update providers and theme extensions.
2. **Theme Integration:** Wire the scale factor into Material component themes.
3. **Settings Update:** Implement the new slider and verify live-reloading.
4. **Refactoring:** Perform surgical replacements of hardcoded sizes in core widgets and pages.

## 5. Success Criteria
- Changing the slider results in an immediate, proportional scaling of both text and surrounding spacing.
- The UI does not "break" or overlap at 1.5x scale.
- No hardcoded spacing literals remain in the primary feature directories (`lib/features/`).
