# StashFlow v1.38.0

## 🎬 Playback

- Switched to the StashFlow media-kit fork, which bundles the latest mpv libraries. Linux playback no longer requires a separately installed mpv library.
- Next/previous scene controls and auto-play-next no longer wait for a Flutter render frame when starting another video, allowing queue changes while the app is minimized.

## ⚙️ Playback Tuning

- Added native playback settings for video output and hardware decoding, including Android GPU next output and Linux VA-API, NVIDIA, VDPAU copy-back, and embedded software output options. Availability depends on your GPU and drivers.
- Added controls for frame interpolation, video synchronization, scaling filters, and debanding. Higher-quality filters increase GPU load, and interpolation depends on display timing and output support.
- Added a custom mpv configuration editor for supported playback-tuning options. Custom values override the selectors; scripts, profiles, and app-owned options are not supported. Settings apply to newly created players; restart the app to update all players. Direct Android and embedded software outputs skip rendering overrides.

## 📊 Playback Diagnostics

- Expanded the optional video debug overlay with codec, active hardware decoding, video output, frame rates, dropped frames, A/V sync, cache, and startup information. The scrollable panel follows player-control visibility; unsupported metrics appear as unavailable.
- Debug logging for seek-preview thumbnails no longer records request URLs or raw error messages that could contain authentication details.

## 🌐 Web Playback

- Fixed media opening in browsers by omitting unsupported custom HTTP headers. Feed videos now use the same browser-compatible authentication fallback as the main player and scene previews.

## 📱 Android Background Controls

- Notification Pause now takes effect immediately after minimizing the app instead of being ignored during a short grace period.
- Pausing from system media controls prevents background keepalive from restarting playback, including when the player is already temporarily paused. Existing Background Playback preferences are preserved.

## 🛠️ Compatibility

- macOS now requires macOS 13 or newer to match the bundled native frameworks.
- Building from source now requires Flutter 3.47.6 or newer.
