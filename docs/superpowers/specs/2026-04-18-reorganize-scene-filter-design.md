# Design Spec: Reorganize Scene Filter Widget & Expand Organized Filter

## 1. Overview
The current `SceneFilterPanel` is cluttered, and the "Organized" filter only supports a boolean toggle (Organized vs. All). This design reorganizes the filter fields into logical sections and upgrades the "Organized" filter to support "All", "Organized", and "Unorganized" across all media types.

## 2. Requirements
- Reorganize `SceneFilterPanel` into seven distinct sections.
- In the "General" section, include only "Minimum Rating" and the new "Organized" filter.
- Implement the "Organized" filter as three selectable chips: **All**, **Organized**, and **Unorganized**.
- Apply the same "Organized" filter logic to `GalleryFilterPanel`, `ImageFilterPanel`, and `StudioFilterPanel`.
- Ensure "Unorganized" filters for items where `organized == false`.
- Keep action buttons ("Apply", "Save Default") fixed at the bottom.

## 3. Architecture & Components

### 3.1 Data Structures
- Create a new enum `OrganizedFilter` to represent the three states.
- Update `SceneOrganizedOnly`, `GalleryOrganizedOnly`, and `ImageOrganizedOnly` providers to use this enum instead of a boolean.
- Update `StudioFilter` to handle the enum if possible, or map it to `bool?`.

```dart
enum OrganizedFilter { all, organized, unorganized }
```

### 3.2 UI Sections (SceneFilterPanel)
1. **General**: Rating, Organized Chips.
2. **Performer**: Performers, Performer Tags, Performer Age, Performer Count.
3. **Library**: Studios, Groups, Galleries, Tags, Tag Count.
4. **Metadata**: Code, Details, Director, URL, Date, Path, Captions.
5. **Media Info**: Resolution, Orientation, Duration, Bitrate, Video Codec, Audio Codec, Framerate, File Count.
6. **Usage**: Play Count, Play Duration, O-Counter, Last Played At, Resume Time, Interactive, Interactive Speed.
7. **System**: ID, Stash ID Count, Oshash, Checksum, Phash, Duplicated, Has Markers, Is Missing, Created At, Updated At.

### 3.3 Implementation Details
- **Organized Chips**: Use `ChoiceChip` in a `Wrap` widget.
- **Sectioning**: Use `FilterSection` (custom widget) for each group.
- **Backend Mapping**:
  - `OrganizedFilter.all` -> `null` (no filter applied)
  - `OrganizedFilter.organized` -> `true`
  - `OrganizedFilter.unorganized` -> `false`

## 4. Testing Strategy
- **Manual Verification**:
  - Open each filter panel and verify the "Organized" chips are present and functional.
  - Verify that selecting "Organized" only shows organized items.
  - Verify that selecting "Unorganized" only shows unorganized items.
  - Verify that "All" resets the filter.
  - Check the `SceneFilterPanel` for correct sectioning and field placement.
- **Regression**:
  - Ensure other filters (Rating, Resolution, etc.) still work correctly.
  - Verify "Save as Default" persists the new enum state correctly.
