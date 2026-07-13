# Settings UI Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify the settings hub and detail pages behind one shared visual system without changing routes, settings behavior, or the server settings list/FAB flow.

**Architecture:** Extend the existing settings shell into a small presentation toolkit in `settings_page_shell.dart`, then migrate the settings pages onto that toolkit in two passes. The first pass proves the seam on one representative page and shared widget test; the second pass applies the same pattern to the remaining pages while keeping `ServerSettingsPage` as a layout exception.

**Tech Stack:** Flutter, Riverpod, Material 3 widgets, Flutter widget tests

## Global Constraints

- Keep `SettingsPageShell` as the route frame and back/close behavior seam.
- Keep existing routes unchanged.
- Keep existing providers and persistence unchanged.
- Keep native Material controls; do not replace them with custom controls.
- Keep `ServerSettingsPage` list/FAB/bottom-sheet behavior unchanged.
- Unify hub and detail-page spacing, section headers, panel surfaces, divider rhythm, and loading/empty states through shared widgets.
- Use TDD: write the failing widget test first, verify it fails for the expected reason, then implement the minimum code.
- Prefer `rtk proxy env HOME=/tmp ...` for Flutter verification if the toolchain tries to write outside the workspace.

---

## File Structure

- Modify: `lib/features/setup/presentation/widgets/settings_page_shell.dart`
  - Expand the existing shell into the shared presentation seam:
    - `SettingsPageBody`
    - `SettingsSectionHeader`
    - `SettingsPanelCard`
    - `SettingsPanelGroup`
    - `SettingsLoadingState`
    - `SettingsEmptyState`
    - updated `SettingsSectionCard`
    - updated `SettingsActionCard`
- Modify: `lib/features/setup/presentation/pages/settings/settings_hub_page.dart`
  - Move the hub onto the shared page body and updated action-card language.
- Modify: `lib/features/setup/presentation/pages/settings/appearance_settings_page.dart`
  - Use it as the first representative migration onto shared section/panel/group widgets.
- Modify: `lib/features/setup/presentation/pages/settings/playback_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/storage_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/security_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/developer_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/support_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/keybind_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/navigation_customization_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/server_settings_page.dart`
  - Apply only shared body spacing and shared empty-state styling.
- Create: `test/features/setup/presentation/widgets/settings_page_shell_test.dart`
  - Focused regression test for the shared settings primitives.
- Modify: `test/features/setup/presentation/pages/settings/playback_settings_page_test.dart`
- Modify: `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`
- Modify: `test/features/setup/presentation/pages/settings/server_settings_page_test.dart`
  - Only where the widget tree shape changes.

### Task 1: Shared Settings Surface Primitives

**Files:**
- Modify: `lib/features/setup/presentation/widgets/settings_page_shell.dart`
- Create: `test/features/setup/presentation/widgets/settings_page_shell_test.dart`

**Interfaces:**
- Consumes: existing `SettingsPageShell`, `SettingsSectionCard`, `SettingsActionCard`
- Produces:
  - `class SettingsPageBody extends StatelessWidget`
  - `class SettingsPanelCard extends StatelessWidget`
  - `class SettingsPanelGroup extends StatelessWidget`
  - `class SettingsSectionHeader extends StatelessWidget`
  - `class SettingsLoadingState extends StatelessWidget`
  - `class SettingsEmptyState extends StatelessWidget`
  - updated `SettingsSectionCard` that renders `SettingsPanelCard` by default

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('SettingsSectionCard wraps content in shared panel chrome', (
  tester,
) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: SettingsPageShell(
          title: 'Settings',
          child: SettingsPageBody(
            child: SettingsSectionCard(
              title: 'Appearance',
              subtitle: 'Theme and scale',
              child: const Text('panel body'),
            ),
          ),
        ),
      ),
    ),
  );

  expect(find.text('Appearance'), findsOneWidget);
  expect(find.text('Theme and scale'), findsOneWidget);
  expect(find.text('panel body'), findsOneWidget);
  expect(find.byType(SettingsPanelCard), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk proxy env HOME=/tmp flutter test test/features/setup/presentation/widgets/settings_page_shell_test.dart`

Expected: FAIL because `SettingsPageBody` and `SettingsPanelCard` do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
class SettingsPageBody extends StatelessWidget {
  const SettingsPageBody({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? EdgeInsets.all(context.dimensions.spacingLarge),
      child: child,
    );
    if (!scrollable) return content;
    return ListView(children: [content]);
  }
}

class SettingsPanelCard extends StatelessWidget {
  const SettingsPanelCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: child,
      ),
    );
  }
}

class SettingsPanelGroup extends StatelessWidget {
  const SettingsPanelGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            Divider(height: context.dimensions.spacingLarge),
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: Update the section composition to use the panel surface**

```dart
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding,
    this.wrapInPanel = true,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final bool wrapInPanel;

  @override
  Widget build(BuildContext context) {
    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    return Padding(
      padding: EdgeInsets.only(bottom: context.dimensions.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null)
            SettingsSectionHeader(title: title, subtitle: subtitle),
          wrapInPanel ? SettingsPanelCard(child: content) : content,
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `rtk proxy env HOME=/tmp flutter test test/features/setup/presentation/widgets/settings_page_shell_test.dart`

Expected: PASS

- [ ] **Step 6: Commit**

```bash
rtk git add \
  lib/features/setup/presentation/widgets/settings_page_shell.dart \
  test/features/setup/presentation/widgets/settings_page_shell_test.dart
rtk git commit -m "refactor: add shared settings surface widgets"
```

### Task 2: Prove the Seam on the Hub and Appearance Settings

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/settings_hub_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/appearance_settings_page.dart`
- Modify: `test/features/setup/presentation/pages/settings/appearance_settings_lifecycle_test.dart`

**Interfaces:**
- Consumes:
  - `SettingsPageBody`
  - `SettingsPanelGroup`
  - `SettingsSectionCard`
  - `SettingsActionCard`
  - `SettingsLoadingState`
- Produces:
  - hub and appearance pages that model the shared page-body/panel/group pattern for later pages

- [ ] **Step 1: Add a focused appearance-page test that will fail on the old structure**

```dart
testWidgets('AppearanceSettingsPage renders shared settings panel chrome', (
  tester,
) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: const AppearanceSettingsPage(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.byType(SettingsPageBody), findsOneWidget);
  expect(find.byType(SettingsPanelCard), findsWidgets);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rtk proxy env HOME=/tmp flutter test test/features/setup/presentation/pages/settings/appearance_settings_lifecycle_test.dart`

Expected: FAIL because `AppearanceSettingsPage` still uses `SingleChildScrollView` and page-local containers.

- [ ] **Step 3: Migrate `SettingsHubPage` to the shared body**

```dart
return SettingsPageShell(
  title: l10n.settings_title,
  child: SettingsPageBody(
    child: SettingsSectionCard(
      title: l10n.settings_core_section,
      subtitle: l10n.settings_core_subtitle,
      wrapInPanel: false,
      child: SettingsPanelGroup(
        children: [
          SettingsActionCard(...),
          if (isDesktop) SettingsActionCard(...),
        ],
      ),
    ),
  ),
);
```

- [ ] **Step 4: Migrate `AppearanceSettingsPage` to shared body/panel/group widgets**

```dart
return SettingsPageShell(
  title: l10n.settings_appearance_title,
  child: _loading
      ? const SettingsLoadingState()
      : SettingsPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsSectionCard(
                title: l10n.settings_appearance_theme_mode,
                subtitle: l10n.settings_appearance_theme_mode_subtitle,
                child: SettingsPanelGroup(
                  children: [
                    _buildThemeModeSelector(l10n),
                    SwitchListTile.adaptive(...),
                  ],
                ),
              ),
              SettingsSectionCard(
                title: l10n.settings_appearance_primary_color,
                subtitle: l10n.settings_appearance_primary_color_subtitle,
                child: _buildColorSelector(),
              ),
            ],
          ),
        ),
);
```

- [ ] **Step 5: Run the appearance test to verify it passes**

Run: `rtk proxy env HOME=/tmp flutter test test/features/setup/presentation/pages/settings/appearance_settings_lifecycle_test.dart`

Expected: PASS

- [ ] **Step 6: Commit**

```bash
rtk git add \
  lib/features/setup/presentation/pages/settings/settings_hub_page.dart \
  lib/features/setup/presentation/pages/settings/appearance_settings_page.dart \
  test/features/setup/presentation/pages/settings/appearance_settings_lifecycle_test.dart
rtk git commit -m "refactor: align hub and appearance settings ui"
```

### Task 3: Sweep the Remaining Settings Pages Without Behavior Changes

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/playback_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/storage_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/security_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/developer_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/support_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/keybind_settings_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/navigation_customization_page.dart`
- Modify: `lib/features/setup/presentation/pages/settings/server_settings_page.dart`
- Modify: `test/features/setup/presentation/pages/settings/playback_settings_page_test.dart`
- Modify: `test/features/setup/presentation/pages/settings/interface_settings_page_test.dart`
- Modify: `test/features/setup/presentation/pages/settings/server_settings_page_test.dart`

**Interfaces:**
- Consumes:
  - shared widgets from Task 1
  - migration pattern proven in Task 2
- Produces:
  - consistent settings page presentation across hub and detail pages
  - updated tests that continue to cover existing behavior

- [ ] **Step 1: Write one failing regression assertion for a migrated page and one for server empty state**

```dart
testWidgets('PlaybackSettingsPage renders shared panel cards', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: const PlaybackSettingsPage())),
  );
  await tester.pumpAndSettle();
  expect(find.byType(SettingsPanelCard), findsWidgets);
});

testWidgets('ServerSettingsPage empty state uses shared settings empty state', (
  tester,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [serverProfilesProvider.overrideWith((ref) => [])],
      child: const MaterialApp(home: Scaffold(body: ServerSettingsPage())),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.byType(SettingsEmptyState), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused tests to verify they fail**

Run: `rtk proxy env HOME=/tmp flutter test test/features/setup/presentation/pages/settings/playback_settings_page_test.dart test/features/setup/presentation/pages/settings/server_settings_page_test.dart`

Expected: FAIL because the pages do not use the shared wrappers yet.

- [ ] **Step 3: Migrate the remaining detail pages to the shared wrappers**

```dart
child: _loading
    ? const SettingsLoadingState()
    : SettingsPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionCard(
              title: ...,
              subtitle: ...,
              child: SettingsPanelGroup(
                children: [
                  SwitchListTile.adaptive(...),
                  _buildEndBehaviorSelector(),
                ],
              ),
            ),
          ],
        ),
      ),
```

Apply the same pattern to:

- `PlaybackSettingsPage`
- `InterfaceSettingsPage`
- `StorageSettingsPage`
- `SecuritySettingsPage`
- `DeveloperSettingsPage`
- `SupportSettingsPage`

- [ ] **Step 4: Migrate the structural outliers without changing behavior**

```dart
return SettingsPageShell(
  title: context.l10n.settings_keyboard_title,
  child: SettingsPageBody(
    scrollable: false,
    child: Column(
      children: [
        SettingsSectionCard(
          title: context.l10n.settings_keyboard_title,
          subtitle: context.l10n.settings_keyboard_subtitle,
          child: SizedBox(
            height: 0,
            width: 0,
          ),
        ),
        Expanded(child: ListView.separated(...)),
      ],
    ),
  ),
);
```

```dart
return SettingsPageShell(
  title: context.l10n.settings_interface_customize_tabs,
  child: SettingsPageBody(
    scrollable: false,
    child: SettingsSectionCard(
      title: context.l10n.settings_interface_customize_tabs,
      subtitle: context.l10n.settings_interface_navigation_subtitle,
      child: SizedBox.expand(
        child: ReorderableListView(...),
      ),
    ),
  ),
);
```

For `ServerSettingsPage`:

```dart
child: profiles.isEmpty
    ? const SettingsPageBody(
        child: SettingsEmptyState(
          icon: Icons.dns_rounded,
          title: ...,
          action: ...,
        ),
      )
    : SettingsPageBody(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: ListView.builder(...),
        scrollable: false,
      ),
```

- [ ] **Step 5: Update the existing page tests only where structure changed**

```dart
expect(find.byType(SettingsPanelCard), findsWidgets);
expect(find.byType(SettingsLoadingState), findsNothing);
expect(find.byType(SettingsEmptyState), findsOneWidget);
```

Do not weaken the existing preference-save assertions.

- [ ] **Step 6: Run verification**

Run: `rtk proxy env HOME=/tmp flutter test test/features/setup/presentation/pages/settings/playback_settings_page_test.dart test/features/setup/presentation/pages/settings/interface_settings_page_test.dart test/features/setup/presentation/pages/settings/server_settings_page_test.dart test/features/setup/presentation/widgets/settings_page_shell_test.dart`

Expected: PASS

Run: `rtk proxy env HOME=/tmp flutter analyze`

Expected: PASS

Run: `rtk git diff --check`

Expected: no output

- [ ] **Step 7: Commit**

```bash
rtk git add \
  lib/features/setup/presentation/widgets/settings_page_shell.dart \
  lib/features/setup/presentation/pages/settings/*.dart \
  test/features/setup/presentation/widgets/settings_page_shell_test.dart \
  test/features/setup/presentation/pages/settings/*.dart
rtk git commit -m "refactor: unify settings page ui"
```

## Self-Review

- Spec coverage:
  - shared widgets: Task 1
  - hub and detail page visual consistency: Tasks 2 and 3
  - server settings exception: Task 3
  - no behavior/routing changes: enforced in Global Constraints and Task 3
- Placeholder scan: no TBD/TODO markers remain.
- Type consistency:
  - `SettingsPageBody`, `SettingsPanelCard`, `SettingsPanelGroup`, `SettingsSectionHeader`, `SettingsLoadingState`, and `SettingsEmptyState` are introduced once in Task 1 and reused consistently in Tasks 2 and 3.
