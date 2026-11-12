# StashFlow v1.42.0

## 🧰 Library Tools

- Added **Tools → Library scan** and **Generate content** with the official web app’s library task options and Material 3 layouts. Run tasks for the entire library or selected server folders using remote browsing or manually entered paths.
- Task options load from the active server, and changes save automatically back to it for use in the web app. Content generation uses the server’s current preview settings.
- View the server job queue, progress, estimated remaining time, subtasks, and errors, with controls to stop individual jobs or all server jobs. Submission confirms the queued job ID rather than reporting the task as complete.

## 🖼️ ImageClips and GIFs

- ImageClips now open as looping videos from image and gallery grids, with play badges on thumbnails and dedicated play/pause and seek controls.
- Video fills the viewer beneath its overlays. Floating playback controls move above image navigation when it is visible and to the bottom safe area when hidden, adapting to rotation and interface scaling without resizing the video.
- Seeking holds the selected position while the seek completes without triggering image navigation. Only the selected clip plays; paging away or closing the viewer releases it, and returning from the background resumes only previously playing clips.
- GIFs remain animated images without video badges or controls, even when the server identifies them as video files. Clips save as videos; GIFs use image saving.

## 🔗 Linked Scenes and Galleries

- Scene details now show a **Galleries** row listing the galleries linked to that scene, and gallery details show a **Scenes** row in the header. Tap a card to open it; pull to refresh reloads the row.
- Scene cards now match gallery cards: the rating appears as a yellow star at the top right, the O-count at the bottom left, and the length at the bottom right, each on a rounded badge. Empty ratings and O-counts are hidden.
- Horizontal scene and gallery rows size themselves to their cards at every interface and text scale, fixing clipped gallery cards and the blank space under scene cards.

## 🔍 Image Viewer Gestures

- Swiping between images now works at any angle when the image isn't zoomed, instead of ignoring diagonal swipes.
- Pinch to zoom responds immediately, including when one finger moves first or the page is still settling after a swipe. Double-tap toggles between fit and 3× zoom, and desktop mouse-wheel zoom no longer scrolls to another image.
- Zoomed images pan only within the picture, not the letterbox around it, and dragging past an edge continues into the next or previous image.
- Original images now load through the shared authenticated image cache, with a retry button when loading fails.

## 🔊 Android Audio Focus

- Added **Settings → Playback → Pause when other apps play media**, enabled by default for Android scene and feed playback. Turn it off if you prefer simultaneous playback with other apps; Android may still enforce interruptions.
- Seeking, looping, feed handoffs, and background recovery respect audio interruptions instead of forcing playback to resume. Manually paused videos stay paused when audio focus returns.

## 🗂️ Image and Preview Caching

- Thumbnails and seek previews on Android and desktop now share an authenticated image cache, including session-cookie logins. Cache clearing and size-limit handling have been updated to cover the shared cache.
- The shared image cache now keeps up to 1,000 images, so recently viewed images and nearby pages reload less often.
- Lists and scene details now refresh with current server data instead of showing stale cached results.
- Lists that fit on screen without scrolling now load their next page automatically.
- Clearing caches on Linux and Windows now removes only StashFlow's own cache folders from the shared temporary directory, and on desktop it no longer deletes unrelated `.hive` files from your Documents folder.

## 🔒 App Lock and Privacy

- Added fingerprint and face unlock for Android devices with enrolled biometrics. Enable it in **Settings → Security** after setting a passcode; the passcode remains available as a fallback.
- Lock on launch now covers the very first frame, and the background timeout still locks the app when the system froze it in the background.
- Credentials in server URLs are masked in the copyable debug log.

## ⚙️ Settings

- First launch now asks for your app language before server setup.
- The Settings hub uses a single column of full-width cards, matching the Tools page.

## 🪟 Desktop Picture-in-Picture

- PiP windows now honor your configured playback shortcuts for play/pause, seeking, previous/next scene, and exiting PiP, even while the on-screen controls are hidden. The defaults include Left/Right for 5-second seeks and J/L for 10-second seeks.
- Fixed keyboard focus on Linux when opening PiP or switching between PiP and the main window, so shortcuts work without first clicking a control.
- Fixed pauses from PiP and the mini-player being undone by background playback recovery while the main app is inactive. Explicitly resuming playback restores normal recovery behavior.
- Fullscreen and window-sizing changes now stay attached to the main app window when PiP has focus. Linux and macOS wait for fullscreen transitions to finish before starting another.

## 🐧 Linux Media Controls

- Updated Linux media-service integration and explicitly enabled play, pause, previous, and next controls so desktop media widgets retain their transport buttons with the newer audio-service dependencies.

## 📦 Desktop Builds and Downloads

- Windows ZIP bundles and installers now reuse a single release build, avoiding a second full compilation during packaging. Architecture checks remain in place for both x64 and ARM64 downloads.
- Intel macOS releases now cross-compile on Apple Silicon runners, and macOS builds no longer repeat the configuration-only step. Separate Intel and Apple Silicon downloads are retained.
- Fixed macOS builds failing with a CocoaPods sandbox or missing `Podfile.lock` error caused by missing build settings.
- Simplified downloads to stable releases and nightly builds. Pushes to `main` no longer publish release-candidate builds.

## 🛠️ Build Compatibility

- Release builds now use Flutter 3.47.9, and the minimum Dart SDK requirement is 3.13.
- Updated the Android build toolchain to Gradle 9.9.0, Android Gradle Plugin 9.5.1, and Kotlin 2.4.21, and added checksum verification for the Gradle download. Building from source continues to require Java 21.
- Linux source builds now also need X11/XInput development headers (`libx11-dev` and `libxi-dev` on Debian/Ubuntu).
