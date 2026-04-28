# Design Spec: Material 3 Expressive Settings UI

**Date**: 2026-04-28
**Topic**: Settings UI Optimization (Material 3 Expressive)
**Status**: Draft

## 1. Overview
Transform the current StashFlow settings experience into a "Soft & Playful" Material 3 Expressive interface. This focuses on organic shapes, tactile interaction, and high-quality typography while replacing legacy selection patterns with modern alternatives.

## 2. Component Refinements

### 2.1 SettingsActionCard (The Unit)
*   **Shape**: Increase `borderRadius` from 16dp to 28dp (`AppTheme.radiusExtraLarge`).
*   **Background**: Change from opaque `surfaceContainerHigh` to `primaryContainer` with 10% opacity (`withValues(alpha: 0.1)`).
*   **Icon Container**: Replace standard container with a `Squircle` shape (via `ContinuousRectangleBorder`) and `secondaryContainer` background.
*   **Trailing Status**: 
    *   Remove legacy `arrow_forward_ios_rounded` icon.
    *   Introduce a "Status Pill": A small, rounded container showing the current value or a relevant icon (e.g., current theme icon).
*   **Interaction**: Add a subtle `0.98x` scale-down animation on press to provide tactile feedback.

### 2.2 SettingsSectionCard (The Group)
*   **Visuals**: Remove card background and elevation (transparent surface).
*   **Typography**: Section title uses `headlineSmall` (24pt) with `FontWeight.bold` and `primary` color.
*   **Spacing**: Vertical gap between group sections increases to 32dp.

## 3. Selection Pattern Overhaul

### 3.1 Selection Bottom Sheet (High-Level Choices)
*   **Use Case**: App Language, Server selection.
*   **Interaction**: Tapping the card opens a `showModalBottomSheet`.
*   **Visuals**: M3 Modal sheet with 28dp top corners. Large list items (56dp height) with primary-tinted selection indicator.

### 3.2 Interactive Slider (Numerical Values)
*   **Use Case**: Font Size, Avatar Size.
*   **Interaction**: Replace `DropdownButton` with a `Slider` inside a `SettingsSectionCard` group.
*   **Visuals**: M3 thick-track slider with discrete divisions and value indicator bubble.

### 3.3 MenuAnchor (Layout & Columns)
*   **Use Case**: Grid Columns, Layout Modes.
*   **Interaction**: Tapping the "Status Pill" (trailing widget) opens a `MenuAnchor`.
*   **Visuals**: Popover menu styled with 28dp radius and soft background tints to match action cards.

## 4. Page-Level Changes

### 4.1 Layout Breathability
*   The gap between individual `SettingsActionCard` items within a section increases to 16dp.
*   `ListView` padding increases to `AppTheme.spacingLarge` (24dp) for a less cramped look.

### 4.2 Motion
*   Implement a staggered list animation (`fadedSlideIn`) where each setting card slides up slightly and fades in when the page is opened.

## 5. Success Criteria
*   Visual consistency across all settings sub-pages.
*   No legacy `DropdownButton` remains in the settings flow.
*   UI remains usable on narrow mobile screens (no overflows).
*   Maintains Material 3 "Expressive" feel through shapes and breathing room.
