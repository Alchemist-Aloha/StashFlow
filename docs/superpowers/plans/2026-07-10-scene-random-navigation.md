# Scene Random Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add one shared setting and one shared backend-random scene navigation path for the scene list page, scene details page, and fullscreen scene player without mutating the main playback queue.

**Architecture:** Reuse `SceneList.getRandomScene(...)` as the only backend-random resolver and add one thin Riverpod controller that reads the new preference and forwards the correct `useCurrentFilter` mode. Wire all three scene-random UI entry points to that controller, and keep queue state unchanged by navigating directly instead of calling queue mutation APIs.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, GoRouter, flutter_test

## Global Constraints

- Add a persisted setting that controls whether scene-random navigation respects the active scene filters.
- When the setting is `true`, random scene resolution must use the active scene search query, scene filter state, and organized filter state.
- When the setting is `false`, random scene resolution must ignore those active scene filters and resolve from the full scene set.
- Every scene-random action must resolve a true random scene from the backend. None of them may sample from the currently loaded client list.
- Random navigation must not rewrite or replace the current playback queue. The main queue should continue to represent the main scene list page state.
- Random navigation should avoid returning the currently open scene when an exclusion id is available.
- Existing empty-state behavior should stay consistent: if no random scene is available, show the existing no-random snackbar/message.
- This controller is the only shared abstraction for scene-random UI. Do not add a separate store, repository, service, or queue layer for this feature.
- Persist it with the same shared-preferences provider pattern already used by other interface settings so scene pages and player controls watch one source of truth. Do not add a separate settings store just for this bool.
- The feature should land as a small diff over existing scene navigation and preference patterns, not as a new generic navigation framework.

---

## File Map

- Modify `lib/features/setup/presentation/providers/navigation_customization_provider.dart`
  - Add the persisted `sceneRandomRespectActiveFilterProvider` bool next to the existing random-navigation visibility provider.
- Modify `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`
  - Load, render, and save the new toggle in the Interface navigation section.
- Modify `lib/l10n/app_en.arb`
  - Add the new Interface settings title and subtitle strings.
- Create `lib/features/scenes/presentation/providers/scene_random_navigation_provider.dart`
  - Hold the thin shared controller that reads the preference and calls `SceneList.getRandomScene(...)`.
- Modify `lib/features/scenes/presentation/pages/scenes_page.dart`
  - Remove loaded-list random sampling and call the shared controller instead.
- Modify `lib/features/scenes/presentation/pages/scene_details_page.dart`
  - Replace the hardcoded `useCurrentFilter: true` branch with the shared controller.
- Modify `lib/features/scenes/presentation/widgets/native_video_controls.dart`
  - Accept and render a fullscreen-only random callback/button.
- Modify `lib/features/scenes/presentation/widgets/player_surface.dart`
  - Thread the random callback into `NativeVideoControls`.
- Modify `lib/features/scenes/presentation/widgets/scene_video_player.dart`
  - Provide the fullscreen random callback for inline/fullscreen scene playback.
- Modify `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`
  - Pass the same random callback for the global fullscreen scene surface.
- Create `test/features/setup/presentation/providers/navigation_customization_provider_test.dart`
  - Cover default and persisted values for the new bool provider.
- Modify `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`
  - Cover the new toggle label, default state, and saved preference.
- Create `test/features/scenes/presentation/providers/scene_random_navigation_provider_test.dart`
  - Cover filter-aware and unfiltered forwarding into `SceneList.getRandomScene(...)`.
- Create `test/features/scenes/presentation/pages/scene_random_navigation_test.dart`
  - Cover scenes-page and details-page random navigation using the shared controller and assert the main playback queue stays unchanged.
- Modify `test/features/scenes/presentation/widgets/native_video_controls_test.dart`
  - Cover fullscreen random button visibility and callback execution.

### Task 1: Add the shared preference and Interface settings toggle

**Files:**
- Modify: `lib/features/setup/presentation/providers/navigation_customization_provider.dart`
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`
- Modify: `lib/l10n/app_en.arb`
- Create: `test/features/setup/presentation/providers/navigation_customization_provider_test.dart`
- Modify: `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`

**Interfaces:**
- Consumes: `sharedPreferencesProvider`
- Produces: `sceneRandomRespectActiveFilterProvider`, `sceneRandomRespectActiveFilterProvider.notifier.set(bool value)`

- [ ] **Step 1: Write the failing provider test**

```dart
test('scene random respect filter defaults to enabled and persists updates', () async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  expect(container.read(sceneRandomRespectActiveFilterProvider), isTrue);

  container
      .read(sceneRandomRespectActiveFilterProvider.notifier)
      .set(false);

  expect(container.read(sceneRandomRespectActiveFilterProvider), isFalse);
  expect(prefs.getBool('scene_random_respect_active_filter'), isFalse);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk flutter test test/features/setup/presentation/providers/navigation_customization_provider_test.dart`
Expected: FAIL with `Undefined name 'sceneRandomRespectActiveFilterProvider'`.

- [ ] **Step 3: Implement the minimal provider**

```dart
@riverpod
class SceneRandomRespectActiveFilter
    extends _$SceneRandomRespectActiveFilter {
  static const _storageKey = 'scene_random_respect_active_filter';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  void set(bool value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_storageKey, value);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `rtk flutter test test/features/setup/presentation/providers/navigation_customization_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Write the failing Interface settings widget test**

```dart
testWidgets('InterfaceSettingsPage saves the random filter toggle', (tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await pumpTestWidget(
    tester,
    prefs: prefs,
    child: const InterfaceSettingsPage(),
  );
  await tester.pumpAndSettle();

  expect(find.text('Respect active filters for random scene'), findsOneWidget);

  final toggle = find.descendant(
    of: find.widgetWithText(
      SwitchListTile,
      'Respect active filters for random scene',
    ),
    matching: find.byType(Switch),
  );

  expect(tester.widget<Switch>(toggle).value, isTrue);

  await tester.tap(toggle);
  await tester.pumpAndSettle();

  expect(prefs.getBool('scene_random_respect_active_filter'), isFalse);
});
```

- [ ] **Step 6: Run test to verify it fails**

Run: `rtk flutter test test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`
Expected: FAIL because the new label and toggle are not rendered.

- [ ] **Step 7: Implement the minimal settings wiring**

```dart
bool _sceneRandomRespectActiveFilter = true;

Future<void> _load() async {
  _showRandomNavigation = ref.read(randomNavigationEnabledProvider);
  _sceneRandomRespectActiveFilter = ref.read(
    sceneRandomRespectActiveFilterProvider,
  );
  // existing loads...
}

Future<void> _saveSettings() async {
  ref
      .read(sceneRandomRespectActiveFilterProvider.notifier)
      .set(_sceneRandomRespectActiveFilter);
  // existing saves...
}

// lib/l10n/app_en.arb
"settings_interface_random_scene_filter": "Respect active filters for random scene",
"settings_interface_random_scene_filter_subtitle": "When enabled, random scene navigation uses the current scene filters.",

SwitchListTile.adaptive(
  contentPadding: EdgeInsets.zero,
  title: Text(context.l10n.settings_interface_random_scene_filter),
  subtitle: Text(
    context.l10n.settings_interface_random_scene_filter_subtitle,
  ),
  value: _sceneRandomRespectActiveFilter,
  onChanged: (value) async {
    setState(() => _sceneRandomRespectActiveFilter = value);
    await _saveSettings();
  },
),
```

- [ ] **Step 8: Run tests to verify they pass**

Run: `rtk flutter gen-l10n && rtk flutter test test/features/setup/presentation/providers/navigation_customization_provider_test.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`
Expected: PASS.

- [ ] **Step 9: Commit**

```bash
rtk git add \
  lib/features/setup/presentation/providers/navigation_customization_provider.dart \
  lib/features/setup/presentation/pages/settings/interface_settings_page.dart \
  test/features/setup/presentation/providers/navigation_customization_provider_test.dart \
  test/features/setup/presentation/pages/settings/interface_settings_page_test.dart
rtk git commit -m "feat: add random scene filter preference"
```

### Task 2: Add the shared scene random-navigation controller

**Files:**
- Create: `lib/features/scenes/presentation/providers/scene_random_navigation_provider.dart`
- Create: `test/features/scenes/presentation/providers/scene_random_navigation_provider_test.dart`

**Interfaces:**
- Consumes: `sceneRandomRespectActiveFilterProvider`, `sceneListProvider.notifier`
- Produces: `sceneRandomNavigationControllerProvider`, `Future<Scene?> getRandomScene({String? excludeSceneId})`

- [ ] **Step 1: Write the failing controller test**

```dart
test('scene random controller forwards the preference and exclusion id', () async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final repo = MockGraphQLSceneRepository()
    ..findScenesResponses.add([_scene('random-a')]);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      sceneRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);

  container.read(sceneSearchQueryProvider.notifier).update('tag:demo');
  container.read(sceneFilterStateProvider.notifier).update(
    SceneFilter(organized: true),
  );

  final scene = await container
      .read(sceneRandomNavigationControllerProvider)
      .getRandomScene(excludeSceneId: 'current');

  expect(scene?.id, 'random-a');
  expect(repo.findSceneCalls.last.filter, 'tag:demo');
  expect(repo.findSceneCalls.last.sort, 'random');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk flutter test test/features/scenes/presentation/providers/scene_random_navigation_provider_test.dart`
Expected: FAIL with `Undefined name 'sceneRandomNavigationControllerProvider'`.

- [ ] **Step 3: Implement the minimal shared controller**

```dart
final sceneRandomNavigationControllerProvider =
    Provider<SceneRandomNavigationController>(
  (ref) => SceneRandomNavigationController(ref),
);

class SceneRandomNavigationController {
  const SceneRandomNavigationController(this.ref);

  final Ref ref;

  Future<Scene?> getRandomScene({String? excludeSceneId}) {
    final useCurrentFilter = ref.read(
      sceneRandomRespectActiveFilterProvider,
    );
    return ref
        .read(sceneListProvider.notifier)
        .getRandomScene(
          useCurrentFilter: useCurrentFilter,
          excludeSceneId: excludeSceneId,
        );
  }
}
```

- [ ] **Step 4: Extend the test for the unfiltered branch**

```dart
test('scene random controller can ignore active filters', () async {
  SharedPreferences.setMockInitialValues({
    'scene_random_respect_active_filter': false,
  });
  final prefs = await SharedPreferences.getInstance();
  final repo = MockGraphQLSceneRepository()
    ..findScenesResponses.add([_scene('random-b')]);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      sceneRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);

  container.read(sceneSearchQueryProvider.notifier).update('filtered');
  container.read(sceneFilterStateProvider.notifier).update(
    SceneFilter(organized: true),
  );

  await container
      .read(sceneRandomNavigationControllerProvider)
      .getRandomScene();

  expect(repo.findSceneCalls.last.filter, isNull);
  expect(repo.findSceneCalls.last.sceneFilter, SceneFilter.empty());
});
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `rtk flutter test test/features/scenes/presentation/providers/scene_random_navigation_provider_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
rtk git add \
  lib/features/scenes/presentation/providers/scene_random_navigation_provider.dart \
  test/features/scenes/presentation/providers/scene_random_navigation_provider_test.dart
rtk git commit -m "feat: add shared scene random controller"
```

### Task 3: Wire scene pages to the shared controller without touching the queue

**Files:**
- Modify: `lib/features/scenes/presentation/pages/scenes_page.dart`
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart`
- Create: `test/features/scenes/presentation/pages/scene_random_navigation_test.dart`

**Interfaces:**
- Consumes: `sceneRandomNavigationControllerProvider.getRandomScene({String? excludeSceneId})`
- Produces: page-level random navigation that uses the shared controller and preserves `playbackQueueProvider`

- [ ] **Step 1: Write the failing scenes-page test**

```dart
class _FakeSceneRandomNavigationController
    implements SceneRandomNavigationController {
  _FakeSceneRandomNavigationController(this.result);

  final Scene? result;

  @override
  Future<Scene?> getRandomScene({String? excludeSceneId}) async => result;
}

testWidgets('ScenesPage random button uses shared controller and preserves the main queue', (tester) async {
  final listedScene = _scene('listed');
  final randomScene = _scene('backend-random');
  final repo = MockGraphQLSceneRepository()..withData([listedScene]);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const ScenesPage()),
      GoRoute(
        path: '/scenes/scene/:id',
        builder: (context, state) => Text('route:${state.pathParameters['id']}'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sceneRepositoryProvider.overrideWithValue(repo),
        sceneRandomNavigationControllerProvider.overrideWithValue(
          _FakeSceneRandomNavigationController(randomScene),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  final container = ProviderScope.containerOf(tester.element(find.byType(ScenesPage)));
  container.read(playbackQueueProvider.notifier).setSequence([listedScene], 0);
  final before = container.read(playbackQueueProvider);

  await tester.tap(find.byTooltip('Random scene'));
  await tester.pumpAndSettle();

  final after = container.read(playbackQueueProvider);
  expect(find.text('route:backend-random'), findsOneWidget);
  expect(after.sequence.map((scene) => scene.id), before.sequence.map((scene) => scene.id));
  expect(after.currentIndex, before.currentIndex);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk flutter test test/features/scenes/presentation/pages/scene_random_navigation_test.dart`
Expected: FAIL because `ScenesPage` still samples its loaded list and/or mutates the queue index.

- [ ] **Step 3: Implement the minimal scenes-page wiring**

```dart
Future<void> _openRandomScene() async {
  final randomScene = await ref
      .read(sceneRandomNavigationControllerProvider)
      .getRandomScene(excludeSceneId: _lastRandomSceneId);
  if (!mounted || randomScene == null) return;

  _lastRandomSceneId = randomScene.id;
  context.push('/scenes/scene/${randomScene.id}', extra: true);
}
```

- [ ] **Step 4: Extend the failing test for the details page**

```dart
testWidgets('SceneDetailsPage random button uses the shared controller', (tester) async {
  final currentScene = _scene('current');
  final randomScene = _scene('backend-next');
  final repo = MockGraphQLSceneRepository()..withData([currentScene]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sceneRepositoryProvider.overrideWithValue(repo),
        sceneRandomNavigationControllerProvider.overrideWithValue(
          _FakeSceneRandomNavigationController(randomScene),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const SceneDetailsPage(sceneId: 'current'),
            ),
            GoRoute(
              path: '/scenes/scene/:id',
              builder: (context, state) =>
                  Text('route:${state.pathParameters['id']}'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip('Random scene'));
  await tester.pumpAndSettle();

  expect(find.text('route:backend-next'), findsOneWidget);
});
```

- [ ] **Step 5: Run test to verify it fails**

Run: `rtk flutter test test/features/scenes/presentation/pages/scene_random_navigation_test.dart`
Expected: FAIL because `SceneDetailsPage` still calls `sceneListProvider.notifier.getRandomScene(useCurrentFilter: true, ...)` directly.

- [ ] **Step 6: Implement the minimal details-page wiring**

```dart
Future<void> _openRandomScene(BuildContext context) async {
  final randomScene = await ref
      .read(sceneRandomNavigationControllerProvider)
      .getRandomScene(excludeSceneId: widget.sceneId);
  if (!context.mounted) return;

  if (randomScene == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.scenes_no_random)));
    return;
  }

  context.push('/scenes/scene/${randomScene.id}', extra: true);
}
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `rtk flutter test test/features/scenes/presentation/pages/scene_random_navigation_test.dart`
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
rtk git add \
  lib/features/scenes/presentation/pages/scenes_page.dart \
  lib/features/scenes/presentation/pages/scene_details_page.dart \
  test/features/scenes/presentation/pages/scene_random_navigation_test.dart
rtk git commit -m "feat: unify scene random page navigation"
```

### Task 4: Add the fullscreen random button and hook it to the same controller

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/native_video_controls.dart`
- Modify: `lib/features/scenes/presentation/widgets/player_surface.dart`
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart`
- Modify: `lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart`
- Modify: `test/features/scenes/presentation/widgets/native_video_controls_test.dart`

**Interfaces:**
- Consumes: `VoidCallback? onRandomScene`, `sceneRandomNavigationControllerProvider`
- Produces: fullscreen-only random button in scene video controls that navigates without touching `playbackQueueProvider`

- [ ] **Step 1: Write the failing fullscreen-controls test**

```dart
testWidgets('fullscreen controls render and trigger the random scene button', (tester) async {
  var randomPressed = false;

  await _pumpControls(
    tester,
    scene: _buildScene(),
    onFullScreenToggle: () {},
    onRandomScene: () => randomPressed = true,
  );

  final container = ProviderScope.containerOf(
    tester.element(find.byType(NativeVideoControls)),
  );
  container.read(playerStateProvider.notifier).setFullScreen(true);
  await tester.pump();

  final randomButton = find.byKey(const Key('fullscreen_random_scene_button'));
  expect(randomButton, findsOneWidget);

  await tester.tap(randomButton);
  await tester.pump();

  expect(randomPressed, isTrue);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk flutter test test/features/scenes/presentation/widgets/native_video_controls_test.dart`
Expected: FAIL because `NativeVideoControls` has no `onRandomScene` parameter or fullscreen random button.

- [ ] **Step 3: Implement the minimal widget plumbing**

```dart
class NativeVideoControls extends ConsumerStatefulWidget {
  const NativeVideoControls({
    required this.controller,
    required this.useDoubleTapSeek,
    required this.enableNativePip,
    this.onFullScreenToggle,
    this.onInlineBack,
    this.onRandomScene,
    required this.scene,
    // ...
  });

  final VoidCallback? onRandomScene;
}

IconButton(
  key: const Key('fullscreen_random_scene_button'),
  tooltip: context.l10n.random_scene,
  style: _controlButtonStyle(colorScheme),
  icon: const Icon(Icons.casino_outlined),
  onPressed: () {
    widget.onRandomScene?.call();
    _showControlsTemporarily();
  },
),
```

- [ ] **Step 4: Thread the callback from the scene player and fullscreen overlay**

```dart
Future<void> _openRandomScene() async {
  final randomScene = await ref
      .read(sceneRandomNavigationControllerProvider)
      .getRandomScene(excludeSceneId: widget.scene.id);
  if (!mounted || randomScene == null) return;

  final router = GoRouter.of(context);
  router.push('/scenes/scene/${randomScene.id}', extra: true);
}

PlayerSurface(
  scene: widget.scene,
  controller: controller,
  onFullScreenToggle: _toggleFullScreen,
  onRandomScene: _openRandomScene,
  // ...
)
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `rtk flutter test test/features/scenes/presentation/widgets/native_video_controls_test.dart`
Expected: PASS.

- [ ] **Step 6: Run the affected verification sweep**

Run: `rtk flutter test test/features/setup/presentation/providers/navigation_customization_provider_test.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart test/features/scenes/presentation/providers/scene_random_navigation_provider_test.dart test/features/scenes/presentation/pages/scene_random_navigation_test.dart test/features/scenes/presentation/widgets/native_video_controls_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
rtk git add \
  lib/features/scenes/presentation/widgets/native_video_controls.dart \
  lib/features/scenes/presentation/widgets/player_surface.dart \
  lib/features/scenes/presentation/widgets/scene_video_player.dart \
  lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart \
  test/features/scenes/presentation/widgets/native_video_controls_test.dart
rtk git commit -m "feat: add fullscreen scene random control"
```

## Self-Review

- Spec coverage: the plan covers the persisted setting, filter-aware vs unfiltered random resolution, shared controller reuse, all three UI entry points, and queue-preservation regression tests.
- Placeholder scan: no `TODO`, `TBD`, or “similar to” references remain.
- Type consistency: the plan uses one produced controller signature throughout: `sceneRandomNavigationControllerProvider.getRandomScene({String? excludeSceneId})`.
