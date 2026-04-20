# Design Spec: Improve Sort Scene Widget

## 1. Overview
The current sort scene widget in `ScenesPage` uses a `Wrap` widget for sort methods, which can grow too large on small screens, pushing important action buttons ("Apply", "Save Default") off-screen. This design improves the layout by constraining the sort method section and ensuring it is scrollable while keeping other elements fixed.

## 2. Requirements
- The "Sort method" section must fit into a smaller, scrollable vertical section.
- "Apply Filter" and "Set Default" buttons must always be visible at the bottom of the sheet.
- The layout must be responsive and work across multiple platforms (Mobile/Desktop).
- Maintain existing functionality: sorting by various fields, toggling direction, and saving defaults.

## 3. Architecture & Components

### Layout Structure (Column)
1. **Header (Fixed)**: 
   - Title: "Sort Scenes"
   - Reset Button: "Reset"
2. **Sort Method Label (Fixed)**: 
   - Label: "Sort method"
3. **Sort Method Section (Scrollable)**: 
   - Container: `Flexible` with `ConstrainedBox` (max height: 250px or 30% of screen height).
   - Scroll View: `SingleChildScrollView` with a `Scrollbar` for desktop visibility.
   - Content: `Wrap` containing `ChoiceChip`s for each `_SceneSortField`.
4. **Direction Section (Fixed)**: 
   - Label: "Direction"
   - Input: `SegmentedButton<bool>` (Ascending/Descending).
5. **Action Buttons (Fixed)**: 
   - Primary: "Apply Sort" (`ElevatedButton`)
   - Secondary: "Save as Default" (`OutlinedButton`)

## 4. Implementation Details

### Scrollable Section
```dart
Flexible(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.3,
    ),
    child: Scrollbar(
      thumbVisibility: true, // Visible on desktop/web
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
        child: Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: _SceneSortField.values.map(...).toList(),
        ),
      ),
    ),
  ),
),
```

### Button Persistence
By using `MainAxisSize.min` on the outer `Column` and wrapping the middle section in `Flexible`, the buttons will stay at the bottom of the sheet even when the middle section scrolls.

## 5. Testing Strategy
- **Manual UI Testing**:
  - Verify scrolling behavior on mobile (touch) and desktop (scroll wheel/scrollbar).
  - Confirm buttons are visible on small screen sizes (e.g., iPhone SE, split-view on Android).
  - Ensure "Reset" properly updates the state within the scrollable section.
- **Regression Testing**:
  - Ensure sorting still triggers the correct data fetch via `_applyServerSort`.
  - Verify "Save as Default" persists the state correctly.
