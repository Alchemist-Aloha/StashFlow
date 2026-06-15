# Interaction-Driven VTT Loading Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove eager scene-card VTT requests and load sprite metadata only on the first scrubbing interaction.

**Architecture:** Scene cards use the GraphQL VTT URL only as a capability hint. `ScrubbingPreview` performs the authoritative interaction-driven load, while `VttService` caches results and shares concurrent requests.

**Tech Stack:** Flutter, Riverpod, package:http, flutter_test

---

### Task 1: Specify scene-card interaction behavior

**Files:**
- Modify: `test/features/scenes/presentation/widgets/scene_card_test.dart`

- [ ] Add a counting `VttService` test double.
- [ ] Verify card construction performs zero fetches.
- [ ] Verify first horizontal drag starts one fetch.
- [ ] Verify a VTT URL remains usable when `paths.sprite` is null.
- [ ] Run the focused test and confirm the new expectations fail.

### Task 2: Make scene-card VTT loading interaction-driven

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_card.dart`

- [ ] Remove initialization and widget-update VTT probes.
- [ ] Use non-empty VTT URL plus positive duration as the capability hint.
- [ ] Mount `ScrubbingPreview` only while interaction is active.
- [ ] Mark the card unavailable when the preview reports no usable cues.
- [ ] Run the focused widget test and confirm it passes.

### Task 3: Deduplicate VTT requests

**Files:**
- Modify: `lib/core/utils/vtt_service.dart`
- Create: `test/core/utils/vtt_service_test.dart`

- [ ] Add a failing test issuing two concurrent requests for one URL.
- [ ] Inject an HTTP client into `VttService`.
- [ ] Track in-flight futures by effective URL and remove them on completion.
- [ ] Keep the existing completed-result cache behavior.
- [ ] Run the focused service test and confirm it passes.

### Task 4: Verify

**Files:**
- No additional files.

- [ ] Format changed Dart files.
- [ ] Run both focused test files.
- [ ] Run `flutter analyze`.
- [ ] Inspect the final diff for unrelated changes.
