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

- Scene lists restore focus and scroll position to the active scene when returning from playback, including when next/previous navigation replaces the details route. Random returns keep the originating playlist item selected.
- Playlist selections replace the current scene-details destination instead of stacking another page, so Back returns to the scene list or feed after one step, even after several playlist hops.
- Feed playback now synchronizes to the active scene after returning from details, fullscreen, or PiP, while keeping user-paused playback paused. Inactive cached videos pause as you swipe between scenes.
- In the feed, tap a scene title to hide playback overlays; tap the video once to bring them back without changing playback. The choice stays in effect until changed.
- Navigation customization now has dedicated drag handles with larger touch targets and translated tab names. Custom tab order and visibility persist across restarts, settings keep at least one tab visible, and compact navigation remains usable with one tab enabled.

## 🔧 Maintenance

- Updated image caching, routing, platform integration, and UI dependencies.
