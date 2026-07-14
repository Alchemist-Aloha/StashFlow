# Keyboard Navigation Usability Design

## Goal

Improve desktop and web keyboard navigation, make shortcut handling resilient to conflicts and invalid saved data, and make keyboard bindings easy to discover and edit.

Mobile touch behavior and mobile hardware keyboards are out of scope.

## Existing System

StashFlow already stores one configurable `Keybind` per `KeybindAction` in `keybindsProvider`. `ShellPage`, `NativeVideoControls`, and `ImageFullscreenPage` create context-specific `CallbackShortcuts` maps from that state. The settings page captures a single key combination, while direct tab shortcuts (`Ctrl+1` through `Ctrl+9`) are currently hard-coded in `ShellPage`.

The existing design will be extended instead of replaced. This preserves saved preferences and avoids an unnecessary `Intent`/`Action` hierarchy.

## Shortcut Contexts

Actions belong to one of three contexts:

- Global navigation: active throughout the desktop/web shell.
- Video player: active only while the video controls own focus.
- Image viewer: active only while the fullscreen image viewer owns focus.

Video and image actions may reuse the same shortcut because those contexts cannot be active together. Global shortcuts overlap both viewer contexts, so assigning a viewer shortcut that conflicts with a global shortcut, or vice versa, moves the shortcut to the newly assigned action.

Global navigation shortcuts must not run while an editable text control has focus. This prevents accidental navigation and loss of in-progress input.

## Default Bindings

### Global navigation

| Action | Default |
| --- | --- |
| Back | `Alt+Left` |
| Next tab | `Ctrl+Tab` |
| Previous tab | `Ctrl+Shift+Tab` |
| Go to tabs 1–9 | `Ctrl+1` through `Ctrl+9` |

Adjacent-tab navigation wraps at the first and last visible tabs. Direct tab actions do nothing when their numbered visible tab does not exist.

### Video player

Existing playback, seeking, volume, mute, fullscreen, picture-in-picture, and speed defaults remain unchanged. Scene navigation changes to common media conventions:

| Action | Default |
| --- | --- |
| Next scene | `Shift+N` |
| Previous scene | `Shift+P` |

`Esc` remains the video close action. It is no longer also the global Back shortcut.

### Image viewer

| Action | Default |
| --- | --- |
| Previous image | `Left` |
| Next image | `Right` |
| First image | `Home` |
| Last image | `End` |
| Close viewer | `Esc` |

First/last navigation is a no-op when already at the corresponding endpoint or when no images are available.

## Persistence and Conflict Handling

The existing `desktop_keybinds` preference remains the storage format: a JSON object keyed by stable enum names. Newly introduced actions receive their defaults when absent from saved data. Existing user choices remain unchanged until reset.

Assignment is atomic. Before saving a new binding, the provider removes the same combination from any action whose context overlaps the target context, then assigns it to the target action and persists once. Unbinding removes the action from saved state. Reset removes the preference and restores all current defaults.

Malformed individual entries fall back to that action's default without discarding other valid saved bindings. Unknown action names are ignored, allowing forward and backward preference compatibility.

## Binding Page

The page groups rows into Global Navigation, Video Player, and Image Viewer sections. Each row contains a localized action name and description, a readable shortcut chip, and accessible Edit and Unbind actions. Standard Flutter buttons and focus traversal provide `Tab`, `Shift+Tab`, `Enter`, and `Space` operation without custom focus code.

The capture dialog names the action and displays the captured combination. `Esc` cancels. Modifier-only events and bare `Tab` are not assignable. Browser and operating-system combinations that StashFlow cannot reliably receive, such as refresh, close-tab/window, and address-bar shortcuts, are rejected with localized feedback. Saving a conflicting shortcut reports which previous action was unbound.

Reset requires confirmation because it changes every customized shortcut.

All existing hard-coded English action labels and descriptions move to app localization resources.

## Runtime Handling

`ShellPage` builds all global bindings from provider state, including direct and adjacent tab navigation. It checks the primary focus before invoking global callbacks and returns without navigation when an `EditableText` owns focus.

`NativeVideoControls` and `ImageFullscreenPage` continue building only the bindings relevant to their own contexts. Image first/last callbacks use the existing page controller and image index state. Unsupported actions are not inserted into a context's shortcut map.

## Testing

Focused tests will cover:

- improved defaults and missing-action migration;
- per-entry recovery from malformed saved JSON;
- atomic conflict moves across overlapping contexts and permitted reuse across video/image contexts;
- unbind and reset persistence;
- direct and wrapping tab navigation;
- suppression of global shortcuts while editing text;
- image first/last navigation and endpoint no-ops;
- capture-dialog cancellation, invalid-key handling, conflict feedback, reset confirmation, and keyboard focus traversal;
- localized binding-page rendering.

Tests will be written before each behavior change and observed failing for the expected reason before implementation.

## Documentation

`docs/wiki/Desktop-Usage-Key-Bindings.md` will be updated with the complete defaults, contexts, focus behavior, customization workflow, conflict rules, reset behavior, and desktop/web scope.
