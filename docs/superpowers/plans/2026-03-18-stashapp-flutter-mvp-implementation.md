_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashFlow MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a functional MVP focused on browsing and playing scenes using Clean Architecture, Riverpod, and Chewie.

**Architecture:** Per-feature Clean Architecture. Entities in Domain, GraphQL Repositories in Data, Riverpod Notifiers and Adaptive Widgets in Presentation.

**Tech Stack:** Flutter, Riverpod, GoRouter, graphql_flutter, video_player, chewie, shared_preferences.

---

### Task 1: Expand Domain Entities & GraphQL Mappings

**Files:**
- Modify: `lib/features/scenes/domain/entities/scene.dart`
- Modify: `lib/features/performers/domain/entities/performer.dart`
- Modify: `lib/features/studios/domain/entities/studio.dart`
- Create: `lib/features/tags/domain/entities/tag.dart`
- Modify: `lib/features/scenes/data/graphql/scenes.graphql`
- Modify: `lib/features/scenes/data/repositories/graphql_scene_repository.dart`

- [ ] **Step 1: Update GraphQL fragments and queries**
    - Modify `lib/features/scenes/data/graphql/scenes.graphql` to implement `SlimSceneData` and `SceneData` fragments.
    - Include technical metadata: `files { format, width, height, video_codec, audio_codec, bit_rate }`.
    - Include rich metadata: `rating100`, `o_counter`, `organized`, `interactive`, `resume_time`, `play_count`.
- [ ] **Step 2: Expand Scene entity with technical and rich metadata**
    - Add fields: `rating100`, `oCounter`, `organized`, `interactive`, `resumeTime`, `playCount`.
    - Add nested types for `SceneFile` (width, height, codec, bitrate) and `ScenePaths`.
- [ ] **Step 3: Define Performer, Studio, and Tag entities**
    - Expand `Performer` with `disambiguation`, `urls`, and basic stats.
    - Expand `Studio` with `disambiguation`, `urls`, and `parent` info.
    - Create a minimal `Tag` entity.
- [ ] **Step 4: Update GraphQLSceneRepository mapping**
    - Update repository to use the generated `SlimSceneData` and `SceneData` types.
- [ ] **Step 5: Run build_runner**
    - Run: `dart run build_runner build --delete-conflicting-outputs`
- [ ] **Step 6: Commit**
    - `git add . && git commit -m "feat: expanded domain entities and graphql optimized fragments"`

---

### Task 2: Adaptive Scene Card & List Pagination

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_card.dart`
- Modify: `lib/features/scenes/presentation/providers/scene_list_provider.dart`
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`

- [ ] **Step 1: Update SceneCard for Adaptive Layout**
    - Add `isGrid` parameter to `SceneCard` (default to false).
    - Implement conditional layout: 1-column (YouTube style) vs 2-column (Grid style).
- [ ] **Step 2: Implement Pagination in SceneListProvider**
    - Transition `SceneList` to support `fetchNextPage`.
    - Maintain a `page` state in the notifier.
- [ ] **Step 3: Add Search functionality to AppBar**
    - Add a search field to `ScenesPage` AppBar.
    - Wire search query to `sceneListProvider`.
- [ ] **Step 4: Commit**
    - `git commit -m "feat: adaptive scene card and paginated list with search"`

---

### Task 3: Scene Detail Page & UI Settings

**Files:**
- Create: `lib/features/scenes/presentation/widgets/expandable_metadata.dart`
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`
- Modify: `lib/setup/presentation/settings_page.dart`

- [ ] **Step 1: Implement "Auto-expand details" setting**
    - Add toggle to `SettingsPage`.
    - Store in `shared_preferences`.
- [ ] **Step 2: Create ExpandableMetadata widget**
    - Shows core metadata (Title, Studio, Date).
    - Expandable section for Tags and Technical info (Resolution, Codec, Bitrate).
- [ ] **Step 3: Assemble SceneDetailsPage layout**
    - Placeholder at top (for VideoPlayer), `ExpandableMetadata` below, scrollable list of Performers.
- [ ] **Step 4: Commit**
    - `git commit -m "feat: scene details layout and auto-expand setting"`

---

### Task 4: Advanced Playback & Mini-Player Sync

**Files:**
- Create: `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- Modify: `lib/features/scenes/presentation/providers/video_player_provider.dart`
- Modify: `lib/features/navigation/presentation/widgets/mini_player.dart`

- [ ] **Step 1: Implement SceneVideoPlayer using Chewie**
    - Create a stateful widget that initializes `VideoPlayerController` and `ChewieController`.
    - Use `sceneStreams` to find the primary HLS or MP4 URL.
- [ ] **Step 2: Global Player State Sync**
    - Update `PlayerState` notifier to hold the active controller.
    - Implement `play(Scene scene)` and `stop()` methods.
- [ ] **Step 3: Mini-Player Implementation**
    - Make `MiniPlayer` reactive to `playerStateProvider`.
    - Show small thumbnail and play/pause button.
- [ ] **Step 4: Persistence across Navigation**
    - Ensure `ShellPage` maintains the `MiniPlayer` instance.
    - When tapping MiniPlayer -> Detail, ensure the player instance is handed back to the detail page.
- [ ] **Step 5: Commit**
    - `git commit -m "feat: chewie integration and persistent playback sync"`

---

### Task 5: Automated Testing & Validation

**Files:**
- Create: `test/features/scenes/domain/entities/scene_test.dart`
- Create: `test/features/scenes/presentation/providers/scene_list_test.dart`

- [ ] **Step 1: Unit Tests for Entity Parsing**
    - Verify `Scene` and `Performer` entities handle null/missing fields from JSON correctly.
- [ ] **Step 2: Mock Repository for UI Testing**
    - Create a `MockSceneRepository`.
    - Test `ScenesPage` states: Loading, Error (network fail), Empty, and Success.
- [ ] **Step 3: Run all tests**
    - Run: `flutter test`
- [ ] **Step 4: Commit**
    - `git commit -m "test: unit and widget tests for core features"`

---

### Task 6: Final MVP Verification

- [ ] **Step 1: End-to-End Test**
    - Connect to real Stash server.
    - Verify: Browse -> Search -> Play -> Navigate Back (MiniPlayer) -> Resume.
- [ ] **Step 2: Commit**
    - `git commit -m "chore: final mvp verification and polish"`

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
