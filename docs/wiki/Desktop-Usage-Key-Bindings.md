# Desktop Usage & Key Bindings

StashFlow supports configurable keyboard shortcuts on Windows, macOS, Linux, and the web. Mobile hardware keyboards are not currently supported.

## Global Navigation

Global shortcuts work throughout the app, except while a text field is being edited.

| Default | Action |
| --- | --- |
| `Alt+Left` | Go back |
| `Ctrl+Tab` | Select the next visible navigation tab, wrapping at the end |
| `Ctrl+Shift+Tab` | Select the previous visible navigation tab, wrapping at the beginning |
| `Ctrl+1` … `Ctrl+9` | Select visible navigation tab 1–9 |

Numbered shortcuts follow the tab order configured in **Settings → Interface → Customize Tabs**. A numbered shortcut does nothing when that visible tab does not exist.

## Video Player

Video shortcuts work while the player has keyboard focus. Click the player once if another control currently has focus.

| Default | Action |
| --- | --- |
| `Space` | Play or pause |
| `Left` | Seek backward 5 seconds |
| `Right` | Seek forward 5 seconds |
| `J` | Seek backward 10 seconds |
| `L` | Seek forward 10 seconds |
| `Up` | Increase volume 5% |
| `Down` | Decrease volume 5% |
| `M` | Mute or restore audio |
| `F` | Toggle fullscreen |
| `Shift+N` | Play the next queued scene |
| `Shift+P` | Play the previous queued scene |
| `[` | Decrease playback speed by 0.25× |
| `]` | Increase playback speed by 0.25× |
| `Backspace` | Reset playback speed to 1× |
| `Esc` | Stop and close the player |

Desktop fullscreen uses the operating system window through `window_manager`. `Esc` also exits the viewer through the configured player action.

## Image Viewer

| Default | Action |
| --- | --- |
| `Left` | Previous image |
| `Right` | Next image |
| `Home` | First image |
| `End` | Last image |
| `Esc` | Close the image viewer |

Mouse and trackpad controls remain available: click to show or hide the overlay, scroll or double-click to zoom, and drag to pan a zoomed image.

## Customizing Shortcuts

Open **Settings → Keyboard Shortcuts** to:

- edit any global, video, or image shortcut;
- unbind an action;
- restore all current defaults after confirmation.

Press `Esc` to cancel shortcut capture. Bare `Tab` remains reserved for moving keyboard focus. Browser and operating-system shortcuts such as refresh, address bar, new/close tab, and `Alt+F4` cannot be assigned because StashFlow cannot receive them reliably.

If a new shortcut overlaps an existing shortcut, it moves to the new action and the old action becomes unbound. Video and image shortcuts may reuse the same keys because those viewers cannot be active together. Global shortcuts cannot overlap viewer shortcuts because their contexts are active at the same time.

Existing saved shortcuts are preserved when StashFlow adds new actions. Use **Reset to Defaults** to adopt every current default.

## Standard Window Shortcuts

The operating system and browser continue to own their normal window-management shortcuts, including `Alt+F4` on Windows, `Cmd+Q` and `Cmd+M` on macOS, and window-manager-specific Linux combinations.
