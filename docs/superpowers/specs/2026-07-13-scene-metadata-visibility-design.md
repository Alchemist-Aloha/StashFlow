# Scene Metadata Visibility Design

## Goal

Place the existing technical scene metadata directly below Studio and Year, hide it by default, and let users reveal it with a local button or disable the default hiding preference in Interface Settings.

## Design

`SceneDetailsPage` will read a persisted Riverpod preference backed by `SharedPreferences`. The preference defaults to `true` (hide technical metadata initially). The page keeps a local `_showTechnicalMetadata` state initialized from that preference when the scene is built. If metadata is hidden, the same header position contains a `Show metadata` text button; tapping it reveals the existing chips for that scene. If the preference is disabled, chips render immediately and no reveal button is shown.

The setting will be added to the existing Interface Settings section with a native adaptive switch. Changing it persists through the provider and affects newly opened/rebuilt scene details pages; it does not override a user’s one-page reveal action.

## Scope

- Reuse the existing technical metadata chip builder.
- Add one provider, one Interface Settings switch, and localized English strings.
- Preserve the existing header keys and action layout behavior where possible.
- Add focused widget coverage for default-hidden, reveal, and preference-disabled states.

## Verification

Run the focused scene UI test, the Interface Settings test if available, `dart format` on touched Dart files, and `flutter analyze` on touched files.
