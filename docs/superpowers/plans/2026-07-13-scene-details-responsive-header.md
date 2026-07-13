# Scene Details Responsive Header Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the scene-details title/action region into a premium responsive header with one clear vertical hierarchy.

**Architecture:** Keep the change inside `SceneDetailsPage`. A `LayoutBuilder` preserves responsive title typography while the identity, control, and metadata groups share one vertical order and the existing Details section surface.

## Follow-up refinement

Later UI refinements supersede the nested control-island and wide-screen split in Task 1: keep title/studio outside, use `_buildSectionContainer` around controls and metadata, and use one `Wrap` with `spaceBetween` so rating/O stays left, actions align right, and narrow layouts stack naturally.

**Tech Stack:** Flutter, Material 3, flutter_test.

## Global Constraints

- Modify only `scene_details_page.dart` and `video_player_ui_test.dart`.
- Preserve all callbacks, keys, tooltips, semantics, ordering, and platform guards.
- Add no dependency, shared abstraction, global theme change, player change, or details-section redesign.
- Base adaptation on the parent width and keep the mobile layout overflow-free at 1.5× text scaling.

---

### Task 1: Build and verify the responsive header

**Files:**
- Modify: `test/features/scenes/video_player_ui_test.dart:86-145`
- Modify: `lib/features/scenes/presentation/pages/scene_details_page.dart:682-945`

**Interfaces:**
- Consumes: existing `Scene`, `_buildTechnicalMetadata`, action callbacks, Material 3 `ColorScheme`, and `AppTheme` spacing.
- Produces: keyed `scene_header_identity` and `scene_header_controls` layout groups; `_buildActions(BuildContext, Scene, {WrapAlignment alignment})`.

- [ ] **Step 1: Write failing adaptive-layout tests**

Add a wide-screen test that expects the identity and control groups to share a top row, with controls to the right:

```dart
testWidgets('SceneDetailsPage splits header controls on large screens', (
  tester,
) async {
  tester.view.physicalSize = const Size(1600, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);
  await pumpTestWidget(
    tester,
    prefs: prefs,
    overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
    child: SceneDetailsPage(sceneId: testScene.id),
  );
  await tester.pump(const Duration(seconds: 1));

  final identity = find.byKey(const Key('scene_header_identity'));
  final controls = find.byKey(const Key('scene_header_controls'));
  expect(tester.getTopLeft(controls).dx, greaterThan(tester.getTopLeft(identity).dx));
  expect(
    tester.getTopLeft(controls).dy,
    closeTo(tester.getTopLeft(identity).dy, 0.1),
  );
});
```

Add a narrow 1.5× text-scale test that expects a full-width vertical stack and no Flutter exception:

```dart
testWidgets('SceneDetailsPage stacks its header without scaled-text overflow', (
  tester,
) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);
  await pumpTestWidget(
    tester,
    prefs: prefs,
    overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
    child: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: SceneDetailsPage(sceneId: testScene.id),
    ),
  );
  await tester.pump(const Duration(seconds: 1));

  final identity = find.byKey(const Key('scene_header_identity'));
  final controls = find.byKey(const Key('scene_header_controls'));
  expect(tester.getBottomLeft(identity).dy, lessThan(tester.getTopLeft(controls).dy));
  expect(tester.getSize(controls).width, closeTo(tester.getSize(identity).width, 0.1));
  expect(tester.takeException(), isNull);
});
```

- [ ] **Step 2: Run the two tests and verify they fail**

Run:

```bash
rtk flutter test test/features/scenes/video_player_ui_test.dart --plain-name "SceneDetailsPage splits header controls on large screens"
rtk flutter test test/features/scenes/video_player_ui_test.dart --plain-name "SceneDetailsPage stacks its header without scaled-text overflow"
```

Expected: both fail because the two layout keys and responsive split do not exist.

- [ ] **Step 3: Implement the minimal responsive composition**

Replace `_buildMainInfo` and update `_buildTitle` with this responsive composition:

```dart
Widget _buildMainInfo(BuildContext context, Scene scene) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 768;
      final colorScheme = Theme.of(context).colorScheme;
      final alignment = isWide ? WrapAlignment.end : WrapAlignment.start;

      final identity = Column(
        key: const Key('scene_header_identity'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context, scene, isWide: isWide),
          const SizedBox(height: 6),
          _buildStudioAndDate(context, scene),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildTechnicalMetadata(context, scene),
        ],
      );
      final controls = Container(
        key: const Key('scene_header_controls'),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(isWide ? 10 : 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildActions(context, scene, alignment: alignment),
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                const SizedBox(width: 32),
                SizedBox(width: 344, child: controls),
              ],
            )
          else ...[
            SizedBox(width: double.infinity, child: identity),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: controls),
          ],
          const SizedBox(height: AppTheme.spacingLarge),
          _buildDetails(context, scene),
        ],
      );
    },
  );
}

Widget _buildTitle(
  BuildContext context,
  Scene scene, {
  required bool isWide,
}) {
  final style = isWide
      ? context.textTheme.headlineMedium
      : context.textTheme.headlineSmall;
  return Text(
    scene.displayTitle,
    style: style?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: isWide ? -0.5 : -0.3,
      color: context.colors.onSurface,
    ),
  );
}
```

Change `_buildActions` to accept `WrapAlignment alignment`, map it to the `Column` cross-axis alignment, and apply it to both existing `Wrap`s:

```dart
Widget _buildActions(
  BuildContext context,
  Scene scene, {
  WrapAlignment alignment = WrapAlignment.start,
}) {
  final crossAxisAlignment = alignment == WrapAlignment.end
      ? CrossAxisAlignment.end
      : CrossAxisAlignment.start;
  return Column(
    crossAxisAlignment: crossAxisAlignment,
    children: [
      Wrap(
        alignment: alignment,
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: 0,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: context.l10n.scene_rating_stars(i),
                  onPressed: () async {
                    final currentRating = scene.rating100 ?? 0;
                    final newRating = (currentRating == i * 20) ? 0 : i * 20;
                    try {
                      await ref
                          .read(sceneRepositoryProvider)
                          .updateSceneRating(scene.id, newRating);
                      await ref
                          .read(sceneRepositoryProvider)
                          .getSceneById(scene.id, refresh: true);
                      ref.invalidate(sceneDetailsProvider(scene.id));
                      _invalidateSceneListUnlessRandom();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.details_failed_update_rating(
                                e.toString(),
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    (scene.rating100 ?? 0) >= i * 20
                        ? Icons.star
                        : Icons.star_border,
                    color: context.colors.ratingColor,
                    size: 24,
                  ),
                ),
            ],
          ),
          FilledButton.tonalIcon(
            onPressed: () async {
              try {
                await ref
                    .read(sceneRepositoryProvider)
                    .incrementSceneOCounter(scene.id);
                await ref
                    .read(sceneRepositoryProvider)
                    .getSceneById(scene.id, refresh: true);
                ref.invalidate(sceneDetailsProvider(scene.id));
                _invalidateSceneListUnlessRandom();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.details_o_count_incremented),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.details_failed_increment_o_count(
                          e.toString(),
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.water_drop_outlined),
            label: Text('${scene.oCounter}'),
          ),
        ],
      ),
      const SizedBox(height: AppTheme.spacingSmall),
      Wrap(
        alignment: alignment,
        spacing: 4,
        runSpacing: 4,
        children: [
          IconButton(
            key: const Key('scene_action_add_marker'),
            tooltip: context.l10n.scene_details_add_marker,
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: () => _showAddMarkerDialog(
              scene,
              markerSeconds: _currentMarkerSeconds(scene),
            ),
          ),
          IconButton(
            key: const Key('scene_action_info'),
            tooltip: context.l10n.common_more,
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showSceneDetailsSheet(scene),
          ),
          if (!kIsWeb)
            IconButton(
              key: const Key('scene_action_download'),
              tooltip: context.l10n.common_download,
              icon: const Icon(Icons.download_outlined),
              onPressed: () => _saveVideoToGallery(scene),
            ),
          IconButton(
            key: const Key('scene_action_edit'),
            tooltip: context.l10n.common_edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/scenes/scene/${scene.id}/edit', extra: scene),
          ),
          IconButton(
            key: const Key('scene_action_delete'),
            tooltip: context.l10n.delete_scene,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteSceneDialog(scene),
          ),
        ],
      ),
    ],
  );
}
```

This is a structural move only: retain the existing rating, O-counter, marker, info, download, edit, and delete callback bodies verbatim.

Wrap the existing studio `Semantics` widget in `Flexible` inside `_buildStudioAndDate`. This gives the linked studio text the row's remaining width, allowing it to wrap under large text scaling while the bullet and year remain visible.

- [ ] **Step 4: Format and run focused verification**

Run:

```bash
rtk dart format lib/features/scenes/presentation/pages/scene_details_page.dart test/features/scenes/video_player_ui_test.dart
rtk flutter test test/features/scenes/video_player_ui_test.dart
rtk flutter analyze lib/features/scenes/presentation/pages/scene_details_page.dart test/features/scenes/video_player_ui_test.dart
```

Expected: formatting succeeds, all scene-details widget tests pass, and analysis reports no issues.

- [ ] **Step 5: Commit**

```bash
rtk git add lib/features/scenes/presentation/pages/scene_details_page.dart test/features/scenes/video_player_ui_test.dart docs/superpowers/plans/2026-07-13-scene-details-responsive-header.md
rtk git commit -m "feat: refine responsive scene details header"
```
