# Global Persistent Player Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the route-based fullscreen player with a persistent global overlay in `ShellPage` to ensure robustness and seamless playback transitions.

**Architecture:** A root-level `Stack` in `ShellPage` hosts the `GlobalFullscreenOverlay`. The overlay animates based on `playerStateProvider.isFullScreen`. It handles its own orientation locking and intercepts back gestures via `PopScope`.

**Tech Stack:** Flutter, Riverpod, GoRouter, media_kit_video.

---

### Task 1: Update Player State and Router Prep

**Files:**
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`
- Modify: `lib/features/navigation/presentation/router.dart`

- [ ] **Step 1: Update PlayerState to handle background synchronization logic**
Add a helper method `syncBackgroundToActiveScene` that checks the current location and navigates if necessary.

```dart
// lib/features/scenes/presentation/providers/video_player_provider.dart

// Inside PlayerState class
void syncBackgroundToActiveScene(BuildContext context) {
  final activeSceneId = state.activeScene?.id;
  if (activeSceneId == null) return;

  final router = GoRouter.of(context);
  final currentPath = router.routeInformationProvider.value.uri.path;
  
  // If we are not already on the details page for this scene
  if (!currentPath.contains('/scenes/scene/$activeSceneId')) {
    AppLogStore.instance.add(
      'PlayerState: syncing background to scene $activeSceneId',
      source: 'player_provider',
    );
    router.go('/scenes/scene/$activeSceneId');
  }
}
```

- [ ] **Step 2: Remove FullscreenPlayerPage routes from router.dart**
Remove the `/scenes/fullscreen/:id` route and any references to `FullscreenPlayerPage`.

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/providers/video_player_provider.dart lib/features/navigation/presentation/router.dart
git commit -m "refactor: remove fullscreen routes and add background sync helper"
```

---

### Task 2: Create GlobalFullscreenOverlay Widget

**Files:**
- Create: `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`

- [ ] **Step 1: Create the base widget with animation and state listening**
This widget will react to `isFullScreen` and show/hide accordingly.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/video_player_provider.dart';
import 'native_video_controls.dart';
import 'transformable_video_surface.dart';
import '../../../../core/utils/app_log_store.dart';

class GlobalFullscreenOverlay extends ConsumerStatefulWidget {
  const GlobalFullscreenOverlay({super.key});

  @override
  ConsumerState<GlobalFullscreenOverlay> createState() => _GlobalFullscreenOverlayState();
}

class _GlobalFullscreenOverlayState extends ConsumerState<GlobalFullscreenOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFullScreenChanged(bool isFullScreen) {
    if (isFullScreen && !_isVisible) {
      setState(() => _isVisible = true);
      _animationController.forward();
      _enterFullScreen();
    } else if (!isFullScreen && _isVisible) {
      _animationController.reverse().then((_) {
        if (mounted) setState(() => _isVisible = false);
      });
      _exitFullScreen();
    }
  }

  // Reuse logic from FullscreenPlayerPage for _enterFullScreen and _exitFullScreen
  // ...
}
```

- [ ] **Step 2: Implement Build method with PopScope and Video Surface**
Ensure it reuses `TransformableVideoSurface` and `NativeVideoControls`.

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart
git commit -m "feat: create GlobalFullscreenOverlay widget"
```

---

### Task 3: Integrate Overlay into ShellPage

**Files:**
- Modify: `lib/features/navigation/presentation/shell_page.dart`

- [ ] **Step 1: Wrap navigation shell in a Stack and add the overlay**
Remove any old logic that depended on `/fullscreen` paths.

```dart
// lib/features/navigation/presentation/shell_page.dart

Stack(
  children: [
    Positioned.fill(child: RepaintBoundary(child: navigationShell)),
    if (!hideMiniPlayer)
      const Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: MiniPlayer(),
      ),
    const GlobalFullscreenOverlay(),
  ],
)
```

- [ ] **Step 2: Add PopScope to handle Back button**
The `PopScope` should check if `isFullScreen` is true and call `setFullScreen(false)` after syncing background.

- [ ] **Step 3: Commit**

```bash
git add lib/features/navigation/presentation/shell_page.dart
git commit -m "feat: integrate GlobalFullscreenOverlay into ShellPage"
```

---

### Task 4: Update UI Triggers and Clean Up

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- Modify: `lib/features/scenes/presentation/widgets/tiktok_scenes_view.dart`

- [ ] **Step 1: Update SceneVideoPlayer to toggle isFullScreen instead of pushing routes**
Update `_toggleFullScreen` method.

- [ ] **Step 2: Update TiktokScenesView to toggle isFullScreen**
Update `_toggleFullScreen` and ensure handoff to global player happens correctly.

- [ ] **Step 3: Remove FullscreenPlayerPage class from scene_video_player.dart**
It is now replaced by `GlobalFullscreenOverlay`.

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/tiktok_scenes_view.dart
git commit -m "refactor: update UI triggers to use global overlay"
```

---

### Task 5: Verification and Final Polish

- [ ] **Step 1: Verify Fullscreen Transition**
  - Open a scene.
  - Tap Fullscreen.
  - Verify it slides up smoothly.
- [ ] **Step 2: Verify Play Next in Fullscreen**
  - Hit "Next" while in fullscreen.
  - Verify it plays the next video without flickering or exiting.
- [ ] **Step 3: Verify Exit Sync**
  - While in fullscreen on the "Next" video, hit the back button.
  - Verify you land on the Details page of the *current* video.
- [ ] **Step 4: Verify System UI/Orientation**
  - Verify status bars are hidden in fullscreen and restored on exit.
  - Verify orientation locks to landscape for landscape videos.
