# StashFlow v1.37.0

## 📱 Android Picture-in-Picture

- PiP now follows the video's display proportions, including rotated videos and aspect-ratio changes when auto-play-next starts another scene. The existing PiP window updates without closing and reopening.
- Entering PiP no longer triggers an app-requested screen rotation. Controls disappear before the transition, and PiP preparation skips the normal fullscreen slide and unnecessary screen resizing.
- PiP entry waits for a prepared video frame instead of a fixed delay. Returning restores the previous inline, fullscreen, or feed presentation; failed entry also restores the previous view.

## 🖥️ Desktop Picture-in-Picture

- PiP follows the current video's display proportions as playback starts or switches scenes, retaining the last known ratio while the next video's dimensions load.
- Improved aspect-ratio resizing for floating PiP windows on Wayland, including Hyprland. Scene changes preserve the window's height where possible, and manual resizing keeps the video ratio locked.
- Removed extra Linux window decoration margins around PiP and updated compatibility with the desktop window plugin.

## 📋 Browsing and Navigation

- Scene masonry grids keep their card placement when returning from playback, while restoring focus to the opened scene.
- Navigation customization now has dedicated drag handles with larger touch targets and translated tab names.
- Custom tab order and visibility persist across restarts. Settings keep at least one tab visible, and compact navigation works when only one tab is enabled.

## 🔧 Maintenance

- Updated image caching, routing, platform integration, and UI dependencies.
