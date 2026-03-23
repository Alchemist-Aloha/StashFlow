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
