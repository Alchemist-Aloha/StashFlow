# Advanced Sorting and Filtering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all sorting and filtering features from the original Stash webapp in StashFlow with a mobile-friendly UI.

**Architecture:**
1.  **Unified Criterion System:** Create generic models for different types of filters (Int, String, Date, Multi-select) to handle various Stash criteria.
2.  **Expanded Entity Filters:** Update `SceneFilter`, `PerformerFilter`, `StudioFilter`, and `GalleryFilter` to include all webapp options.
3.  **Repository Updates:** Enhance GraphQL repositories to translate these new filters into Stash's GraphQL input types.
4.  **Mobile UI:** Implement a scrollable, organized filter panel with common filters easily accessible and advanced filters in expandable sections.

**Tech Stack:** Flutter, Riverpod, GraphQL (ferry/graphql_flutter), Freezed.

---

### Task 1: Define Unified Criterion Models

**Files:**
- Create: `lib/core/domain/entities/criterion.dart`

- [ ] **Step 1: Create generic criterion models**
    Define `IntCriterion`, `StringCriterion`, `DateCriterion`, `MultiCriterion`, and `HierarchicalMultiCriterion` with modifiers (EQUALS, NOT_EQUALS, GREATER_THAN, etc.).

### Task 2: Expand Scene Filtering

**Files:**
- Modify: `lib/features/scenes/domain/entities/scene_filter.dart`
- Modify: `lib/features/scenes/data/repositories/graphql_scene_repository.dart`

- [ ] **Step 1: Update `SceneFilter`**
    Add missing fields like `oCount`, `lastPlayedAt`, `interactive`, `interactiveSpeed`, `performerAge`, `bitrate`, `framerate`, `videoCodec`, `audioCodec`, `oshash`, `checksum`, `phash`, `hasMarkers`, `isMissing`, `fileCount`.
- [ ] **Step 2: Update `GraphQLSceneRepository`**
    Update `_runFindScenes` to map all new `SceneFilter` fields to `Input$SceneFilterType`.

### Task 3: Implement Performer, Studio, and Gallery Filters

**Files:**
- Create: `lib/features/performers/domain/entities/performer_filter.dart`
- Create: `lib/features/studios/domain/entities/studio_filter.dart`
- Create: `lib/features/galleries/domain/entities/gallery_filter.dart` (Expand existing)
- Modify: Repositories for these entities.

- [ ] **Step 1: Create filter entities for each feature**
    Mirror the webapp's criteria for Performers (age, height, weight, gender, etc.), Studios (parent studio, subsidiary count, etc.), and Galleries.
- [ ] **Step 2: Update repositories to support these filters**
    Ensure `findPerformers`, `findStudios`, and `findGalleries` use the new filter entities.

### Task 4: Advanced Sorting Options

**Files:**
- Modify: `lib/features/scenes/presentation/providers/scene_list_provider.dart` (and other list providers)

- [ ] **Step 1: Expand `sortBy` options**
    Include all webapp sort options (bitrate, framerate, play_count, etc.) in the providers and UI.

### Task 5: Mobile-Friendly Filter UI

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_filter_panel.dart`
- Create: `lib/features/performers/presentation/widgets/performer_filter_panel.dart`
- Create: `lib/features/studios/presentation/widgets/studio_filter_panel.dart`

- [ ] **Step 1: Redesign `FilterPanel`**
    - Use a `DraggableScrollableSheet` for the panel.
    - Group filters by category (General, Media Info, Performance).
    - Use expandable sections (`ExpansionTile`) for advanced filters.
    - Implement a "Clear All" and "Save Default" functionality.
- [ ] **Step 2: Create picker widgets for multi-select criteria**
    - Implement entity pickers (Performers, Studios, Tags) that support multi-selection with "Include/Exclude" modifiers.

### Task 6: Verification

- [ ] **Step 1: Verify all sorting options work as expected**
- [ ] **Step 2: Verify complex filter combinations return correct results**
- [ ] **Step 3: Ensure the UI remains responsive and usable on small screens**
