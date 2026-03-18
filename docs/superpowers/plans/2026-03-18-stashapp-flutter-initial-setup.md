# StashAppFlutter Initial Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the Flutter project and configure core dependencies for Clean Architecture, Riverpod, GoRouter, and GraphQL.

**Architecture:** Per-feature Clean Architecture (Data, Domain, Presentation layers within each feature).

**Tech Stack:** Flutter, Riverpod, GoRouter, graphql_flutter, video_player, chewie.

---

### Task 1: Scaffold Flutter Project

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`

- [ ] **Step 1: Create Flutter project**

Run: `flutter create --org com.github.damontecres --platforms android .`
Expected: SUCCESS

- [ ] **Step 2: Add core dependencies**

Run: `flutter pub add flutter_riverpod go_router graphql_flutter video_player chewie shared_preferences flutter_hooks hooks_riverpod path_provider path`
Expected: SUCCESS

- [ ] **Step 3: Add dev dependencies**

Run: `flutter pub add -d build_runner freezed freezed_annotation json_annotation json_serializable riverpod_generator riverpod_annotation graphql_codegen`
Expected: SUCCESS

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "chore: scaffold flutter project and add dependencies"
```

---

### Task 2: Configure GraphQL Codegen

**Files:**
- Create: `graphql/schema.graphql` (Copy from StashAppAndroid)
- Create: `build.yaml`

- [ ] **Step 1: Create graphql directory and copy schema**

Run: `mkdir -p graphql && cp ../StashAppAndroid/app/src/main/graphql/schema.graphqls graphql/schema.graphql`
Expected: SUCCESS

- [ ] **Step 2: Configure build.yaml for graphql_codegen**

```yaml
targets:
  $default:
    builders:
      graphql_codegen:
        options:
          schema_mapping:
            - schema: graphql/schema.graphql
              queries_glob: lib/**/*.graphql
              output_directory: lib/core/data/graphql/__generated__
```

- [ ] **Step 3: Commit**

```bash
git add graphql/schema.graphql build.yaml
git commit -m "chore: configure graphql codegen and schema"
```

---

### Task 3: Define Initial Directory Structure

**Files:**
- Create: `lib/core/`
- Create: `lib/features/setup/`
- Create: `lib/features/navigation/`

- [ ] **Step 1: Create directory skeleton**

Run: `mkdir -p lib/core/{data,domain,presentation,utils} lib/features/{scenes,performers,studios,tags,galleries,groups,images,setup,navigation}/{data,domain,presentation}`
Expected: SUCCESS

- [ ] **Step 2: Create a placeholder main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StashAppFlutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('StashAppFlutter Placeholder')),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/
git commit -m "chore: initial directory structure and main.dart"
```
