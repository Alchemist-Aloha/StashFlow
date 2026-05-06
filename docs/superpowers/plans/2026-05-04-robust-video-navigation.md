# Robust Video Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix desync between fullscreen and detail pages, prevent redundant playback initialization, and ensure a robust "Back" navigation history.

**Architecture:** Introduce `PlayerViewMode` to `GlobalPlayerState` for ownership control and implement a "Stack Reconstruction" strategy in the `PlaybackCoordinator` (via `PlayerState` notifier) to keep navigation in sync with playback.

**Tech Stack:** Flutter, Riverpod, GoRouter, MediaKit.

---

### Phase 1: State & Provider Updates

#### Task 1: Update `GlobalPlayerState` with View Context

**Files:**
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`

- [ ] **Step 1: Define `PlayerViewMode` enum and update `GlobalPlayerState`**

Add the enum and new fields to the class.

```dart
enum PlayerViewMode { inline, fullscreen, tiktok }

class GlobalPlayerState {
  // ...
  final PlayerViewMode viewMode;
  final bool isTransitioning;

  GlobalPlayerState({
    // ...
    this.viewMode = PlayerViewMode.inline,
    this.isTransitioning = false,
  }) { ... }

  GlobalPlayerState copyWith({
    // ...
    PlayerViewMode? viewMode,
    bool? isTransitioning,
  }) {
    return GlobalPlayerState(
      // ...
      viewMode: viewMode ?? this.viewMode,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }
}
```

- [ ] **Step 2: Update `PlayerState` notifier to manage new fields**

Implement `setViewMode` and ensure `isTransitioning` is used in `playNext`.

```dart
  void setViewMode(PlayerViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void _setTransitioning(bool value) {
    state = state.copyWith(isTransitioning: value);
  }
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/providers/video_player_provider.dart
git commit -m "feat(video): add viewMode and isTransitioning to GlobalPlayerState"
```

---

### Phase 2: Navigation Coordination

#### Task 2: Implement Navigation Intent & Coordinator Hook

**Files:**
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`
- Modify: `lib/features/navigation/presentation/shell_page.dart` (or suitable top-level widget)

- [ ] **Step 1: Add `navigationIntent` to `GlobalPlayerState`**

```dart
class NavigationIntent {
  final String path;
  final bool isReplacement;
  NavigationIntent(this.path, {this.isReplacement = false});
}

class GlobalPlayerState {
  // ...
  final NavigationIntent? navigationIntent;
  // Update constructor and copyWith
}
```

- [ ] **Step 2: Create a method to emit navigation intents**

```dart
  void _navigate(String path, {bool replacement = false}) {
    state = state.copyWith(navigationIntent: NavigationIntent(path, isReplacement: replacement));
    // Immediately clear intent so it's not re-processed on next state update
    Future.microtask(() {
      if (ref.mounted) state = state.copyWith(navigationIntent: null);
    });
  }
```

- [ ] **Step 3: Update `_handleVideoFinished` to use coordinated navigation**

When auto-playing in fullscreen, reconstruct the stack.

```dart
      case VideoEndBehavior.next:
        if (state.viewMode == PlayerViewMode.fullscreen) {
           // Sequence: replace current fullscreen with new details, then push new fullscreen
           _navigate('/scenes/scene/${nextScene.id}', replacement: true);
           _navigate('/scenes/fullscreen/${nextScene.id}');
        } else {
           playNext();
        }
        break;
```

- [ ] **Step 4: Register the listener in `ShellPage`**

```dart
    ref.listen(playerStateProvider.select((s) => s.navigationIntent), (prev, next) {
      if (next != null) {
        if (next.isReplacement) {
          context.pushReplacement(next.path);
        } else {
          context.push(next.path);
        }
      }
    });
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/scenes/presentation/providers/video_player_provider.dart lib/features/navigation/presentation/shell_page.dart
git commit -m "feat(video): implement coordinated navigation via navigationIntent"
```

---

### Phase 3: Widget Refactoring

#### Task 3: Refactor `SceneVideoPlayer` for Ownership

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`

- [ ] **Step 1: Update `_startPlaybackIfNeeded` to check `viewMode`**

```dart
    // In SceneVideoPlayer._startPlaybackIfNeeded
    if (playerState.viewMode != PlayerViewMode.inline && !force) {
      AppLogStore.instance.add(
        'SceneVideoPlayer: Skipping playback - viewMode is ${playerState.viewMode}',
        source: 'scene_video_player',
      );
      return;
    }
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_video_player.dart
git commit -m "refactor(video): respect viewMode in SceneVideoPlayer"
```

#### Task 4: Refactor `FullscreenPlayerPage` & `SceneDetailsPage`

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart` (for FullscreenPlayerPage)
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`

- [ ] **Step 1: Update `FullscreenPlayerPage` exit logic**

Use `PopScope` to reset `viewMode`.

```dart
    // In FullscreenPlayerPage.build
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(playerStateProvider.notifier).setViewMode(PlayerViewMode.inline);
        }
      },
      child: ...
    );
```

- [ ] **Step 2: Remove navigation listener from `SceneDetailsPage`**

Delete the `ref.listen(playerStateProvider, ...)` block in `SceneDetailsPage.build` that handles `shouldRouteToNextScene`.

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/pages/scene_details_page.dart
git commit -m "refactor(video): cleanup widget-driven navigation and set viewMode on pop"
```

---

### Phase 4: Verification

#### Task 5: End-to-End Verification

- [ ] **Step 1: Test Fullscreen Auto-play**
  - Open a scene, go to fullscreen.
  - Wait for video to end.
  - Verify it moves to the next scene without exiting fullscreen.
  - Press "Back". Verify you land on the **current** scene's details page.
  - Press "Back" again. Verify you land on the **previous** scene's details page.

- [ ] **Step 2: Test Inline Auto-play**
  - Stay on details page.
  - Wait for video to end.
  - Verify it navigates to the next details page.

- [ ] **Step 3: Verify Log Store**
  - Check `AppLogStore` to ensure no redundant `playScene` calls are happening from background widgets.
