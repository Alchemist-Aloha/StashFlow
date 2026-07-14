# Scene Metadata Visibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move technical scene metadata below Studio + Year, hide it by default with a local reveal button, and expose a persisted Interface Settings toggle.

**Architecture:** Add a single Riverpod `SharedPreferences`-backed boolean provider in the existing layout settings provider. `SceneDetailsPage` reads it for initial rendering and owns only the transient reveal state. `InterfaceSettingsPage` reads and saves the provider using its existing settings-card/switch pattern.

**Tech Stack:** Flutter, Riverpod, `SharedPreferences`, Flutter widget tests, generated Flutter localization.

## Global Constraints

- Do not add dependencies or new abstractions beyond the existing preference provider pattern.
- Keep technical metadata content unchanged.
- Default preference is hidden (`true`).
- Use existing Interface Settings cards and native Material controls.

### Task 1: Add the persisted preference

**Files:**
- Modify: `lib/core/presentation/providers/layout_settings_provider.dart`
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`
- Modify: `lib/l10n/app_en.arb`
- Test: existing scene/settings widget tests as the regression surface

- [ ] Add `HideSceneTechnicalMetadata` with storage key `hide_scene_technical_metadata`, default `true`.
- [ ] Load/save its value in `InterfaceSettingsPage`.
- [ ] Add localized title/subtitle and reveal-button strings.
- [ ] Run localization generation if required by the repository.

### Task 2: Reposition and reveal metadata

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`
- Test: `test/features/scenes/video_player_ui_test.dart`

- [ ] Initialize local reveal state from `hideSceneTechnicalMetadataProvider`.
- [ ] Render `_buildTechnicalMetadata` directly below `_buildStudioAndDate` when visible.
- [ ] Render a `Show metadata` button in that position when hidden.
- [ ] Keep the existing `scene_header_metadata` key on the visible metadata widget.

### Task 3: Verify behavior

**Files:**
- Test: `test/features/scenes/video_player_ui_test.dart`

- [ ] Assert default hidden state and reveal action.
- [ ] Assert preference-off renders metadata immediately.
- [ ] Run `dart format` on touched Dart files.
- [ ] Run focused Flutter tests and `flutter analyze`.
