# StashFlow v1.44.0

## 🖼️ AVIF & JPEG XL Images

- AVIF and JPEG XL images now display in grids, thumbnails, avatars, and the fullscreen image viewer on Android, iOS, macOS, Windows (including ARM64), Linux, and the web. Previously they showed a broken-image icon.
- On native platforms they load from the existing image cache and decode in the background, so scrolling stays smooth, and grid thumbnails are scaled down like any other image. The web version decodes them with the browser.
- Animated AVIF and JPEG XL files show their first frame.

## 🎬 Scene Details

- The video now stays fixed at the top of the page. Everything below it sits in a panel you can drag up over the video by its handle, by swiping on the video, or by continuing a scroll past the top or bottom of the content.
- The scene title stays pinned above the scrolling content, and the action buttons are centered and evenly spaced.
- The byline under the title shows only the studio and year that exist. Release date, rating, O-count, play count, and other facts moved into the Details and Technical sections of the scene information panel.
- **Details** now opens the scene information panel in place, keeping the panel where it was; its close button or Back returns to the scene.
- Added **Settings → Interface → Show scene metadata section** to show a collapsible Metadata section under the title. It is off unless you turn it on.
- The cover/preview toggle in the media section is always shown and starts on the cover; a preview that fails to load just disables its option.
- Scene, gallery, and image details sheets keep their heading and close button pinned, and match the width of the filter and sort sheets.
- The inline player now opens with its controls hidden; tap the video to show them. Controls still appear whenever playback pauses.
- Vertical swipes adjust brightness and volume only in fullscreen. On the inline player they move the scene panel instead.

## 📱 Tablet Layout

- Scene details on portrait tablets now use the single-column phone layout. The side-by-side video and related-content columns only appear once the page is at least 768 points wide, such as in landscape.
- Pull-to-refresh on scene details in the two-column layout now reloads the scene from the server and refreshes its galleries, the same as on phones.

## ▶️ Playback Settings

- Added **Settings → Playback → Default Resolution**, shown when the default stream source is a transcode. StashFlow picks the highest available resolution that does not exceed your choice; Original is the default. It is included in configuration backups.
- Background playback is now on by default on Android, iOS, and the web; a choice you already saved is kept. Desktop apps always keep playing when minimized, so the setting is no longer shown there.
- Picture-in-Picture is now always available where supported, and the separate Native Picture-in-Picture setting is gone.
- Added **Picture-in-picture on leave** on Android. When it is on, leaving StashFlow while a scene is playing continues it in a Picture-in-Picture window, and returning restores the page you were on. It is off by default.

## 🔔 Android Media Controls

- Added **Settings → Playback → System media controls** on Android. Turn it off to hide StashFlow's player from the notification shade and lock screen and to stop it from taking headset buttons. It applies right away, is on by default, and is included in configuration backups.
- System media controls, audio-focus pausing, and Picture-in-picture on leave are shown only while background playback is on. With background playback off, StashFlow pauses when another app takes audio and shows no media notification.
- A paused StashFlow player can now be swiped away from the notification shade.

## 🌐 Web

- Password login now works on the web when StashFlow is served by Stash itself. A [Stash Docker image with StashFlow built in](https://github.com/Alchemist-Aloha/stash/tree/stashflow) serves it at `/stashflow/`; the hosted demo remains API-key only.
- If the browser blocks a video from starting automatically, the player controls now appear so you can press Play.

## 🪟 Windows Playback

- Hardware-accelerated video on Windows now renders through mpv's standard Direct3D 11 interface, with updated bundled libmpv binaries.
- If you point StashFlow at your own or a system libmpv on Windows, it must include the Direct3D 11 render backend (client API 2.6 or newer).

## 🐧 Linux

- Fixed crashes on Linux when a system library, such as a VA-API video driver, reports an internal error during playback.

## ⚡ Performance

- Playing video with hidden controls, and the mini-player, no longer redraw the app on every position update; scene card progress bars now advance once per second, and the player controls rebuild less often.

## 🧰 Platform Updates

- Built with Flutter 3.50.1, with updated desktop window handling and refreshed dependencies.
