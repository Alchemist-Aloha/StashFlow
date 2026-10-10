# StashFlow v1.37.0

## 🎨 Appearance

- Custom theme colors now have a full-spectrum picker with hue, saturation, and brightness sliders, a color preview, and hexadecimal input. Apply saves the color; Cancel leaves the current theme unchanged.

## 📱 Android Picture-in-Picture

- PiP now follows the video's display proportions, including rotated videos and aspect-ratio changes when auto-play-next starts another scene. The existing PiP window updates without closing and reopening.
- Entering PiP no longer triggers an app-requested screen rotation. Controls disappear before the transition, and PiP preparation skips the normal fullscreen slide and unnecessary screen resizing.
- PiP entry waits for a prepared video frame instead of a fixed delay. Returning restores the previous inline, fullscreen, or feed presentation; failed entry also restores the previous view.

## 🖥️ Desktop Picture-in-Picture

- PiP follows the current video's display proportions as playback starts or switches scenes, retaining the last known ratio while the next video's dimensions load.
- Improved aspect-ratio resizing for floating PiP windows on Wayland, including Hyprland. Scene changes preserve the window's height where possible, and manual resizing keeps the video ratio locked.
- Removed extra Linux window decoration margins around PiP and updated compatibility with the desktop window plugin.
- Updated desktop startup handling to support floating PiP windows.

## 📋 Browsing and Navigation

- Scene lists restore focus and scroll position to the active scene when returning from playback, including when next/previous navigation replaces the details route. Random returns keep the originating playlist item selected.
- Playlist selections replace the current scene-details destination instead of stacking another page, so Back returns to the scene list or feed after one step, even after several playlist hops.
- Feed playback now synchronizes to the active scene after returning from details, fullscreen, or PiP, while keeping user-paused playback paused. Inactive cached videos pause as you swipe between scenes.
- In the feed, tap a scene title to hide playback overlays; tap the video once to bring them back without changing playback. The choice stays in effect until changed.
- Navigation customization now has dedicated drag handles with larger touch targets and translated tab names. Custom tab order and visibility persist across restarts, settings keep at least one tab visible, and compact navigation remains usable with one tab enabled.

## 🔎 Filters and Details

- Filter panels now use consistent full-width controls and spacing for narrow layouts and larger text.
- Selected entity filters display names instead of only IDs, with an ID fallback when a name is unavailable.
- Scene and image details now show readable file sizes. Text in scene, image, and gallery metadata panels can be selected and copied.

## 🎬 Playback

- Inline players are now no wider than 16:9. Wider videos and scene screenshots fit the player width without cropping, with black bars above and below; portrait and fullscreen sizing are unchanged.
- Player controls now stay visible for two seconds by default; existing custom auto-hide settings are preserved.
- Stream preloading stops stalled requests and limits downloads when servers ignore byte-range requests.

## 🛠️ Diagnostics and Compatibility

- Debug logs now capture previously silent failures, including background cache cleanup. New error entries record failure types and stack traces without copying potentially sensitive error messages.
- Improved Linux build compatibility with Clang 23.
- Updated image caching, routing, platform integration, and UI dependencies.
