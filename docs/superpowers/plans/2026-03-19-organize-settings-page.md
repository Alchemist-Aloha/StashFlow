# Settings Page Organization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the settings page into logical categories with a modern, consistent UI following Material 3 principles.

**Architecture:** 
- Use `SettingsSection` and `SettingsTile` patterns.
- Group settings into: **Connection**, **Playback**, **Display**, **Appearance**, and **Diagnostics**.
- Move **Connection Status** to a prominent header position.

**Tech Stack:** Flutter, Material 3, Riverpod.

---

### Task 1: Refactor SettingsPage Layout

**Files:**
- Modify: `lib/features/setup/presentation/settings_page.dart`

- [ ] **Step 1: Define section header and group settings**

Update the `build` method to use a more structured approach with headers and consistent spacing.

- [ ] **Step 2: Reorder sections**

1.  **Connection Status** (Header card)
2.  **Server Configuration** (URL, API Key, Clear button)
3.  **Playback Settings** (sceneStreams, Autoplay, Background Playback, PiP, Seek Interaction)
4.  **Display Settings** (Grid Layout, Video Debug Info)
5.  **Appearance** (Theme Mode)
6.  **Diagnostics** (Debug Log Viewer)

- [ ] **Step 3: Standardize text styles and padding**

Use `context.textTheme` and `AppTheme` constants for all labels and containers.

- [ ] **Step 4: Commit**

```bash
git add lib/features/setup/presentation/settings_page.dart
git commit -m "ui: reorganize settings page into logical sections"
```

---

### Task 2: Verification

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: PASS

- [ ] **Step 2: Visual verification**
- Ensure all previously available settings are still present and functional.
- Verify that saving server settings still works (auto-save on focus loss or manual submission).
- Verify toggles still update the provider state immediately.
