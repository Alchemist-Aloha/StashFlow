# Spec: Play Next Overhaul & Queue Removal

## Status: Proposed
## Date: 2026-03-23

## 1. Overview
Overhaul the "Play Next" functionality to strictly follow the sequence of the scenes list, while removing the manual "Add to Queue" feature. This ensures a predictable, list-driven playback experience across all views (List, Details, Fullscreen, and TikTok).

## 2. Goals
- Ditch the manual "Add to Queue" function throughout the app.
- Ensure the playback sequence matches the current state of the Scenes list.
- Keep the playback sequence static until an explicit refresh or sort change in the list.
- Add a "Next Video" button to the standard video player's bottom control bar.
- Unify the TikTok view with this global playback sequence design.

## 3. Architecture & Data Flow

### 3.1. Unified Playback Queue (`PlaybackQueue`)
The `PlaybackQueue` provider will be the single source of truth for sequential navigation.
- **State:**
    - `List<Scene> sequence`: The current list of scenes available for sequential playback.
    - `int currentIndex`: The index of the currently active scene within the `sequence`.
- **Logic:**
    - `setSequence(List<Scene> scenes, int initialIndex)`: Replaces the current sequence.
    - `updateSequence(List<Scene> scenes)`: Appends new scenes to the existing sequence (used for pagination).
    - `setIndex(int index)`: Updates the current index (e.g., when swiping in TikTok view).
    - `getNextScene()`: Returns the scene at `currentIndex + 1` if available.
    - `playNext()`: Increments `currentIndex` and triggers playback of the next scene.

### 3.2. Synchronization with `SceneList`
- The `sequence` in `PlaybackQueue` is initialized/reset **only** when `SceneList` performs a fresh fetch (initial load, explicit refresh, or sort/filter change).
- When `SceneList` fetches the next page (pagination), those scenes are appended to the `PlaybackQueue.sequence`.

## 4. Component & UI Changes

### 4.1. Standard Video Player (`NativeVideoControls`)
- **Next Button:** Add `IconButton(icon: Icons.skip_next)` to the bottom control bar, immediately to the right of the Play/Pause button.
- **Floating UI Removal:** Remove the "Next: [Title]" floating button and its associated logic.
- **Dynamic State:** The "Next" button should be disabled (`null` onPressed) if `currentIndex` is at the end of the `sequence`.

### 4.2. TikTok View (`TiktokScenesView`)
- Observe `PlaybackQueue.sequence` for its list of items.
- Notify `PlaybackQueue.setIndex(newIndex)` via `onPageChanged` to keep the global state in sync.
- Use `PlaybackQueue.updateSequence` logic when reaching the end of the scroll to trigger pagination.

### 4.3. Cleanup (Removal of "Add to Queue")
- **SceneCard:** Remove the "Add to queue" option from the context menu (long-press/three-dot menu).
- **SceneDetailsPage:** Remove the "Add to queue" button from the AppBar.
- **PlaybackQueue:** Remove the `manualQueue` state and `add`/`remove`/`clear` methods related to it.

## 5. Navigation Logic
- **ScenesPage -> Details/Fullscreen:** Tapping a card will call `PlaybackQueue.setIndex(index)` but **not** `setSequence`, unless the list has been refreshed/sorted since the last sequence was set.
- **Details -> Next:** Clicking "Next" in the player will call `PlaybackQueue.playNext()`. The `SceneDetailsPage` already has a listener for `playerStateProvider` that will handle navigating to the new `activeScene.id`.

## 6. Testing Strategy
- **Unit Tests:** Verify `PlaybackQueue` correctly manages index and sequence appends during pagination.
- **Widget Tests:** 
    - Verify "Next" button visibility and functionality in `NativeVideoControls`.
    - Verify absence of "Add to Queue" buttons in `SceneCard` and `SceneDetailsPage`.
- **Integration Tests:** 
    - Load a list, play a video, click "Next", and verify it follows the list order.
    - Verify TikTok swipe updates the global `currentIndex`.
