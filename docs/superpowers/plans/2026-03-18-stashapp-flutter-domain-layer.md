_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashFlow Domain Layer & Core State Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Define domain entities and repository interfaces for core features (Scenes, Performers, Studios) and set up Riverpod state management.

**Architecture:** Clean Architecture (Domain Layer).

**Tech Stack:** Flutter, Riverpod, Freezed.

---

### Task 1: Define Core Domain Entities (Scene, Performer, Studio)

**Files:**
- Create: `lib/features/scenes/domain/entities/scene.dart`
- Create: `lib/features/performers/domain/entities/performer.dart`
- Create: `lib/features/studios/domain/entities/studio.dart`

- [ ] **Step 1: Define Scene entity with Freezed**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene.freezed.dart';

@freezed
class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String title,
    String? details,
    String? path,
    required DateTime date,
    required double rating,
    required List<String> tags,
    required List<String> performers,
    required String? studio,
    required String? streamUrl,
    required String? thumbUrl,
  }) = _Scene;
}
```

- [ ] **Step 2: Define Performer entity**

```dart
@freezed
class Performer with _$Performer {
  const factory Performer({
    required String id,
    required String name,
    String? details,
    String? gender,
    required String? birthdate,
    required String? imagePath,
    required List<String> tags,
  }) = _Performer;
}
```

- [ ] **Step 3: Define Studio entity**

```dart
@freezed
class Studio with _$Studio {
  const factory Studio({
    required String id,
    required String name,
    String? details,
    required String? imagePath,
  }) = _Studio;
}
```

- [ ] **Step 4: Run build_runner to generate files**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: define core domain entities"
```

---

### Task 2: Define Repository Interfaces

**Files:**
- Create: `lib/features/scenes/domain/repositories/scene_repository.dart`
- Create: `lib/features/performers/domain/repositories/performer_repository.dart`

- [ ] **Step 1: Define SceneRepository interface**

```dart
import '../entities/scene.dart';

abstract class SceneRepository {
  Future<List<Scene>> findScenes({int? page, int? perPage, String? filter});
  Future<Scene> getSceneById(String id);
}
```

- [ ] **Step 2: Define PerformerRepository interface**

```dart
import '../entities/performer.dart';

abstract class PerformerRepository {
  Future<List<Performer>> findPerformers({int? page, int? perPage, String? filter});
  Future<Performer> getPerformerById(String id);
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: define repository interfaces"
```

---

### Task 3: Set Up Riverpod Notifiers (AsyncNotifier)

**Files:**
- Create: `lib/features/scenes/presentation/providers/scene_list_provider.dart`

- [ ] **Step 1: Create SceneListProvider using Riverpod Generator**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';

part 'scene_list_provider.g.dart';

@riverpod
class SceneList extends _$SceneList {
  @override
  FutureOr<List<Scene>> build() async {
    final repository = ref.watch(sceneRepositoryProvider);
    return repository.findScenes();
  }
}

// Provider for Repository interface (to be implemented later)
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  throw UnimplementedError();
});
```

- [ ] **Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: setup riverpod notifiers for scenes"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
