# StashFlow v1.38.0

## 🎬 Playback

- Switched to the StashFlow media-kit fork, which bundles the latest mpv libraries. Linux playback no longer requires a separately installed mpv library.
- Next/previous scene controls and auto-play-next no longer wait for a Flutter render frame when starting another video, allowing queue changes while the app is minimized.

## 📱 Android Background Controls

- Notification Pause now takes effect immediately after minimizing the app instead of being ignored during a short grace period.
- Pausing from system media controls prevents background keepalive from restarting playback, including when the player is already temporarily paused. Existing Background Playback preferences are preserved.

## 🛠️ Compatibility

- macOS now requires macOS 13 or newer to match the bundled native frameworks.
- Building from source now requires Flutter 3.47.6 or newer.
