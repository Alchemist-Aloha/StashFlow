# Testing and Stability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a robust, reusable testing framework and increase coverage for core modules (Performers, Studios, Tags, Scenes) and global UI states.

**Architecture:** Hybrid testing strategy using shared manual mocks and a unified `pumpTestWidget` helper to minimize boilerplate and ensure consistency.

**Tech Stack:** Flutter Test, Riverpod (ProviderScope overrides), Manual Mocks.

---

### Task 1: Shared Test Helpers

**Files:**
- Create: `test/helpers/test_helpers.dart`

- [ ] **Step 1: Define base Mock Repository classes**
Create `MockPerformerRepository`, `MockStudioRepository`, `MockTagRepository`, and `MockSceneRepository` with support for data/empty/error states.

- [ ] **Step 2: Implement `pumpTestWidget` helper**
Create a helper function that sets up `ProviderScope` with all necessary overrides and wraps the child in a `MaterialApp`.

- [ ] **Step 3: Add custom finders and common matchers**
Implement `find.loadingSpinner()`, `find.errorView()`, and `find.retryButton()`.

- [ ] **Step 4: Commit**
```bash
git add test/helpers/test_helpers.dart
git commit -m "test: add shared test helpers and manual mocks"
```

---

### Task 2: Global UI States Tests

**Files:**
- Create: `test/global_ui_states_test.dart`

- [ ] **Step 1: Test Empty States across major pages**
Verify "No items found" message appears on Scenes, Performers, Studios, and Tags pages when repositories return empty lists.

- [ ] **Step 2: Test Error States and Retry logic**
Verify `ErrorStateView` appears when repositories throw exceptions and that clicking "Retry" triggers a refresh.

- [ ] **Step 3: Run tests to verify**
Run: `flutter test test/global_ui_states_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**
```bash
git add test/global_ui_states_test.dart
git commit -m "test: add global UI state tests for empty and error scenarios"
```

---

### Task 3: Performers, Studios, and Tags Feature Tests

**Files:**
- Create: `test/features/performers/performers_ui_test.dart`
- Create: `test/features/studios/studios_ui_test.dart`
- Create: `test/features/tags/tags_ui_test.dart`

- [ ] **Step 1: Implement Performers UI tests**
Verify list rendering, search query updates, and "Favorites only" filter.

- [ ] **Step 2: Implement Studios and Tags UI tests**
Similar to Performers, verify list content and basic filtering/sorting UI.

- [ ] **Step 3: Run tests to verify**
Run: `flutter test test/features/performers/ test/features/studios/ test/features/tags/`
Expected: PASS

- [ ] **Step 4: Commit**
```bash
git add test/features/
git commit -m "test: add focused widget tests for Performers, Studios, and Tags"
```

---

### Task 4: Video Player and Fullscreen Mode Tests

**Files:**
- Create: `test/features/scenes/video_player_ui_test.dart`
- Create: `test/features/scenes/fullscreen_mode_test.dart`

- [ ] **Step 1: Implement Video Player UI tests**
Verify overlays, rating widget interaction, and playback queue navigation.

- [ ] **Step 2: Implement Fullscreen Mode tests**
Verify route-based entry, layout changes, and state recovery on pop.

- [ ] **Step 3: Run tests to verify**
Run: `flutter test test/features/scenes/`
Expected: PASS

- [ ] **Step 4: Commit**
```bash
git add test/features/scenes/
git commit -m "test: add video player and fullscreen mode tests"
```
