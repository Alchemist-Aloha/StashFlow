# UI Enhancements and DLNA Casting Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate StashFlow's UI polish with skeleton loaders, modern video gestures, and DLNA casting support.

**Architecture:** 
- **Skeletons:** Standalone `Skeleton` utility + `SceneCardSkeleton` integrated into `ListPageScaffold`.
- **Gestures:** Enhanced `NativeVideoControls` with long-press speed-up and split-screen vertical swipes.
- **Casting:** `CastService` provider using `dlna_dart` with a Material bottom sheet for device selection.

**Tech Stack:** Flutter, Riverpod, dlna_dart, screen_brightness.

---

### Task 0: Project Setup & Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add required dependencies**
Add `dlna_dart: ^0.1.0` and `screen_brightness: ^2.0.0` to the dependencies section.

- [ ] **Step 2: Run flutter pub get**
Run: `flutter pub get`
Expected: SUCCESS

- [ ] **Step 3: Commit**
```bash
git add pubspec.yaml
git commit -m "chore: add dlna_dart and screen_brightness dependencies"
```

---

### Task 1: Core Skeleton Widget

**Files:**
- Create: `lib/core/presentation/widgets/skeleton.dart`

- [ ] **Step 1: Implement the base Skeleton widget**
Create a stateful widget that uses `ShaderMask` and a repeating `AnimationController` to animate a `LinearGradient`.

- [ ] **Step 2: Commit**
```bash
git add lib/core/presentation/widgets/skeleton.dart
git commit -m "feat: add base Skeleton widget with shimmer effect"
```

---

### Task 2: Scene Card Skeleton & Integration

**Files:**
- Create: `lib/features/scenes/presentation/widgets/scene_card_skeleton.dart`
- Modify: `lib/core/presentation/widgets/list_page_scaffold.dart`

- [ ] **Step 1: Create SceneCardSkeleton mimicking SceneCard layout**
Implement a widget that mirrors `SceneCard`'s layout (AspectRatio thumbnail + text blocks) using `Skeleton` children.

- [ ] **Step 2: Update ListPageScaffold to use skeletons**
Update the `loading` branch of the `AsyncValue.when` in `build` to render a grid/list of `SceneCardSkeleton` items instead of a simple spinner.

- [ ] **Step 3: Commit**
```bash
git add lib/features/scenes/presentation/widgets/scene_card_skeleton.dart lib/core/presentation/widgets/list_page_scaffold.dart
git commit -m "feat: integrate SceneCardSkeleton into ListPageScaffold"
```

---

### Task 3: Video Gesture Feedback Overlay

**Files:**
- Create: `lib/features/scenes/presentation/widgets/video_controls/player_gesture_feedback.dart`

- [ ] **Step 1: Implement centered feedback overlay**
Create a stateless widget that displays an icon and a label (e.g., "2.0x", "80%") with `AnimatedOpacity` and `AnimatedScale` for smooth feedback.

- [ ] **Step 2: Commit**
```bash
git add lib/features/scenes/presentation/widgets/video_controls/player_gesture_feedback.dart
git commit -m "feat: add PlayerGestureFeedback overlay widget"
```

---

### Task 4: Advanced Video Gestures

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/native_video_controls.dart`

- [ ] **Step 1: Add gesture state and screen_brightness support**
Add state variables for tracking current speed, volume/brightness feedback values, and visibility.

- [ ] **Step 2: Implement long-press speed-up**
Update `onLongPressStart`, `onLongPressMoveUpdate`, and `onLongPressEnd` to handle 2.0x+ speed-up and feedback.

- [ ] **Step 3: Implement side-swipes for Volume/Brightness**
Add logic to `onScaleUpdate` to detect single-pointer vertical swipes on the left (brightness) and right (volume) halves of the screen.

- [ ] **Step 4: Commit**
```bash
git add lib/features/scenes/presentation/widgets/native_video_controls.dart
git commit -m "feat: implement advanced video gestures and side-swipes"
```

---

### Task 5: DLNA Cast Service

**Files:**
- Create: `lib/core/data/services/cast_service.dart`

- [ ] **Step 1: Implement DLNA discovery service**
Create a Riverpod `NotifierProvider` that wraps `DLNAManager` to discover and list local devices.

- [ ] **Step 2: Commit**
```bash
git add lib/core/data/services/cast_service.dart
git commit -m "feat: add DLNA CastService for device discovery"
```

---

### Task 6: Cast Selection UI & Integration

**Files:**
- Create: `lib/features/scenes/presentation/widgets/video_controls/cast_selection_sheet.dart`
- Modify: `lib/features/scenes/presentation/widgets/video_controls/video_playback_controls.dart`

- [ ] **Step 1: Create CastSelectionSheet**
A Material bottom sheet that watches `castServiceProvider` and allows selecting a device to initiate playback.

- [ ] **Step 2: Add Cast button to VideoPlaybackControls**
Add an `IconButton` to the player controls that triggers the `CastSelectionSheet`.

- [ ] **Step 3: Commit**
```bash
git add lib/features/scenes/presentation/widgets/video_controls/cast_selection_sheet.dart lib/features/scenes/presentation/widgets/video_controls/video_playback_controls.dart
git commit -m "feat: implement cast selection UI and integration"
```
