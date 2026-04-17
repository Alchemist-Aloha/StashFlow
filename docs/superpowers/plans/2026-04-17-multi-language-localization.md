# Multi-Language Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement full localization support for StashFlow across 10 locales using Flutter's `gen-l10n` tool and provide AI-generated translations.

**Architecture:** We will use the standard Flutter `gen-l10n` approach with ARB files. A `BuildContext` extension will be provided for concise string access. The app will be systematically updated to replace hardcoded strings with localized ones.

**Tech Stack:** Flutter SDK, `flutter_localizations`, `intl`.

---

### Task 1: Environment Setup

**Files:**
- Modify: `pubspec.yaml`
- Create: `l10n.yaml`

- [ ] **Step 1: Add dependencies to pubspec.yaml**
    ```yaml
    dependencies:
      flutter_localizations:
        sdk: flutter
      intl: ^0.19.0
    
    flutter:
      generate: true
    ```
- [ ] **Step 2: Create l10n.yaml in root**
    ```yaml
    arb-dir: lib/l10n
    template-arb-file: app_en.arb
    output-localization-file: app_localizations.dart
    ```
- [ ] **Step 3: Run flutter pub get**
    Run: `flutter pub get`
- [ ] **Step 4: Commit setup**
    ```bash
    git add pubspec.yaml l10n.yaml
    git commit -m "chore: setup localization dependencies and config"
    ```

---

### Task 2: Infrastructure & Core Template

**Files:**
- Create: `lib/l10n/app_en.arb`
- Create: `lib/core/utils/l10n_extensions.dart`

- [ ] **Step 1: Create initial app_en.arb with core strings**
    ```json
    {
      "@@locale": "en",
      "appTitle": "StashFlow",
      "@appTitle": {
        "description": "The name of the application"
      },
      "common_error": "Error: {message}",
      "@common_error": {
        "placeholders": {
          "message": {
            "type": "String"
          }
        }
      }
    }
    ```
- [ ] **Step 2: Create BuildContext extension**
    ```dart
    import 'package:flutter/widgets.dart';
    import 'package:flutter_gen/gen_l10n/app_localizations.dart';

    extension L10nX on BuildContext {
      AppLocalizations get l10n => AppLocalizations.of(this)!;
    }
    ```
- [ ] **Step 3: Run l10n generation**
    Run: `flutter gen-l10n`
- [ ] **Step 4: Commit infrastructure**
    ```bash
    git add lib/l10n/app_en.arb lib/core/utils/l10n_extensions.dart
    git commit -m "feat: add l10n infrastructure and core template"
    ```

---

### Task 3: App Integration

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Import localizations in main.dart**
    ```dart
    import 'package:flutter_localizations/flutter_localizations.dart';
    import 'package:flutter_gen/gen_l10n/app_localizations.dart';
    ```
- [ ] **Step 2: Add delegates and supported locales to MaterialApp.router**
    ```dart
    return MaterialApp.router(
      // ...
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // ...
    );
    ```
- [ ] **Step 3: Verify app still builds and runs**
    Run: `flutter build bundle` (or check for analysis errors)
- [ ] **Step 4: Commit integration**
    ```bash
    git add lib/main.dart
    git commit -m "feat: integrate localization delegates into MaterialApp"
    ```

---

### Task 4: String Extraction - Navigation & Common

**Files:**
- Modify: `lib/features/navigation/presentation/widgets/main_navigation_bar.dart` (and related)
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Identify and move navigation strings to ARB**
    Keys: `nav_scenes`, `nav_images`, `nav_galleries`, `nav_performers`, `nav_tags`, `nav_studios`, `nav_groups`.
- [ ] **Step 2: Replace hardcoded strings in Navigation widgets**
- [ ] **Step 3: Commit navigation localization**
    ```bash
    git commit -m "feat: localize navigation labels"
    ```

---

### Task 5: Systematic Extraction - All Features

**Files:**
- Modify: `lib/features/**/*.dart`
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Scan and extract strings for Scenes, Images, Performers, Tags, Studios.**
- [ ] **Step 2: Update ARB with descriptive keys.**
- [ ] **Step 3: Replace strings in UI code.**
- [ ] **Step 4: Commit feature localizations**
    ```bash
    git commit -m "feat: localize feature-specific strings"
    ```

---

### Task 6: AI-Generated Translations

**Files:**
- Create: `lib/l10n/app_es.arb`
- Create: `lib/l10n/app_zh_Hans.arb`
- Create: `lib/l10n/app_zh_Hant.arb`
- Create: `lib/l10n/app_ja.arb`
- Create: `lib/l10n/app_ko.arb`
- Create: `lib/l10n/app_fr.arb`
- Create: `lib/l10n/app_it.arb`
- Create: `lib/l10n/app_de.arb`
- Create: `lib/l10n/app_ru.arb`

- [ ] **Step 1: Generate Spanish translations.**
- [ ] **Step 2: Generate Chinese (Simplified & Traditional) translations.**
- [ ] **Step 3: Generate Japanese, Korean, French, Italian, German, Russian translations.**
- [ ] **Step 4: Run flutter gen-l10n and verify.**
- [ ] **Step 5: Commit translations**
    ```bash
    git add lib/l10n/*.arb
    git commit -m "feat: add translations for 9 locales"
    ```

---

### Task 7: Final Validation

- [ ] **Step 1: Run analyzer to ensure no missing context or errors.**
    Run: `flutter analyze`
- [ ] **Step 2: Check for any remaining hardcoded strings.**
- [ ] **Step 3: Verify pluralization and placeholders work as expected.**
