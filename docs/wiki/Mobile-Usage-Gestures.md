# Mobile Usage & Gestures

This page documents all touch gestures available in StashFlow on Android.

---

## Video Player

### Seek Interaction Mode

StashFlow supports two seek interaction modes. Switch between them in  
**Settings → Playback → Seek interaction**.

#### Double-Tap Seek (default)

| Gesture | Action |
|---------|--------|
| **Single tap** | Show / hide player controls |
| **Double-tap left half** | Seek backward 10 seconds |
| **Double-tap right half** | Seek forward 10 seconds |

#### Drag Seek

| Gesture | Action |
|---------|--------|
| **Single tap** | Show / hide player controls |
| **Horizontal drag left** | Seek backward (drag distance ∝ time skipped) |
| **Horizontal drag right** | Seek forward (drag distance ∝ time skipped) |

> Drag seek uses a non-linear (curved) mapping so short drags make fine adjustments while long drags jump further.

### Fullscreen

| Gesture | Action |
|---------|--------|
| **Tap fullscreen icon** (controls visible) | Enter / exit immersive fullscreen |
| **Back button / back gesture** | Exit fullscreen (returns to inline player) |

---

## TikTok-Style Scene View

The TikTok layout is a full-screen vertical scroll feed of scenes.  
Enable it via **Settings → Interface → Scene Layout → TikTok**.

| Gesture | Action |
|---------|--------|
| **Swipe up** | Next scene |
| **Swipe down** | Previous scene |
| **Tap** | Show / hide overlay controls |
| **Long press** | Instantly speed up playback to 5× |
| **Long press + drag upward** | Further increase speed (up to 20×); release to return to normal speed |

---

## Image Fullscreen Viewer

### Navigation

The swipe direction to advance images is configurable via  
**Settings → Interface → Fullscreen Image Swipe Direction**.

| Setting | Next image | Previous image |
|---------|-----------|----------------|
| **Vertical swipe** (default) | Swipe up | Swipe down |
| **Horizontal swipe** | Swipe left | Swipe right |

### Zoom & Controls

| Gesture | Action |
|---------|--------|
| **Tap** | Show / hide overlay (navigation buttons, rating, etc.) |
| **Double-tap** | Toggle zoom — 1× → 3× → 1× |
| **Pinch** | Free zoom in / out |
| **Tap ‹ / › buttons** (overlay visible) | Go to previous / next image |

---

## Discovery & Navigation

| Gesture | Action |
|---------|--------|
| **Shake device** | Jump to a random item in the current tab |

> Enable Shake-to-Discover in **Settings → Interface → Shake to Discover**.  
> Works on the Scenes, Images, and Galleries tabs.

---

## Mini-Player

The mini-player appears at the bottom of the screen when a video is playing and you navigate away from the scene details page.

| Gesture | Action |
|---------|--------|
| **Tap** mini-player | Return to the current scene's details page |
| **Tap ▶ / ⏸ button** | Play / pause without leaving the current page |

---

## Settings Quick Reference

| Setting | Location | Effect on gestures |
|---------|----------|--------------------|
| Seek interaction | Settings → Playback | Switches between double-tap seek and drag seek |
| Fullscreen image swipe direction | Settings → Interface | Changes swipe axis for image navigation |
| Shake to Discover | Settings → Interface | Enables / disables shake-to-random |
| Autoplay Next | Settings → Playback | Automatically advances to next scene on completion |
| Background Playback | Settings → Playback | Audio continues when app is minimised |
| Native Picture-in-Picture | Settings → Playback | Enters PiP automatically when app is backgrounded |
