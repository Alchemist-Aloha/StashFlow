# Fullscreen Aspect Ratio Orientation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement automatic orientation matching based on video aspect ratio in the fullscreen player, with a setting to toggle gravity-controlled (sensor-based) rotation.

**Architecture:** Extend the global player state to include a `videoGravityOrientation` preference. Update the `FullscreenPlayerPage` to calculate allowed orientations dynamically when entering fullscreen. Add a toggle in the playback settings for user control.

**Tech Stack:** Flutter, Riverpod, SharedPreferences.

---

### Task 1: Update Player State and Persistence

**Files:**
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`

- [ ] **Step 1: Add field to GlobalPlayerState**
Add `videoGravityOrientation` to `GlobalPlayerState` class and its `copyWith` method.

- [ ] **Step 2: Update PlayerState notifier**
Add the preference key, initialize it in `build()`, and add a setter.

- [ ] **Step 3: Commit state changes**

### Task 2: Add Localization for New Setting

**Files:**
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Add ARB keys**
Add keys for the new setting.

- [ ] **Step 2: Run l10n generation**

- [ ] **Step 3: Commit localization**

### Task 3: Update Playback Settings UI

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/playback_settings_page.dart`

- [ ] **Step 1: Add variable to state**
Add `_videoGravityOrientation` to `_PlaybackSettingsPageState`.

- [ ] **Step 2: Add SwitchListTile to UI**
Add the toggle to the "Playback behavior" section.

- [ ] **Step 3: Commit UI changes**

### Task 4: Implement Orientation Matching in Fullscreen

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`

- [ ] **Step 1: Update _enterFullScreen logic**
Calculate allowed orientations based on aspect ratio and gravity setting.

- [ ] **Step 2: Commit orientation implementation**

### Task 5: Verification

- [ ] **Step 1: Manual test landscape video**
- [ ] **Step 2: Manual test portrait video**
- [ ] **Step 3: Verify square video**
