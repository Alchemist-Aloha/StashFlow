# Desktop Usage & Key Bindings

This page documents keyboard shortcuts and desktop-specific behaviour in StashFlow on Windows, macOS, and Linux.

---

## Video Player

These shortcuts are active whenever the video player has keyboard focus (click the player area to ensure it does).

| Key | Action |
|-----|--------|
| `Space` | Play / Pause |
| `←` Arrow Left | Seek backward 10 seconds |
| `→` Arrow Right | Seek forward 10 seconds |

### Fullscreen

| Action | How |
|--------|-----|
| Enter fullscreen | Click the **⛶ fullscreen** button in the player controls |
| Exit fullscreen | Press `Esc`, click the **⛶ fullscreen** button again, or use the window manager's fullscreen toggle |

> On Desktop, entering fullscreen via the player uses the OS-level fullscreen window (via `window_manager`), giving you a true immersive experience without the title bar.

---

## Image Fullscreen Viewer

These shortcuts are active when the fullscreen image viewer is open.

| Key | Action |
|-----|--------|
| `←` Arrow Left | Previous image |
| `→` Arrow Right | Next image |
| `Esc` | Close the fullscreen viewer |

### Mouse interactions

| Action | How |
|--------|-----|
| Show / hide overlay | Click anywhere on the image |
| Zoom in / out | Scroll wheel, or double-click to toggle 1× ↔ 3× |
| Pan (when zoomed) | Click and drag |
| Previous / next image | Click the **‹** / **›** overlay buttons |

---

## Navigation

StashFlow uses a persistent **Navigation Rail** on the left side on desktop, giving you one-click access to all library sections:

- Scenes
- Images
- Galleries
- Performers
- Studios
- Tags
- Groups

There are no additional keyboard shortcuts for tab switching at this time. Use the rail or standard OS window management.

---

## Window Management

StashFlow uses [`window_manager`](https://pub.dev/packages/window_manager) on desktop, so standard OS keyboard shortcuts for window management all work normally:

| OS | Shortcut | Action |
|----|----------|--------|
| Windows | `Alt + F4` | Close window |
| Windows | `Win + ↑` / `Win + ↓` | Maximise / restore |
| macOS | `Cmd + Q` | Quit application |
| macOS | `Cmd + M` | Minimise |
| macOS | `Cmd + Ctrl + F` | Toggle OS fullscreen |
| Linux | Varies by window manager | — |

---

## Settings Quick Reference

| Setting | Location | Description |
|---------|----------|-------------|
| Autoplay Next | Settings → Playback | Advance to the next scene automatically when playback ends |
| Prefer sceneStreams | Settings → Playback | Use the Stash `sceneStreams` endpoint (recommended) vs. direct file paths |
| Show Video Debug Info | Settings → Playback | Overlay showing stream source and startup timing |
| Default Subtitle Language | Settings → Playback | Auto-load subtitles in the selected language |
| Subtitle Font Size | Settings → Playback | 12–32 px |
| Subtitle Vertical Position | Settings → Playback | % distance from bottom of screen |
| Subtitle Text Alignment | Settings → Playback | Left / Center / Right |
| Scene Layout | Settings → Interface | List, Grid, or TikTok |
| Show Random Navigation | Settings → Interface | Floating random/dice buttons on list and detail pages |
| Fullscreen Image Swipe | Settings → Interface | Swipe direction in the image viewer (not applicable on desktop mouse) |

---

## Tips for Desktop Use

- **Grid density** scales automatically with window width — the wider the window, the more columns are shown (up to 5+).
- The **Navigation Rail** collapses to icon-only when the window is narrow.
- Use **Settings → Interface → Show Random Navigation** to toggle the floating dice/random buttons that are visible throughout the app.
- The **Metadata editor** (scene title, date, details, URLs, studio, performers, tags) is accessible via the edit icon on the Scene Details page — fully usable with mouse and keyboard.
