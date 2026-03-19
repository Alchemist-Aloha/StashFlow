_Historical note (2026-03-19): This document is retained for planning/spec context and may not reflect the current implementation exactly._

# StashAppFlutter UI Implementation (Scenes List) Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Scenes List UI using the real data from the GraphQL repository, emulating a YouTube-style mobile experience.

**Architecture:** Clean Architecture (Presentation Layer).

**Tech Stack:** Flutter, Riverpod, Material 3.

---

### Task 1: Create Video Card Widget

**Files:**
- Create: `lib/features/scenes/presentation/widgets/scene_card.dart`

- [ ] **Step 1: Implement SceneCard widget**

```dart
class SceneCard extends StatelessWidget {
  final Scene scene;
  const SceneCard({required this.scene, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            scene.thumbUrl ?? 'https://via.placeholder.com/320x180',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Placeholder(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 20, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${scene.studio ?? "Unknown Studio"} • ${scene.date.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: create scene card widget"
```

---

### Task 2: Implement Scenes Page with Riverpod

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`

- [ ] **Step 1: Connect ScenesPage to SceneListProvider**

```dart
class ScenesPage extends ConsumerWidget {
  const ScenesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenesAsync = ref.watch(sceneListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stash'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.cast)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 20)),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(sceneListProvider.future),
        child: scenesAsync.when(
          data: (scenes) => ListView.builder(
            itemCount: scenes.length,
            itemBuilder: (context, index) => SceneCard(scene: scenes[index]),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: implement scenes page with riverpod"
```

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [../../UIGUIDELINE.md](../../UIGUIDELINE.md) for current UI standards.
