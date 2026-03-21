_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashFlow Navigation & Initial UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up GoRouter for navigation and create the initial YouTube-style Shell (Bottom Navigation Bar and Mini-Player placeholder).

**Architecture:** Clean Architecture (Presentation Layer).

**Tech Stack:** Flutter, GoRouter, Material 3.

---

### Task 1: Set Up GoRouter

**Files:**
- Create: `lib/features/navigation/presentation/router.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Define initial routes and ShellRoute**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../scenes/presentation/pages/scenes_page.dart';
import 'shell_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/scenes',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/scenes',
            builder: (context, state) => const ScenesPage(),
          ),
          // Add other routes (Explore, Subscriptions, Library)
        ],
      ),
    ],
  );
}
```

- [ ] **Step 2: Update main.dart to use router**

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'StashFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: setup gorouter with shell route"
```

---

### Task 2: Create YouTube-style Shell Page

**Files:**
- Create: `lib/features/navigation/presentation/shell_page.dart`
- Create: `lib/features/navigation/presentation/widgets/mini_player.dart`

- [ ] **Step 1: Create MiniPlayer placeholder widget**

```dart
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[900],
      child: const Row(
        children: [
          AspectRatio(aspectRatio: 16/9, child: Placeholder()),
          Expanded(child: Text('Now Playing Placeholder')),
          IconButton(onPressed: null, icon: Icon(Icons.play_arrow)),
          IconButton(onPressed: null, icon: Icon(Icons.close)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create ShellPage with Bottom Navigation**

```dart
class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Library'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: create shell page with mini player and bottom nav"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
