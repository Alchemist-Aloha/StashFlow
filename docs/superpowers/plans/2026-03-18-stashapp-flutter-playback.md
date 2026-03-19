_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashAppFlutter Detail Pages & Playback Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement scene details and video playback with a persistent YouTube-style mini-player.

**Architecture:** Clean Architecture (Presentation Layer + State Management).

**Tech Stack:** Flutter, Riverpod, GoRouter, video_player, chewie.

---

### Task 1: Video Player State Management

**Files:**
- Create: `lib/features/scenes/presentation/providers/video_player_provider.dart`

- [ ] **Step 1: Define PlayerState and ActiveScene provider**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import 'package:video_player/video_player.dart';

part 'video_player_provider.g.dart';

@riverpod
class PlayerState extends _$PlayerState {
  @override
  Scene? build() => null;

  void playScene(Scene scene) {
    state = scene;
  }

  void stop() {
    state = null;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: setup video player state provider"
```

---

### Task 2: Implement Scene Details Page

**Files:**
- Create: `lib/features/scenes/presentation/pages/scene_details_page.dart`
- Modify: `lib/features/navigation/presentation/router.dart`

- [ ] **Step 1: Create SceneDetailsPage with placeholder video**

```dart
class SceneDetailsPage extends ConsumerWidget {
  final String sceneId;
  const SceneDetailsPage({required this.sceneId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch scene by ID if not in state
    return Scaffold(
      appBar: AppBar(title: const Text('Scene Details')),
      body: Column(
        children: [
          const AspectRatio(aspectRatio: 16/9, child: Placeholder()), // Video Player
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scene Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Studio Name • 2024', style: TextStyle(color: Colors.grey)),
                const Divider(height: 32),
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Performer Name')),
                    OutlinedButton(onPressed: () {}, child: const Text('Follow')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add Route to GoRouter**

```dart
GoRoute(
  path: '/scene/:id',
  builder: (context, state) => SceneDetailsPage(sceneId: state.pathParameters['id']!),
),
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: implement scene details page and routing"
```

---

### Task 3: Connect MiniPlayer to State

**Files:**
- Modify: `lib/features/navigation/presentation/widgets/mini_player.dart`

- [ ] **Step 1: Make MiniPlayer reactive**

```dart
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScene = ref.watch(playerStateProvider);
    if (activeScene == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/scene/${activeScene.id}'),
      child: Container(
        height: 60,
        color: Colors.grey[900],
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(activeScene.thumbUrl ?? '', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Placeholder()),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(activeScene.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
            IconButton(onPressed: () => ref.read(playerStateProvider.notifier).stop(), icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: connect mini player to active scene state"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
