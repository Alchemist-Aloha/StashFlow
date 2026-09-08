# StashFlow v1.33.0

## 🖼️ Thumbnail Reliability

- Stopped repeated thumbnail retry storms: when images fail to load because a file is missing or the server is briefly unreachable, StashFlow now pauses retrying that image for 30 seconds and shows a placeholder instead.
- Reduced redundant requests and browsing stalls when many thumbnails are unavailable at once, while letting images recover automatically once the server is reachable again.

## 🔐 Sign-in Reliability

- Made session restore more robust: a network hiccup while refreshing an existing session during startup now falls back cleanly to signed-out instead of interrupting the restore partway.

## 🎬 Linux Playback

- Connected video playback to Linux system media controls, including scene details, artwork, playback position, and play, pause, seek, previous, and next actions.
- Fixed a freeze that could occur after returning from a playing scene to the scene list and then opening another scene.

## 🔧 Maintenance

- Removed unused experimental developer options for web and proxy-based authentication.
- Updated core Flutter dependencies and Android build compatibility, including support for Android API 37.
- Simplified internal playback, fullscreen, queue, and cache handling without changing app behavior.
