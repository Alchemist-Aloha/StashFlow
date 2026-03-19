_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashAppFlutter GraphQL Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement optimized GraphQL fragments and refactor repositories to use generated classes for better type safety and performance.

**Architecture:** Data Layer refactoring. Moving from manual `gql` strings to `graphql_codegen` generated classes.

**Tech Stack:** Flutter, GraphQL, graphql_codegen, Riverpod.

---

### Task 1: Define GraphQL Fragments for Scenes

**Files:**
- Modify: `lib/features/scenes/data/graphql/scenes.graphql`

- [ ] **Step 1: Add SlimSceneData and SceneData fragments**

```graphql
fragment SlimSceneData on Scene {
  id
  title
  date
  rating100
  o_counter
  organized
  interactive
  resume_time
  play_count
  paths {
    screenshot
    preview
    stream
  }
  studio {
    id
    name
  }
  performers {
    id
    name
  }
}

fragment SceneData on Scene {
  ...SlimSceneData
  details
  path
  urls
  director
  files {
    format
    width
    height
    video_codec
    audio_codec
    bit_rate
  }
  tags {
    id
    name
  }
}

query FindScenes($filter: FindFilterType, $scene_filter: SceneFilterType) {
  findScenes(filter: $filter, scene_filter: $scene_filter) {
    count
    scenes {
      ...SlimSceneData
    }
  }
}

query FindScene($id: ID!) {
  findScene(id: $id) {
    ...SceneData
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenes/data/graphql/scenes.graphql
git commit -m "feat(graphql): define scene fragments and update queries"
```

---

### Task 2: Generate GraphQL Classes

**Files:**
- Generate: `lib/core/data/graphql/__generated__/`

- [ ] **Step 1: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS. Verify files are created in `lib/core/data/graphql/__generated__/`.

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "chore: generate graphql classes"
```

---

### Task 3: Refactor GraphQLSceneRepository

**Files:**
- Modify: `lib/features/scenes/data/repositories/graphql_scene_repository.dart`

- [ ] **Step 1: Update imports and use generated classes**

```dart
import 'package:graphql/client.dart';
import '../../../core/data/graphql/__generated__/scenes.graphql.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';

class GraphQLSceneRepository implements SceneRepository {
  final GraphQLClient client;
  GraphQLSceneRepository(this.client);

  @override
  Future<List<Scene>> findScenes({int? page, int? perPage, String? filter}) async {
    final result = await client.query$FindScenes(
      Options$Query$FindScenes(
        variables: Variables$Query$FindScenes(
          filter: Input$FindFilterType(
            page: page,
            per_page: perPage,
          ),
          scene_filter: filter != null ? Input$SceneFilterType(title: Input$StringCriterionInput(value: filter, modifier: Enum$CriterionModifier.EQUALS)) : null,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findScenes.scenes.map((s) => Scene(
      id: s.id,
      title: s.title ?? '',
      date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
      rating100: s.rating100,
      oCounter: s.o_counter ?? 0,
      organized: s.organized,
      interactive: s.interactive,
      resumeTime: s.resume_time,
      playCount: s.play_count ?? 0,
      files: [], // Slim data doesn't have files
      paths: ScenePaths(
        screenshot: s.paths.screenshot,
        preview: s.paths.preview,
        stream: s.paths.stream,
      ),
      studioId: s.studio?.id,
      studioName: s.studio?.name,
      performerIds: s.performers.map((p) => p.id).toList(),
      performerNames: s.performers.map((p) => p.name).toList(),
      tagIds: [],
      tagNames: [],
    )).toList();
  }

  @override
  Future<Scene> getSceneById(String id) async {
    final result = await client.query$FindScene(
      Options$Query$FindScene(
        variables: Variables$Query$FindScene(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
    final s = result.parsedData!.findScene;
    if (s == null) throw StateError('Scene not found');

    return Scene(
      id: s.id,
      title: s.title ?? '',
      details: s.details,
      path: s.path,
      date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
      rating100: s.rating100,
      oCounter: s.o_counter ?? 0,
      organized: s.organized,
      interactive: s.interactive,
      resumeTime: s.resume_time,
      playCount: s.play_count ?? 0,
      files: s.files.map((f) => SceneFile(
        format: f.format,
        width: f.width,
        height: f.height,
        videoCodec: f.video_codec,
        audioCodec: f.audio_codec,
        bitRate: f.bit_rate,
      )).toList(),
      paths: ScenePaths(
        screenshot: s.paths.screenshot,
        preview: s.paths.preview,
        stream: s.paths.stream,
      ),
      studioId: s.studio?.id,
      studioName: s.studio?.name,
      performerIds: s.performers.map((p) => p.id).toList(),
      performerNames: s.performers.map((p) => p.name).toList(),
      tagIds: s.tags.map((t) => t.id).toList(),
      tagNames: s.tags.map((t) => t.name).toList(),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenes/data/repositories/graphql_scene_repository.dart
git commit -m "refactor: use generated graphql classes in SceneRepository"
```

---

### Task 4: Define Fragments for Performers

**Files:**
- Modify: `lib/features/performers/data/graphql/performers.graphql`

- [ ] **Step 1: Add Performer fragments**

```graphql
fragment PerformerData on Performer {
  id
  name
  disambiguation
  url
  urls
  gender
  birthdate
  ethnicity
  country
  eye_color
  height_cm
  measurements
  fake_tits
  penis_length
  circumcised
  career_start
  career_end
  tattoos
  piercings
  alias_list
  favorite
  image_path
  details
  death_date
  hair_color
  weight
  rating100
}

query FindPerformers($filter: FindFilterType, $performer_filter: PerformerFilterType) {
  findPerformers(filter: $filter, performer_filter: $performer_filter) {
    count
    performers {
      ...PerformerData
    }
  }
}

query FindPerformer($id: ID!) {
  findPerformer(id: $id) {
    ...PerformerData
  }
}
```

- [ ] **Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat(graphql): define performer fragments and update queries"
```

---

### Task 5: Refactor GraphQLPerformerRepository

**Files:**
- Modify: `lib/features/performers/data/repositories/graphql_performer_repository.dart`

- [ ] **Step 1: Use generated classes in PerformerRepository**

(Follow similar pattern as Task 3)

- [ ] **Step 2: Commit**

```bash
git add lib/features/performers/data/repositories/graphql_performer_repository.dart
git commit -m "refactor: use generated graphql classes in PerformerRepository"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
