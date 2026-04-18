# Scraping and Stashbox Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement scene, performer, and studio scraping features, including plugin and Stashbox scrapers, and perpetual hash generation.

**Architecture:** 
1. Enhance Repository layer (Domain and Data) to support performer and studio scraping, and phash generation.
2. Enhance Presentation layer (Providers) to expose new features.
3. Build a comprehensive `ScrapeDialog` and Stashbox query UI in Flutter.
4. Integrate "Generate PHash" and "Query Stashbox by Fingerprint" into Scene Edit page.

**Tech Stack:** Flutter, Riverpod, GraphQL (ferry/graphql_flutter)

---

### Task 1: Update Domain Models and Repository Interfaces

**Files:**
- Modify: `lib/features/scenes/domain/models/scraped_scene.dart`
- Modify: `lib/features/scenes/domain/repositories/scene_repository.dart`
- Modify: `lib/features/performers/domain/repositories/performer_repository.dart`
- Modify: `lib/features/studios/domain/repositories/studio_repository.dart`

- [ ] **Step 1: Add `ScrapedStudio` model to `scraped_scene.dart`**
- [ ] **Step 2: Add scraping and phash methods to `SceneRepository`**
- [ ] **Step 3: Add `scrapePerformer` to `PerformerRepository`**
- [ ] **Step 4: Add `scrapeStudio` to `StudioRepository`**

### Task 2: Implement Data Layer Enhancements

**Files:**
- Modify: `lib/features/scenes/data/repositories/graphql_scene_repository.dart`
- Modify: `lib/features/performers/data/repositories/graphql_performer_repository.dart`
- Modify: `lib/features/studios/data/repositories/graphql_studio_repository.dart`

- [ ] **Step 1: Implement `generatePhash` in `GraphQLSceneRepository`**
- [ ] **Step 2: Implement `scrapeSinglePerformer` in `GraphQLPerformerRepository`**
- [ ] **Step 3: Implement `scrapeSingleStudio` in `GraphQLStudioRepository`**
- [ ] **Step 4: Update `listScrapers` to support filtering by types correctly**

### Task 3: Enhance Presentation Layer Providers

**Files:**
- Modify: `lib/features/scenes/presentation/providers/scene_scrape_provider.dart`
- Create: `lib/features/performers/presentation/providers/performer_scrape_provider.dart`
- Create: `lib/features/studios/presentation/providers/studio_scrape_provider.dart`

- [ ] **Step 1: Add `generatePhash` and Stashbox query methods to `SceneScrapeNotifier`**
- [ ] **Step 2: Create `PerformerScrapeNotifier` and provider**
- [ ] **Step 3: Create `StudioScrapeNotifier` and provider**

### Task 4: Build Enhanced Scrape UI

**Files:**
- Create: `lib/features/scenes/presentation/widgets/scrape_query_dialog.dart`
- Create: `lib/features/scenes/presentation/widgets/enhanced_scrape_dialog.dart`

- [ ] **Step 1: Create `ScrapeQueryDialog` for manual query input and Stashbox endpoint selection**
- [ ] **Step 2: Create `EnhancedScrapeDialog` for merging scraped data with existing fields (matching original webapp's functionality)**

### Task 5: Integrate into Scene Edit Page

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scene_edit_page.dart`

- [ ] **Step 1: Replace simple `_scrape` with the new enhanced scraping flow**
- [ ] **Step 2: Add "Generate PHash" button and logic**
- [ ] **Step 3: Add "Query Stashbox by Fingerprint" logic**

### Task 6: Implement Performer and Studio Edit Page Scraping

**Files:**
- Modify: `lib/features/performers/presentation/pages/performer_edit_page.dart` (if exists)
- Modify: `lib/features/studios/presentation/pages/studio_edit_page.dart` (if exists)

- [ ] **Step 1: Add scraping feature to Performer Edit Page**
- [ ] **Step 2: Add scraping feature to Studio Edit Page**

---
