_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashAppFlutter GraphQL API Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the data layer using GraphQL to fetch real data from the Stash server.

**Architecture:** Clean Architecture (Data Layer).

**Tech Stack:** Flutter, graphql_flutter, graphql_codegen, Riverpod.

---

### Task 1: Setup GraphQL Client & Configuration [DONE]

**Files:**
- Create: `lib/core/data/graphql/graphql_client.dart`
- Create: `lib/features/setup/domain/entities/server_config.dart`

- [x] **Step 1: Define ServerConfig entity**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_config.freezed.dart';

@freezed
class ServerConfig with _$ServerConfig {
  const factory ServerConfig({
    required String baseUrl,
    required String apiKey,
  }) = _ServerConfig;
}
```

- [x] **Step 2: Create GraphQL Client provider**

```dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'graphql_client.g.dart';

@riverpod
GraphQLClient graphqlClient(GraphqlClientRef ref) {
  // TODO: Fetch from shared preferences (Task 5 of setup)
  // Hardcoded for now for development
  const serverUrl = 'http://localhost:9999/graphql';
  const apiKey = '';

  final HttpLink httpLink = HttpLink(
    serverUrl,
    defaultHeaders: {
      'ApiKey': apiKey,
    },
  );

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  );
}
```

- [x] **Step 3: Run build_runner**

Run: `/home/likun/develop/flutter/bin/dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS

- [x] **Step 4: Commit**

```bash
git add .
git commit -m "feat: setup graphql client provider"
```

---

### Task 2: Create GraphQL Query Files

**Files:**
- Create: `lib/features/scenes/data/graphql/scenes.graphql`
- Create: `lib/features/performers/data/graphql/performers.graphql`

- [ ] **Step 1: Create Scene queries (Copy-paste logic from StashAppAndroid)**

```graphql
query FindScenes($filter: SceneFilterType, $scene_filter: SceneListFilterType) {
  findScenes(filter: $filter, scene_filter: $scene_filter) {
    count
    scenes {
      id
      title
      details
      path
      date
      rating
      # Add other fields as needed based on fragment
    }
  }
}
```

- [ ] **Step 2: Create Performer queries**

```graphql
query FindPerformers($filter: PerformerFilterType, $performer_filter: PerformerListFilterType) {
  findPerformers(filter: $filter, performer_filter: $performer_filter) {
    count
    performers {
      id
      name
      details
      image_path
    }
  }
}
```

- [ ] **Step 3: Run build_runner to generate GraphQL classes**

Run: `/home/likun/develop/flutter/bin/dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "feat: create graphql query files"
```

---

### Task 3: Implement GraphQL Repositories

**Files:**
- Create: `lib/features/scenes/data/repositories/graphql_scene_repository.dart`
- Modify: `lib/features/scenes/presentation/providers/scene_list_provider.dart`

- [ ] **Step 1: Implement GraphQLSceneRepository**

```dart
class GraphQLSceneRepository implements SceneRepository {
  final GraphQLClient client;
  GraphQLSceneRepository(this.client);

  @override
  Future<List<Scene>> findScenes({int? page, int? perPage, String? filter}) async {
    final result = await client.query$FindScenes(
      Options$Query$FindScenes(
        variables: Variables$Query$FindScenes(
          filter: Input$SceneFilterType(
            page: page,
            per_page: perPage,
          ),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
    
    return result.parsedData!.findScenes.scenes.map((s) => Scene(
      id: s.id,
      title: s.title ?? '',
      date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
      rating: s.rating?.toDouble() ?? 0.0,
      tags: [], // Map tags
      performers: [], // Map performers
      studio: null,
      streamUrl: null,
      thumbUrl: null,
    )).toList();
  }

  @override
  Future<Scene> getSceneById(String id) {
    // Implement getSceneById
    throw UnimplementedError();
  }
}
```

- [ ] **Step 2: Update Provider to use implementation**

Modify `lib/features/scenes/presentation/providers/scene_list_provider.dart`:
```dart
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLSceneRepository(client);
});
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: implement graphql scene repository"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
