# Mobile Usage & Gestures

This page documents the touch gestures and controls available in StashFlow on Android.

---

## Video Player

### Tap and seek

| Gesture | Action |
|---------|--------|
| **Single tap** | Show / hide player controls |

StashFlow supports two seek interaction modes. Switch between them in
**Settings → Playback → Seek interaction**.

#### Drag Seek (default)

| Gesture | Action |
|---------|--------|
| **Horizontal drag left** | Seek backward — drag distance maps to time skipped |
| **Horizontal drag right** | Seek forward — drag distance maps to time skipped |

> Drag seek uses a non-linear (curved) mapping, so short drags make fine adjustments while long
> drags jump further. While a scene exposes VTT thumbnails, the drag shows a scrubbing preview.

#### Double-Tap Seek

| Gesture | Action |
|---------|--------|
| **Double-tap left half** | Seek backward 10 seconds |
| **Double-tap right half** | Seek forward 10 seconds |

### Vertical drag — brightness and volume

| Gesture | Action |
|---------|--------|
| **Vertical drag on the left half** | Adjust screen brightness |
| **Vertical drag on the right half** | Adjust volume |

A percentage overlay appears while you drag.

### Playback speed

| Gesture | Action |
|---------|--------|
| **Long press** | Speed up to 2× |
| **Long press + drag upward** | Increase speed up to 10× |
| **Release** | Return to the previous speed |

### Zoom and rotation

| Gesture | Action |
|---------|--------|
| **Two-finger pinch** | Zoom the video |
| **Two-finger rotate** | Freely rotate the video |

### Fullscreen

| Gesture | Action |
|---------|--------|
| **Tap fullscreen icon** (controls visible) | Enter / exit immersive fullscreen |
| **Double-tap** (desktop-style pointer, when Double-Tap Seek is off) | Toggle fullscreen |
| **Back button / back gesture** | Exit fullscreen (returns to inline player) |

---

## TikTok-Style Scene Feed

The Feed layout is a full-screen vertical scroll feed of scenes.
Enable it via **Settings → Interface → Scenes Layout → Default Layout → Feed**.

| Gesture | Action |
|---------|--------|
| **Swipe up** | Next scene |
| **Swipe down** | Previous scene |
| **Tap** | Play / pause |
| **Long press** | Speed up to 5× |
| **Long press + drag upward** | Increase speed up to 20×; release returns to normal speed |

---

## Image Fullscreen Viewer

### Navigation

The swipe direction to advance images is configurable via
**Settings → Interface → Image Viewer → Fullscreen Swipe Direction**.

| Setting | Next image | Previous image |
|---------|-----------|----------------|
| **Vertical swipe** (default) | Swipe up | Swipe down |
| **Horizontal swipe** | Swipe left | Swipe right |

### Zoom & Controls

| Gesture | Action |
|---------|--------|
| **Tap** | Show / hide the overlay (navigation, rating, actions) |
| **Double-tap** | Toggle zoom — 1× ↔ 3×, centered on the tap point |
| **Pinch** | Zoom in / out (roughly 0.9×–5×) |
| **Drag** | Pan while zoomed |
| **Tap ‹ / › buttons** (overlay visible) | Previous / next image |

---

## Scene Cards

| Gesture | Action |
|---------|--------|
| **Horizontal drag** | Scrub the preview thumbnail (when the scene has VTT sprites) |
| **Long press** | Open the card's context menu |

---

## Discovery & Random Navigation

There is no shake gesture. Random discovery is handled by the floating **casino** buttons:

| Action | Result |
|--------|--------|
| **Tap the casino button** on a list or details page | Jump to a random item in the current context |

> Toggle these buttons in **Settings → Interface → Show Random Navigation Buttons**.
> For Scenes, **Respect active filters for random scene** controls whether the current filter is
> applied when picking a random scene.

---

## Mini-Player

The mini-player appears at the bottom of the screen when a video is playing and you navigate away
from the scene details page.

| Action | Result |
|--------|--------|
| **Tap** the mini-player | Return to the current scene's details page |
| **Tap the play / pause button** | Play or pause without leaving the current page |
| **Tap the close button** | Stop playback and dismiss the mini-player |

> The mini-player can show the live video surface instead of a screenshot. Toggle this in
> **Settings → Interface → Use actual scene video in miniplayer**.

---

## Settings Quick Reference

| Setting | Location | Effect on gestures |
|---------|----------|--------------------|
| Seek interaction | Settings → Playback | Switches between drag seek and double-tap seek |
| Fullscreen Swipe Direction | Settings → Interface → Image Viewer | Changes the swipe axis for image navigation |
| Show Random Navigation Buttons | Settings → Interface | Enables / disables the random casino buttons |
| Respect active filters for random scene | Settings → Interface | Whether random scenes honor the active filter |
| Play End Behavior | Settings → Playback | What happens when a scene ends (stop / loop / next) |
| Background Playback | Settings → Playback | Audio continues when the app is minimised |
| Native Picture-in-Picture | Settings → Playback | Auto-enter PiP when the app is backgrounded |
| Use actual scene video in miniplayer | Settings → Interface | Live video vs. screenshot in the mini-player |
