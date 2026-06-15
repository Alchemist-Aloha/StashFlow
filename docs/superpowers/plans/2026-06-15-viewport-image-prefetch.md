# Viewport Image Prefetch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate page image preloading around Flutter scrollable `cacheExtent` while preserving responsive grid density.

**Architecture:** Vertical page scrollables own a one-viewport pixel cache region. Images load normally when Flutter builds children in that region; explicit prefetch remains only for standalone horizontal strips.

**Tech Stack:** Flutter, Riverpod, cached_network_image, flutter_staggered_grid_view, flutter_test

---

### Task 1: Specify viewport caching behavior

**Files:**
- Modify: `test/core/presentation/widgets/list_page_scaffold_test.dart`

- [ ] Add a test that fixed grids use a one-viewport `cacheExtent`.
- [ ] Count built children in two-column and five-column grids.
- [ ] Assert the five-column layout builds more cached-ahead children.
- [ ] Run the focused test and confirm it fails because `cacheExtent` is null.

### Task 2: Replace page prefetch loops

**Files:**
- Modify: `lib/core/presentation/widgets/list_page_scaffold.dart`

- [ ] Remove prefetch state, URL callbacks from prefetch execution, and scroll-index calculations.
- [ ] Keep responsive `memCacheWidth` calculation.
- [ ] Set `cacheExtent` to `MediaQuery.sizeOf(context).height` on list, grid, and masonry views.
- [ ] Keep responsive page-size calculation separate from image loading.
- [ ] Run the scaffold tests and confirm they pass.

### Task 3: Remove per-image prefetch scheduling

**Files:**
- Modify: `lib/core/presentation/widgets/stash_image.dart`

- [ ] Remove post-frame cache inspection and automatic prefetch.
- [ ] Keep the public static prefetch helper for horizontal strips.
- [ ] Keep normal retrying image loading and corrupted-file eviction behavior.
- [ ] Run `stash_image_test.dart`.

### Task 4: Verify

**Files:**
- No additional files.

- [ ] Format changed Dart files.
- [ ] Run scaffold, image, scene strip, gallery strip, and media strip tests where present.
- [ ] Run `flutter analyze --no-pub`.
- [ ] Run `git diff --check` and inspect scope.
