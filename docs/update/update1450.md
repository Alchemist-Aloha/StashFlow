# StashFlow v1.45.0

## 🔔 Android Background Playback

- Fixed queue playback stopping when the screen is locked. The next scene no longer stays paused at 0:00 after an automatic advance, and scenes you open afterwards no longer pause at their start until you press Play.
- After a phone call or another app takes over audio, starting a scene now plays it again instead of leaving it paused.

## 🌐 Web

- The web version now runs as WebAssembly in browsers that support it, with the previous JavaScript build kept as a fallback for older browsers.
- Fixed the seek bar jumping back to the resume point after dragging it to an earlier position in a resumed scene. The video now plays from where you drop the thumb, and the bar shows the right time.
