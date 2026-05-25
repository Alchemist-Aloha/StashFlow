# Scenes

This component covers the main media browsing flow: scene lists, scene detail pages, video playback, stream resolution, and playback queue state.

## Issue: Scene video player keeps local resources alive after disposal

**Severity:** Medium  
**Category:** Performance  
**Location:** `lib/features/scenes/presentation/widgets/scene_video_player.dart`  
**Status:** Open

### Description
`SceneVideoPlayer` owns a buffering timer and a transformation notifier, but `dispose()` only delegates to the shared player controller lifecycle. The local timer and notifier are never explicitly cleaned up.

### Evidence
The state class creates `_bufferingDisplayTimer` and `_transformationNotifier` at field initialization time. `dispose()` only contains a comment explaining that the controller is shared and then calls `super.dispose()`.

### Impact
Repeated scene navigation can leave stale timer callbacks and listener registrations around longer than necessary. Even if mounted checks prevent some crashes, the widget still leaks lifecycle noise and cleanup work.

### Suggested Fix
Cancel the buffering timer and dispose the transformation notifier in `dispose()`. Keep shared controller ownership in the provider, but fully release the widget-local state.

### Validation
Open and close scene pages repeatedly while watching for stale callbacks, then run the existing widget tests for the player to confirm disposal is clean.

## Issue: Playback startup resolves the same stream more than once

**Severity:** Medium  
**Category:** Performance  
**Location:** `lib/features/scenes/presentation/widgets/scene_video_player.dart`  
**Status:** Open

### Description
Startup prewarming resolves the preferred stream and the main playback start resolves it again. That means the player does the selection work twice for the same user action.

### Evidence
`_startPlaybackIfNeeded()` schedules `_prewarmStream(widget.scene)` and then separately calls `resolver.resolvePreferredStream(widget.scene)` before playback. Both paths rely on the same stream-resolution logic.

### Impact
On slow networks or under load, playback startup performs avoidable duplicate work. The extra resolution also increases the chance that the prewarm and the actual player start race each other.

### Suggested Fix
Cache the selected stream or pass the prewarm choice through to the main playback path. Keep the connectivity probe, but do not repeat the expensive resolution work.

### Validation
Instrument stream-resolution calls during playback startup and verify the count drops to one per scene start.

## Issue: Infinite-scroll pagination drops failures on the floor

**Severity:** Medium  
**Category:** UX  
**Location:** `lib/features/scenes/presentation/providers/scene_list_provider.dart`  
**Status:** Open

### Description
`fetchNextPage()` catches exceptions and ignores them. The list can end up half-loaded with no user-visible error or retry action.

### Evidence
The pagination branch updates `_isLoadingMore`, performs a repository call, and then swallows any exception in an empty `catch (e)` block. The code even comments that a snackbar might be nice, but it is not implemented.

### Impact
Users can scroll into a dead end without understanding whether the list is exhausted or a request failed. That makes the infinite-scroll experience feel unreliable in weak network conditions.

### Suggested Fix
Expose the last pagination error in provider state or surface a retry affordance in the UI. At minimum, log and present the failure instead of ignoring it.

### Validation
Simulate a network failure during pagination and confirm the app shows a meaningful failure state and retry path.

