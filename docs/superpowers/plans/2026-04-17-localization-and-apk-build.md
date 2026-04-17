# Localization and APK Build Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Localize hardcoded strings in `TagsPage` and `SceneFilterPanel`, add them to ARB files, and build the release APK.

**Architecture:** Use `AppLocalizations` (via `context.l10n`) to replace hardcoded strings. Add new keys to `app_en.arb` and generate translations for all supported locales. Use `flutter build apk --release --split-per-abi` for release.

**Tech Stack:** Flutter, ARB, Dart `intl`.

---

### Task 1: Update `app_en.arb` and Generate Translations

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Run: `flutter gen-l10n`

- [ ] **Step 1: Add new keys to `lib/l10n/app_en.arb`**

```json
  "tags_search_placeholder": "Search tags...",
  "scenes_duration_short": "< 5m",
  "scenes_duration_medium": "5-20m",
  "scenes_duration_long": "> 20m"
```

- [ ] **Step 2: Generate localization classes**

Run: `flutter gen-l10n`

- [ ] **Step 3: Update other ARB files**
Add these keys (translated) to:
`lib/l10n/app_de.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_it.arb`, `lib/l10n/app_ja.arb`, `lib/l10n/app_ko.arb`, `lib/l10n/app_ru.arb`, `lib/l10n/app_zh.arb`, `lib/l10n/app_zh_Hans.arb`, `lib/l10n/app_zh_Hant.arb`.

- [ ] **Step 4: Commit**
`git add lib/l10n/app_*.arb && git commit -m "feat(l10n): add new localization keys"`

---

### Task 2: Localize `TagsPage`

**Files:**
- Modify: `lib/features/tags/presentation/pages/tags_page.dart`
- Test: Build project

- [ ] **Step 1: Update title, search, and list item**

Replace "Tags", "Search tags...", and "scenes" with localized strings:

```dart
// AppBar title
title: Text(context.l10n.nav_tags), // or equivalent

// Search
searchHint: context.l10n.tags_search_placeholder,

// List item
trailing: Text(
  context.l10n.nScenes(tag.sceneCount), // Uses existing nScenes key
  style: context.textTheme.bodySmall,
),
```

- [ ] **Step 2: Ensure sorting title is localized**

```dart
// Sort Panel
Text(
  context.l10n.tags_sort_title, // Use existing key
  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
),
```

- [ ] **Step 3: Commit**
`git add lib/features/tags/presentation/pages/tags_page.dart && git commit -m "feat(l10n): localize TagsPage"`

---

### Task 3: Localize `SceneFilterPanel`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`
- Test: Build project

- [ ] **Step 1: Update duration chips**

```dart
// Inside SceneFilterPanel _buildDurationChip calls
_buildDurationChip(null, 300, context.l10n.scenes_duration_short),
_buildDurationChip(300, 1200, context.l10n.scenes_duration_medium),
_buildDurationChip(1200, null, context.l10n.scenes_duration_long),
```

- [ ] **Step 2: Commit**
`git add lib/features/scenes/presentation/widgets/scene_filter_panel.dart && git commit -m "feat(l10n): localize SceneFilterPanel"`

---

### Task 4: Build Release APK

**Files:**
- Output: `build/app/outputs/flutter-apk/`

- [ ] **Step 1: Build release APK**

Run: `flutter build apk --release --split-per-abi`

- [ ] **Step 2: Verify output**

Check for files:
`build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
`build/app/outputs/flutter-apk/app-x86_64-release.apk`
