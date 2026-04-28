# Global UI Scaling System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate font and element scaling into a single "Global UI Scale" slider that affects typography, spacing, and component dimensions proportionally.

**Architecture:** Use a single `appGlobalScaleProvider` (renamed from `appFontSizeProvider`) to drive both `textTheme` scaling and a custom `AppDimensions` theme extension. Spacing constants will move from static fields to reactive theme extension properties.

**Tech Stack:** Flutter, Riverpod (Riverpod Generator), Shared Preferences, Material 3.

---

### Task 1: Migrate State Management

**Files:**
- Modify: `lib/core/presentation/providers/layout_settings_provider.dart`
- Modify: `lib/features/setup/presentation/pages/settings/appearance_settings_page.dart` (partial)
- Modify: `lib/main.dart` (partial)

- [ ] **Step 1: Rename provider and storage key**

In `lib/core/presentation/providers/layout_settings_provider.dart`, rename `AppFontSize` to `AppGlobalScale` and update the storage key.

```dart
@riverpod
class AppGlobalScale extends _$AppGlobalScale {
  static const _storageKey = 'app_global_scale_factor';
  static const _legacyKey = 'app_font_size_factor';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Migration: prefer new key, fallback to legacy
    return prefs.getDouble(_storageKey) ?? prefs.getDouble(_legacyKey) ?? 1.0;
  }

  Future<void> set(double value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_storageKey, value);
  }
}
```

- [ ] **Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `appGlobalScaleProvider` is generated.

- [ ] **Step 3: Update references to the provider**

Update `lib/main.dart` and `lib/features/setup/presentation/pages/settings/appearance_settings_page.dart` to use `appGlobalScaleProvider` instead of `appFontSizeProvider`.

- [ ] **Step 4: Commit**

```bash
git add lib/core/presentation/providers/layout_settings_provider.dart lib/core/presentation/providers/layout_settings_provider.g.dart lib/main.dart lib/features/setup/presentation/pages/settings/appearance_settings_page.dart
git commit -m "feat: rename font size provider to global scale provider"
```

---

### Task 2: Expand AppDimensions ThemeExtension

**Files:**
- Modify: `lib/core/presentation/theme/app_theme.dart`

- [ ] **Step 1: Update AppDimensions class**

Modify the `AppDimensions` class in `lib/core/presentation/theme/app_theme.dart` to include spacing and padding fields.

```dart
@immutable
class AppDimensions extends ThemeExtension<AppDimensions> {
  const AppDimensions({
    required this.performerAvatarSize,
    required this.cardTitleFontSize,
    required this.fontSizeFactor,
    required this.spacingSmall,
    required this.spacingMedium,
    required this.spacingLarge,
    required this.buttonHeight,
  });

  final double performerAvatarSize;
  final double cardTitleFontSize;
  final double fontSizeFactor;
  final double spacingSmall;
  final double spacingMedium;
  final double spacingLarge;
  final double buttonHeight;

  @override
  AppDimensions copyWith({
    double? performerAvatarSize,
    double? cardTitleFontSize,
    double? fontSizeFactor,
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    double? buttonHeight,
  }) {
    return AppDimensions(
      performerAvatarSize: performerAvatarSize ?? this.performerAvatarSize,
      cardTitleFontSize: cardTitleFontSize ?? this.cardTitleFontSize,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      spacingSmall: spacingSmall ?? this.spacingSmall,
      spacingMedium: spacingMedium ?? this.spacingMedium,
      spacingLarge: spacingLarge ?? this.spacingLarge,
      buttonHeight: buttonHeight ?? this.buttonHeight,
    );
  }

  @override
  AppDimensions lerp(ThemeExtension<AppDimensions>? other, double t) {
    if (other is! AppDimensions) return this;
    return AppDimensions(
      performerAvatarSize: lerpDouble(performerAvatarSize, other.performerAvatarSize, t)!,
      cardTitleFontSize: lerpDouble(cardTitleFontSize, other.cardTitleFontSize, t)!,
      fontSizeFactor: lerpDouble(fontSizeFactor, other.fontSizeFactor, t)!,
      spacingSmall: lerpDouble(spacingSmall, other.spacingSmall, t)!,
      spacingMedium: lerpDouble(spacingMedium, other.spacingMedium, t)!,
      spacingLarge: lerpDouble(spacingLarge, other.spacingLarge, t)!,
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
    );
  }
}
```

- [ ] **Step 2: Update AppTheme.buildTheme**

Update `buildTheme` to calculate these values based on `fontSizeFactor` (renamed to `scaleFactor` internally).

```dart
static ThemeData buildTheme(
  Brightness brightness,
  Color seedColor, {
  bool useTrueBlack = false,
  double? cardTitleFontSize,
  double? performerAvatarSize,
  double fontSizeFactor = 1.0, // This is our scaleFactor
}) {
  // ... existing color logic ...
  
  final dims = AppDimensions(
    performerAvatarSize: (performerAvatarSize ?? 16.0) * fontSizeFactor,
    cardTitleFontSize: (cardTitleFontSize ?? 12.0) * fontSizeFactor,
    fontSizeFactor: fontSizeFactor,
    spacingSmall: 8.0 * fontSizeFactor,
    spacingMedium: 16.0 * fontSizeFactor,
    spacingLarge: 24.0 * fontSizeFactor,
    buttonHeight: 48.0 * fontSizeFactor,
  );

  return ThemeData(
    // ...
    inputDecorationTheme: InputDecorationTheme(
      // ...
      contentPadding: EdgeInsets.symmetric(
        horizontal: dims.spacingMedium,
        vertical: dims.spacingMedium,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(dims.buttonHeight),
        padding: EdgeInsets.symmetric(
          horizontal: dims.spacingLarge,
          vertical: dims.spacingMedium,
        ),
        // ...
      ),
    ),
    // Repeat for OutlinedButton and TextButton themes
    extensions: [
      dims,
      // ... other extensions
    ],
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/presentation/theme/app_theme.dart
git commit -m "feat: add scaled spacing and button dimensions to AppDimensions"
```

---

### Task 3: Update Appearance Settings UI

**Files:**
- Modify: `lib/features/setup/presentation/pages/settings/appearance_settings_page.dart`
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Update Localization Strings**

Update `lib/l10n/app_en.arb` (and other languages if possible, or just EN for now) to reflect "Global UI Scale".

```json
"settings_appearance_font_size": "Global UI Scale",
"settings_appearance_font_size_subtitle": "Scale typography and spacing proportionally",
```

- [ ] **Step 2: Update Slider in AppearanceSettingsPage**

Rename `_buildFontSizeFactorSlider` to `_buildGlobalScaleSlider` and ensure it uses `appGlobalScaleProvider`.

- [ ] **Step 3: Commit**

```bash
git add lib/l10n/app_en.arb lib/features/setup/presentation/pages/settings/appearance_settings_page.dart
git commit -m "ui: update appearance settings to control global UI scale"
```

---

### Task 4: Systematic Refactoring of Hardcoded Sizes

**Files:**
- Modify: `lib/features/scenes/presentation/widgets/scene_card.dart`
- Modify: `lib/core/presentation/widgets/grid_card.dart`
- Modify: (Other files identified in grep)

- [ ] **Step 1: Replace hardcoded EdgeInsets and SizedBox**

In identified files, replace `AppTheme.spacingMedium` (static) or `16.0` (literal) with `context.dimensions.spacingMedium`.

Example for `lib/features/scenes/presentation/widgets/scene_card.dart`:
```dart
// OLD
padding: const EdgeInsets.all(AppTheme.spacingMedium),
// NEW
padding: EdgeInsets.all(context.dimensions.spacingMedium),
```

- [ ] **Step 2: Test scaling**

Verify that changing the slider scales these specific widgets correctly.

- [ ] **Step 3: Commit**

```bash
git add lib/features/
git commit -m "refactor: replace hardcoded spacing with context.dimensions"
```
