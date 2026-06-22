# Scene Details Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Put scene actions beside rating and O-counter controls, attach navigation to the auto-hiding inline player UI, and make metadata edit/scrape access permanently available.

**Architecture:** `SceneDetailsPage` retains ownership of scene action callbacks but renders them in `_buildActions` rather than an AppBar. `PlayerSurface` supplies a page-back callback to `NativeVideoControls`, which renders it inside the existing `_controlsVisible` overlay. Removing the shared scrape preference eliminates its settings UI and all conditional edit/scrape branches from scene, performer, and studio surfaces.

**Tech Stack:** Flutter, Riverpod, GoRouter, flutter_test, SharedPreferences.

---

## File map

- `lib/features/scenes/presentation/pages/scene_details_page.dart`: removes the AppBar, moves the five callbacks into the rating/O action wrap, and always exposes scene editing.
- `lib/features/scenes/presentation/widgets/scene_video_player.dart`: passes page-back navigation to the inline player surface.
- `lib/features/scenes/presentation/widgets/player_surface.dart`: accepts and forwards the optional inline-back callback.
- `lib/features/scenes/presentation/widgets/native_video_controls.dart`: renders a controls-visible inline back action.
- `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`: removes the obsolete Show Edit Button state, import, and switch.
- `lib/features/setup/presentation/providers/scrape_customization_provider.dart`: delete; its persisted preference has no remaining owner.
- `lib/features/scenes/presentation/pages/scene_edit_page.dart`, `lib/features/performers/presentation/pages/performer_details_page.dart`, `lib/features/performers/presentation/pages/performer_edit_page.dart`, `lib/features/studios/presentation/pages/studio_details_page.dart`, and `lib/features/studios/presentation/pages/studio_edit_page.dart`: remove scrape-provider imports, reads, and conditionals so edit and scrape actions remain visible.
- `lib/l10n/app_de.arb`, `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_it.arb`, `app_ja.arb`, `app_ko.arb`, `app_ru.arb`, `app_zh.arb`, `app_zh_Hans.arb`, `app_zh_Hant.arb`, and generated localization output: remove the obsolete Show Edit Button strings and regenerate localizations.
- `test/features/scenes/video_player_ui_test.dart`, `test/features/scenes/presentation/widgets/native_video_controls_test.dart`, and `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`: focused UI regressions.

### Task 1: Lock down the scene-details control placement

**Files:**
- Modify: `test/features/scenes/video_player_ui_test.dart:91-162`
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart:520-750,864-945`

- [ ] **Step 1: Write failing widget tests for the body action row**

Add keys to the five scene action buttons in the expected action row and assert the old AppBar is absent:

```dart
expect(find.byType(AppBar), findsNothing);
expect(find.byKey(const Key('scene_action_add_marker')), findsOneWidget);
expect(find.byKey(const Key('scene_action_info')), findsOneWidget);
expect(find.byKey(const Key('scene_action_download')), findsOneWidget);
expect(find.byKey(const Key('scene_action_edit')), findsOneWidget);
expect(find.byKey(const Key('scene_action_delete')), findsOneWidget);
expect(
  tester.getTopLeft(find.byKey(const Key('scene_action_edit'))).dy,
  greaterThan(tester.getTopLeft(find.byIcon(Icons.star)).dy),
);
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run: `rtk flutter test test/features/scenes/video_player_ui_test.dart --plain-name "SceneDetailsPage renders scene actions below rating and O counter"`

Expected: FAIL because the AppBar and its action buttons still exist, and the new keys are absent.

- [ ] **Step 3: Remove the AppBar and move its action builders into `_buildActions`**

Delete only the `appBar: AppBar(...)` member from the existing `Scaffold`; leave its current floating action button and `LayoutBuilder` body unchanged. Change the main-info call to avoid passing `scrapeEnabled`:

```dart
Widget _buildMainInfo(BuildContext context, Scene scene) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildTitle(context, scene),
    const SizedBox(height: AppTheme.spacingSmall),
    _buildStudioAndDate(context, scene),
    const SizedBox(height: AppTheme.spacingSmall),
    _buildTechnicalMetadata(context, scene),
    const SizedBox(height: AppTheme.spacingSmall),
    _buildActions(context, scene),
    const SizedBox(height: AppTheme.spacingMedium),
    _buildDetails(context, scene),
  ],
);
```

Append the existing handlers after the O counter in `_buildActions`, preserving their platform guard and behavior:

```dart
IconButton(
  key: const Key('scene_action_edit'),
  tooltip: context.l10n.common_edit,
  icon: const Icon(Icons.edit_outlined),
  onPressed: () => context.push(
    '/scenes/scene/${scene.id}/edit',
    extra: scene,
  ),
),
```

Use equivalent keyed buttons for add marker, info, download, and delete; retain `if (!kIsWeb)` only around download.

- [ ] **Step 4: Run the focused test and verify it passes**

Run: `rtk flutter test test/features/scenes/video_player_ui_test.dart --plain-name "SceneDetailsPage renders scene actions below rating and O counter"`

Expected: PASS.

- [ ] **Step 5: Run existing scene-details behavior tests**

Run: `rtk flutter test test/features/scenes/video_player_ui_test.dart`

Expected: PASS; rating, O-counter, marker, download, and delete behavior remains covered.

### Task 2: Add an auto-hiding inline video back control

**Files:**
- Modify: `test/features/scenes/presentation/widgets/native_video_controls_test.dart`
- Modify: `lib/features/scenes/presentation/widgets/native_video_controls.dart:31-58,1229-1311`
- Modify: `lib/features/scenes/presentation/widgets/player_surface.dart:29-47,231-245`
- Modify: `lib/features/scenes/presentation/widgets/scene_video_player.dart:464-472`

- [ ] **Step 1: Write a failing control-overlay test**

Construct `NativeVideoControls` with an `onInlineBack` callback and assert that it is called from the top overlay while controls are visible:

```dart
var backPressed = false;
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: NativeVideoControls(
        controller: controller,
        scene: testScene,
        useDoubleTapSeek: false,
        enableNativePip: false,
        onInlineBack: () => backPressed = true,
      ),
    ),
  ),
);
await tester.tap(find.byKey(const Key('inline_video_back_button')));
expect(backPressed, isTrue);
```

Also pump past the control auto-hide duration and assert the top control is no longer hit-testable with the other video controls.

- [ ] **Step 2: Run the focused test and verify it fails**

Run: `rtk flutter test test/features/scenes/presentation/widgets/native_video_controls_test.dart --plain-name "inline back control follows video controls visibility"`

Expected: FAIL because `NativeVideoControls` has no callback or back-control key.

- [ ] **Step 3: Thread and render the callback through the player stack**

Add a nullable callback to `PlayerSurface` and `NativeVideoControls`:

```dart
final VoidCallback? onInlineBack;
```

Inside the existing `AnimatedOpacity(opacity: _controlsVisible ? 1 : 0)` top-overlay section, render only for non-fullscreen playback:

```dart
if (!isFullScreen && widget.onInlineBack != null)
  Positioned(
    top: 8,
    left: 8,
    child: SafeArea(
      child: IconButton(
        key: const Key('inline_video_back_button'),
        tooltip: context.l10n.common_back,
        style: _controlButtonStyle(colorScheme),
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: widget.onInlineBack,
      ),
    ),
  ),
```

Pass it from `SceneVideoPlayer` using router-safe pop semantics:

```dart
onInlineBack: () {
  final router = GoRouter.of(context);
  if (router.canPop()) router.pop();
},
```

- [ ] **Step 4: Run the focused test and verify it passes**

Run: `rtk flutter test test/features/scenes/presentation/widgets/native_video_controls_test.dart --plain-name "inline back control follows video controls visibility"`

Expected: PASS.

- [ ] **Step 5: Run player widget coverage**

Run: `rtk flutter test test/features/scenes/presentation/widgets/native_video_controls_test.dart test/features/scenes/presentation/widgets/scene_video_player_test.dart`

Expected: PASS.

### Task 3: Remove the edit/scrape visibility preference

**Files:**
- Modify: `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart:1-120,250-297`
- Delete: `lib/features/setup/presentation/providers/scrape_customization_provider.dart`
- Modify: `lib/features/scenes/presentation/pages/scene_edit_page.dart:412-447`
- Modify: `lib/features/performers/presentation/pages/performer_details_page.dart:80-105`
- Modify: `lib/features/performers/presentation/pages/performer_edit_page.dart:384-412`
- Modify: `lib/features/studios/presentation/pages/studio_details_page.dart:60-85`
- Modify: `lib/features/studios/presentation/pages/studio_edit_page.dart:187-215`
- Modify: `lib/l10n/app_*.arb`
- Modify: generated `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Write failing settings and edit-access tests**

Assert Interface Settings no longer renders the English Show Edit Button text, then pump a scene, performer, and studio details page with default preferences and assert each edit icon is present:

```dart
expect(find.text('Show Edit Button'), findsNothing);
expect(find.byTooltip(context.l10n.common_edit), findsOneWidget);
```

Keep each entity in a separate widget test so route and repository setup remain focused.

- [ ] **Step 2: Run the focused tests and verify they fail**

Run: `rtk flutter test test/features/setup/presentation/pages/settings/interface_settings_page_test.dart test/features/scenes/video_player_ui_test.dart`

Expected: FAIL because the setting is rendered and default preferences hide the scene edit action.

- [ ] **Step 3: Delete the preference and make actions unconditional**

Remove the scrape-provider imports, state reads, and `if (scrapeEnabled)` branches. Keep the existing scrape spinner/action in each edit page but make it unconditional:

```dart
actions: [
  if (_isScraping)
    const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    )
  else IconButton(onPressed: _scrape, icon: const Icon(Icons.search)),
  IconButton(
    onPressed: _isSaving ? null : _save,
    icon: _isSaving
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.save),
  ),
],
```

Remove `_showScrapeButton`, its `_load` and `_saveSettings` reads/writes, the switch tile, and the provider source file. Remove the two `settings_interface_show_edit*` entries from every `app_*.arb` source, then run localisation generation to remove generated getters.

- [ ] **Step 4: Run focused tests and verify they pass**

Run: `rtk flutter test test/features/setup/presentation/pages/settings/interface_settings_page_test.dart test/features/scenes/video_player_ui_test.dart`

Expected: PASS.

- [ ] **Step 5: Verify no obsolete preference reference remains**

Run: `rtk rg -n "scrapeEnabledProvider|show_scrape_button|settings_interface_show_edit" lib test`

Expected: exit 1 with no matches.

### Task 4: Format and verify the complete change

**Files:**
- Modify: all implementation and test files above, only as required by formatter/localization generation.

- [ ] **Step 1: Format changed Dart source**

Run: `rtk dart format lib/features/scenes/presentation/pages/scene_details_page.dart lib/features/scenes/presentation/widgets/scene_video_player.dart lib/features/scenes/presentation/widgets/player_surface.dart lib/features/scenes/presentation/widgets/native_video_controls.dart lib/features/setup/presentation/pages/settings/interface_settings_page.dart lib/features/scenes/presentation/pages/scene_edit_page.dart lib/features/performers/presentation/pages/performer_details_page.dart lib/features/performers/presentation/pages/performer_edit_page.dart lib/features/studios/presentation/pages/studio_details_page.dart lib/features/studios/presentation/pages/studio_edit_page.dart test/features/scenes/video_player_ui_test.dart test/features/scenes/presentation/widgets/native_video_controls_test.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`

Expected: formatter exits 0.

- [ ] **Step 2: Run static analysis**

Run: `rtk flutter analyze`

Expected: exit 0 with no analysis errors.

- [ ] **Step 3: Run the complete focused regression suite**

Run: `rtk flutter test test/features/scenes/video_player_ui_test.dart test/features/scenes/presentation/widgets/native_video_controls_test.dart test/features/scenes/presentation/widgets/scene_video_player_test.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`

Expected: PASS with zero failures.

- [ ] **Step 4: Review the final diff**

Run: `rtk git diff --check && rtk git diff -- lib/features/scenes lib/features/performers lib/features/studios lib/features/setup lib/l10n test/features/scenes test/features/setup`

Expected: no whitespace errors and only the scoped layout, control, preference, localization, and test changes.

- [ ] **Step 5: Commit scoped changes**

Run: `rtk git add lib/features/scenes lib/features/performers lib/features/studios lib/features/setup lib/l10n test/features/scenes test/features/setup docs/superpowers && rtk git commit -m "refactor: streamline scene detail controls"`

Expected: commit contains only this feature; do not stage the pre-existing groups, tags, or shared-filter changes.
