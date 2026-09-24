# StashFlow v1.34.0

## 🪟 Desktop Picture-in-Picture

- Picture-in-Picture now works on Windows, macOS, and Linux. Press `P` or click the PiP button to pop the video into a separate small window while the main app window stays exactly as it was.
- The PiP window is frameless, floats above other windows where the platform allows, and stays out of the taskbar and dock. Hover for previous, play/pause, next, seek, and exit controls, drag the video to move the window, and double-click it or press `Esc` to exit. Closing the window returns the player to the main window without interrupting playback.
- The window is locked to the video's aspect ratio and resizes freely down to a small minimum, so portrait and ultra-wide videos no longer get stuck at a large fixed size. On Windows the main window keeps its own minimum size.
- The PiP window shares playback state with the app, so entering or leaving PiP never restarts the video.
- Android keeps its existing system PiP behaviour, and the Playback setting that enables Picture-in-Picture now applies to desktop as well.

## 📺 Casting Reliability

- Remote completion now follows the configured playback-end behavior, so **Stop**, **Loop**, and **Next** work the same while casting as they do locally and the queue keeps advancing.
- Changed scenes now switch the active cast session instead of only the local player: queue buttons, keyboard shortcuts, media controls, playlists, and contextual scene strips all send the selected scene to the renderer.
- Resuming a cast whose transport had stopped (or that ignored **Play**) now re-points the current media at the last known position instead of sending another play command, so playback resumes where it left off.
- Seeking while paused stays paused, even when the renderer resumes on its own.
- Progress keeps advancing in the app while casting, and DLNA sessions that stop reporting are polled directly so position and play state stay in sync.

## 🎬 Playback Navigation

- Autoplay-next no longer opens the scene details page when playback is minimized to the mini player; the next scene plays in the mini player in place.
- The scene details page (and fullscreen) still advances to the next scene's details page as before.

## 🖼️ Scene Details Previews

- Scenes whose preview file is missing no longer offer a preview option: StashFlow probes the preview and falls back to the cover.
- If a preview fails during playback after passing the check, it shows "Preview video unavailable" and returns to the cover instead of a broken player.

## 🌍 Localization

- Localized the resolution filter labels (4K, FHD, HD, SD) instead of raw constant names.
- Clarified sort and filter labels across all supported languages, including "File Modification Time", "File Size", "Total Scene Duration", "O-Count", and "Last O Activity".
- Corrected terminology such as "pHash", "Non-binary", and "Scene Number in Group/Movie".
- Localized the new Picture-in-Picture controls and the updated playback setting description.

## 🔧 Maintenance

- Pinned `objective_c` and `hive_ce` to compatible versions to keep builds reproducible.
- Updated project wiki and agent documentation.
