# Playback and Rating Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement dynamic "Playlist" strategy using the current query sequence and add scene rating functionality.

**Architecture:** Extend `PlaybackQueue` state, update `ScenesPage` to populate current sequence, and add rating UI/API.

**Tech Stack:** Flutter, Riverpod, GraphQL.

---

### Task 1: Dynamic Playback Sequence

**Files:**
- Modify: `lib/features/scenes/presentation/providers/playback_queue_provider.dart`
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`

- [ ] **Step 1: Update PlaybackQueue state**
Add `List<Scene> currentSequence = []` to the state.

- [ ] **Step 2: Update getNextScene() logic**
```dart
  Scene? getNextScene() {
    final activeScene = ref.read(playerStateProvider).activeScene;
    if (activeScene == null) return null;

    // 1. Check manual queue first
    final manualIndex = state.manualQueue.indexWhere((s) => s.id == activeScene.id);
    if (manualIndex != -1 && manualIndex < state.manualQueue.length - 1) {
      return state.manualQueue[manualIndex + 1];
    }

    // 2. Fallback to current sequence (query list)
    final seqIndex = state.currentSequence.indexWhere((s) => s.id == activeScene.id);
    if (seqIndex != -1 && seqIndex < state.currentSequence.length - 1) {
      return state.currentSequence[seqIndex + 1];
    }
    
    return null;
  }
```

- [ ] **Step 3: Update currentSequence on scene tap**
In `ScenesPage`, when navigating to `SceneDetailsPage`, call `ref.read(playbackQueueProvider.notifier).setCurrentSequence(loadedScenes)`.

- [ ] **Step 4: Commit**
```bash
git add lib/features/scenes/presentation/providers/playback_queue_provider.dart lib/features/scenes/presentation/pages/scenes_page.dart
git commit -m "feat: implement dynamic playback sequence from current query"
```

---

### Task 2: Scene Rating UI and API

**Files:**
- Modify: `lib/features/scenes/domain/repositories/scene_repository.dart`
- Modify: `lib/features/scenes/data/repositories/graphql_scene_repository.dart`
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`

- [ ] **Step 1: Add updateSceneRating to Repository**
Implement a method that calls the `sceneUpdate` mutation.

- [ ] **Step 2: Add Rating Bar to SceneDetailsPage**
Add a 5-star rating widget (can use `IconButton`s or a library if available, but simple `Row` of `Icon`s is fine).

- [ ] **Step 3: Handle rating change**
Call repository, then invalidate `sceneDetailsProvider` and `sceneListProvider`.

- [ ] **Step 4: Commit**
```bash
git add lib/features/scenes/domain/repositories/scene_repository.dart lib/features/scenes/data/repositories/graphql_scene_repository.dart lib/features/scenes/presentation/pages/scene_details_page.dart
git commit -m "feat: allow rating scenes from details page"
```
