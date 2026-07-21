# Design Specifications

Categorized by domain. Last updated: 2026-07-21.
Total specs: 60

---
> **For agents:** Browse by category below. Each spec contains goal, scope, data-flow, and implementation guidance.

## 🧭 Navigation & Routing

### 1. 2026-03-20-navigation-discovery-playback

# Design Spec: Navigation, Discovery, and Playback Enhancements

## 1. Customizable Navigation
**Goal:** Add a global setting to toggle the visibility of floating random navigation buttons.

### Changes
- **Data Layer:**
  - Add `show_random_navigation` key to `SharedPreferences`.
  - Add `randomNavigationEnabledProvider` (Notifier) in `lib/features/setup/presentation/providers/navigation_customization_provider.dart` (or similar).
- **Settings UI:**
  - Add "Show Random Navigation Buttons" switch in `SettingsPage` under a "Navigation" or "Discovery" section.
- **Feature UI:**
  - Conditionally wrap `FloatingActionButton.small` in `ScenesPage`, `PerformersPage`, `StudiosPage`, `TagsPage`.
  - Conditionally wrap `FloatingActionButton.small` in `SceneDetailsPage`, `PerformerDetailsPage`, `StudioDetailsPage`, `TagDetailsPage`.

## 2. Advanced Discovery
**Goal:** Expand sorting and filtering options for Performers, Studios, and Tags to match the depth of the Scenes page.

### Changes
- **Performers:**
  - Add sorting by: Rating, Scene Count, Image Count, Gallery Count, Play Count, O-Counter, Created At, Updated At.
  - Add filtering by: Gender, Ethnicity, Country, Eye Color, Height, Measurements, Fake Tits, Penis Length, Circumcision, Career Start/End, Tattoos, Piercings, Tags, Scene/Marker/Image/Gallery/Play/O Count, Rating, Hair Color, Weight.
- **Studios:**
  - Add sorting by: Scene Count, Image Count, Performer Count, Group Count, Rating, Created At, Updated At.
  - Add filtering by: Parent Studio, Tags, Rating, Favorite, Scene/Image/Gallery/Group/Tag/Child Count, Organized, Created At, Updated At.
- **Tags:**
  - Add sorting by: Scene Count, Image Count, Performer Count, Marker Count, Parent/Child Count, Created At, Updated At.
  - Add filtering by: Favorite, Scene/Image/Gallery/Performer/Studio/Group/Marker/Parent/Child Count, Parent Tags, Child Tags, Created At, Updated At.

## 3. Playback Queue Fixes & Strategy
**Goal:** Fix "Play Next" logic and implement dynamic "Playlist" strategy using the current query sequence.

### Changes
- **PlaybackQueue Provider:**
  - Add `currentSequence` (List<Scene>) to state or a separate provider.
  - `getNextScene()` should check `currentSequence` if the manual queue is empty or the active scene is not in the manual queue.
- **Scenes Page:**
  - When a scene is tapped, update the `currentSequence` in `PlaybackQueue` with the currently loaded list of scenes from `sceneListProvider`.
- **Scene Details:**
  - Ensure "Play Next" correctly advances through the `currentSequence`.

## 4. Scene Rating
**Goal:** Implement the ability to rate scenes directly from the details page.

### Changes
- **UI:** Add a rating bar (5 stars or similar) on `SceneDetailsPage`.
- **Data:** Implement `updateSceneRating` in `SceneRepository` and a corresponding mutation.
- **State:** Invalidate `sceneDetailsProvider` and `sceneListProvider` after rating change.

## 5. Data Fetching Optimization
**Goal:** Reduce redundant API calls and fix "double-refresh" in Media Strips.

### Changes
- **Persistence:** Add `ref.keepAlive()` to `SceneList`, `PerformerList`, etc., to prevent disposal and re-fetch on simple navigation.
- **Stability:** Ensure `shuffledItems` in `MediaStrip` usage is stable (e.g., seeded by ID) or moved to a provider that doesn't rebuild unnecessarily.
- **Manual Refresh:** Ensure "Pull-to-refresh" still works to force update.

---

### 2. 2026-04-06-ui-navigation-gestures-customization

# Spec: UI, Navigation, and Gesture Customization

Enhance StashFlow's personalization by allowing users to tune the visual depth, choose their navigation layout, and discover content via physical gestures.

## 1. UI & Theming: "True Black" (AMOLED)

### Problem
Default dark themes often use dark grey surfaces (`#121212`). On OLED/AMOLED screens, pure black (`#000000`) saves more battery and provides infinite contrast.

### Solution
Add a "True Black" toggle that overrides the standard Material 3 dark surface colors.

### Implementation Details
- **Provider**: Create `TrueBlackEnabledProvider` in `lib/core/presentation/theme/true_black_provider.dart` using `Notifier` and `SharedPreferences`.
- **Theme Logic**: 
  - Update `AppTheme.buildTheme` (in `lib/core/presentation/theme/app_theme.dart`) to accept a `bool useTrueBlack`.
  - When `useTrueBlack` is true and `brightness` is `dark`:
    - Set `scaffoldBackgroundColor` to `Colors.black`.
    - Set `colorScheme.surface` and `colorScheme.surfaceContainer` variants to `Colors.black`.
    - Ensure `colorScheme.onSurface` and `colorScheme.outline` maintain readable contrast.
- **UI**: Add a `SwitchListTile` to `AppearanceSettingsPage` under a new "Advanced Theming" section.

## 2. Navigation: Customizable Tabs

### Problem
Not all users use all 5 tabs (Scenes, Performers, Studios, Tags, Galleries). Some might want to hide "Galleries" or move "Performers" to the first position.

### Solution
A dynamic navigation system where the order and visibility of the `NavigationBar`/`NavigationRail` destinations are stored in user preferences.

### Implementation Details
- **Data Model**: Define a `NavigationTab` enum or class with `id`, `label`, `icon`, and `defaultOrder`.
- **Provider**: Create `NavigationTabsProvider` in `lib/features/setup/presentation/providers/navigation_tabs_provider.dart`.
  - State: `List<NavigationTab>` representing the enabled tabs in their desired order.
  - Persist as a JSON string or comma-separated list of IDs in `SharedPreferences`.
- **ShellPage Integration**:
  - `ShellPage` (in `lib/features/navigation/presentation/shell_page.dart`) will watch `navigationTabsProvider`.
  - It will map the stored IDs to the actual `GoRouter` branch indices.
  - **Constraint**: Since `StatefulNavigationShell` indices are fixed by the router configuration, the `ShellPage` must map the "UI Index" (0, 1, 2...) to the "Branch Index" defined in `router.dart`.
- **UI**: Add a "Customize Navigation" sub-page or section in `InterfaceSettingsPage` allowing users to toggle visibility and drag-to-reorder tabs (using `ReorderableListView`).

## 3. Gestures: Shake to Random

### Problem
Users often want "serendipitous" discovery without looking for a specific button. 

### Solution
Implement a "Shake to Random" gesture that triggers the "Random" discovery action for the currently active tab.

### Implementation Details
- **Dependency**: Add `shake_gesture` to `pubspec.yaml`.
- **ShellPage Integration**:
  - Wrap the `Scaffold` or main `body` in `ShellPage` with a `ShakeGesture` widget.
  - **Logic**: On shake, check the `navigationShell.currentIndex`.
    - Map the index to the corresponding feature (Scenes -> jump to random scene, Performers -> jump to random performer, etc.).
    - Call the relevant `jumpToRandom()` method on the feature's list provider.
- **UI**: Add a "Shake to Discover" toggle in `InterfaceSettingsPage` under a "Gestures" section.

## 4. Testing Strategy
- **Unit Tests**: Verify `NavigationTabsProvider` correctly handles reordering and visibility toggles.
- **Widget Tests**: 
  - Verify `AppTheme` produces pure black colors when "True Black" is enabled.
  - Verify `ShellPage` renders the correct number of destinations based on visibility settings.
- **Integration Tests**: Simulate a shake gesture and verify that the page navigates to a random item.

---

### 3. 2026-04-13-desktop-web-ux

# Spec: Desktop and Web Experience Enhancements

**Date:** 2026-04-13
**Status:** Draft
**Topic:** Improving navigation, video control, and UI for desktop (Windows, Linux, macOS) and web without affecting the mobile-first experience.

## 1. Executive Summary
This document outlines the design for enhancing the StashFlow desktop and web experience. The goal is to provide desktop power-user features (keyboard shortcuts, mouse interactions, and enhanced UI feedback) while strictly maintaining the mobile-first design philosophy. These enhancements will be "layered" on top of the existing mobile UI, ensuring zero impact on touch-based usage.

## 2. Architecture & State Management

### 2.1 Capability-Based Logic
Instead of platform-specific checks, we will use a "capability-based" approach.
- **DesktopCapabilities Provider**: A Riverpod provider that determines if the current environment supports desktop-like interactions (e.g., keyboard, mouse wheel, hover).
- **Persistent Desktop State**: A `DesktopSettings` provider to store desktop-only preferences:
    - `volume`: 0.0 to 1.0 (defaults to 1.0).
    - `isMuted`: Boolean.
    - `lastWindowMode`: (Optional) Tracking window state.

### 2.2 Global Interaction Layer
- **Shortcut Manager**: A `Focus` and `CallbackShortcuts` wrapper in `ShellPage` to handle global app shortcuts.
- **Mouse Interaction Layer**: Use `MouseRegion` and `Listener` widgets to handle hover and scroll events without adding weight to mobile touch targets.

## 3. Navigation & Layout Enhancements

### 3.1 Keyboard Navigation
- **Tab Switching**: Keys `1`-`9` will switch between visible navigation tabs in the `NavigationRail` or `NavigationBar`.
- **Search Focus**: The `/` key will automatically focus the search bar (if present on the current page).

### 3.2 Visual Feedback (Hover)
- **Navigation Rail**: Subtle background highlights or color shifts when hovering over icons.
- **Interactive Elements**: Buttons and cards will gain hover states to provide immediate visual feedback for mouse users.

### 3.3 Scrolling
- **Consistent Friction**: Ensure mouse-wheel scrolling feels natural across all platforms, especially on Web where default scrolling can sometimes feel "choppy" in Flutter.

## 4. Video Control & UI

### 4.1 Enhanced Keyboard Shortcuts
Available only when the video player is active or in fullscreen:
- `Space`: Toggle Play/Pause.
- `f`: Toggle Fullscreen.
- `m`: Toggle Mute.
- `j` / `l`: Seek backward/forward 10 seconds.
- `Arrow Left` / `Arrow Right`: Seek backward/forward 5 seconds.
- `Arrow Up` / `Arrow Down`: Increase/Decrease volume by 5%.

### 4.2 Mouse Interactions
- **Volume Control**:
    - A volume slider will appear **only when hovering** over the volume icon.
    - **Mouse Wheel**: Scrolling over the video player will adjust the volume.
- **Double-Click**: Quickly toggle between windowed and fullscreen mode.

### 4.3 UI Feedback
- **Status Overlays**: Brief icons/labels (e.g., a volume bar or a "Muted" icon) will appear in the center of the video player when volume is adjusted or mute is toggled, providing clear feedback for non-touch interactions.

## 5. Web-Specific Considerations
- **Browser Fullscreen**: Use the `dart:html` (or `package:web`) API to trigger browser-level fullscreen where appropriate.
- **PWA Support**: Ensure keyboard shortcuts don't conflict with common browser shortcuts.

## 6. Testing Strategy
- **Unit Tests**: Verify `DesktopSettings` provider logic (volume clamping, mute toggling).
- **Widget Tests**: Mock keyboard events to ensure shortcuts trigger the correct navigation and player actions.
- **Manual Verification**: Test hover states and mouse-wheel volume adjustment on Windows, Linux, and Web targets.

---

### 4. 2026-05-05-global-player-overlay

# Design: Global Persistent Player Overlay

This design replaces the route-based fullscreen player with a persistent global overlay managed at the root of the application. This ensures that the player's lifecycle is decoupled from navigation, providing a more robust experience during "Play Next" transitions and cross-page navigation.

## Goals

- **Robustness:** Eliminate "controller not found" errors caused by route-based state handoffs.
- **Continuity:** Allow seamless playback while navigating the background app.
- **Predictable Navigation:** Ensure exiting fullscreen always lands the user on the correct scene details page.
- **Smooth Transitions:** Use a persistent widget to avoid flickering during `Hero` transitions or page swaps.

## Architecture

### 1. Root-Level Integration (`ShellPage`)

The `ShellPage` will be refactored to include a `Stack` at its root.

```dart
Stack(
  children: [
    // Layer 0: Main Navigation (GoRouter Shell)
    navigationShell, 
    
    // Layer 1: Mini Player (Visible when not in fullscreen and scene active)
    if (!isFullScreen && hasActiveScene) MiniPlayer(),

    // Layer 2: Global Fullscreen Overlay
    GlobalFullscreenOverlay(),
  ],
)
```

### 2. GlobalFullscreenOverlay Component

This new component will be a stateful widget that reacts to `playerStateProvider.isFullScreen`.

- **Visibility:** Uses `AnimatedVisibility` or a `Stack` entry with a `SlideTransition` to animate in/out.
- **State Source:** Consumes `playerStateProvider` for the `activeScene`, `player`, and `videoController`.
- **Orientation Control:** Manages `SystemChrome.setPreferredOrientations` locally based on its visibility state.
- **Back Gesture Handling:** Uses `PopScope` to intercept system back events when visible, triggering the exit flow instead of popping the background stack.

### 3. Navigation Synchronization

To maintain a logical history while allowing independent playback in fullscreen:

- **Playback in Fullscreen:** When "Next" is triggered, `PlayerState` updates the `activeScene` and `player` state. The background URL remains unchanged.
- **Exit Flow:**
    1. User triggers exit (Back button or UI toggle).
    2. The system compares the current URL with the `activeScene.id`.
    3. If they don't match, `context.go('/scenes/scene/${activeScene.id}')` is called to sync the background "silently" before the overlay disappears.
    4. `playerStateProvider.isFullScreen` is set to `false`, triggering the exit animation.

## UI/UX

- **Entry Animation:** Slide up from bottom or scale-up from the mini-player (if active).
- **Exit Animation:** Slide down to bottom or fade out.
- **Controls:** Reuses `NativeVideoControls` and `TransformableVideoSurface`.

## Success Criteria

1.  Entering fullscreen from any page (Details, TikTok, Search) works reliably.
2.  Playing the "Next" video while in fullscreen works without exiting or flickering.
3.  Exiting fullscreen from a "Next" video lands the user on the Details page for that *new* video.
4.  The system back gesture correctly closes the fullscreen overlay.

---

### 5. 2026-06-02-scene-saved-presets-panel

# Scene Saved Presets Panel Design

## Goal

Update the scenes saved presets panel so it feels consistent with the existing Material 3 sort panel: compact, structured, and action-oriented, while preserving the current save and load behavior.

## Current Problems

- The saved presets panel uses a near-fullscreen custom sheet, which feels heavier than the sort panel.
- The visual hierarchy is weaker than the sort panel: the current settings summary, saved presets list, and actions do not read as clearly separated sections.
- The presets list rows are functional but visually plain relative to the rest of the app's Material 3 surfaces.
- The panel styling is not obviously aligned with the sort panel's spacing, section labels, and action layout.

## Non-Goals

- No change to saved filter server behavior.
- No change to the save naming dialog workflow.
- No new preset editing, deleting, or reordering features.
- No cross-feature refactor of the sort panel.

## Reference Pattern

The sort panel in `ScenesPage` is the design reference:

- Content-driven bottom sheet height rather than a tall full-height panel.
- Clear header with title and lightweight action.
- Section labels using existing typography.
- Constrained scroll region for long content.
- Full-width primary action treatment where appropriate.
- Standard Material 3 controls and surfaces instead of custom framing.

## Proposed Layout

The saved presets panel should become a compact bottom sheet with bounded height and four vertical regions:

1. Header
   Title on the left, dismiss control on the right, and a save action that remains easy to find without dominating the sheet.

2. Current settings summary
   A compact tonal surface that summarizes what will be saved:
   - sort and direction
   - active filter count
   - search query when present

3. Saved presets section
   A labeled section containing a constrained scrollable list of presets.

4. Bottom spacing
   Standard bottom padding that respects the keyboard inset and safe area without turning the whole sheet into a full-screen surface.

## Component Behavior

### Header

- Use the same general structure as the sort panel: title-first, compact actions.
- Keep the save trigger in the header.
- Prefer a Material action presentation that feels native to the app rather than a custom toolbar treatment.
- Keep close behavior unchanged.

### Current Settings Summary

- Use a tonal Material surface (`surfaceVariant` or equivalent app token).
- Keep the copy short and functional.
- Use tighter chips than the current version so the summary reads as supporting context, not as the main feature.
- Omit the search chip when there is no query.

### Saved Presets List

- Use a section title and a constrained scrollable list similar in spirit to the sort chip region.
- Keep rows as standard Material list items with:
  - preset name as the title
  - condensed metadata as the subtitle
  - trailing load icon
- Sort order remains alphabetical by name.

### Empty State

- Keep the empty state inside the list region.
- Use compact spacing and neutral copy.
- Do not expand the sheet just to emphasize the empty state.

### Error State

- Keep the error state inside the list region.
- Preserve retry behavior.
- Use standard Material spacing and button styling.

### Save Dialog

- Preserve the current save dialog flow:
  - tap save action
  - prompt for preset name
  - save current settings to server
- No behavior changes beyond visual consistency if any dialog spacing tweaks are needed.

## Sizing

- Replace the current 90% height treatment with a content-driven sheet.
- Cap the presets list height so long preset collections scroll internally.
- Preserve keyboard-safe bottom padding for the naming dialog and any text input interaction.

## Styling

- Reuse existing typography from the scenes sort panel where possible:
  - larger title for the sheet heading
  - label-style section headers
  - standard body text for metadata
- Reuse the app's existing spacing tokens from `context.dimensions`.
- Keep corners and surfaces aligned with the app theme and Material 3 expectations.
- Avoid additional decorative containers or nested card-like framing.

## Implementation Scope

- Update `SceneSavedFilterDialog` layout and styling.
- Keep `SceneSavedFilterConfig`, repository behavior, and page-level integration unchanged unless required by the visual refactor.
- Leave server save/load semantics untouched.

## Test Plan

- Update the existing widget test for `SceneSavedFilterDialog` to keep covering the header save flow.
- Add assertions for the compact Material 3 presentation cues that matter to behavior and structure, for example:
  - the saved presets title
  - the presence of the constrained saved presets section
  - the save action remaining in the header
- Keep tests focused on stable structural behavior, not fragile pixel-level styling details.

## Risks

- Making the sheet too compact could make long preset names or dense metadata harder to scan.
- Over-mirroring the sort panel could hide the difference between "save current settings" and "load saved preset" if the summary and list are not visually separated enough.

## Mitigations

- Keep a distinct current settings summary surface above the presets list.
- Constrain list height instead of truncating the dataset.
- Keep the save action discoverable in the header.

## Acceptance Criteria

- The saved presets panel opens as a compact bottom sheet rather than a near-fullscreen panel.
- The panel visually aligns with the sort panel's Material 3 structure and spacing.
- The current settings summary remains visible and easy to scan.
- The presets list remains scrollable and load behavior is unchanged.
- Saving still requires naming the preset in a dialog and still saves to the server.
- Existing and updated saved presets tests pass.

---

### 6. 2026-07-10-scene-random-navigation

# Scene random navigation design

## Goal

Make all scene-random actions use one shared policy and one backend-random
resolution path.

The affected entry points are:

- `ScenesPage` random FAB
- `SceneDetailsPage` random FAB
- fullscreen scene player random button

## Required behavior

- Add a persisted setting that controls whether scene-random navigation
  respects the active scene filters.
- When the setting is `true`, random scene resolution must use the active
  scene search query, scene filter state, and organized filter state.
- When the setting is `false`, random scene resolution must ignore those
  active scene filters and resolve from the full scene set.
- Every scene-random action must resolve a true random scene from the backend.
  None of them may sample from the currently loaded client list.
- Random navigation must not rewrite or replace the current playback queue.
  The main queue should continue to represent the main scene list page state.
- Random navigation should avoid returning the currently open scene when an
  exclusion id is available.
- Existing empty-state behavior should stay consistent: if no random scene is
  available, show the existing no-random snackbar/message.

## Architecture

Reuse the existing `SceneList.getRandomScene(...)` backend-random path and put
one thin scene-specific Riverpod controller in front of it.

Responsibilities:

- read the persisted `respect active filter` setting
- call `SceneList.getRandomScene(...)` with the correct filter mode
- optionally exclude the current scene id
- return the resolved scene without mutating the playback queue

This controller is the only shared abstraction for scene-random UI. Do not add
a separate store, repository, service, or queue layer for this feature.

## Settings

Put the new toggle in `InterfaceSettingsPage`, adjacent to the existing random
navigation visibility setting because this is global navigation behavior, not
player-only behavior.

Persist it with the same shared-preferences provider pattern already used by
other interface settings so scene pages and player controls watch one source of
truth. Do not add a separate settings store just for this bool.

## UI changes

### Scene list page

Replace the current loaded-list sampling logic with the shared random
controller. The button should navigate to the resolved random scene and leave
the main playback queue untouched.

### Scene details page

Replace the current hardcoded `useCurrentFilter: true` behavior with the shared
controller so it honors the same toggle as the list page.

### Fullscreen player

Add a fullscreen-only random button to the scene player controls and wire it to
the shared random controller.

The button should:

- only appear for scene playback surfaces
- respect the global random-navigation visibility setting
- resolve the next scene through the shared controller
- navigate to the resolved scene without rewriting the main queue

## Data flow

1. User taps a scene-random button.
2. UI calls the shared scene-random controller.
3. Controller reads the persisted filter-respect setting.
4. Controller calls `SceneList.getRandomScene(...)` using either active scene
   filter state or an empty filter scope.
5. UI navigates to the resolved scene details route or fullscreen scene route
   as appropriate.
6. Playback queue state remains unchanged.

## Testing

- provider/store tests for the new setting default and persistence
- settings page test for the new toggle
- scene random-controller tests for filter-aware vs unfiltered resolution
- `ScenesPage` test that random navigation no longer samples the loaded list
- `SceneDetailsPage` test that random navigation follows the shared setting
- fullscreen controls test that the random button appears in fullscreen and
  triggers the provided callback
- regression coverage that random navigation does not modify the main playback
  queue

## Risks and constraints

- `SceneList.getRandomScene(...)` currently has a loaded-list fallback. Keep it
  only as an internal last-resort safeguard if the backend-random call fails;
  the intended UI path must remain backend-random.
- Fullscreen navigation must preserve the current playback ownership rules and
  must not introduce a second, player-owned queue concept.
- The feature should land as a small diff over existing scene navigation and
  preference patterns, not as a new generic navigation framework.

---

### 7. 2026-07-13-scene-details-responsive-header

# Scene Details Responsive Header Design

## Goal

Refine only the scene-details region from the title through the action buttons. The result should feel deliberate and premium on mobile and large screens without changing any control, callback, tooltip, platform guard, or content below the actions.

## Visual Direction

Use a **Soft Structuralist vertical hierarchy**: strong title typography followed by controls and compact technical metadata.

- Use semantic colors from the existing Material 3 theme so light, dark, and custom color schemes remain correct.
- Keep the title and Studio/Year identity block directly on the page background.
- Wrap only the control group and metadata chips in the existing section container so their rectangle uses the exact color, radius, padding, and margin used by Details.
- Do not add a nested control surface, border, or shadow.
- Do not use gradients, backdrop blur, grain, or decorative animation in this scrolling region.
- Keep the existing outlined icon glyphs and dependencies, but normalize the action icons to a precise visual size and consistent tonal treatment.

## Responsive Composition

Use `LayoutBuilder` at `_buildMainInfo`; the breakpoint follows the width allocated to the content, not the device type or orientation.

### Mobile: below 768 logical pixels

Use a full-width vertical composition:

1. Title.
2. Studio and year, 6 logical pixels below the title.
3. Rating/O and action controls, 16 logical pixels below the studio line.
4. Technical metadata chips, 16 logical pixels below the controls.

Below the outside identity block, stack rating/O and the five scene actions as two wrapping rows inside the shared section rectangle. Metadata chips follow inside the same rectangle. Use an 8-pixel rhythm and allow either row to wrap under text scaling. Nothing may scroll horizontally.

On tablet and desktop widths where both groups fit, place rating/O and all scene actions on one line. Rating/O stays left; the action group is pinned to the right edge. Use one responsive `Wrap` so the actions fall back below only when required to preserve 48-pixel touch targets.

### Large screen: 768 logical pixels and above

Use the same identity → controls → metadata order as mobile. Keep the larger title typography and the single-line control composition whenever both control groups fit.

The title must retain the dominant width. Long titles wrap naturally instead of compressing or pushing controls off-screen. The Details card remains full-width below the header card using the shared section margin.

## Typography and Rhythm

- Mobile title: existing `headlineSmall`, weight 700, slightly tightened letter spacing.
- Large title: existing `headlineMedium`, weight 700, slightly tightened letter spacing.
- Studio/year: existing theme typography with studio as the primary link and year at reduced emphasis.
- Metadata: retain the existing compact chips, using 6-pixel spacing and run spacing.
- Shared section padding: use the existing `AppTheme.spacingMedium` value without another control wrapper.
- Maintain a 48×48 logical-pixel minimum hit area for every icon action, including rating stars. Visual icons may remain smaller inside those targets.

Do not introduce a font package or modify the global theme for this isolated region.

## Interaction and Accessibility

All rating, O-counter, marker, info, download, edit, and delete behavior remains unchanged. Preserve existing keys, tooltips, semantics, focus behavior, ordering, and the non-web download guard.

Use native Material state layers for hover, focus, press, and disabled feedback. Do not add entrance or breakpoint animations: this header lives inside a scrolling page, and layout motion would add noise without clarifying state.

The layout must remain overflow-free at narrow widths and at 1.5× text scaling. Touch targets must not overlap when either control row wraps.

## Scope

Modify only `scene_details_page.dart` and its focused scene-details widget test. Reuse existing theme values and button widgets. Add no dependency, shared abstraction, global theme change, player change, or details-section redesign.

## Verification

Add stable keys for the identity and control groups, then verify:

- Mobile: identity is above the control group and both use the available width without overflow.
- Large screen: controls remain below the identity block and above metadata.
- Tablet/desktop controls: rating/O and actions share a line, with actions aligned right.
- Surface parity: the controls/metadata and Details cards use the exact same section-container color while title and Studio/Year remain outside.
- Text scaling: the mobile layout at 1.5× produces no overflow exceptions.
- Existing scene action, rating, O-counter, safe-area, and navigation tests continue to pass.

Run the focused scene-details widget tests and static analysis for the two changed Dart files.

---

### 8. 2026-07-14-keyboard-navigation-usability

# Keyboard Navigation Usability Design

## Goal

Improve desktop and web keyboard navigation, make shortcut handling resilient to conflicts and invalid saved data, and make keyboard bindings easy to discover and edit.

Mobile touch behavior and mobile hardware keyboards are out of scope.

## Existing System

StashFlow already stores one configurable `Keybind` per `KeybindAction` in `keybindsProvider`. `ShellPage`, `NativeVideoControls`, and `ImageFullscreenPage` create context-specific `CallbackShortcuts` maps from that state. The settings page captures a single key combination, while direct tab shortcuts (`Ctrl+1` through `Ctrl+9`) are currently hard-coded in `ShellPage`.

The existing design will be extended instead of replaced. This preserves saved preferences and avoids an unnecessary `Intent`/`Action` hierarchy.

## Shortcut Contexts

Actions belong to one of three contexts:

- Global navigation: active throughout the desktop/web shell.
- Video player: active only while the video controls own focus.
- Image viewer: active only while the fullscreen image viewer owns focus.

Video and image actions may reuse the same shortcut because those contexts cannot be active together. Global shortcuts overlap both viewer contexts, so assigning a viewer shortcut that conflicts with a global shortcut, or vice versa, moves the shortcut to the newly assigned action.

Global navigation shortcuts must not run while an editable text control has focus. This prevents accidental navigation and loss of in-progress input.

## Default Bindings

### Global navigation

| Action | Default |
| --- | --- |
| Back | `Alt+Left` |
| Next tab | `Ctrl+Tab` |
| Previous tab | `Ctrl+Shift+Tab` |
| Go to tabs 1–9 | `Ctrl+1` through `Ctrl+9` |

Adjacent-tab navigation wraps at the first and last visible tabs. Direct tab actions do nothing when their numbered visible tab does not exist.

### Video player

Existing playback, seeking, volume, mute, fullscreen, picture-in-picture, and speed defaults remain unchanged. Scene navigation changes to common media conventions:

| Action | Default |
| --- | --- |
| Next scene | `Shift+N` |
| Previous scene | `Shift+P` |

`Esc` remains the video close action. It is no longer also the global Back shortcut.

### Image viewer

| Action | Default |
| --- | --- |
| Previous image | `Left` |
| Next image | `Right` |
| First image | `Home` |
| Last image | `End` |
| Close viewer | `Esc` |

First/last navigation is a no-op when already at the corresponding endpoint or when no images are available.

## Persistence and Conflict Handling

The existing `desktop_keybinds` preference remains the storage format: a JSON object keyed by stable enum names. Newly introduced actions receive their defaults when absent from saved data. Existing user choices remain unchanged until reset.

Assignment is atomic. Before saving a new binding, the provider removes the same combination from any action whose context overlaps the target context, then assigns it to the target action and persists once. Unbinding stores an explicit null marker so it remains distinct from a newly introduced action that needs its default. Reset removes the preference and restores all current defaults.

Malformed individual entries fall back to that action's default without discarding other valid saved bindings. Unknown action names are ignored, allowing forward and backward preference compatibility.

## Binding Page

The page groups rows into Global Navigation, Video Player, and Image Viewer sections. Each row contains a localized action name and description, a readable shortcut chip, and accessible Edit and Unbind actions. Standard Flutter buttons and focus traversal provide `Tab`, `Shift+Tab`, `Enter`, and `Space` operation without custom focus code.

The capture dialog names the action and displays the captured combination. `Esc` cancels. Modifier-only events and bare `Tab` are not assignable. Browser and operating-system combinations that StashFlow cannot reliably receive, such as refresh, close-tab/window, and address-bar shortcuts, are rejected with localized feedback. Saving a conflicting shortcut reports which previous action was unbound.

Reset requires confirmation because it changes every customized shortcut.

All existing hard-coded English action labels and descriptions move to app localization resources.

## Runtime Handling

`ShellPage` builds all global bindings from provider state, including direct and adjacent tab navigation. It checks the primary focus before invoking global callbacks and returns without navigation when an `EditableText` owns focus.

`NativeVideoControls` and `ImageFullscreenPage` continue building only the bindings relevant to their own contexts. Image first/last callbacks use the existing page controller and image index state. Unsupported actions are not inserted into a context's shortcut map.

## Testing

Focused tests will cover:

- improved defaults and missing-action migration;
- per-entry recovery from malformed saved JSON;
- atomic conflict moves across overlapping contexts and permitted reuse across video/image contexts;
- unbind and reset persistence;
- direct and wrapping tab navigation;
- suppression of global shortcuts while editing text;
- image first/last navigation and endpoint no-ops;
- capture-dialog cancellation, invalid-key handling, conflict feedback, reset confirmation, and keyboard focus traversal;
- localized binding-page rendering.

Tests will be written before each behavior change and observed failing for the expected reason before implementation.

## Documentation

`docs/wiki/Desktop-Usage-Key-Bindings.md` will be updated with the complete defaults, contexts, focus behavior, customization workflow, conflict rules, reset behavior, and desktop/web scope.

---

## 🧪 Testing & Stability

### 1. 2026-03-21-testing-and-stability

# Design Spec: Testing and Stability Enhancements (2026-03-21)

## Overview
This document outlines a hybrid testing strategy to increase code coverage and stability for StashFlow. The goal is to move from ad-hoc testing to a structured, reusable framework using manual mocks and shared utilities.

## Core Strategy: Hybrid Testing (Approach C)
We will implement a central testing foundation to minimize boilerplate while maintaining focused, isolated tests for each module.

### 1. Shared Test Utilities (`test/helpers/test_helpers.dart`)
A central repository of helpers to ensure consistency across all widget tests.

- **Manual Mock Factory:** Classes for `MockPerformerRepository`, `MockStudioRepository`, `MockTagRepository`, and `MockSceneRepository`.
    - Support for `withData`, `withEmpty`, and `withError` states via constructor or methods.
    - Default implementations for all interface methods to avoid `UnimplementedError`.
- **`pumpTestWidget` Helper:** 
    - Wraps components in `ProviderScope`.
    - Handles common overrides (SharedPreferences, GraphQL client, etc.).
    - Provides a standard `MaterialApp` with the app theme.
    - Simplifies complex setup like GoRouter or Riverpod state initialization.
- **Custom Finders:**
    - `find.loadingSpinner()`
    - `find.errorView(message)`
    - `find.retryButton()`

### 2. Feature-Focused Widget Tests
Dedicated tests for core modules using the shared utilities.

#### Performers, Studios, and Tags (`test/features/...`)
- **List View:** Verify that data from the mock repository is rendered correctly in cards.
- **Search/Filter:** 
    - Verify that typing in search updates the provider query.
    - Test "Favorites only" toggle and its effect on the rendered list.
- **Sorting:** Test that the sort bottom sheet updates the sort configuration and triggers a list refresh.
- **Navigation:** Ensure tapping a card triggers the correct `GoRouter` path.

#### Video Player & Scenes (`test/features/scenes/video_player_ui_test.dart`)
- **Overlays:** Verify play/pause, seek, and volume control visibility and interaction.
- **State Feedback:** Test that loading spinners appear during buffering and disappear when playback starts.
- **Rating:** Test the rating widget's interaction and ensure it calls the repository's `updateSceneRating` method.
- **Queue:** Verify "Play Next" and "Previous" buttons navigate through the `playbackQueueProvider`.

### 3. Global UI States (`test/global_ui_states_test.dart`)
A safety-net test that systematically verifies error and empty states across major entry points.

- **Empty State:** Inject empty lists into all repositories and verify consistent "No items found" messaging.
- **Error State:** Inject repository failures and verify `ErrorStateView` appears on all major pages.
- **Retry Interaction:** Verify that clicking "Retry" on an error view triggers a refresh call to the relevant provider/repository.

### 4. Fullscreen Mode (`test/features/scenes/fullscreen_mode_test.dart`)
Tests focused on the high-impact fullscreen transition.

- **State Transition:** Verify that entering `/fullscreen/:id` sets `fullScreenModeProvider` to true.
- **Layout:** Verify that the UI hides bottom navigation and expands the video container.
- **Gestures:** Test the custom swipe-back/pop behavior to return to standard view.
- **Recovery:** Ensure popping the fullscreen route resets the global state correctly.

## Technical Implementation Details
- **Mocks:** Manual classes implementing the repository interfaces.
- **Riverpod:** Extensive use of `ProviderScope` overrides in tests.
- **Navigation:** Mocking or using `GoRouter` in testing mode to verify navigation without side effects.

## Success Criteria
- [ ] Shared test utilities are implemented and used by at least 3 feature modules.
- [ ] Performers, Studios, and Tags have verified list, search, and filter widget tests.
- [ ] Global error and empty states are verified on all main pages.
- [ ] Fullscreen mode navigation and state recovery are verified.
- [ ] Video player controls and rating interactions are verified.

---

## 🎨 UI & Design System

### 1. 2026-03-23-color-scheme-selector

# Design Spec: Color Scheme Selector

**Date:** 2026-03-23
**Status:** Approved
**Topic:** Material 3 Color Scheme Selector in Settings

## 1. Objective
Add a color scheme selector to the StashFlow settings page, allowing users to choose from a set of preset Material 3 seed colors or provide a custom Hex value. The application theme should dynamically update based on the selected seed color.

## 2. Architecture & State Management

### 2.1. Theme Color Provider
A new provider will be created to manage the application's seed color.

- **File:** `lib/core/presentation/theme/theme_color_provider.dart`
- **Provider:** `appThemeColorProvider` (a `NotifierProvider<AppThemeColorNotifier, Color>`)
- **State:** The current `Color` used as the seed for `ColorScheme.fromSeed`.
- **Default Value:** `0xFF0F766E` (Teal)
- **Persistence:** 
    - **Key:** `app_theme_seed_color`
    - **Storage:** `SharedPreferences` (stored as an integer or hex string)

### 2.2. Theme Integration
The `AppTheme` class will be refactored to accept a seed color.

- **File:** `lib/core/presentation/theme/app_theme.dart`
- **Change:** Modify `_buildTheme(Brightness brightness)` to take an additional `Color seedColor` parameter.
- **Change:** Update `lightTheme` and `darkTheme` static members to be methods or handled dynamically in `MyApp`.

### 2.3. Root Application Update
`MyApp` will watch the new provider and rebuild when the theme color changes.

- **File:** `lib/main.dart`
- **Change:** Watch `appThemeColorProvider` in `MyApp.build`.
- **Change:** Pass the current seed color to `AppTheme.buildTheme(Brightness.light/dark, seedColor)`.

## 3. UI Design

### 3.1. Settings Page Integration
The selector will be added to the "Appearance" section of the `SettingsPage`.

- **Components:**
    - **Horizontal Swatch Strip:** A scrollable row of circular color swatches.
    - **Presets:** Teal (`0xFF0F766E`), Blue (`0xFF2196F3`), Purple (`0xFF9C27B0`), Orange (`0xFFFF9800`), Red (`0xFFF44336`), Green (`0xFF4CAF50`), Grey (`0xFF9E9E9E`).
    - **Custom Swatch:** A final swatch with `Icons.palette_outlined`.
    - **Selection Indicator:** Active color will be highlighted (e.g., border or checkmark).
    - **Hex Input:** A `TextField` that appears only when "Custom" is active.
        - Label: "Custom Hex Color"
        - Hint: "#0F766E"
        - Validation: Validates for 6 or 8 character hex strings.

## 4. Testing & Validation
- Verify that selecting a preset color immediately updates the entire app UI.
- Verify that entering a valid Hex code updates the theme.
- Verify that invalid Hex codes do not crash the app and show an error message.
- Verify that the selected color persists after app restart.
- Verify that both Light and Dark modes respect the new seed color.

---

### 2. 2026-03-25-tablet-optimization

# Tablet Optimization Design Spec

## Goal
Optimize StashFlow for tablet devices (>= 600px width) by introducing an adaptive navigation sidebar and a 3-column grid layout, while preserving the existing mobile UI for smaller screens.

## Architecture & Utilities

### Breakpoints
We will define a centralized `Responsive` utility class in `lib/core/utils/responsive.dart`:
- **Mobile**: < 600px
- **Tablet**: >= 600px and < 1200px
- **Desktop**: >= 1200px (future-proofing)

### Design Tokens
New spacing and layout constants will be added to `AppTheme` if necessary to handle tablet-specific padding.

## Components

### Adaptive Navigation (`ShellPage`)
The `ShellPage` will be updated to use a conditional layout:
- **Mobile**: Standard `Scaffold` with `bottomNavigationBar`.
- **Tablet/Desktop**: `Scaffold` where the `body` is a `Row` containing a `NavigationRail` on the left and the `StatefulNavigationShell` on the right.
- **State Management**: Both layouts will share the same `navigationShell.currentIndex` and `onDestinationSelected` logic.

### Dynamic Grid (`ListPageScaffold`)
The `ListPageScaffold` will be enhanced to support responsive grid delegates:
- **Grid Column Count**:
  - < 600px: 2 columns
  - >= 600px: 3 columns
- **Implementation**: The `ListPageScaffold` will automatically calculate `crossAxisCount` if a `useResponsiveGrid` flag is set, or we will update the `gridDelegate` passed from pages like `ScenesPage`.

### Page-Specific Updates
- **ScenesPage**: Update `_onScroll` prefetching logic and `gridDelegate` to use the responsive column count.
- **PerformerMediaGridPage, StudioMediaGridPage, TagMediaGridPage**: Similar updates to ensure 3-column grids on tablets.

## Data Flow
- Navigation state remains managed by `go_router`'s `StatefulNavigationShell`.
- UI responsiveness is driven by `MediaQuery` and the new `Responsive` utility.

## Testing Strategy
- **Widget Tests**: Verify that `NavigationRail` is present at 800px width and `NavigationBar` is present at 400px width.
- **Integration Tests**: Ensure navigation still works correctly when switching between branches on both layouts.
- **Visual Verification**: Manual check of grid layouts on tablet emulators/simulators.

---

### 3. 2026-04-28-global-ui-scaling

# Design Spec: Global UI Scaling System

## 1. Problem Statement
The current application uses a mix of hardcoded literals and static constants for UI sizing (padding, spacing, component dimensions). While a font scaling factor exists, it does not affect the overall layout spacing or component sizes, leading to inconsistent UI density when font sizes are changed.

## 2. Goals
- Consolidate font and element scaling into a single "Global UI Scale" factor.
- Move all spacing and component dimensions into the `Theme` via a `ThemeExtension`.
- Provide a single slider in Appearance Settings to control this factor.
- Ensure the app layout remains proportional across different scale settings.

## 3. Proposed Changes

### 3.1 State Management
- **Provider:** Rename `AppFontSize` to `AppGlobalScale` in `lib/core/presentation/providers/layout_settings_provider.dart`.
- **Storage Key:** Change `app_font_size_factor` to `app_global_scale_factor` (with migration/fallback).
- **Range:** 0.8x to 1.5x (default 1.0x).

### 3.2 Theme System (`lib/core/presentation/theme/app_theme.dart`)
- **AppDimensions Extension:** Expand to include:
    - `spacingSmall`, `spacingMedium`, `spacingLarge`
    - `performerAvatarSize`
    - `buttonHeight`
    - `inputPadding`
- **Theme Builder:** Update `AppTheme.buildTheme` to:
    1. Accept `scaleFactor` (replacing `fontSizeFactor`).
    2. Apply `scaleFactor` to all `AppDimensions` fields.
    3. Update `FilledButtonThemeData`, `OutlinedButtonThemeData`, and `TextButtonThemeData` to use scaled padding and heights from `AppDimensions`.
    4. Update `InputDecorationThemeData` to use scaled `contentPadding`.
    5. Maintain fixed `borderRadius` and `borderSide` widths.

### 3.3 UI Components
- **Migration:** Systematically replace hardcoded `EdgeInsets.all(8)`, `SizedBox(height: 16)`, etc., with `context.dimensions.spacingSmall` and `context.dimensions.spacingMedium`.
- **Icons:** Ensure icons in major components (Buttons, ListTiles) scale using the global factor where appropriate.

### 3.4 Settings UI (`lib/features/setup/presentation/pages/settings/appearance_settings_page.dart`)
- Rename "Global Font Size" section to "Global UI Scale".
- Update the slider to watch and write to `appGlobalScaleProvider`.
- Update labels and tooltips to reflect that this scales the entire UI.

## 4. Implementation Plan (Summary)
1. **Infrastructure:** Update providers and theme extensions.
2. **Theme Integration:** Wire the scale factor into Material component themes.
3. **Settings Update:** Implement the new slider and verify live-reloading.
4. **Refactoring:** Perform surgical replacements of hardcoded sizes in core widgets and pages.

## 5. Success Criteria
- Changing the slider results in an immediate, proportional scaling of both text and surrounding spacing.
- The UI does not "break" or overlap at 1.5x scale.
- No hardcoded spacing literals remain in the primary feature directories (`lib/features/`).

---

### 4. 2026-04-28-ui-enhancements-casting

# Design Spec: UI Enhancements and DLNA Casting

**Date:** 2026-04-28
**Topic:** Improving StashFlow's UI polish and feature set by porting high-impact patterns from PiliPlus.

## 1. Overview
The goal is to elevate StashFlow's user experience in three key areas:
1.  **Perceived Performance:** Replace generic loading indicators with shimmering skeleton loaders that mirror the actual content layout.
2.  **Video Interaction:** Add modern video gestures (long-press speed-up and vertical side-swipes for volume/brightness) with polished visual feedback.
3.  **Connectivity:** Implement DLNA/UPnP casting to allow users to play content on Smart TVs and media players.

## 2. Architecture & Components

### 2.1 Skeleton Loading System
A unified shimmering system to reduce perceived wait times.

- **`Skeleton` Widget:** A core utility widget using `ShaderMask` and `AnimationController` to create a sweeping gradient effect over its child.
- **`SceneCardSkeleton`:** A dedicated skeleton widget that perfectly mirrors the structure of `SceneCard` (Thumbnail + Metadata + Icons). It will support both Grid and List layouts.
- **Integration:** `ListPageScaffold` will be updated to render a placeholder list/grid of skeletons when `provider.isLoading` is true, ensuring a seamless transition to the actual data.

### 2.2 Advanced Video Gestures
Enhanced control for the `NativeVideoControls` widget.

- **Long-Press Speed-Up:**
    - Initial `onLongPressStart`: Sets playback speed to 2.0x.
    - `onLongPressMoveUpdate`: If dragging upwards (negative `dy`), linearly increases speed from 2.0x to 10.0x.
    - `onLongPressEnd`: Resets speed to the original value (usually 1.0x).
- **Vertical Side-Swipes:**
    - Split the screen into two vertical zones.
    - **Left Zone:** Vertical drag adjusts screen brightness (via `screen_brightness` package).
    - **Right Zone:** Vertical drag adjusts volume (via `playerStateProvider` or native volume APIs).
- **Gesture Feedback Overlay:**
    - A centralized overlay widget in `NativeVideoControls`.
    - Uses `AnimatedScale` and `AnimatedOpacity` to show a large, semi-transparent icon and percentage/speed label in the center of the screen when gestures are active.

### 2.3 DLNA Casting
Native discovery and playback on external devices.

- **`CastService` (Riverpod):** Manages device discovery and life-cycle using the `dlna_dart` package.
- **`CastSelectionSheet`:** A Material bottom sheet triggered from the video player that lists discovered DLNA devices.
- **Playback Control:** When a device is selected, the local player pauses, and the video URL (with auth headers) is sent to the target device via UPnP `SetAVTransportURI` and `Play` commands.

## 3. Data Flow & State Management

- **Gestures:** Local state within `NativeVideoControls` will handle the real-time feedback (speed/volume levels). Permanent changes (volume) will be synced back to the global `DesktopSettings` or `PlayerState`.
- **Casting:** `CastService` will maintain an `AsyncValue<List<DLNADevice>>` of discovered devices. Selection state will be managed globally to allow the mini-player to reflect that the content is being cast.

## 4. Success Criteria
- [ ] `ScenesPage` displays a shimmering grid/list during initial load.
- [ ] Long-pressing a video in `NativeVideoControls` speeds it up to 2x+, with a visual "2.0x" indicator.
- [ ] Vertical swiping on the left/right sides of the video player adjusts brightness/volume with smooth visual feedback.
- [ ] "Cast" button appears in video controls and successfully discovers local DLNA devices.
- [ ] Video playback can be started on a DLNA-compatible device.

## 5. Testing Strategy
- **Unit Tests:** Verify `Skeleton` animation logic and `CastService` device discovery filtering.
- **Widget Tests:** Ensure `SceneCardSkeleton` renders correctly in various layout modes.
- **Manual Verification:** Test gesture sensitivity and visual feedback across different screen sizes and orientations. Validate DLNA casting with real hardware.

---

### 5. 2026-07-07-settings-ui-unification

# Design Spec: Settings UI Unification

**Date:** 2026-07-07
**Status:** Draft
**Topic:** Unify settings page presentation without changing routes or behavior

## 1. Problem Statement

The settings experience already has separate routes and a shared top-level shell, but the pages do not read as one system. Today they diverge in:

- Page padding and max-width usage
- Section spacing and header rhythm
- Card and panel treatment
- Divider usage inside grouped controls
- Loading and empty-state presentation
- Hub-card styling versus detail-page styling

This creates a fragmented UI even though the information architecture is already settled. The goal is to unify the visual system without reopening routing, settings semantics, or category structure.

## 2. Scope

### In scope

- Shared presentation primitives for settings pages
- Consistent layout rhythm across the settings hub and detail pages
- Consistent panel styling for grouped controls and action rows
- Shared loading and empty-state presentation for settings surfaces
- Light visual alignment for `ServerSettingsPage` while preserving its current list/FAB behavior

### Out of scope

- Route changes
- Settings category changes
- New settings behavior or persistence changes
- Reorganizing server settings into a form-style page
- New navigation patterns such as sidebars or split-view settings

## 3. Goals

1. Make the settings hub and detail pages feel like one UI family.
2. Centralize the presentation rules in shared widgets instead of repeating styling page by page.
3. Keep the diff focused on presentation, with minimal risk to behavior.

## 4. Non-Goals

- Replacing native Material controls with custom controls
- Refactoring providers, persistence, or routing
- Combining multiple settings pages into fewer screens

## 5. Proposed Solution

Strengthen the existing settings presentation seam in `lib/features/setup/presentation/widgets/settings_page_shell.dart` and migrate the settings pages onto the stronger shared layer.

The design keeps `SettingsPageShell` as the route frame and extends it with reusable layout primitives:

- `SettingsPageBody`
  - Owns standard page padding, scroll treatment, width constraint, and top-to-bottom section rhythm.
- `SettingsSectionHeader`
  - Owns title/subtitle spacing and typography for all settings sections.
- `SettingsPanelCard`
  - Owns the shared surface treatment for grouped controls and action content.
- `SettingsPanelGroup`
  - Owns vertical stacking and divider rhythm for settings rows inside a panel.
- `SettingsLoadingState`
  - Standard loading presentation for settings pages.
- `SettingsEmptyState`
  - Standard empty-state presentation for settings pages that need one.

`SettingsSectionCard` remains the section-level composition point, but it will be upgraded to render its content inside the shared panel surface by default. `SettingsActionCard` will be visually aligned to that same panel system so hub actions and detail content no longer feel unrelated.

## 6. Page-Level Migration Rules

### Hub page

- Keep the existing categories and routes.
- Use the shared page body and section panel treatment.
- Update `SettingsActionCard` styling to visually match detail-page panels.

### Detail pages

The following pages move to the shared body/panel/group rhythm:

- `AppearanceSettingsPage`
- `PlaybackSettingsPage`
- `InterfaceSettingsPage`
- `StorageSettingsPage`
- `SecuritySettingsPage`
- `DeveloperSettingsPage`
- `SupportSettingsPage`
- `KeybindSettingsPage`
- `NavigationCustomizationPage`

These pages will continue to use native controls such as `SwitchListTile`, `SegmentedButton`, `DropdownButton`, and `ListTile`, but those controls will sit inside consistent shared section containers.

### Server settings

- Keep the current profile list and floating action button flow.
- Keep the current bottom-sheet editing flow.
- Apply the shared page body spacing.
- Align the empty state with the shared settings visual language.
- Do not force the profile list into the same grouped-control panel structure as the other settings pages.

## 7. Data Flow and Behavior

No settings behavior changes are required.

- Existing providers remain the state seam.
- Existing routes remain unchanged.
- Existing save/load timing remains unchanged.
- Existing server-profile interactions remain unchanged.

This is intentionally a presentation refactor with no new settings model or controller layer.

## 8. Testing Strategy

Use a small TDD path centered on the new shared presentation seam.

1. Add a focused widget test for the shared settings primitives.
   - Verify a section renders a shared panel surface and header rhythm.
2. Migrate one representative settings page first.
   - Recommended representative page: `AppearanceSettingsPage` because it exercises grouped controls, sliders, and segmented controls.
3. Run the representative page test and confirm the failure is due to the expected structural change before finishing the implementation.
4. Migrate the remaining pages.
5. Adjust existing settings page tests only where the widget tree shape changes.

Verification ladder:

- Focused settings widget tests
- `flutter analyze`
- `git diff --check`

In this environment, prefer the existing `HOME=/tmp` workaround if Flutter tries to write outside the workspace.

## 9. Risks and Mitigations

### Risk: tree-shape churn breaks brittle widget tests

Mitigation:

- Keep existing semantics and labels unchanged.
- Limit new wrappers to the shared settings seam.
- Update only structure-sensitive tests.

### Risk: server settings gets over-normalized and loses its better list behavior

Mitigation:

- Treat `ServerSettingsPage` as the explicit exception.
- Align spacing and empty state only.

### Risk: helper widgets become another abstraction layer that pages bypass

Mitigation:

- Put the shared widgets next to the existing shell.
- Migrate all current settings pages in the same change.
- Keep the API small and presentation-only.

## 10. Success Criteria

- The settings hub and detail pages share the same spacing and panel language.
- Most settings page styling is owned by shared widgets, not page-local containers.
- `ServerSettingsPage` still behaves exactly as it does today.
- Existing settings behavior remains unchanged.

---

## 💾 Data & Performance

### 1. 2026-03-23-performance-improvement

# Performance Improvement Design

Goal: Optimize GraphQL fetch policies for better caching behavior.

- findX (list) methods -> FetchPolicy.cacheAndNetwork
- detail methods -> FetchPolicy.cacheFirst

Exceptions:
- Random queries -> FetchPolicy.noCache

---

### 2. 2026-03-29-media-feature

# Design Spec: Media Feature (Image Waterfall & Gallery Folder View)

Date: 2026-03-29
Status: Draft
Author: Gemini CLI

## 1. Overview
The goal is to implement a unified "Media" experience in StashFlow, replacing the "Settings" tab in the bottom navigation. This feature provides two distinct views for media: a true staggered "Waterfall" grid for individual Images and a "Folder-like" grid for Galleries.

## 2. Requirements & User Experience

### 2.1 Navigation & Routing
- **Bottom Navigation:** Replace "Settings" with "Media" (Index 4).
- **Sub-routing (Route-Driven):** 
  - `/media/images`: Waterfall view of all images.
  - `/media/galleries`: Folder-like view of all galleries.
- **Toggle:** A UI toggle in the `AppBar` or `sortBar` to switch between `/media/images` and `/media/galleries`.
  - **Persistence:** The toggle state (last active view) will be persisted via `SharedPreferences`.
- **Drill-down:** Clicking a Gallery card in the folder view navigates to `/media/images?gallery_id={id}`.
- **Settings:** Move the "Settings" button to the top-right of the `AppBar` (integrated via `ListPageScaffold`).

### 2.2 Image Waterfall View
- **Layout:** True staggered grid (Pinterest-style) using `MasonryGridView`.
  - **Responsiveness:** Use 2 columns on mobile (adaptive to 1 if extremely narrow) and 3-5 columns on larger screens/tablets.
- **Interactions:**
  - Tapping an image opens the Fullscreen Viewer.
  - Independent filtering and sorting from Galleries.
- **Performance:**
  - `CachedNetworkImage` for all thumbnails.
  - Pre-calculated aspect ratio placeholders to prevent layout shifts.

### 2.3 Gallery Folder View
- **Layout:** Uniform grid of folder cards.
- **Details:** Cards display the gallery title and a badge with the `image_count`.
- **Interactions:** Independent filtering and sorting from Images.

### 2.4 Fullscreen Image Viewer
- **Navigation:** Vertical `PageView` (swipe up/down) mirroring the waterfall's sort/filter order.
- **Pinch-to-Zoom:** Using `InteractiveViewer` for each image.
- **UI Overlay (Hybrid):**
  - Persistent back button and index indicator (e.g., `5 / 100`).
  - Full metadata available via a "More Info" button or tap-to-reveal.
- **Pre-fetching:** Background loading of the next/previous images in the sequence.

## 3. Architecture & Data Flow

### 3.1 Domain Layer
- **Image Entity:** `id`, `title`, `rating100`, `date`, `urls` (a list of source strings from GraphQL), `thumbnailPath`, `previewPath`, `imagePath`.
- **Repository Interface:** `ImageRepository` with `findImages(filter, sort, page)`.

### 3.2 Data Layer
- **GraphQL Implementation:** `GraphQLImageRepository` using the `findImages` query from the Stash GraphQL schema.
- **Independent State:** Separate `Notifier` classes for `ImageListFilter` and `GalleryListFilter`.

### 3.3 Presentation Layer
- **Providers:**
  - `ImageListProvider`: Fetches images based on current `ImageFilterState`.
  - `GalleryListProvider`: Fetches galleries based on current `GalleryFilterState`.
- **Widgets:**
  - `MediaPage`: A shell or wrapper that handles the route logic.
  - `ImageWaterfallView`: The staggered grid implementation.
  - `GalleryFolderView`: The uniform grid implementation.
  - `FullscreenViewerPage`: The vertical `PageView` implementation.

## 4. Implementation Details

### 4.1 Staggered Grid
- Package: `flutter_staggered_grid_view`.
- Use `SliverMasonryGrid` for smooth integration with `ListPageScaffold`'s scrolling.

### 4.2 Vertical Navigation
- Use `PageView` with `scrollDirection: Axis.vertical`.
- Ensure the controller index is synced with the tapped image from the grid.

### 4.3 Filter Sync/Isolation
- Filters are isolated. Navigating from a gallery applies a temporary `gallery_id` override to the `ImageListProvider`.

## 5. Verification Plan
- [ ] Verify tab switching between Scenes, Performers, Studios, Tags, and Media.
- [ ] Verify toggle button between Image and Gallery views.
- [ ] Verify staggered grid layout with varying aspect ratios.
- [ ] Verify vertical swipe navigation in fullscreen mode.
- [ ] Verify pinch-to-zoom functionality.
- [ ] Verify Settings button is accessible in the top-right.
- [ ] Verify independent sorting/filtering for Images and Galleries.

---

### 3. 2026-03-31-codebase-restructuring

# Design Spec: Core-Driven Codebase Restructuring

**Date:** 2026-03-31
**Status:** Approved
**Goal:** Reduce Technical Debt & Increase Test Coverage

## 1. Overview
The StashFlow codebase currently suffers from large files, repetitive boilerplate, and mixed concerns (e.g., cross-feature logic in repositories). This design proposes a **Core-Driven Standardization** approach, focusing on building a robust foundational layer in `lib/core` to simplify and unify feature implementations. Include detailed docstring along with the code generated/ modified.

## 2. Repository & Data Source Abstraction
We will introduce a `BaseRepository` class in `lib/core/data/graphql` to centralize GraphQL result handling and error mapping.

### Key Components:
- **`BaseRepository`**:
  - Handles `QueryResult` validation (checking `hasException`).
  - Maps GraphQL errors to domain-specific exceptions.
  - Standardizes the use of `graphql_codegen` generated models and documents.
- **`DataSource` Pattern (Optional)**: If repositories remain too large, extract raw GraphQL calls into feature-specific `DataSource` classes.

## 3. Standardized UI Components
Extract common UI patterns into reusable widgets in `lib/core/presentation/widgets`.

### Key Components:
- **`MediaCard`**: A configurable grid/list item widget for scenes, performers, studios, etc.
- **`MediaHeader`**: A consistent header for details pages (title, studio, metadata chips).
- **`AttributeChipList`**: A generic scrollable or wrapped list of chips (tags, performers, genres).
- **`ListPageScaffold` Enhancement**: Simplify the search, sort, and filter interaction logic to reduce boilerplate in page files.

## 4. Common Mapping Utilities
Move repetitive data mapping logic into shared utilities or extension methods.

### Key Components:
- **`DataMapper` Extensions**: Create extensions on `graphql_codegen` models (e.g., `extension SceneMapper on Fragment$Scene`) to handle domain entity conversion.
- **Shared Utils**: Standardize `displayTitle`, `formatDuration`, and `resolveMediaPath` in `lib/core/utils`.

## 5. Error & Loading UX
Unify the user experience for asynchronous operations.

### Key Components:
- **`LoadingStateView`**: A consistent centered progress indicator.
- **`ErrorStateView`**: A robust error view with message, icon, and retry hook.
- **Integration**: `BaseRepository` will provide standardized hooks for UI layers to handle errors consistently.

## 6. Testing Foundation
Build a reusable testing infrastructure in `test/helpers`.

### Key Components:
- **Mock Providers**: Pre-configured mock providers for `graphqlClient`, `sharedPreferences`, etc.
- **Base Test Classes**: Provide a consistent structure for testing repositories and providers.
- **Helper Methods**: Utilities for pumping widgets with `ProviderScope` and common overrides.

## 7. Success Criteria
- [ ] Large files (e.g., `scenes_page.dart`, `graphql_scene_repository.dart`) are reduced in size and complexity.
- [ ] No raw GraphQL strings remain in feature repositories (all use `codegen`).
- [ ] Test coverage increases for extracted core components and feature logic.
- [ ] New features can be implemented with significantly less boilerplate.

## 8. Implementation Phases
1. **Phase 1: Core Foundation** (`BaseRepository`, `MappingUtils`, `TestingHelpers`).
2. **Phase 2: UI Standardization** (`MediaCard`, `MediaHeader`, `ListPageScaffold` refactor).
3. **Phase 3: Feature Migration (Scenes)**: Refactor the `scenes` feature as a reference implementation.
4. **Phase 4: Global Migration**: Update other features (`performers`, `studios`, etc.) to use the new core patterns.

---

### 4. 2026-04-29-cache-management

# Cache Management Design Specification

## Overview
This document outlines the architecture and implementation strategy for adding cache cleaning and size management features to the StashFlow Flutter application. The system targets three primary storage hogs: image caches (thumbnails and full-size), temporary video buffers, and the local GraphQL database.

## 1. Architecture: `AppCacheService`
A centralized, Riverpod-managed service (`AppCacheService`) will be introduced to act as the single source of truth for cache operations.

### Responsibilities
- **Size Calculation:** Asynchronously compute the disk space used by different cache categories in megabytes (MB).
- **Cache Clearing:** Expose methods to clear specific cache categories or all caches simultaneously.
- **Size Enforcement:** Enforce user-defined size limits by pruning older files when thresholds are exceeded.

### Targeted Cache Mechanisms
1. **Images:**
   - **Thumbnails/Grid:** Managed by `flutter_cache_manager` (used in `StashImage`).
   - **Full-Size:** Managed by `extended_image` (used in `image_fullscreen_page.dart`). Both must be cleared when "Clear Image Cache" is triggered.
2. **Videos:**
   - Temporary buffer files created by `media_kit` in the system's temporary directory. The service will identify and delete these files based on their extensions or paths.
3. **Database:**
   - The `graphql_flutter` HiveStore database. Clearing this will wipe the stored GraphQL responses, forcing fresh network requests on the next load.

## 2. Configuration & Preferences
New settings will be added to the existing preferences system (`shared_preferences_provider.dart`):

- **`max_image_cache_size_mb`**: Defines the maximum allowed size for image caches.
  - Options: 100 MB, 500 MB, 1 GB, Unlimited.
- **`max_video_cache_size_mb`**: Defines the maximum allowed size for video temporary files.
  - Options: 500 MB, 1 GB, 2 GB, Unlimited.

*Enforcement:* The `AppCacheService` will check these limits (e.g., on app startup or periodically) and prune files (oldest first) if the calculated size exceeds the selected limit.

## 3. UI/UX: `StorageSettingsPage`
A new dedicated settings page will be added to provide visibility and control to the user.

- **Location:** Accessible via `SettingsHubPage` under a new "Storage & Cache" section.
- **Visuals:** 
  - A summary card or list displaying the current calculated size for Images, Videos, and the Database.
- **Controls:**
  - Individual "Clear" buttons for each category.
  - A global "Clear All Caches" button.
  - Dropdown menus to select the `max_image_cache_size_mb` and `max_video_cache_size_mb` preferences.

## 4. Testing & Error Handling
- **Concurrency:** Ensure size calculations and clearing operations run asynchronously to avoid blocking the UI thread.
- **File System Locks:** Handle potential `FileSystemException` gracefully if a file is currently in use (e.g., a video currently playing) when a clear operation is triggered.
- **State Updates:** Ensure the UI (sizes displayed) automatically refreshes after a clear operation or when limits are changed, utilizing Riverpod's reactive state.

## 5. Scope & Constraints
- The design specifically addresses local caching on the device. It does not affect data stored on the remote Stash server.
- Database cache limits are managed purely by manual clearing, as enforcing strict MB limits on the Hive database is complex and error-prone; limits apply strictly to media files.

---

## 🎬 Video Playback & Player

### 1. 2026-03-23-play-next-overhaul

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

---

### 2. 2026-03-29-video-player-prewarm

# Design Spec: Video Player Prewarm & Logging Fix

**Date:** 2026-03-29
**Status:** Draft
**Topic:** Improving video playback cold start and fixing network logging.

## 1. Problem Statement

1.  **Manual Start Latency:** Manual playback initialization in `SceneVideoPlayer` suffers from a "cold start" wait. This is caused by a redundant `_prewarmStream` method that performs a full `GET` request and drains the response before the actual `VideoPlayerController` is initialized.
2.  **Redundant URL Resolution:** The stream URL is resolved twice (once for prewarm, once for playback), hitting the GraphQL API twice.
3.  **Missing Port in Logs:** The `StreamResolver` strips port numbers from URLs in logs, making it difficult to debug network issues when using non-standard ports (e.g., Stash running on 9999).

## 2. Proposed Changes

### 2.1. Fix Logging in `StreamResolver`
Modify `StreamResolver._shortUrl` to include the port number if it is present and not the default for the scheme.

### 2.2. Implement Stream URL Caching
Add an in-memory cache to the `StreamResolver` notifier.
- **Cache Key:** `scene.id`
- **Cache Value:** `StreamChoice`
- **Behavior:** `resolvePreferredStream` will check the cache before making a GraphQL query.

### 2.3. Optimize Manual Prewarm
Refactor `_SceneVideoPlayerState._prewarmStream` in `lib/features/scenes/presentation/widgets/scene_video_player.dart`:
- Replace the full `GET` request and `response.drain()` with a lightweight `HEAD` request.
- Ensure the prewarm doesn't block the actual player initialization.

### 2.4. Proactive Background Prewarm
Implement proactive prewarming for the playback queue in `PlayerState`:
- When a video starts playing, identify the "Next" scene in the `PlaybackQueue`.
- Trigger a background URL resolution for the next scene via `StreamResolver.prewarm(scene)`.
- This ensures that when the user clicks "Next", the URL is already cached and the transition is instant.

## 3. Architecture & Data Flow

1.  **User clicks Play:**
    - `SceneVideoPlayer` triggers `StreamResolver.resolvePreferredStream`.
    - If not in cache, GraphQL query runs and result is cached.
    - `VideoPlayerController` initializes immediately using the cached URL.
2.  **Playback Starts:**
    - `PlayerState` sees a new active scene.
    - It asks `PlaybackQueue` for the `nextScene`.
    - It calls `StreamResolver.resolvePreferredStream(nextScene)` in the background to warm the cache.
3.  **User clicks Next:**
    - `PlayerState.playNext()` is called.
    - It calls `StreamResolver.resolvePreferredStream(nextScene)`.
    - Result is returned instantly from cache.
    - New `VideoPlayerController` initializes without any API wait.

## 4. Testing Plan

- **Unit Tests:**
    - Verify `StreamResolver._shortUrl` includes the port.
    - Verify `StreamResolver` caches results and returns them on subsequent calls.
- **Integration/Manual Tests:**
    - Verify manual start in `SceneDetailsPage` is faster.
    - Check logs to confirm only one GraphQL query is made for manual starts.
    - Check logs to confirm "Next" video resolution happens in the background while the current video is playing.

---

### 3. 2026-04-06-smaller-video-player-ui

# Design Spec: Smaller Video Player UI Elements

This document outlines the design changes required to scale down the UI elements in both the inline and full-screen video players to create a more compact and less intrusive overlay.

## 1. Seek Feedback Overlay
The transient overlay shown during seeking/dragging will be reduced in size.

| Property | Current | Proposed |
| :--- | :--- | :--- |
| **Padding** | `18x12` | `14x10` |
| **Font Size** | `15` | `13` |
| **Icon Size** | `20` | `18` |
| **Border Radius** | `24` | `18` |

## 2. Bottom Control Bar (Container)
The main container for the playback controls will be tightened.

| Property | Current | Proposed |
| :--- | :--- | :--- |
| **Outer Margin** | `8dp` | `6dp` |
| **Inner Padding** | `12x10, 12x8` | `10x8, 10x6` |
| **Corner Radius** | `AppTheme.radiusLarge` (20) | `AppTheme.radiusMedium` (14) |

## 3. Control Buttons & Interactive Elements
Individual control buttons (Play, Pause, Skip, Fullscreen) will be scaled down.

| Property | Current | Proposed |
| :--- | :--- | :--- |
| **Button Min Size** | `44x44` | `38x38` |
| **Button Padding** | `10` | `8` |
| **Icon Size** | `22` | `20` |
| **Corner Radius** | `14` | `10` |

## 4. Playback Slider
The progress bar will be made more subtle.

| Property | Current | Proposed |
| :--- | :--- | :--- |
| **Track Height** | `4` | `3` |
| **Thumb Radius** | `7` | `6` |
| **Overlay Radius** | `14` | `12` |
| **Drag Handle Width**| `34` | `28` |
| **Drag Handle Height**| `4` | `3` |

## 5. Text, Labels & Selectors
Metadata and status text will be reduced in size.

| Property | Current | Proposed |
| :--- | :--- | :--- |
| **Time/Speed Text** | `12` | `11` |
| **Speed Selector Pad**| `10x6` | `8x4` |
| **Speed Selector Radius**| `14` | `10` |
| **Fullscreen Title** | `16` | `14` |

## 6. Layout Adjustments
*   **Spacing:** Reduce spacing between buttons and text elements (e.g., from `8` to `6`, or `12` to `8`).
*   **Safe Area Padding:** Ensure top bar in fullscreen maintains appropriate `SafeArea` but with tighter internal padding.

## Success Criteria
*   The UI elements occupy less screen area.
*   Buttons remain easily tappable on mobile devices (target ~38dp min).
*   Text remains legible at a glance.
*   Consistent look and feel across inline and fullscreen modes.

---

### 4. 2026-04-22-video-pinch-zoom-rotate

# Design Spec: Video Player Pinch-to-Zoom and Free Rotation

## 1. Overview
Add the ability for users to pinch to zoom and freely rotate the video surface in both the inline (scene details) and fullscreen video players. This improves accessibility and allows users to inspect details or adjust for orientation in non-standard video files.

## 2. Requirements
- **Pinch-to-Zoom**: Smoothly scale the video content using a two-finger pinch gesture.
- **Free Rotation**: Allow continuous rotation of the video content using a two-finger twist gesture.
- **Panning**: Allow moving the zoomed/rotated video surface within its container.
- **Gesture Isolation**: Transformation gestures must only trigger when 2 fingers are detected to avoid conflicts with one-finger seek/scrub gestures.
- **Reset State**: Transformations must reset to the default (identity) state when:
    - Navigating between scenes.
    - Entering or exiting fullscreen mode.
- **UI Integrity**: Subtitles and playback controls must remain fixed and should NOT be affected by the video transformation.

## 3. Architecture

### 3.1 `TransformableVideoSurface` Widget
A new stateful widget will be created to manage the transformation state and gesture handling.

**Props:**
- `VideoPlayerController controller`: The active controller.
- `double aspectRatio`: The intended aspect ratio of the video surface.

**State:**
- `Matrix4 _transformationMatrix`: Stores the combined scale, rotation, and translation.
- `Offset _lastFocalPoint`: Tracks the center of the gesture for smooth panning.
- `double _startScale`: Scale value at the start of the gesture.
- `double _startRotation`: Rotation value at the start of the gesture.

### 3.2 Integration into `SceneVideoPlayer`
The `SceneVideoPlayer` widget (used for both inline and fullscreen) currently renders the `VideoPlayer` directly inside a `Stack`.

**Current Structure:**
```dart
Stack(
  children: [
    VideoPlayer(controller), // To be replaced
    SceneSubtitleOverlay(...),
    NativeVideoControls(...),
  ]
)
```

**New Structure:**
```dart
Stack(
  children: [
    TransformableVideoSurface(
      controller: controller,
      aspectRatio: controller.value.aspectRatio,
    ),
    SceneSubtitleOverlay(...),
    NativeVideoControls(...),
  ]
)
```

## 4. Gesture Handling Logic

The `GestureDetector` inside `TransformableVideoSurface` will handle the following:

### 4.1 `onScaleStart`
- Store initial `_transformationMatrix`.
- Record `_lastFocalPoint`.
- Initialize `_startScale` and `_startRotation`.

### 4.2 `onScaleUpdate`
- Check `details.pointerCount`.
- If `pointerCount == 2`:
    - Calculate `scaleDelta` and `rotationDelta`.
    - Calculate `translationDelta` from focal point movement.
    - Update `_transformationMatrix` using `Matrix4` operations (scaling and rotating around the focal point).
    - Call `setState()`.

### 4.3 `onScaleEnd`
- Finalize the transformation.
- No inertia/decay will be implemented in the first iteration to keep the logic simple and predictable.

## 5. Reset Behavior
The `TransformableVideoSurface` will be keyed by the `sceneId` or explicitly reset in `initState`. Since entering/exiting fullscreen uses a `Hero` transition and different page instances, the state will naturally reset as the new widget instance initializes with `Matrix4.identity()`.

## 6. Testing Strategy
- **Manual Verification**:
    - Verify one-finger horizontal drag still performs seeking.
    - Verify two-finger pinch scales the video.
    - Verify two-finger twist rotates the video.
    - Verify controls and subtitles stay fixed during transformation.
    - Verify exiting fullscreen resets the zoom/rotation.
- **Automated Tests**:
    - Add a widget test to ensure `TransformableVideoSurface` applies the correct `Matrix4` updates when receiving simulated scale gestures.

---

### 5. 2026-04-25-disable-scrubbing-if-no-vtt

# Spec: Disable Scene Card Scrubbing if VTT is Missing

## Problem
Currently, the `SceneCard` in the scene list page always listens for pan gestures even if the sprite image (VTT) is unavailable. While it doesn't show the preview, the active `GestureDetector` might still intercept gestures that should ideally pass through to parent widgets (like a scroll view) or simply remain inactive.

## Goal
Explicitly disable the pan gesture on the `SceneCard` if the VTT URL is empty, ensuring the UI remains responsive and gestures are handled predictably.

## Proposed Changes

### lib/features/scenes/presentation/widgets/scene_card.dart
- Update the `GestureDetector` in the `build` method (and sub-building methods if applicable).
- Conditionally set `onPanStart`, `onPanUpdate`, and `onPanEnd` to `null` if `vttUrl.isEmpty`.

## Success Criteria
- `SceneCard` does not intercept pan gestures when no VTT is available.
- Scrolling performance is unaffected or improved on cards without sprites.
- Scrubbing remains fully functional for cards with valid VTT URLs.

---

### 6. 2026-04-28-remove-video-middle-layer

# Remove Video Middle Layer Design

## Overview
The goal of this project is to remove the `video_player` to `media_kit` conversion middle layer step by step, without breaking the UI and video-related logic. The app currently uses an adapter pattern (`AppVideoController` and `MediaKitVideoControllerAdapter`) to expose `media_kit` via a `ValueListenable` interface that mimics `video_player`. We will migrate the UI to use `media_kit`'s native reactive stream APIs.

## Architecture & Components
The middle layer consists of:
1. `AppVideoController`, `AppVideoValue`, and `MediaKitVideoControllerAdapter` (in `app_video_controller.dart`).
2. `AppVideoSurface` (in `app_video_surface.dart`).

These will be entirely removed. 

The replacement involves:
- **`GlobalPlayerState`**: Replacing `AppVideoController? videoPlayerController` with `Player? player` and `VideoController? videoController` from `media_kit`.
- **`PlayerState` Provider**: Changing initialization logic to instantiate `Player` and `VideoController` natively, and updating the stream listeners inside the provider to rely on `media_kit` events.
- **UI Components** (`SceneVideoPlayer`, `NativeVideoControls`, `TransformableVideoSurface`, `VideoPlaybackControls`, `SceneSubtitleOverlay`): These will accept `Player` and/or `VideoController` instead of the adapter interface. They will use direct `StreamSubscription` or `StreamBuilder` logic in `initState` and `build` to respond to state changes such as `position`, `playing`, `duration`, `buffer`, and `subtitle`.
- **Surface**: Using the native `media_kit_video` `Video(controller: videoController)` widget directly instead of `AppVideoSurface`.

## Data Flow
- The `PlayerState` provider handles video initialization and provides `Player` and `VideoController` instances to the UI tree.
- UI widgets will listen to `player.stream.*` (`player.stream.position`, `player.stream.playing`, `player.stream.duration`, `player.stream.buffer`, `player.stream.subtitle`, `player.stream.rate`, `player.stream.videoParams`) to rebuild themselves selectively. This replaces the monolithic `ValueListenableBuilder<AppVideoValue>` approach.

## Error Handling & Testing
- Errors during stream resolution or initialization will continue to be caught in the `PlayerState` provider. The widget lifecycle will remain unchanged (i.e. loading spinners while `controller.player.state.width == null`).
- Tests that mock `AppVideoController` will be updated to mock `Player` or stub its streams to simulate the same behaviors.

## Implementation Steps
1. Refactor `GlobalPlayerState` and `PlayerState` to expose `Player` and `VideoController`.
2. Refactor child UI components (`NativeVideoControls`, `TransformableVideoSurface`, etc.) to consume `Player`/`VideoController` and direct streams.
3. Remove `app_video_controller.dart` and `app_video_surface.dart`.
4. Fix and verify existing unit tests related to video playback.
5. Manually verify video playback and controls locally.

---

### 7. 2026-05-25-video-player-complexity-reduction

# Spec: Video Player Complexity Reduction

**Date:** 2026-05-25
**Topic:** Reduce complexity in video playback, queue advancement, and fullscreen handling without changing user-visible behavior.

## Problem

The video playback system works, but its responsibilities are concentrated in a few large modules:

- `lib/features/scenes/presentation/providers/video_player_provider.dart` owns media-kit player lifecycle, global state, preferences, subtitles, activity tracking, media-session callbacks, queue advancement, stream prewarming, fullscreen state, and navigation intents.
- `lib/features/scenes/presentation/widgets/scene_video_player.dart` and `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart` render similar playback surfaces with duplicated transform, buffering, casting, subtitle, loading, and control wiring.
- Fullscreen truth is spread across `playerStateProvider.isFullScreen`, `PlayerViewMode`, route-path checks, `ShellPage` back handling, platform fullscreen APIs, and overlay-local animation state.
- Queue advancement currently resolves, navigates, updates queue index, and opens media from the player notifier, so failures can leave queue state, active scene, and background navigation out of sync.

This makes the system fragile when features cross boundaries: fullscreen autoplay, direct navigation, TikTok handoff, background playback, casting, subtitles, and resume tracking all interact with the same provider.

## Goals

- Keep current playback behavior intact while reducing coupling.
- Make the shared player ownership invariant explicit: only one scene owns the media-kit player at a time.
- Make inline and fullscreen rendering share one playback surface implementation.
- Make fullscreen enter/exit behavior deterministic across desktop, mobile, and web.
- Make queue next/previous transitions transactional: either the target scene is ready and committed, or existing playback state remains coherent.
- Improve testability by moving logic out of widgets and out of the monolithic player notifier.

## Non-Goals

- No media-kit replacement.
- No redesign of video controls.
- No change to queue semantics or existing queue IDs.
- No removal of TikTok playback handoff.
- No broad navigation rewrite beyond the playback/fullscreen boundaries.

## Recommended Approach

Use incremental extraction behind the existing `playerStateProvider` facade. This keeps call sites stable while the internals become smaller, testable units.

### Phase 1: Shared Player Surface

Create a reusable `PlayerSurface` widget used by both inline and fullscreen playback. It owns only rendering concerns:

- Transform matrix and pinch/rotate handlers.
- Debounced buffering indicator.
- Cast placeholder.
- `TransformableVideoSurface`.
- `NativeVideoControls` wiring.
- Subtitle alignment and sizing.
- Loading overlay.

`SceneVideoPlayer` remains responsible for deciding when a scene should start playback. `GlobalFullscreenOverlay` remains responsible for overlay visibility and platform fullscreen effects. Both delegate actual media surface rendering to `PlayerSurface`.

### Phase 2: Settings and Activity Extraction

Move preference-backed player settings into a `PlayerSettings` value and controller. Move play count, play duration, resume time, and periodic saving into a `PlaybackActivityTracker`.

The player notifier should ask these collaborators to load/apply settings and start/stop tracking, instead of storing their timers and preference keys directly.

### Phase 3: Session Lifecycle Extraction

Create a `PlaybackSessionController` that owns:

- `Player` creation.
- `VideoController` creation.
- `player.open(Media(effectiveStreamUrl, httpHeaders: headers, start: initialPosition))`.
- stream subscriptions.
- borrowed controller attach/detach semantics.
- disposal rules.

The public provider still exposes `GlobalPlayerState`, but the low-level session controller returns session snapshots/events instead of mutating unrelated state directly.

### Phase 4: Fullscreen State Machine

Replace scattered fullscreen booleans and route checks with explicit transitions:

- `inline`
- `enteringFullscreen`
- `fullscreen`
- `exitingFullscreen`
- `tiktok`

The fullscreen controller owns platform side effects:

- `SystemChrome.setEnabledSystemUIMode`.
- mobile orientation constraints.
- desktop `window_manager` fullscreen/maximize restore.
- web fullscreen entry/exit.

The overlay renders from this state; `ShellPage` handles back gestures by dispatching a fullscreen exit command.

### Phase 5: Queue Playback Coordinator

Move `playNext` and `playPrevious` into a coordinator that performs transitions atomically:

1. Read the active queue and current active scene.
2. Compute the target scene without mutating queue state.
3. Resolve the target stream.
4. Open or attach the target playback session.
5. Commit active scene, queue index, prewarm state, and navigation intent together.
6. If resolution/open fails, keep the previous queue index and active scene.

This coordinator should be the only module that combines queue state, stream resolution, navigation intent, and playback scene switching.

## Target Architecture

```text
SceneVideoPlayer
  - decides inline ownership and start conditions
  - delegates rendering to PlayerSurface

GlobalFullscreenOverlay
  - observes fullscreen mode
  - applies platform fullscreen side effects
  - delegates rendering to PlayerSurface

PlayerSurface
  - pure playback UI surface
  - receives scene, controller, player state, and callbacks

PlayerState facade
  - public provider used by existing widgets
  - delegates to focused services/controllers

PlaybackSessionController
  - media-kit player/controller lifecycle

PlaybackActivityTracker
  - play count, duration, resume saves

PlayerSettingsController
  - prefs-backed playback settings

QueuePlaybackCoordinator
  - next/previous transactions and navigation commands

FullscreenController
  - fullscreen mode transitions and platform side effects
```

## Invariants

- Fullscreen overlay always renders `playerState.activeScene`, never a local page scene.
- Entering fullscreen from a scene details page must first ensure `activeScene.id == pageScene.id`; if ownership cannot be acquired, fullscreen entry aborts.
- Inline scene players cannot reclaim the global player while fullscreen or TikTok mode owns it.
- Queue index changes only after the target scene is successfully selected for playback.
- Platform fullscreen side effects are paired: every enter path has a corresponding exit cleanup path.
- Player disposal must never dispose a borrowed TikTok controller unless ownership was explicitly transferred.

## Testing Strategy

- Add widget tests for `PlayerSurface` independent of fullscreen overlay and scene-details start rules.
- Keep existing `SceneVideoPlayer` and `GlobalFullscreenOverlay` tests as regression coverage after Phase 1.
- Add unit tests around extracted pure helpers: aspect ratio, resume-position eligibility, subtitle selection, queue target calculation, and fullscreen transition state.
- Add provider tests for queue transaction failure: failed stream resolution/open must not advance queue state.
- Keep targeted verification small per phase, then run broader scene/player tests before merging each phase.

## Success Criteria

- Inline and fullscreen player rendering use a single surface widget.
- `video_player_provider.dart`, `scene_video_player.dart`, and `global_fullscreen_overlay.dart` shrink through responsibility extraction without losing behavior.
- Fullscreen entry/exit and queue next/previous behavior are covered by targeted tests.
- Existing tests for scene video player, fullscreen mode, queue state, and play-end behavior continue to pass.
- Future fixes to buffering, casting, subtitles, controls, or transform behavior are made once in `PlayerSurface`.

---

### 8. 2026-07-13-android-media-notification-playback-end

# Android Media Notification and Playback-End Design

## Goal

Keep Android notification-shade media controls synchronized with the active video and remove the notification immediately whenever playback terminates.

## Scope

Retain the existing `audio_service`, `media_kit`, Riverpod player, queue coordinator, and user-selectable `stop`, `loop`, and `next` end behaviors. Do not add dependencies or migrate the player to native Media3.

## Design

`StashMediaHandler` remains the system-media boundary. Its playback update accepts the real processing state, exposes only valid controls, and provides one explicit dismissal operation that publishes an idle, non-playing state and clears the current media item. Removing the Android task stops playback but does not call `SystemNavigator.pop()` after the task is already being removed.

`PlaybackSessionController` treats `player.stream.completed` as an edge: one callback for each transition to `true`, reset after `false` or a new binding. This prevents duplicate completion handling without adding timers.

`PlayerState` remains the end-behavior owner:

- `stop` exits playback through the existing shared stop path and dismisses the notification.
- `loop` seeks to zero and resumes the same player without dismissing the notification.
- `next` preserves fullscreen, resolves and starts the next queue item transactionally, and returns whether it advanced. If no next item exists or resolution/startup fails, playback stops and the notification is dismissed.
- Manual stop uses the same notification dismissal path.
- Notification Previous is wired to the existing `playPrevious()` command.

Artwork loading remains asynchronous, but an artwork result may update metadata only while its scene is still active. A stale downloaded file is deleted instead of replacing the current scene's artwork.

## Error Handling

Queue advancement commits only after the target scene becomes active. Failed or unavailable automatic advancement terminates cleanly. Artwork download failures continue to fall back to text metadata; stale results are silently discarded. Media callbacks remain safe when no player or queue target exists.

## Verification

Focused tests will prove:

- idle state clears the media item and represents notification dismissal;
- notification Previous invokes the player callback;
- task removal stops without requesting a second application pop;
- duplicate completion `true` events trigger once and reset after `false`;
- `stop` dismisses and exits fullscreen;
- `loop` preserves the active scene and restarts playback;
- `next` preserves fullscreen on success and stops when advancement is unavailable;
- failed automatic advancement does not commit the queue index.

Run focused Flutter tests for `media_handler_test.dart`, `playback_session_controller_test.dart`, and `playend_behavior_test.dart`, then analyze all touched Dart files.

---

### 9. 2026-07-13-notification-stop-action

# Notification Stop Action Removal

## Scope

Remove the Stop action from the system media notification. Keep the internal
player stop behavior, media-handler stop callback, and task-removal cleanup.

## Change

- Remove `MediaControl.stop` from `StashMediaHandler.updatePlaybackState`.
- Shift the Next compact-action index from `3` to `2`.
- Add a focused regression assertion that Stop is not published.

## Verification

Run the focused media-handler test, analyzer, and `git diff --check`.

Audio-focus settings are intentionally deferred.

---

### 10. 2026-07-14-android-notification-seeking

# Android Notification True Seeking Design

## Goal

Make the existing Android media-notification progress bar perform exact seeks in the active `media_kit` video while preserving whether playback was paused or playing.

## Root cause

`StashMediaHandler` already advertises `MediaAction.seek` and forwards Android's seek callback. `PlayerState` publishes the notification's media duration only when a scene is first attached. If `media_kit` reports a zero or incomplete duration at that moment, later duration-stream updates never reach the notification. The callback also forwards the requested position without clamping or immediately publishing the accepted position back to the media session.

## Scope

- Keep `audio_service` and the existing Android service configuration.
- Keep notification controls and `MediaAction.seek` unchanged.
- Update only the shared `PlayerState` notification/seek seam.
- Do not add dependencies, native Android code, settings, or a second playback abstraction.

## Design

`PlayerState` will bind `mediaHandler.onSeekCallback` to a private async handler. That handler will:

1. Return when there is no active player.
2. Clamp negative positions to zero and positions beyond a known duration to that duration.
3. Capture the current playing state, await `player.seek`, and restore the captured state if the player changes it during the seek.
4. Immediately publish the accepted target position, current buffer, speed, and processing state to `StashMediaHandler` so Android's progress thumb moves without waiting for a later player event.

The existing duration stream already reaches `_videoListener`. When its real duration differs from the current notification `MediaItem.duration`, `_videoListener` will refresh only the media metadata. It will not refetch artwork or recreate the notification unnecessarily.

## Error handling

No media-session position update is published when `player.seek` fails. A missing player is a no-op, matching the existing remote-control callbacks. The player remains the source of truth after the immediate optimistic notification update; subsequent position events correct any backend rounding or adjustment.

## Verification

Focused provider tests will cover duration arriving after attachment, an out-of-range notification seek being clamped, exact position publication, and preservation of a playing player when a backend pauses during seek. Existing media-handler callback tests remain in place. Run focused Flutter tests, touched-file analysis, formatting, `git diff --check`, and a debug Android APK build when the local Flutter toolchain permits it.

---

### 11. 2026-07-14-background-playback-lifecycle

# Background Playback Lifecycle Design

**Goal:** Make Background Playback off explicitly pause the global video when the Android app is backgrounded, while keeping native Android PiP independent.

## Current behavior and root cause

The setting is persisted in `PlayerSettingsStore` and copied into `GlobalPlayerState`. `PlayerState` only schedules keep-alive recovery when the setting is on; it does not explicitly pause when the setting is off. The shared `Video` widget currently pauses itself on Android lifecycle `paused`/`detached` events, which leaves the policy split between the widget and `PlayerState`. Native PiP is requested independently by `NativeVideoControls`, creating a lifecycle-ordering risk if the provider also starts pausing.

## Decision

Make `PlayerState` the lifecycle owner for the global player:

- Background Playback on keeps the existing recovery behavior.
- Background Playback off explicitly pauses on `hidden`, `paused`, and `detached` transitions when the player is not in native PiP.
- Native Android PiP takes precedence over the background setting and keeps playback running.
- Android task removal continues to stop the media session through `StashMediaHandler.onTaskRemoved`.
- The global `Video` surface will not run its own background pause logic; this avoids two components competing over the same player.
- Local preview players outside the global player remain unchanged.

PiP entry will be requested from the provider lifecycle path rather than from `NativeVideoControls`. If PiP entry fails, the provider applies the selected background policy: pause when off, or schedule recovery when on.

## Files

- Modify `lib/features/scenes/presentation/providers/video_player_provider.dart` to centralize lifecycle policy and coordinate PiP fallback.
- Modify `lib/features/scenes/presentation/widgets/native_video_controls.dart` to remove its duplicate lifecycle observer.
- Modify `lib/features/scenes/presentation/widgets/transformable_video_surface.dart` to disable package-level background pausing for the global surface.
- Modify `test/features/scenes/presentation/providers/playend_behavior_test.dart` with a regression test proving background-off pauses an active player.

## Verification

Run the focused provider test and the existing media-handler tests. The focused regression must fail before the provider change because the current background-off path does not call `pause()`, then pass after the change. Inspect the final diff for unrelated changes and run `flutter analyze` if the Flutter SDK is available.

## Non-goals

- No new dependency or Android service is introduced.
- No change to local preview-video lifecycle behavior.
- No change to the user-facing setting or its persisted key.

---

## 🖼️ Scenes, Images & Galleries

### 1. 2026-03-31-rename-galleries-and-scroll-to-top

# Rename 'Media' to 'Galleries' and Handle Scroll-to-Top

> **Topic:** User Interface / Navigation Enhancement
> **Date:** 2026-03-31

## Context
The user wants to rename the 'Media' label in the bottom panel (and navigation rail) to 'Galleries'. Additionally, clicking this 'Galleries' button when the user is already on the page should navigate to the top of the gallery page.

## Proposed Changes

### 1. Navigation Label Change (ShellPage)
Modify `lib/features/navigation/presentation/shell_page.dart` to rename 'Media' to 'Galleries' in both `NavigationBar` and `NavigationRail`.

-   **File**: `lib/features/navigation/presentation/shell_page.dart`
-   **Change**: Update `navigationDestinations` and `navigationRailDestinations`.

### 2. Connect Scroll Controller (GalleriesPage)
Modify `lib/features/galleries/presentation/pages/galleries_page.dart` to use `galleryScrollControllerProvider` in its `ListPageScaffold`. This allows the scroll-to-top logic in `ShellPage` to work.

-   **File**: `lib/features/galleries/presentation/pages/galleries_page.dart`
-   **Change**: Pass `ref.watch(galleryScrollControllerProvider)` to the `scrollController` property of `ListPageScaffold`.

## Logic Flow
1.  **Renaming**: Simple UI string update in `ShellPage`.
2.  **Scrolling**:
    -   `ShellPage.onDestinationSelected` already has a `case 4` that calls `ref.read(galleryScrollControllerProvider.notifier).scrollToTop()`.
    -   `GalleryScrollController` (in `lib/features/galleries/presentation/providers/gallery_list_provider.dart`) manages a `ScrollController`.
    -   By passing this `ScrollController` to `ListPageScaffold` in `GalleriesPage`, the animation triggered by `scrollToTop()` will scroll the actual list/grid on the page.

## Verification Plan
1.  **Visual Confirmation**: Ensure the bottom navigation bar and navigation rail now show 'Galleries' instead of 'Media'.
2.  **Functional Testing**:
    -   Navigate to the Galleries page.
    -   Scroll down.
    -   Click the 'Galleries' icon in the bottom navigation bar.
    -   Verify the page scrolls smoothly to the top.

---

### 2. 2026-04-25-dynamic-masonry-grid

# Spec: Dynamic Height Masonry Grid

## Problem
In the current grid view, cards use a fixed `childAspectRatio` (default 1.15). On desktop screens where cards are wider, this ratio forces a very tall text section. If the scene title is short and there are no performer avatars, this results in significant empty space, making the UI look sparse and unpolished.

## Goal
Implement a dynamic height grid (Masonry) that allows items to take only as much vertical space as their content requires.

## Proposed Changes

### 1. lib/core/presentation/widgets/list_page_scaffold.dart
- Add `bool useMasonry` to the `ListPageScaffold` constructor (defaults to `false`).
- Update the `build` method:
    - If `useMasonry` is true:
        - Use `MasonryGridView.builder` from `flutter_staggered_grid_view`.
        - Use `SliverSimpleGridDelegateWithFixedCrossAxisCount` for column management, leveraging existing responsive logic.
    - Maintain existing `ListView` and `GridView` (fixed ratio) logic for backward compatibility.

### 2. lib/features/scenes/presentation/pages/scenes_page.dart
- Set `useMasonry: isGridView` when calling `ListPageScaffold`.

### 3. lib/features/scenes/presentation/widgets/scene_card.dart
- No structural changes needed, as `_buildGridCard` already uses a `Column` that is compatible with dynamic height layouts.

## Success Criteria
- Grid items in the Scenes page adapt their height to their content.
- No excessive empty space in the text section on desktop.
- Responsive column counts (2 on mobile, 3+ on desktop) are preserved.
- Infinite scrolling and search functionality remain fully operational.

---

### 3. 2026-04-25-scene-card-enhancements

# Design Spec: Scene Card Enhancements (Metadata, Hover Scrubbing, Desktop Context)

Date: 2026-04-25
Author: Gemini CLI

## 1. Overview
Enhance the `SceneCard` widget to improve information density and platform-specific interactivity. Key improvements include metadata overlays on thumbnails, desktop-optimized hover scrubbing, and expanded performer context for desktop users.

## 2. Requirements

### 2.1 Metadata Overlays (Grid & List)
- **Position:** Bottom of the thumbnail image.
- **Background:** Semi-transparent black bar for readability.
- **Data Points:**
    - **Left:** Play count (views).
    - **Center:** Numerical rating (converted from 100-point scale to 5.0 scale).
    - **Right:** Scene duration.
- **Visibility:** Enabled for both Grid and List modes.

### 2.2 Platform-Specific Scrubbing
- **Mobile (Android/iOS):** Maintain existing horizontal drag-to-scrub logic.
- **Desktop (Windows/macOS/Linux/Web):** Replace drag logic with horizontal `MouseRegion` hover. Scrub time scales linearly with mouse X-position relative to card width.

### 2.3 Desktop Expanded Context
- **Feature:** Show performer avatars next to the studio name in `SceneCard` footer on desktop.
- **Configuration:** Max number of avatars defaults to 3, user-configurable in Interface Settings.
- **Overflow:** If total performers exceed the limit, display a `+N` text indicator.

## 3. Architecture & Implementation

### 3.1 Data Model & Settings
- **Settings:** Update `AppSettings` (or equivalent provider) to include `maxPerformerAvatars` (int).
- **Scene Entity:** Use existing `playCount`, `rating100`, and `performerImagePaths`.

### 3.2 UI Components

#### Thumbnail Overlay
A new internal widget `_ThumbnailMetadataOverlay` will be created inside `scene_card.dart`:
- Uses `Row` with `MainAxisAlignment.spaceBetween`.
- Icon + Text pairs for Views and Rating.
- Text for Duration.

#### Platform Interaction Logic
- Use `kIsWeb` or `defaultTargetPlatform` to determine environment.
- Wrap thumbnail in `MouseRegion` for desktop.
- Logic: `_scrubTime = (localX / cardWidth) * totalDuration`.

#### Performer Avatar Row
A new internal widget `_PerformerAvatarRow` will be created:
- Takes `List<String?> imagePaths` and `int limit`.
- Uses `Row` with `CircleAvatar` widgets.
- Handles empty paths with a placeholder `Icons.person`.

## 4. Testing Strategy
- **Widget Tests:** Verify metadata bar rendering in both Grid and List modes.
- **Platform Simulation:** Test hover logic (desktop) vs drag logic (mobile) using `tester.binding.setSurfaceSize`.
- **Settings Integration:** Verify that changing `maxPerformerAvatars` correctly updates the avatar count in the UI.

## 5. Success Criteria
- [ ] View count and rating are visible on thumbnails.
- [ ] Hover scrubbing works on desktop without clicking.
- [ ] Performer avatars appear on desktop but are hidden on mobile.
- [ ] `+N` indicator appears correctly when performer count exceeds limit.

---

### 4. 2026-05-05-image-download-button

# Design Spec: Image Download Button

## Overview
Add a download button to the image fullscreen view that allows users to download the current image by opening its authenticated URL in the system's default browser.

## User Interface
- **Location:** `lib/features/images/presentation/pages/image_fullscreen_page.dart` in the overlay footer.
- **Components:**
  - A new `IconButton` for downloading.
  - The existing Slideshow button will be updated to match the new style.
- **Styling:**
  - Both the **Slideshow** and **Download** buttons will use `IconButton.filledTonal`.
  - Download Icon: `Icons.download_rounded`.
  - Download Tooltip: `context.l10n.common_download`.

## Data & Logic
- **URL Resolution:**
  - The image URL will be resolved using `image.paths.image ?? image.paths.preview`.
  - Authentication will be handled by `applyWebMediaAuthFallback` from `url_resolver.dart`, which appends an API key if available.
- **Trigger:**
  - Uses `url_launcher` with `LaunchMode.externalApplication`.

## Technical Implementation
- Import `package:url_launcher/url_launcher.dart`.
- Import `../../../../core/data/graphql/url_resolver.dart`.
- Add a `_downloadImage` method to `_ImageFullscreenPageState`.
- Update the `build` method to include the new button and update the slideshow button style.

## Testing Strategy
- Manual verification:
  - Open an image in fullscreen.
  - Verify the new download button is present and styled correctly.
  - Verify the slideshow button style is updated.
  - Click the download button and verify it opens the correct image URL in the system browser.
  - Verify the image is accessible in the browser (authenticated via `apikey`).

---

### 5. 2026-05-05-save-to-gallery

# Design Spec: Save to Gallery with Gal

## Overview
Replace the "Open in Browser" download feature with a direct "Save to Gallery" feature for images. This will use the `gal` package to integrate with the system's photo library.

## User Interface
- **Button:** Keep the existing download button in `image_fullscreen_page.dart`.
- **Feedback:** 
  - Show a "Saving..." indicator or SnackBar.
  - Show "Saved to Gallery" SnackBar upon success.
  - Show error SnackBar upon failure.

## Data & Logic
- **Dependency:** Add `gal` package.
- **Authentication:** Use existing `mediaHeadersProvider` to fetch the image bytes via `dio`. This ensures images behind auth can be downloaded.
- **Process:**
  1. Resolve image URL.
  2. Get auth headers.
  3. Download image to a temporary file using `dio`.
  4. Check/Request gallery access permissions using `Gal`.
  5. Save the temporary file to the gallery using `Gal.putImage`.
  6. Delete the temporary file.

## Technical Implementation
- **Files to Modify:**
  - `pubspec.yaml`: Add `gal`.
  - `android/app/src/main/AndroidManifest.xml`: Add permissions and `requestLegacyExternalStorage`.
  - `lib/features/images/presentation/pages/image_fullscreen_page.dart`: Update `_downloadImage` (rename to `_saveImageToGallery`).

## Testing Strategy
- **Manual Verification:**
  - Click the download button on an image.
  - Check system notification/gallery for the saved image.
  - Verify it works for both authenticated and non-authenticated images.
  - Verify permission request pop-up appears on first use (Android).

---

### 6. 2026-06-11-scene-cover-fullscreen-viewer

# Scene Cover Fullscreen Viewer Design

## Goal

Allow users to tap the scene cover in the scene information sheet and inspect
it in a simple full-screen zoomable viewer.

## Presentation

The cover opens as an opaque black full-screen dialog on the root navigator.
The scene information bottom sheet remains mounted underneath and is revealed
unchanged when the viewer closes.

The viewer does not enter immersive system UI mode. It does not modify status
bar, navigation bar, desktop window fullscreen state, or orientation.

## Image

The viewer displays the same authenticated screenshot URL as the media section
using `StashImage` with `BoxFit.contain`. The image fills the available dialog
area without cropping.

Only cover mode opens the viewer. Preview mode remains controlled exclusively
by the preview player's gestures and native controls.

## Zoom And Pan

The image is wrapped in an `InteractiveViewer` with:

- minimum scale `1.0`;
- maximum scale `4.0`;
- panning enabled while enlarged;
- pinch-to-zoom enabled.

A `TransformationController` owns zoom state. Double-tapping at scale `1.0`
zooms to `2.5` around the tap position. Double-tapping while enlarged restores
the identity transform.

## Exit

A safe-area-aware exit-fullscreen icon button is pinned at the top right. It
uses the existing `common_exit_fullscreen` localization and closes only the
dialog. Android back, desktop escape/back navigation, and the exit button all
return to the scene information sheet.

## Components

Create `SceneCoverFullscreenViewer`, a focused stateful widget responsible for
the zoom controller, double-tap behavior, image display, and exit control.

`SceneInfoMediaSection` wraps only the cover surface in a semantic Material
tap target and calls a helper that presents the viewer through
`showGeneralDialog` with the root navigator.

## Testing

Widget tests verify:

- tapping cover mode opens the full-screen viewer;
- the exit button closes the viewer while leaving the media section mounted;
- double-tap changes the `InteractiveViewer` transform to an enlarged scale;
- a second double-tap restores the identity transform;
- pinch zoom remains enabled with the specified scale bounds;
- tapping the preview surface does not open the cover viewer.

---

### 7. 2026-06-11-scene-info-media-section

# Scene Info Media Section Design

## Goal

Add a media section near the top of the scene information bottom sheet that
lets users view the scene cover or a short preview video without affecting the
app's global scene player.

## Placement

The media section appears directly below the sheet header and before scene
metadata chips, studio information, performers, tags, and technical details.

## Availability Rules

The section derives two independent capabilities from the scene:

- Cover is available when `scene.paths.screenshot` is non-empty.
- Preview is available when `scene.paths.preview` is non-empty.

The rendered state is:

| Cover | Preview | Result |
| --- | --- | --- |
| Yes | Yes | Show a Cover/Preview toggle and default to Cover. |
| Yes | No | Show the cover without a toggle. |
| No | Yes | Show the preview player paused without a toggle. |
| No | No | Hide the entire media section. |

## Cover Mode

Cover mode renders the authenticated scene screenshot in a clipped 16:9 black
media surface using `StashImage` and `BoxFit.contain`. It does not initialize a
video player.

## Preview Mode

Preview mode owns an isolated `media_kit` `Player` and `VideoController`. It
resolves relative preview URLs against the configured GraphQL endpoint and
uses the existing media playback authentication behavior, including the web
URL fallback.

Preview-only scenes open with `play: true` and start automatically. When the
user switches from Cover to Preview, the player also opens with `play: true`.
The `Video` widget uses media_kit's Material controls, providing play/pause,
progress seeking, and fullscreen.

The preview player is initialized lazily when Preview mode first becomes
visible. Switching back to Cover removes and disposes the preview player. The
player and error subscription are also disposed when the media widget leaves
the tree or changes to a different scene or preview URL.

Initialization and playback errors are shown over the black media surface
without removing the mode toggle.

## Component Boundary

Create a public `SceneInfoMediaSection` widget alongside the existing scene
presentation widgets. It accepts a `Scene`, owns display mode and preview
player lifecycle, and renders nothing when neither media asset exists.

`SceneInfoPage` only places this widget below its header. This keeps player
state and authentication details out of the already substantial information
page and prevents the preview from taking ownership of the global playback
session.

## Testing

Widget tests cover:

- both assets show the toggle and default to the cover;
- selecting Preview replaces the cover with the preview surface;
- cover-only scenes show no toggle;
- preview-only scenes show the preview surface without a toggle;
- scenes with neither asset hide the section;
- returning to Cover pauses an initialized preview player through the widget's
  injected player boundary.

Tests use an injectable player/controller factory so media lifecycle behavior
can be verified without loading native media backends.

---

### 8. 2026-06-15-interaction-driven-vtt-loading

# Interaction-Driven VTT Loading Design

## Problem

Stash always returns constructed `paths.vtt` and `paths.sprite` URLs. Their
presence does not prove that the generated files exist. `SceneCard` currently
fetches and parses every VTT while cards are created, producing avoidable
network and rebuild work during scrolling.

## Design

- Treat a non-empty VTT URL and positive scene duration as a scrubbing
  capability hint.
- Do not fetch VTT data while building or initializing a scene card.
- Start loading only when the user first hovers or horizontally drags a card.
- Let the VTT response and parsed cues determine actual availability.
- Stop requiring `paths.sprite`; each VTT cue contains the authoritative sprite
  image URL.
- Cache completed requests and deduplicate concurrent requests in `VttService`.
- Disable further scrubbing for the card after an empty or unavailable VTT is
  returned.

## Verification

- Building a card with a VTT URL performs zero VTT requests.
- First interaction performs one request.
- A VTT URL works without a separate sprite path.
- Concurrent requests for the same URL share one HTTP request.
- Missing VTT data disables subsequent scrubbing attempts.

---

### 9. 2026-06-15-viewport-image-prefetch

# Viewport Image Prefetch Design

## Problem

Page grids currently schedule image work twice:

- `ListPageScaffold` manually calculates visible indices and calls
  `StashImage.prefetch`.
- Every `StashImage` performs another post-frame cache check and prefetch.

The item-based calculations are expensive, use a fixed minimum of 40 items,
and approximate masonry layouts using one measured item height.

## Design

- Use each vertical scrollable's pixel-based `cacheExtent` as the only
  page-level preloading mechanism.
- Set the extent to one viewport height.
- Let `ListView`, `GridView`, and `MasonryGridView` build children in that
  region. Each built `StashImage` then loads normally through
  `CachedNetworkImageProvider`.
- Grid density is handled by layout: more columns naturally build more items
  inside the same pixel extent.
- Keep `memCacheWidth` sizing based on the active grid column count.
- Remove page-level index tracking and explicit image prefetch loops.
- Remove `StashImage`'s automatic post-frame prefetch. Keep corrupt cached-file
  recovery in the image loading retry path.
- Preserve explicit prefetching for independent horizontal strips.
- Keep backend pagination independent from image preloading. Page-size
  calculation may still use responsive item capacity, but must not schedule
  image requests.

## Verification

- Page list, fixed grid, and masonry grid expose a one-viewport `cacheExtent`.
- A denser fixed grid builds more cached-ahead children for the same viewport.
- Page scaffolds no longer call `StashImage.prefetch`.
- `StashImage` no longer schedules its own post-frame prefetch.
- Horizontal strip prefetch behavior remains unchanged.

---

### 10. 2026-06-22-scene-details-layout

# Scene details layout and metadata edit access

## Scope

Refactor the scene-details header hierarchy and remove the preference that
conditionally hides metadata editing. The result applies metadata-edit access
consistently to scenes, performers, and studios.

## Layout

`SceneDetailsPage` will no longer build a `Scaffold` AppBar. The video player
remains the first content element. Its inline video-controls overlay will own a
back action that follows the same visibility and auto-hide behavior as the
existing playback controls.

The five former AppBar actions remain unchanged in behavior and order:

1. Add marker
2. Scene information
3. Download (non-web only)
4. Edit metadata
5. Delete scene

They move to the existing main-information action row immediately after the
rating-star controls and O-counter. The row uses wrapping so constrained
widths retain access to every action without overflow.

## Metadata edit availability

The shared scrape-enabled preference and the Interface Settings control that
updates it will be removed. Scene, performer, and studio detail/edit surfaces
will no longer gate metadata-edit affordances or related edit behavior on that
preference. Edit is visible by default and always usable subject only to the
existing route and repository error handling.

## Component boundaries

- `SceneDetailsPage` owns scene-level action handlers and presents them beside
  rating and O-counter controls.
- `SceneVideoPlayer` / its inline control overlay owns the video-attached back
  affordance and delegates navigation through the current router context.
- Interface settings removes the obsolete preference UI and provider use.
- Performer and studio pages remove their use of the same obsolete gate.

## Error handling and behavior preservation

Existing marker, info, download, edit, and delete handlers are retained. Their
existing dialogs, navigation, platform condition for download, loading states,
and error SnackBars remain intact. The back button uses normal router pop
semantics and is only displayed while the inline playback controls are shown.

## Verification

Widget coverage will demonstrate that scene details has no AppBar action panel,
the five actions are available with the rating/O action row, and a back control
is rendered by the inline video UI. Settings coverage will demonstrate the
obsolete preference is absent. Existing scene-detail, player, performer, and
studio tests will be run alongside focused new regression tests.

---

### 11. 2026-06-23-entity-gallery-images-via-gallery-filter

# Entity gallery images via gallery filter

## Goal

Make the existing Images page show images that belong to galleries related to
the selected performer, studio, or tag, even when the images themselves have
no corresponding metadata.

## Data flow

The entity-gallery bottom-pill action will continue to reset the shared image
filter and open `/galleries/images`. Instead of writing performer, studio, or
tag criteria onto `ImageFilter` directly, it will set a nested gallery filter:

- performer pages use `galleries_filter.performers`.
- studio pages use `galleries_filter.studios`.
- tag pages use `galleries_filter.tags`.

This uses Stash's server-side `ImageFilterType.galleries_filter` relationship
query, so it covers every matching gallery rather than only galleries loaded
in the current grid page.

## Implementation boundary

`ImageFilter` will gain an optional `GalleryFilter galleriesFilter` field.
`GraphQLImageRepository` will serialize that field as the generated
`Input$ImageFilterType.galleries_filter` input. The existing entity-gallery
filter-scope helper will construct the nested filter for the selected entity.
No new route, image page, or gallery-ID prefetch is needed.

## Testing

Add focused tests that verify each entity kind produces the expected nested
gallery filter, and that the image repository emits the matching GraphQL
`galleries_filter` payload. The existing widget regression will continue to
verify navigation and reset of stale image state.

---

### 12. 2026-06-24-entity-image-filter-method-setting

# Entity image filter method setting

## Goal

Let users choose how the existing entity-gallery All Images action scopes the
reused Images page. The default remains direct image metadata filtering.

## Interface

Add an Interface settings entry named `Entity image filtering` with a
single-choice segmented control:

- `Direct entity` is the default. Performer, studio, and tag pages filter
  images by the matching direct image relationship.
- `Related galleries` filters images through galleries that have the matching
  performer, studio, or tag relationship.

The labels describe the behavior consistently for all entity kinds rather
than implying that studio and tag pages use performer metadata.

## State and navigation

Persist an enum preference in SharedPreferences. A provider in the entity
gallery filter scope reads the stored value and exposes an update method.
When the bottom-pill action is tapped, it reads that provider and constructs
either the current direct `ImageFilter` criteria or the nested
`galleries_filter` criteria. Existing Images routes and UI stay unchanged.

## Testing

Cover the default and persisted setting values, interaction with the Interface
settings control, and both filter outputs for performer, studio, and tag
actions.

---

### 13. 2026-07-13-scene-metadata-visibility

# Scene Metadata Visibility Design

## Goal

Place the existing technical scene metadata directly below Studio and Year, hide it by default, and let users reveal it with a local button or disable the default hiding preference in Interface Settings.

## Design

`SceneDetailsPage` will read a persisted Riverpod preference backed by `SharedPreferences`. The preference defaults to `true` (hide technical metadata initially). The page keeps a local `_showTechnicalMetadata` state initialized from that preference when the scene is built. If metadata is hidden, the same header position contains a `Show metadata` text button; tapping it reveals the existing chips for that scene. If the preference is disabled, chips render immediately and no reveal button is shown.

The setting will be added to the existing Interface Settings section with a native adaptive switch. Changing it persists through the provider and affects newly opened/rebuilt scene details pages; it does not override a user’s one-page reveal action.

## Scope

- Reuse the existing technical metadata chip builder.
- Add one provider, one Interface Settings switch, and localized English strings.
- Preserve the existing header keys and action layout behavior where possible.
- Add focused widget coverage for default-hidden, reveal, and preference-disabled states.

## Verification

Run the focused scene UI test, the Interface Settings test if available, `dart format` on touched Dart files, and `flutter analyze` on touched files.

---

### 14. 2026-07-15-scene-details-action-padding

# Scene Details Action Padding

## Goal

Make the scene details rating/action card use equal upper and lower padding.

## Design

Remove the metadata-dependent padding override from `SceneDetailsPage` so the
existing section-container default, `EdgeInsets.all(AppTheme.spacingMedium)`,
applies on every side. Keep the current spacing between the identity block and
the card, action layout, and metadata behavior unchanged.

## Verification

Add one widget assertion that the controls have equal top and bottom inset
inside `scene_header_section`, then run the focused scene player UI test.

---

### 15. 2026-07-18-scene-performer-age

# Scene Performer Age Design

## Goal

On the scene details page, display each performer's age during the scene's
calendar year immediately after the performer name. The age uses the simple
calculation `scene year - birth year`; it does not adjust for whether the
performer's birthday had occurred by the scene date.

## Data Flow

Extend the existing scene GraphQL performer selection with `birthdate`. Map the
returned values into a `performerBirthdates` list on `Scene`, preserving the
same ordering as `performerIds`, `performerNames`, and
`performerImagePaths`. This keeps scene loading to one request and avoids a
broader refactor to full performer objects.

Existing `Scene` construction sites remain source-compatible by giving the new
list an empty default. Repository mappings populate it when GraphQL performer
data is available.

## Age Calculation and Rendering

Add a small, independently testable helper that parses the birthdate year and
returns `scene.year - birthYear`. It returns no age when the birthdate is
missing or invalid, or when the result would be negative.

In each performer row on `SceneDetailsPage`, render the existing performer name
followed by ` (age)` when an age is available. The performer name retains its
current body text style. The age suffix uses the same typography with the
theme's less-saturated `onSurfaceVariant` color. When no valid age is
available, render only the performer name and preserve the row's existing
navigation behavior.

## Testing

- Unit coverage verifies the year-only calculation, including that it does not
  adjust for month/day.
- Unit coverage verifies missing, invalid, and future birthdates omit the age.
- Widget coverage verifies the name and age appear together and that the age
  suffix uses the muted theme color.
- Existing scene repository and page tests must continue to pass after GraphQL
  and model generation.

## Scope

This change affects only performer rows on the scene details page. It does not
add age to scene cards, the scene information sheet, performer pages, or other
entity views, and it does not introduce additional performer fetches.

---

## 🔧 Platform & Build

### 1. 2026-04-10-github-pages-deployment

# Design Spec: GitHub Pages Deployment for StashFlow

This document outlines the strategy for hosting the Flutter web version of StashFlow on GitHub Pages, integrated into the existing release workflows.

## 1. Objective
Enable automated deployment of the Flutter web build to a dedicated `gh-pages` branch whenever a release or nightly build is triggered.

## 2. Architecture & Components

### 2.1 Deployment Target
- **Branch:** `gh-pages`
- **Hosting URL:** `https://<github-user>.github.io/StashFlow/`
- **Base HREF:** `/StashFlow/` (Required for GitHub Pages sub-directory hosting)

### 2.2 Workflow Integration
The deployment logic will be added to two existing workflows:
1.  `.github/workflows/release.yml` (Triggers on version tags `v*`)
2.  `.github/workflows/nightly-release.yml` (Triggers on schedule or push to `dev`)

### 2.3 Tools & Actions
- **Flutter Web Build:** `flutter build web --release --base-href /StashFlow/`
- **Deployment Action:** `peaceiris/actions-gh-pages@v4`

## 3. Implementation Details

### 3.1 Permissions
The workflows require expanded permissions to push to the repository:
```yaml
permissions:
  contents: write
  pages: write
  id-token: write
```

### 3.2 Build Step Modification
The web build command will be updated to include the `--base-href` flag:
```bash
if [ "${{ matrix.target }}" = "web" ]; then
  flutter build web --release --base-href /StashFlow/
fi
```

### 3.3 Deployment Step
A new step will be added to the `build` job, running only for the `web` target:
```yaml
- name: Deploy to GitHub Pages
  if: matrix.target == 'web'
  uses: peaceiris/actions-gh-pages@v4
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./build/web
    user_name: 'github-actions[bot]'
    user_email: 'github-actions[bot]@users.noreply.github.com'
    commit_message: "Deploy to GitHub Pages: ${{ github.sha }}"
```

## 4. Verification Plan

### 4.1 Automated Validation
- Verify YAML syntax using `python3 -c "import yaml; ..."`
- Check that the `gh-pages` branch is created/updated after the first successful run.

### 4.2 Manual Validation
- Navigate to `https://<github-user>.github.io/StashFlow/` after deployment.
- Verify that assets (icons, scripts) load correctly (no 404s).
- Confirm the app is interactive and matches the latest build.

## 5. Rollback Plan
- If deployment fails, the `gh-pages` branch can be manually reverted to a previous commit.
- The deployment step can be commented out or removed from the workflow files.

---

### 2. 2026-04-13-fdroid-preparation

# Design: Preparing StashFlow for F-Droid Publishing

Date: 2026-04-13
Topic: F-Droid Publishing Preparation
Status: Approved

## Overview
StashFlow is a Flutter companion app for Stash. To be published on F-Droid's official repository, the app must be fully open-source, including all its dependencies. The current use of the `fvp` package (based on the proprietary `libmdk`) is a blocker for F-Droid. This design introduces a dual-flavor architecture to maintain a full-featured "standard" version while providing a strictly FOSS-compliant "foss" version for F-Droid.

## Goals
1.  Migrate the Application ID to a more descriptive and unique one: `io.github.alchemistaloha.stashflow`.
2.  Implement a dual-flavor Android build system (`standard` and `foss`).
3.  Ensure the `foss` flavor is strictly FOSS-compliant by excluding `fvp` proprietary binaries.
4.  Set up Fastlane metadata for automated F-Droid ingestion.
5.  Adapt the Flutter code to handle the presence or absence of the `fvp` plugin at runtime.

## Architecture & Implementation

### 1. Identity & Package Structure Migration
-   **Application ID:** Change from `com.github.alchemistaloha.stash_app_flutter` to `io.github.alchemistaloha.stashflow`.
-   **Android Namespace:** Update `namespace` in `android/app/build.gradle.kts`.
-   **Kotlin Source:** Move `MainActivity.kt` from `android/app/src/main/kotlin/com/github/damontecres/stash_app_flutter/` to `android/app/src/main/kotlin/io/github/alchemistaloha/stashflow/`.
-   **Dart Code:** Update hardcoded references to the old App ID (e.g., in `main.dart` for `AudioServiceConfig`).

### 2. Dual-Flavor Android Configuration
Modify `android/app/build.gradle.kts` to include:
-   `flavorDimensions += "version"`
-   `productFlavors`:
    -   `standard`: The default version for GitHub/Direct downloads. Includes `fvp`.
    -   `foss`: The version for F-Droid. Excludes `fvp` native libraries.

```kotlin
android {
    flavorDimensions.add("version")
    productFlavors {
        create("standard") {
            dimension = "version"
            applicationIdSuffix = ""
        }
        create("foss") {
            dimension = "version"
            applicationIdSuffix = ".foss"
            versionNameSuffix = "-foss"
        }
    }
}
```

### 3. FOSS Compliance & Dependency Management
-   **Dependency Exclusion:** In the `foss` build, we will use Gradle's `packagingOptions` or `configurations` to ensure no `libmdk` or `fvp` related native binaries are bundled.
-   **Runtime Check:** `lib/main.dart` will be updated to safely attempt `fvp` registration using a `try-catch` block or a conditional check based on the environment/flavor.

### 4. Fastlane Metadata
Create the standard Fastlane metadata structure for F-Droid:
-   `android/fastlane/metadata/android/en-US/title.txt`
-   `android/fastlane/metadata/android/en-US/short_description.txt`
-   `android/fastlane/metadata/android/en-US/full_description.txt`
-   `android/fastlane/metadata/android/en-US/changelogs/` (for future releases)

## Testing Strategy
1.  **Build Verification:** Run `flutter build apk --flavor standard` and `flutter build apk --flavor foss` to ensure both build successfully.
2.  **Binary Inspection:** Inspect the `foss` APK to verify that no `libmdk.so` or `libfvp.so` files are present.
3.  **Runtime Verification:** Run the `foss` flavor on an emulator/device and confirm that video playback falls back to the default `video_player` implementation (ExoPlayer) without crashing.
4.  **Metadata Verification:** Verify that the Fastlane directory is correctly structured.

## Rollout Plan
1.  Perform identity migration (App ID and folder moves).
2.  Apply Gradle changes for flavors.
3.  Update Dart code for runtime adaptation.
4.  Create Fastlane metadata files.
5.  Perform final verification builds.

---

### 3. 2026-04-15-password-auth

# Design Spec: Password-Based Auth and Cookie-Based Content Fetching

## Goal
Implement a password-based authentication method in the `StashFlow` Flutter app that supports session cookies for both GraphQL requests and media (images/videos) fetching, while maintaining compatibility with the existing API key-based authentication.

## Background
The official Stash server supports two main authentication methods:
1. **API Key**: Passed via `ApiKey` header or `apikey` query parameter.
2. **Session Cookie**: Set by a POST request to `/login` with `username` and `password`.

Currently, `StashFlow` only supports the API Key method.

## Architecture

### 1. New Components

#### `AuthMode` Enum
```dart
enum AuthMode {
  apiKey,
  password,
}
```

#### `AuthService`
A service that uses `Dio` with `dio_cookie_manager` and `PersistCookieJar` to handle:
- `login(String username, String password)`: POST to `/login`.
- `logout()`: GET to `/logout`.
- Access to the shared `CookieJar`.

#### `AuthProvider`
A Riverpod provider that manages:
- Current `AuthMode`.
- Credentials (stored securely using `FlutterSecureStorage`).
- Login status.

### 2. Integration with Existing Systems

#### GraphQL Client (`lib/core/data/graphql/graphql_client.dart`)
- If `AuthMode.apiKey`, continue using `ApiKey` header.
- If `AuthMode.password`, use session cookies. 
- Since `HttpLink` (from `graphql_flutter`) uses the `http` package, we will need to manually sync cookies from `CookieJar` into the `defaultHeaders` or use a custom `Link`.

#### Media Fetching (`lib/core/presentation/widgets/stash_image.dart`)
- `CachedNetworkImage` currently uses `HttpFileService`.
- We will implement `DioFileService` which uses the same `Dio` instance as `AuthService` (sharing the `CookieJar`).
- This ensures that images are fetched with the session cookie.

#### Video Playback
- Video players (like `video_player` or `fvp`) will need to include the session cookie in their HTTP headers when in `password` mode.

### 3. UI Changes
- **Server Settings Page**: 
  - Add an "Authentication Method" selector.
  - Show "API Key" field when in API Key mode.
  - Show "Username" and "Password" fields when in Password mode.
  - Add a "Login" button to test/initiate the session.

### 4. Persistence
- Store `AuthMode` in `SharedPreferences`.
- Store `username`, `password`, and `apiKey` in `FlutterSecureStorage`.
- `PersistCookieJar` will handle cookie persistence across app restarts.

## Implementation Plan

### Step 1: Foundation
- Create `AuthMode` enum.
- Implement `AuthService` with `Dio` and `PersistCookieJar`.
- Create `authProvider` to manage state.

### Step 2: Network Integration
- Implement `DioFileService` for `CachedNetworkImage`.
- Update `graphqlClientProvider` to support session cookies.
- Update `mediaHeadersProvider`.

### Step 3: UI Implementation
- Update `ServerSettingsPage` to support new auth fields.
- Implement login/logout flow in UI.

### Step 4: Testing & Verification
- Unit tests for `AuthService` and `AuthProvider`.
- Integration tests for cookie persistence.
- Verify both API Key and Password modes work independently.

## Security Considerations
- Credentials MUST be stored in `FlutterSecureStorage`.
- Cookies are stored in `PersistCookieJar` which should be stored in a private app directory.
- Sensitive information should never be logged.

---

### 4. 2026-04-17-fullscreen-aspect-ratio-orientation

# Design: Fullscreen Aspect Ratio Orientation Support

This design implements automatic orientation matching based on video aspect ratio in the fullscreen player, with a setting to toggle gravity-controlled (sensor-based) rotation.

## 1. Objectives

- Ensure the fullscreen video player automatically selects the orientation that best fits the video's aspect ratio (landscape for landscape videos, portrait for portrait videos).
- Provide a user setting to toggle whether the device sensor (gravity) can rotate the video between matching orientations (e.g., flipping between landscape left and landscape right).
- Maintain backward compatibility and a clean settings interface.

## 2. Technical Design

### 2.1 State & Preferences

Add `videoGravityOrientation` to the global player state to track the user preference.

- **File:** `lib/features/scenes/presentation/providers/video_player_provider.dart`
- **Class:** `GlobalPlayerState`
- **Field:** `final bool videoGravityOrientation;`
- **Default:** `true`
- **SharedPreferences Key:** `video_gravity_orientation`

Update `PlayerState` notifier to include:
- `setVideoGravityOrientation(bool value)`: Updates the state and persists to `SharedPreferences`.
- Initialization of `videoGravityOrientation` from `SharedPreferences` in `build()`.

### 2.2 Orientation Logic

Modify the orientation selection logic in the fullscreen player.

- **File:** `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- **Component:** `FullscreenPlayerPage`
- **Method:** `_enterFullScreen()`

**Logic:**
1. Retrieve `videoPlayerController` from state.
2. Get `aspectRatio` from `controller.value.aspectRatio`.
3. Retrieve `videoGravityOrientation` from `playerState`.
4. Determine allowed orientations:
   - **If `aspectRatio > 1.0` (Landscape):**
     - If `videoGravityOrientation` is `true`: `[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]`
     - Else: `[DeviceOrientation.landscapeLeft]`
   - **If `aspectRatio <= 1.0` (Portrait/Square):**
     - If `videoGravityOrientation` is `true`: `[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]`
     - Else: `[DeviceOrientation.portraitUp]`
5. Call `SystemChrome.setPreferredOrientations(orientations)`.

### 2.3 Settings UI

Add a new toggle in the playback settings.

- **File:** `lib/features/setup/presentation/pages/settings/playback_settings_page.dart`
- **Section:** Playback Behavior
- **Widget:** `SwitchListTile.adaptive`
- **Label:** `context.l10n.settings_playback_gravity_orientation`
- **Subtitle:** `context.l10n.settings_playback_gravity_orientation_subtitle`

### 2.4 Localization

Update the English ARB file with new keys.

- **File:** `lib/l10n/app_en.arb`
- **Keys:**
  - `settings_playback_gravity_orientation`: "Gravity-controlled orientation"
  - `settings_playback_gravity_orientation_subtitle`: "Allow rotating between matching orientations using the device sensor (e.g. flipping landscape left/right)."

## 3. Testing Strategy

### 3.1 Manual Verification
1. Open a landscape video and enter fullscreen. Verify it enters landscape mode.
2. If gravity control is ON, verify flipping the device 180° rotates the video.
3. If gravity control is OFF, verify it stays in one landscape orientation.
4. Repeat with a portrait video. Verify it enters portrait mode.
5. Verify square videos are treated as portrait (only allowing portrait orientations, even if gravity control is ON).

### 3.2 Automated Tests
- Add a widget test for `PlaybackSettingsPage` to verify the toggle exists and updates the provider.
- Add a unit test for `PlayerState` to verify the new preference is correctly saved and loaded.

---

### 5. 2026-04-17-localization-and-apk-build

# Design Spec: Localization and APK Build

## Overview
Systematically localize hardcoded strings in the `TagsPage` and `SceneFilterPanel`, add missing localization keys to ARB files (including AI-generated translations for all supported languages), and finally build a release APK with split ABI.

## Architecture & Components

### 1. Localization Layer
- **Source Files:**
    - `lib/features/tags/presentation/pages/tags_page.dart`
    - `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`
    - `lib/l10n/app_en.arb` (and all other `.arb` files in `lib/l10n/`)
- **Key Changes:**
    - Replace hardcoded `Text` literals and string parameters with `context.l10n.<key>`.
    - Use `AppLocalizations` (via `context.l10n` extension) to access translated strings.

### 2. ARB Resources
- **New Keys in `app_en.arb`:**
    - `tags_search_placeholder`: "Search tags..."
    - `scenes_duration_short`: "< 5m"
    - `scenes_duration_medium`: "5-20m"
    - `scenes_duration_long`: "> 20m"
- **Translation Strategy:**
    - Automatically generate translations for the new keys across all supported locales: DE, ES, FR, IT, JA, KO, RU, ZH, ZH-Hans, ZH-Hant.
    - Ensure consistency with existing naming conventions (e.g., `nScenes` for plurals).

### 3. Build System
- **Command:** `flutter build apk --release --split-per-abi`
- **Output:** Release APKs for each architecture (armeabi-v7a, arm64-v8a, x86_64).

## Data Flow
1. **Developer (Agent):** Identifies hardcoded strings.
2. **ARB Files:** Updated with new keys and translations.
3. **Code Generation:** `flutter gen-l10n` creates updated `AppLocalizations` classes.
4. **UI Components:** Updated to consume the new localized getters.
5. **Flutter Build:** Compiles the localized app into APKs.

## Testing & Validation
- **Localization Check:** Verify that `flutter gen-l10n` runs without errors and that all updated widgets compile.
- **Visual Verification:** Check that the `TagsPage` and `SceneFilterPanel` display correctly in English.
- **Build Verification:** Ensure the APK build completes successfully and produces the expected artifacts in `build/app/outputs/flutter-apk/`.

## Success Criteria
- Zero hardcoded strings in `TagsPage` and `SceneFilterPanel`.
- Complete ARB coverage for the new keys across all 11 supported locales.
- Successful APK build with `split-per-abi`.

---

### 6. 2026-07-14-windows-window-initialization-fullscreen

# Windows Window Initialization and Fullscreen Design

## Goal

Initialize the Windows window through `window_manager`'s documented ready-to-show lifecycle and make both image and video fullscreen viewers enter true OS fullscreen when the app was maximized.

## Design

Windows startup will create a `WindowOptions` value with the existing 800×600 size and minimum size, then use `waitUntilReadyToShow`. Its callback will maximize, show, and focus the window. Linux and macOS retain their current initialization behavior.

Both fullscreen viewers delegate desktop transitions to the shared `DesktopFullscreen` singleton. The helper calls `windowManager.setFullScreen(true)` and `windowManager.setFullScreen(false)` directly on every desktop platform. On Windows, `window_manager` owns the native transition: it records the current maximized state, frame, and window style when fullscreen begins and restores them when fullscreen ends. The app must not unmaximize first or separately maximize afterward, because doing so changes the state that the plugin records and restores.

## Verification

- A startup source check covers `WindowOptions`, `waitUntilReadyToShow`, maximize, show, and focus.
- A shared-helper test verifies that fullscreen enter and exit delegate only to `window_manager.setFullScreen` without separate maximize, unmaximize, or custom runner calls.
- Existing image and video viewer checks continue proving that both call `DesktopFullscreen.instance.enter()` and `.exit()`.
- Flutter analysis and the focused tests must pass.

## Scope

No plugin fork, custom Windows method channel, new dependency, fullscreen state abstraction, or unrelated window behavior change.

---

### 7. 2026-07-15-android-apk-build-cleanup

# Android APK Build Cleanup

## Goal

Improve Android release correctness and shrinking without changing application features.

## Changes

1. Remove the English-only Android resource configuration. Android and plugin resources will retain every locale supplied by their dependencies, avoiding a manually maintained locale list that can drift from Flutter's supported locales.
2. Remove `WRITE_EXTERNAL_STORAGE` and `requestLegacyExternalStorage`. Gallery writes will continue through the existing `gal` package and modern Android media APIs.
3. Remove the broad ProGuard rules that retain all Flutter plugin and AudioService classes. Manifest entry points and dependency consumer rules will remain responsible for preserving required native classes. Source/line metadata and Kotlin metadata rules will remain.

## Validation

- Add a focused repository test that asserts the obsolete resource filter, storage declarations, and broad keep rules are absent.
- Demonstrate that the test fails against the current configuration before applying production changes.
- Run the focused test after the changes.
- Run Android unit tests and build split release APKs.
- Inspect the merged release manifest to confirm the legacy storage declarations are absent.
- Verify APK signing and 16 KB ZIP alignment.
- Compare release APK sizes with the existing 39 MB arm64, 36 MB armeabi-v7a, and 44 MB x86_64 baselines.

## Scope

The change does not alter cleartext networking, `WRITE_SETTINGS`, media playback dependencies, ABI support, signing credentials, or distribution formats.

---

### 8. 2026-07-15-linux-icon-path

# Linux Icon Path Resolution Design

## Problem

The Linux runner loads `data/app_icon.png` relative to the process working
directory. The build correctly installs the icon beside the executable under
`data/`, but launching the executable from another directory makes the lookup
fail.

## Design

Resolve the running executable through `/proc/self/exe`, take its parent
directory, and append `data/app_icon.png`. Keep the existing CMake bundle
layout and GTK icon-loading behavior unchanged.

If the executable path cannot be resolved or the PNG cannot be decoded, emit a
warning and continue starting the application without a custom window icon.
The icon is cosmetic and must not make startup fatal.

Alternatives considered were embedding the PNG as a GResource and probing
paths relative to the working directory. GResource embedding adds unnecessary
build machinery for one existing asset, while working-directory probes retain
the ambiguity that caused the defect.

## Verification

Add a focused native path-resolution test that supplies an executable path and
expects its sibling `data/app_icon.png` path. Observe the test fail before the
helper exists, then pass after implementation. Build the release Linux bundle
and launch it from the repository root to confirm the previous missing-icon
warning is absent.

---

### 9. 2026-07-16-windows-borderless-fullscreen

# Windows Borderless Fullscreen Design

## Goal

Make image and video fullscreen on Windows cover the entire current monitor with no title bar, caption buttons, resizing frame, or system border, including when fullscreen starts from a maximized window. Exiting fullscreen must restore the exact pre-fullscreen normal or maximized state.

## Root Cause

`DesktopFullscreen` currently delegates Windows transitions to `window_manager` 0.5.2. That plugin records whether the window was maximized, but its Windows implementation only switches the window to its frameless mode when the pre-fullscreen window was not maximized. When fullscreen starts maximized, the caption style remains active, so resizing the window to monitor bounds does not produce a true borderless fullscreen window.

The previous Dart-side maximize, unmaximize, and retry approaches also split ownership of the transition across asynchronous calls. That changes or races the native state which must be captured atomically before fullscreen entry.

## Architecture

`DesktopFullscreen` remains the single Dart API used by the image and video viewers. On Windows it invokes a dedicated `stash_app_flutter/window_fullscreen` method channel with `enter` and `exit` methods. On Linux and macOS it continues delegating to `windowManager.setFullScreen`.

The Windows runner owns one `WindowsFullscreenController` for the top-level `HWND`. The controller is implemented in focused `windows_fullscreen_controller.h` and `.cpp` files rather than mixing Win32 state management into `FlutterWindow`. `FlutterWindow` only registers the channel and converts controller failures into Flutter platform errors.

All Win32 calls run synchronously on Flutter's Windows platform thread. The controller is the sole owner of the Windows fullscreen transition; Dart must not separately maximize, unmaximize, resize, hide the title bar, or retry with delays.

## Entering Fullscreen

If already fullscreen, `Enter()` succeeds without changing state. Otherwise it:

1. Captures a complete `WINDOWPLACEMENT` with `GetWindowPlacement`.
2. Captures the current `GWL_STYLE` and `GWL_EXSTYLE` values.
3. Resolves the nearest display using `MonitorFromWindow(..., MONITOR_DEFAULTTONEAREST)` and obtains its full `rcMonitor` bounds with `GetMonitorInfo`.
4. Removes `WS_OVERLAPPEDWINDOW` from the regular style. This clears `WS_CAPTION`, `WS_THICKFRAME`, `WS_SYSMENU`, `WS_MINIMIZEBOX`, and `WS_MAXIMIZEBOX`, guaranteeing that the Windows title bar and frame disappear.
5. Removes extended edge styles which can draw residual non-client borders: `WS_EX_DLGMODALFRAME`, `WS_EX_WINDOWEDGE`, `WS_EX_CLIENTEDGE`, and `WS_EX_STATICEDGE`.
6. Applies the styles with `SetWindowLongPtr`, then uses `SetWindowPos` with `SWP_FRAMECHANGED` to cover the monitor's physical-pixel bounds.

The window is raised with `HWND_TOP`, not `HWND_TOPMOST`. Fullscreen therefore covers the taskbar during active playback without making StashFlow permanently topmost, changing display resolution, or using exclusive display mode.

If any mutation fails, the controller immediately makes a best-effort rollback to the captured styles and placement and returns an error. It does not report itself as fullscreen unless entry completes.

## Exiting Fullscreen

If not fullscreen, `Exit()` succeeds without changing state. Otherwise it:

1. Restores the exact saved `GWL_STYLE` and `GWL_EXSTYLE` values.
2. Restores the saved `WINDOWPLACEMENT`, including `SW_SHOWMAXIMIZED` when fullscreen began from a maximized window and the exact restored rectangle when it began from a normal window.
3. Calls `SetWindowPos` with `SWP_FRAMECHANGED`, `SWP_NOMOVE`, `SWP_NOSIZE`, and `SWP_NOZORDER` so Windows recalculates the non-client area and redraws the original title bar and frame.

Exit attempts every restoration operation even if one fails. The controller retains the captured state after an incomplete restoration so a subsequent exit request can retry safely. Captured state is cleared only after complete restoration.

## Errors and Lifecycle

Native failures return a `fullscreen_error` platform error containing the failed Win32 operation and `GetLastError()` value. Dart propagates the error to the existing viewer lifecycle, which already logs transition failures. There is no automatic fallback to `window_manager` on Windows because mixing two fullscreen owners could overwrite or lose the saved placement.

The channel handler is removed before the Flutter controller and native fullscreen controller are destroyed. Repeated `enter` and `exit` calls are idempotent.

## Verification

Automated Dart tests must prove:

- Windows `enter` and `exit` invoke only the app-owned channel.
- Linux and macOS retain `window_manager.setFullScreen(true/false)`.
- Native platform errors are propagated rather than followed by plugin fallback calls.
- Both the image viewer and video overlay continue using `DesktopFullscreen`.

Windows-native source/build checks must prove:

- `WS_OVERLAPPEDWINDOW` is removed before monitor-sized placement, which necessarily removes `WS_CAPTION` and the title bar.
- Both normal and extended styles plus `WINDOWPLACEMENT` are saved and restored.
- Full monitor bounds use `rcMonitor`, not `rcWork`.
- `HWND_TOPMOST` is not used.
- The new controller sources are part of the Windows runner target.

Manual Windows acceptance must cover:

1. Start maximized, enter video fullscreen: no title bar or frame is visible and content covers the taskbar; exit returns maximized.
2. Start in a normal window, enter and exit: the original size and position return exactly.
3. Repeat both cases for image fullscreen.
4. Enter fullscreen on a secondary monitor: that monitor is covered and exit restores the window on the same monitor.
5. Toggle fullscreen repeatedly and use Alt+Tab while fullscreen: transitions remain stable and the window is not permanently topmost.

## Scope

This change adds no dependency, display-mode switch, exclusive fullscreen mode, global window-style policy, or non-Windows behavior change. It does not fork `window_manager`; that dependency remains responsible for non-Windows fullscreen and other window-management features.

---

### 10. 2026-07-16-windows-maximized-fullscreen-exit

# Windows Maximized Fullscreen Exit Design

## Goal

Make Windows video and image fullscreen reliably leave app-owned borderless fullscreen when the application entered fullscreen from a maximized window. A successful exit must return to a normal Windows-managed maximized window with its title bar, frame, work-area bounds, and taskbar behavior restored.

## Confirmed Failure

The Windows fullscreen controller saves `WINDOWPLACEMENT`, `GWL_STYLE`, and `GWL_EXSTYLE`, removes the overlapped-window frame, and expands the window to `MONITORINFO.rcMonitor`. When the source window is maximized, the fullscreen style still carries the native maximized state because removing `WS_OVERLAPPEDWINDOW` does not clear `WS_MAXIMIZE`.

The current exit path restores the saved styles and reapplies a saved `SW_SHOWMAXIMIZED` placement while Windows still considers the window maximized. This does not force a show-state transition, so the physical-monitor rectangle established for borderless fullscreen can remain in effect. `SetWindowPos(..., SWP_FRAMECHANGED)` then refreshes that stale maximized geometry instead of establishing a fresh system-managed maximized window.

The Dart video lifecycle compounds the failure by launching native exit without awaiting it and immediately marking fullscreen exited. A native platform error is therefore detached from the fullscreen state machine while the Flutter overlay disappears.

## Native Restore Contract

`WindowsFullscreenController` remains the sole owner of Windows fullscreen geometry and styles. Entry additionally captures whether `IsZoomed(window)` was true before any fullscreen mutation.

Exit restores the saved regular and extended styles first. It then follows one of two paths:

1. If the source window was normal, restore the saved `WINDOWPLACEMENT` directly.
2. If the source window was maximized, call `ShowWindow(window, SW_RESTORE)` to leave the still-active maximized state, restore the saved `WINDOWPLACEMENT`, and call `ShowWindow(window, SW_MAXIMIZE)` to establish a new Windows-managed maximized state.

After either path, call `SetWindowPos` with `SWP_FRAMECHANGED`, `SWP_NOMOVE`, `SWP_NOSIZE`, `SWP_NOZORDER`, and `SWP_NOOWNERZORDER` so Windows recalculates the non-client area without changing the newly restored geometry or z-order.

The maximized transition is synchronous and uses the saved normal rectangle through `WINDOWPLACEMENT`; it does not guess work-area coordinates, add delays, or delegate part of the transition to `window_manager`.

## Verification and Recovery

Native exit must read back `GWL_STYLE` and `GWL_EXSTYLE` after restoration. The values must match the captured styles. The final zoom state must match the captured state: `IsZoomed(window)` must be true for a previously maximized window and false for a previously normal window.

If a Win32 operation or read-back check fails, exit returns a `fullscreen_error`, retains the saved state, and enters the existing restore-pending state so a later exit can retry. Saved state is cleared only after every mutation and verification succeeds.

The controller must attempt all safe restore operations after a failure so a partial restoration has the best chance of returning chrome and useful geometry. Error reporting retains the first failure to identify the original fault.

## Flutter Lifecycle

The video overlay exit operation becomes an awaited `Future<void>`. It marks the provider fullscreen lifecycle exited only after `DesktopFullscreen.exit()` completes. Native failures are recorded in `AppLogStore` and the provider returns to fullscreen state so the overlay remains available for another exit attempt.

The image viewer continues to trigger native restoration from `dispose`, which cannot be asynchronous. Its detached future must handle and log errors so a failed restoration is observable rather than becoming an unhandled asynchronous error.

## Testing

Automated tests must cover:

- The pure Windows restore decision for normal and maximized source windows.
- Maximized restoration requiring a normalize-then-maximize transition.
- Native source preserving read-back verification and restore-pending behavior.
- Video fullscreen lifecycle awaiting native exit before marking exit complete.
- Video native-exit failures being logged and returned to a retryable fullscreen UI state.
- Image viewer detached exit failures being handled.
- Existing Windows channel routing and all non-Windows fullscreen behavior remaining unchanged.

Manual Windows acceptance must verify video and image fullscreen from both normal and maximized windows, repeated toggles, secondary-monitor placement, Alt+Tab, restored title-bar buttons, and taskbar behavior.

## Scope

This change adds no dependency, timer, exclusive display mode, topmost policy, or non-Windows window-management change. It does not replace the dedicated Windows method channel or mix `window_manager` calls into the native Windows transition.

---

## 📊 Sorting, Filtering & Discovery

### 1. 2026-04-18-improve-sort-scene-widget

# Design Spec: Improve Sort Scene Widget

## 1. Overview
The current sort scene widget in `ScenesPage` uses a `Wrap` widget for sort methods, which can grow too large on small screens, pushing important action buttons ("Apply", "Save Default") off-screen. This design improves the layout by constraining the sort method section and ensuring it is scrollable while keeping other elements fixed.

## 2. Requirements
- The "Sort method" section must fit into a smaller, scrollable vertical section.
- "Apply Filter" and "Set Default" buttons must always be visible at the bottom of the sheet.
- The layout must be responsive and work across multiple platforms (Mobile/Desktop).
- Maintain existing functionality: sorting by various fields, toggling direction, and saving defaults.

## 3. Architecture & Components

### Layout Structure (Column)
1. **Header (Fixed)**: 
   - Title: "Sort Scenes"
   - Reset Button: "Reset"
2. **Sort Method Label (Fixed)**: 
   - Label: "Sort method"
3. **Sort Method Section (Scrollable)**: 
   - Container: `Flexible` with `ConstrainedBox` (max height: 250px or 30% of screen height).
   - Scroll View: `SingleChildScrollView` with a `Scrollbar` for desktop visibility.
   - Content: `Wrap` containing `ChoiceChip`s for each `_SceneSortField`.
4. **Direction Section (Fixed)**: 
   - Label: "Direction"
   - Input: `SegmentedButton<bool>` (Ascending/Descending).
5. **Action Buttons (Fixed)**: 
   - Primary: "Apply Sort" (`ElevatedButton`)
   - Secondary: "Save as Default" (`OutlinedButton`)

## 4. Implementation Details

### Scrollable Section
```dart
Flexible(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.3,
    ),
    child: Scrollbar(
      thumbVisibility: true, // Visible on desktop/web
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
        child: Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: _SceneSortField.values.map(...).toList(),
        ),
      ),
    ),
  ),
),
```

### Button Persistence
By using `MainAxisSize.min` on the outer `Column` and wrapping the middle section in `Flexible`, the buttons will stay at the bottom of the sheet even when the middle section scrolls.

## 5. Testing Strategy
- **Manual UI Testing**:
  - Verify scrolling behavior on mobile (touch) and desktop (scroll wheel/scrollbar).
  - Confirm buttons are visible on small screen sizes (e.g., iPhone SE, split-view on Android).
  - Ensure "Reset" properly updates the state within the scrollable section.
- **Regression Testing**:
  - Ensure sorting still triggers the correct data fetch via `_applyServerSort`.
  - Verify "Save as Default" persists the state correctly.

---

### 2. 2026-04-18-reorganize-scene-filter

# Design Spec: Reorganize Scene Filter Widget & Expand Organized Filter

## 1. Overview
The current `SceneFilterPanel` is cluttered, and the "Organized" filter only supports a boolean toggle (Organized vs. All). This design reorganizes the filter fields into logical sections and upgrades the "Organized" filter to support "All", "Organized", and "Unorganized" across all media types.

## 2. Requirements
- Reorganize `SceneFilterPanel` into seven distinct sections.
- In the "General" section, include only "Minimum Rating" and the new "Organized" filter.
- Implement the "Organized" filter as three selectable chips: **All**, **Organized**, and **Unorganized**.
- Apply the same "Organized" filter logic to `GalleryFilterPanel`, `ImageFilterPanel`, and `StudioFilterPanel`.
- Ensure "Unorganized" filters for items where `organized == false`.
- Keep action buttons ("Apply", "Save Default") fixed at the bottom.

## 3. Architecture & Components

### 3.1 Data Structures
- Create a new enum `OrganizedFilter` to represent the three states.
- Update `SceneOrganizedOnly`, `GalleryOrganizedOnly`, and `ImageOrganizedOnly` providers to use this enum instead of a boolean.
- Update `StudioFilter` to handle the enum if possible, or map it to `bool?`.

```dart
enum OrganizedFilter { all, organized, unorganized }
```

### 3.2 UI Sections (SceneFilterPanel)
1. **General**: Rating, Organized Chips.
2. **Performer**: Performers, Performer Tags, Performer Age, Performer Count.
3. **Library**: Studios, Groups, Galleries, Tags, Tag Count.
4. **Metadata**: Code, Details, Director, URL, Date, Path, Captions.
5. **Media Info**: Resolution, Orientation, Duration, Bitrate, Video Codec, Audio Codec, Framerate, File Count.
6. **Usage**: Play Count, Play Duration, O-Counter, Last Played At, Resume Time, Interactive, Interactive Speed.
7. **System**: ID, Stash ID Count, Oshash, Checksum, Phash, Duplicated, Has Markers, Is Missing, Created At, Updated At.

### 3.3 Implementation Details
- **Organized Chips**: Use `ChoiceChip` in a `Wrap` widget.
- **Sectioning**: Use `FilterSection` (custom widget) for each group.
- **Backend Mapping**:
  - `OrganizedFilter.all` -> `null` (no filter applied)
  - `OrganizedFilter.organized` -> `true`
  - `OrganizedFilter.unorganized` -> `false`

## 4. Testing Strategy
- **Manual Verification**:
  - Open each filter panel and verify the "Organized" chips are present and functional.
  - Verify that selecting "Organized" only shows organized items.
  - Verify that selecting "Unorganized" only shows unorganized items.
  - Verify that "All" resets the filter.
  - Check the `SceneFilterPanel` for correct sectioning and field placement.
- **Regression**:
  - Ensure other filters (Rating, Resolution, etc.) still work correctly.
  - Verify "Save as Default" persists the new enum state correctly.

---

### 3. 2026-06-02-entity-saved-presets

# Entity Saved Presets Design

## Goal

Extend the scene-style named saved preset workflow to performers, studios, tags, images, and galleries so each page can save and load server-backed presets containing the current search query, sort field, sort direction, and effective filter state.

## Current Problems

- `ScenesPage` is the only list page with a named preset workflow exposed from the app bar.
- The other list pages only persist a single local default via `SharedPreferences`.
- The current scene implementation is feature-specific, so copying it directly would create six divergent preset flows.
- Several entity pages have effective filter state that spans more than one provider, so a naive reuse of the scene code would miss part of what the user sees on screen.

## Non-Goals

- No change to the existing "save as default" buttons or `SharedPreferences` behavior.
- No new preset delete, rename, or reorder UI.
- No change to server-side saved filter semantics.
- No unrelated refactor of list pages beyond what is needed to support presets cleanly.

## Reference Pattern

`ScenesPage` is the behavioral source of truth:

- bookmark action in the app bar opens a saved presets bottom sheet
- save flow prompts for a preset name and stores the current page state on the server
- load flow restores search query, sort, direction, and filter state, then refreshes the list
- the bottom sheet uses the compact Material 3 layout already implemented for scenes

The new pages should match that behavior exactly.

## Proposed Architecture

Introduce a small shared saved-preset layer under `core` that separates:

1. shared preset UI
2. shared server repository mechanics
3. mode-specific config serialization and page integration

### Shared Preset UI

Create a generic dialog widget that mirrors `SceneSavedFilterDialog` structurally but is parameterized by:

- sheet title
- current config summary data
- async loader for saved presets
- async saver for saved presets
- load callback

This keeps the Material 3 sheet layout in one place and avoids cloning the same widget five more times.

### Shared Saved Config Contract

Define a generic saved preset model that stores:

- optional saved filter id
- preset name
- filter mode
- search query
- sort key
- descending flag
- optional per-page page size
- serialized object filter payload

Mode-specific adapters will handle translation between server payloads and local filter entities.

### Shared Server Repository

Replace the scene-only repository shape with a reusable saved filter repository that can:

- load presets by `FilterMode`
- save a preset for a given `FilterMode`

The repository should stay thin: GraphQL query/mutation plus conversion hooks. Mode-specific logic should remain outside it.

### Mode-Specific Adapters

Each target feature will provide a small adapter/config type that knows how to:

- build a save payload for its filter mode
- parse a saved server payload back into local state
- report the effective filter count for summary display

This keeps page-specific mapping explicit instead of hiding conditional logic inside one large generic serializer.

## Filter Mode Coverage

Add preset support for:

- performers
- studios
- tags
- images
- galleries

Each one should use the server `FilterMode` that matches the page.

## Effective State Rules

Each preset must restore exactly what the user sees as active state on that page.

### Performers

- search query from `performerSearchQueryProvider`
- sort from `performerSortProvider`
- filter from `performerFilterStateProvider`

### Studios

- search query from `studioSearchQueryProvider`
- sort from `studioSortProvider`
- filter from `studioFilterStateProvider`

### Tags

- search query from `tagSearchQueryProvider`
- sort from `tagSortProvider`
- favorites-only filter from `tagFavoritesOnlyProvider`

### Images

- search query from `imageSearchQueryProvider`
- sort from `imageSortProvider`
- filter from `imageFilterStateProvider.filter`
- organized toggle from `imageOrganizedOnlyProvider`

`galleryId` should not be part of named presets because it represents page navigation context, not a reusable list filter. Loading a preset should preserve the current gallery context if the page is already scoped to one.

### Galleries

- search query from `gallerySearchQueryProvider`
- sort from `gallerySortProvider`
- filter from `galleryFilterStateProvider`
- organized toggle from `galleryOrganizedOnlyProvider`

## Page Integration

Each target page should gain:

- a bookmark `IconButton` beside sort/filter actions
- a `_showSavedFilterDialog()` method
- an `_applySavedFilterConfig(...)` method that mirrors scenes

Load behavior must:

- update local sort UI state used by the bottom sheet
- push restored search/filter/sort values into providers
- invalidate the list provider so data refreshes immediately

## UI Behavior

The saved presets sheet should be visually consistent across all six pages:

- same compact bottom-sheet shell as scenes
- same save icon/header action pattern
- same current settings summary
- same bounded presets list
- same name prompt dialog

Only the localized title/summary labels should differ by feature where needed.

## Testing Strategy

Use test-first coverage in three layers:

1. config parsing/serialization unit tests
2. repository tests for mode-aware saved filter loading and saving
3. widget tests for the reusable preset dialog and at least one non-scene page integration path

The tests should prove:

- the right `FilterMode` is queried and saved
- saved payloads round-trip into the correct local filter state
- the dialog still opens the naming prompt before saving
- loading a preset updates providers and refreshes the page state

## Risks

- Object filter key mapping differs by entity, so a shared serializer could silently produce invalid payloads.
- Tags use `favoritesOnly` instead of a full filter object, which is easy to omit during reuse.
- Images and galleries combine normal filter state with organized-only state, and losing either would make loaded presets incomplete.

## Mitigations

- Keep per-entity payload mapping in small dedicated adapters.
- Add explicit round-trip tests for tags, images, and galleries.
- Reuse the existing scene dialog layout rather than rewriting it independently per feature.

## Acceptance Criteria

- Performers, studios, tags, images, and galleries each expose a bookmark action that opens a saved presets sheet.
- Saving a preset stores the current search query, sort, direction, and effective filter state for that page on the server.
- Loading a preset restores those values into local providers and refreshes the corresponding list.
- The preset sheet behavior and layout match `ScenesPage`.
- Existing scene saved preset behavior remains intact.
- New and updated targeted tests pass.

---

## ⚙️ Settings & Configuration

### 1. 2026-04-27-server-profiles

# Spec: Server Profiles

Allow users to save and switch between multiple server configurations (profiles) within the application.

## 1. Data Model

### `ServerProfile` (Model)
```dart
class ServerProfile {
  final String id;
  final String? name;
  final String baseUrl;
  final AuthMode authMode;
  final bool allowWebPasswordLogin;

  ServerProfile({
    required this.id,
    this.name,
    required this.baseUrl,
    required this.authMode,
    this.allowWebPasswordLogin = false,
  });
}
```

## 2. Persistence Strategy

### SharedPreferences (Metadata)
- `server_profiles`: JSON-encoded list of `ServerProfile` objects (excluding credentials).
- `active_server_profile_id`: String ID of the currently selected profile.

### SecureStorage (Credentials)
Credentials will be stored per-profile to ensure isolation:
- `profile_{id}_api_key`
- `profile_{id}_username`
- `profile_{id}_password`

## 3. Migration (v1.12.x -> v1.13.0+)

1. On startup, check for `server_base_url` in legacy `SharedPreferences`.
2. If it exists and no profiles are defined:
   - Generate a new UUID.
   - Create a profile named "Default".
   - Copy legacy credentials from `SecureStorage` (keys: `server_api_key`, `server_username`, `server_password`) to the new profile-scoped keys.
   - Save the "Default" profile and set it as active.
   - (Optional) Clean up legacy keys after successful migration.

## 4. UI/UX (Approach 1: Profile List with Edit Drawer)

### ServerSettingsPage (Main)
- **ListView**: Vertical list of profile cards.
- **Profile Card**:
    - Title: `profile.name ?? profile.baseUrl`
    - Subtitle: `profile.baseUrl` (if name is present)
    - Leading: Active indicator (Radio button or Check icon).
    - Trailing: Connection status icon (Green check / Red error) + "Edit" button.
    - Tap Behavior: Switch active profile and trigger global refresh.
- **FAB**: Floating Action Button `(+)` to open the "Add Profile" drawer.

### Profile Edit Drawer (ModalBottomSheet)
- **Form Fields**:
    - Profile Name (Optional)
    - Server URL
    - Auth Method (Dropdown)
    - Credentials (API Key, Username/Password based on Auth Method)
- **Actions**:
    - **Test Connection**: Attempts a GraphQL `GetVersion` query using current form values.
    - **Delete**: Remove the profile (if not the only one).
    - **Save**: Update SharedPreferences and SecureStorage.

## 5. Technical Implementation Details

### Providers
- `serverProfilesProvider`: StateNotifier managing the list.
- `activeProfileProvider`: Watches the active ID and returns the corresponding profile.
- `serverUrlProvider` / `authProvider`: Updated to read from the `activeProfileProvider`.

### Cache Flushing
The existing `_flushRuntimeCachesAfterServerChange` logic will be invoked whenever the `active_server_profile_id` changes to ensure the app state matches the new server context.

---

### 2. 2026-04-27-simplify-server-url

# Spec: Simplify Server URL Input

## Background
Currently, the application requires (or strongly suggests) that users include the `/graphql` suffix in the server URL input. While the internal logic (`normalizeGraphqlServerUrl`) is already capable of appending this suffix automatically if it is missing, the UI hints and localization examples still show the full endpoint.

## Goals
- Update the UI to encourage entering only the base URL (e.g., `http://localhost:9999`).
- Ensure a seamless transition for existing users who already have the full URL saved.
- Update all localization files to reflect this change.

## Design
### 1. Localization Changes
Update the following keys in `lib/l10n/app_en.arb`:
- `settings_server_url_helper`: Change from "Example format: http(s)://host:port/graphql." to "Example format: http(s)://host:port."
- `settings_server_url_example`: Change from "http://192.168.1.100:9999/graphql" to "http://192.168.1.100:9999"

These changes will be propagated to all other language files using existing project scripts or manual updates.

### 2. UI Changes
In `lib/features/setup/presentation/widgets/server_profile_drawer.dart`:
- Replace the hardcoded `hintText: 'http://localhost:9999/graphql'` with `l10n.settings_server_url_example`.
- Ensure the `hintText` for the URL input is derived from localization.

### 3. Data Compatibility
No changes are required for `normalizeGraphqlServerUrl` in `lib/core/data/graphql/graphql_client.dart` as it already handles:
- Appending `/graphql` if missing.
- Keeping it if already present.

## Verification Plan
1. **Manual Test**: Create a new server profile using only the base URL (e.g., `http://localhost:9999`) and verify it connects successfully.
2. **Regression Test**: Ensure existing profiles with `/graphql` still function correctly.
3. **Build Verification**: Run `flutter build apk --split-per-abi` to ensure no compilation errors.

---

### 3. 2026-07-15-app-config-backup

# App Configuration Backup Design

## Goal

Let users export and fully restore StashFlow's user-facing settings and server profiles on Android, iOS, Linux, macOS, Windows, and web. Credentials are excluded by default and may optionally be included as unencrypted plain text after an explicit warning.

## Scope

The backup includes:

- user-facing settings managed by an explicit typed registry;
- server profiles and the active profile selection;
- API key, username, password, and cookie header for each profile, plus the app-lock passcode, only when the user enables credential export.

The backup excludes caches, cached metadata, logs, cookies outside the profile credential fields, search history, generated state, and other transient or internal preferences.

Import performs a full replacement of the managed configuration. Unmanaged and transient data is left untouched.

## Backup Format

Backups use UTF-8 JSON with a `.stashflow-config.json` suffix. The root object contains:

- `format`: the constant `stashflow-app-config`;
- `schemaVersion`: an integer format version;
- `createdAt`: an ISO-8601 UTC timestamp;
- `appVersion`: the exporting application version;
- `settings`: typed, explicitly supported user-facing settings;
- `serverProfiles`: serialized server profiles;
- `activeServerProfileId`: a profile ID or null;
- `credentials`: omitted unless credential export is enabled; when present it contains a `profiles` object and may contain `appLockPasscode`.

Profile credential entries are keyed by profile ID and may contain `apiKey`, `username`, `password`, and `cookieHeader`. Empty credential values are omitted. The schema never infers credential inclusion from secure-storage contents. When credentials are excluded, imported app-lock settings are normalized to disabled so a restored configuration cannot lock the user out without its passcode.

Unknown fields in a supported schema version are ignored for forward-compatible additions. Missing required fields, wrong value types, duplicate profile IDs, invalid profile URLs, references to missing profiles, invalid active-profile IDs, and unsupported future schema versions are rejected before storage is modified. Older supported versions pass through explicit migrations into the current immutable model.

## Settings Registry

An application configuration registry explicitly declares every exportable preference key, its value type, validation rule, and default/removal behavior. Supported scalar types are boolean, integer, double, string, and string list. Structured user-facing settings receive dedicated codecs instead of being treated as arbitrary strings.

Raw SharedPreferences enumeration and denylist filtering are prohibited. This prevents caches, fallback secure-storage values, newly introduced internal keys, and transient state from entering backups accidentally. A registry coverage test documents the user-facing providers included in the feature and must be updated when a new persisted setting is added.

Server profiles and credentials use their existing typed storage APIs rather than registry entries.

## Services and Boundaries

`AppConfigBackupCodec` owns deterministic JSON encoding, decoding, validation, and schema migration. It has no Flutter UI or storage dependencies.

`AppConfigService` coordinates export and replacement. It depends on SharedPreferences, `AppSecureStorage`, package-version metadata, a clock, and the settings registry through injectable interfaces. It does not open platform dialogs.

`AppConfigDocumentAdapter` transfers bytes to and from the user. Import uses Flutter's endorsed `file_selector`, which supports opening a file on Android, iOS, Linux, macOS, Windows, and web. Export uses a desktop save location on Linux, macOS, and Windows; Android and iOS use the system share/document flow; web uses byte download/share fallback. Platform-specific code is isolated behind conditional implementations so the domain and storage layers never import `dart:io` on web.

The macOS application receives the user-selected read/write file entitlement required by the endorsed selector implementation.

## Export Flow

1. The Storage settings page opens an export options sheet.
2. `Include credentials` is off by default.
3. Enabling it displays a prominent warning that the file contains readable secrets and anyone with the file can access configured servers.
4. The service reads only registry settings, typed profiles, active profile ID, and optionally the known credential keys for those profiles and the app-lock passcode.
5. The codec validates the in-memory model and creates complete UTF-8 bytes before any platform transfer begins.
6. The document adapter saves, shares, or downloads a timestamped file. User cancellation returns a distinct cancelled result and displays no error.

No backup file is written into application storage as an intermediate. Adapters that require a temporary file must use the platform temporary directory and remove the file in a `finally` block.

## Import Flow and Atomicity

1. The document adapter selects one file and enforces a conservative byte-size limit before decoding.
2. The codec parses, migrates, and validates the entire backup without touching storage.
3. The UI previews the creation time, source app version, setting count, profile count, and whether plain-text credentials are present.
4. The user confirms that all managed settings and profiles will be replaced. A backup containing credentials adds an explicit secret-import warning.
5. The service snapshots all current managed settings, profiles, active profile ID, and known profile credentials in memory.
6. It removes managed preference keys, writes imported settings and profiles, removes credentials for all replaced profiles, and then writes imported credentials when present.
7. If any mutation fails, the service restores the complete snapshot. A rollback failure is reported separately and never presented as a successful import.
8. On success, affected Riverpod providers are invalidated from a single coordinator. The UI reports whether an application restart is required for settings that cannot safely refresh live.

Credentials absent from a backup are deleted as part of full replacement. This includes the app-lock passcode; app lock is disabled when no passcode is restored. Unknown secure-storage keys are not enumerated or deleted.

## User Interface

Storage settings gains an `App configuration` section using existing responsive settings components and dynamic dimensions. It provides `Export configuration` and `Import configuration` actions.

Operations use modal sheets consistent with the current settings design. Actions are disabled while work is in progress. Import preview and both credential warnings require explicit confirmation. Messages distinguish invalid JSON, unsupported version, validation failure, file too large, read/write failure, replacement failure with successful rollback, and replacement failure with failed rollback. Picker cancellation is silent.

All new user-visible strings are added to ARB localization files for English, German, Spanish, French, Italian, Japanese, Korean, Russian, and Chinese variants. Generated localization outputs are regenerated through Flutter tooling.

## Security and Privacy

- Credential export is always opt-in and defaults off for every export.
- The UI and backup metadata clearly label included credentials as unencrypted plain text.
- Backup content and credentials are never logged.
- Parse errors do not echo file contents or secrets.
- File size and structural limits prevent unreasonable memory use or deeply nested input.
- Import never accepts arbitrary SharedPreferences or secure-storage keys.
- Temporary files are deleted after the platform handoff where temporary files are unavoidable.

Encryption and cloud synchronization are outside this feature's scope.

## Testing

Codec unit tests cover deterministic round trips, credential omission/inclusion, all supported setting types, malformed JSON, invalid values, duplicate IDs, invalid profile references, old-version migration, unknown future versions, unknown fields, size limits, and secret-safe errors.

Service tests use in-memory preference and secure-storage fakes. They cover export allowlisting, full replacement, removal of absent credentials, write failure at each mutation stage, successful rollback, rollback failure reporting, and provider refresh signaling.

Widget tests cover the default-off credential switch, plain-text warning, export cancellation, import preview, replacement confirmation, credential warning, progress state, success state, and each error category.

Document-adapter contract tests cover byte preservation, filename/MIME metadata, cancellation, desktop save, mobile share, web download, temporary-file cleanup, and operation without `dart:io` on web.

Final verification runs code generation, formatting, analysis, the full Flutter test suite, Android host tests, and Android, Linux, and web release builds available on the current host. Other platform adapters are verified through contract tests and their native project configuration is inspected.

---
