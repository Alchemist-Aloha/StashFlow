# Design Spec: Localization and APK Build

## Overview
Systematically localize hardcoded strings in the `TagsPage` and `SceneFilterPanel`, add missing localization keys to ARB files (including AI-generated translations for all supported languages), and finally build a release APK with split ABI.

## Architecture & Components

### 1. Localization Layer
- **Source Files:**
    - `lib/features/tags/presentation/pages/tags_page.dart`
    - `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`
    - `lib/l10n/app_en.arb` (and all other `.arb` files in `lib/l10n/`)
- **Key Changes:**
    - Replace hardcoded `Text` literals and string parameters with `context.l10n.<key>`.
    - Use `AppLocalizations` (via `context.l10n` extension) to access translated strings.

### 2. ARB Resources
- **New Keys in `app_en.arb`:**
    - `tags_search_placeholder`: "Search tags..."
    - `scenes_duration_short`: "< 5m"
    - `scenes_duration_medium`: "5-20m"
    - `scenes_duration_long`: "> 20m"
- **Translation Strategy:**
    - Automatically generate translations for the new keys across all supported locales: DE, ES, FR, IT, JA, KO, RU, ZH, ZH-Hans, ZH-Hant.
    - Ensure consistency with existing naming conventions (e.g., `nScenes` for plurals).

### 3. Build System
- **Command:** `flutter build apk --release --split-per-abi`
- **Output:** Release APKs for each architecture (armeabi-v7a, arm64-v8a, x86_64).

## Data Flow
1. **Developer (Agent):** Identifies hardcoded strings.
2. **ARB Files:** Updated with new keys and translations.
3. **Code Generation:** `flutter gen-l10n` creates updated `AppLocalizations` classes.
4. **UI Components:** Updated to consume the new localized getters.
5. **Flutter Build:** Compiles the localized app into APKs.

## Testing & Validation
- **Localization Check:** Verify that `flutter gen-l10n` runs without errors and that all updated widgets compile.
- **Visual Verification:** Check that the `TagsPage` and `SceneFilterPanel` display correctly in English.
- **Build Verification:** Ensure the APK build completes successfully and produces the expected artifacts in `build/app/outputs/flutter-apk/`.

## Success Criteria
- Zero hardcoded strings in `TagsPage` and `SceneFilterPanel`.
- Complete ARB coverage for the new keys across all 11 supported locales.
- Successful APK build with `split-per-abi`.
