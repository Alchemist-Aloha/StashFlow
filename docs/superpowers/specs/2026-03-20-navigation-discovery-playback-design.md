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
