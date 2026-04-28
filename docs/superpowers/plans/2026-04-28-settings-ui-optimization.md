# Material 3 Expressive Settings UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the Settings UI into a "Soft & Playful" Material 3 Expressive interface with enhanced components and modern selection patterns.

**Architecture:** Refactor `settings_page_shell.dart` components for expressive styling, then systematically replace legacy selection widgets in sub-pages with specialized bottom sheets, sliders, and menu anchors.

**Tech Stack:** Flutter, Riverpod, Material 3.

---

### Task 1: Refactor SettingsActionCard for Expressive Styling

**Files:**
- Modify: `lib/features/setup/presentation/widgets/settings_page_shell.dart`

- [ ] **Step 1: Update SettingsActionCard styling**
Modify the `build` method to use `AppTheme.radiusExtraLarge`, a tinted background, and the `Squircle` icon container. Add scale animation.

```dart
// lib/features/setup/presentation/widgets/settings_page_shell.dart

class SettingsActionCard extends StatefulWidget { // Change to StatefulWidget for animation
  const SettingsActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  State<SettingsActionCard> createState() => _SettingsActionCardState();
}

class _SettingsActionCardState extends State<SettingsActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
        ),
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingMedium,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Icon(widget.icon, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                widget.trailing ?? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/features/setup/presentation/widgets/settings_page_shell.dart
git commit -m "feat(settings): update SettingsActionCard to M3 Expressive style"
```

---

### Task 2: Refactor SettingsSectionCard and Shell Spacing

**Files:**
- Modify: `lib/features/setup/presentation/widgets/settings_page_shell.dart`
- Modify: `lib/features/setup/presentation/pages/settings/settings_hub_page.dart`

- [ ] **Step 1: Update SettingsSectionCard to be transparent with bold headers**

```dart
// lib/features/setup/presentation/widgets/settings_page_shell.dart

class SettingsSectionCard extends StatelessWidget {
  // ... existing fields ...

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
              child: Text(
                title!,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
          // ... subtitle logic ...
          const SizedBox(height: AppTheme.spacingMedium),
          child,
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update SettingsHubPage layout and spacing**
Increase vertical spacing between cards to 16dp.

- [ ] **Step 3: Commit changes**

```bash
git add lib/features/setup/presentation/widgets/settings_page_shell.dart lib/features/setup/presentation/pages/settings/settings_hub_page.dart
git commit -m "feat(settings): refine section headers and shell spacing"
```

---

### Task 3: Implement Selection Bottom Sheet for Language Settings

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`

- [ ] **Step 1: Replace Language Dropdown with Bottom Sheet**
Create a helper method `_showLanguagePicker` and update the Language setting card to call it.

- [ ] **Step 2: Commit changes**

```bash
git add lib/features/setup/presentation/pages/settings/interface_settings_page.dart
git commit -m "feat(settings): use bottom sheet for language selection"
```

---

### Task 4: Implement Interactive Sliders for Size Settings

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`

- [ ] **Step 1: Replace Font Size and Avatar Size dropdowns with Sliders**
Add `Slider` widgets within the section card for `_cardTitleFontSize` and `_performerAvatarSize`.

- [ ] **Step 2: Commit changes**

```bash
git add lib/features/setup/presentation/pages/settings/interface_settings_page.dart
git commit -m "feat(settings): replace size dropdowns with interactive sliders"
```

---

### Task 5: Implement MenuAnchor for Layout and Columns

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/interface_settings_page.dart`

- [ ] **Step 1: Replace Grid Column dropdowns with MenuAnchor**
Update `_buildGridColumnSetting` to use a `MenuAnchor` with a "Status Pill" trailing widget.

- [ ] **Step 2: Commit changes**

```bash
git add lib/features/setup/presentation/pages/settings/interface_settings_page.dart
git commit -m "feat(settings): use MenuAnchor for grid column selection"
```

---

### Task 6: Final Polish and Appearance Page Update

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/appearance_settings_page.dart`

- [ ] **Step 1: Update AppearanceSettingsPage**
Ensure SegmentedButton and Theme Mode selection match the new expressive style.

- [ ] **Step 2: Verify all settings pages**
Check `playback_settings_page.dart`, `server_settings_page.dart`, etc., to ensure they inherit the new component styles correctly.

- [ ] **Step 3: Commit changes**

```bash
git add lib/features/setup/presentation/pages/settings/appearance_settings_page.dart
git commit -m "feat(settings): polish appearance page and verify consistency"
```
