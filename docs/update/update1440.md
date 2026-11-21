# StashFlow v1.44.0

## 🖼️ AVIF & JPEG XL Images

- AVIF and JPEG XL images now display in grids, thumbnails, avatars, and the fullscreen image viewer on Android, iOS, macOS, Windows (including ARM64), and Linux. Previously they showed a broken-image icon.
- They load from the existing image cache and decode in the background, so scrolling stays smooth, and grid thumbnails are scaled down like any other image.
- Animated AVIF and JPEG XL files show their first frame.

## 🪟 Windows Playback

- Hardware-accelerated video on Windows now renders through mpv's standard Direct3D 11 interface, with updated bundled libmpv binaries.
- If you point StashFlow at your own or a system libmpv on Windows, it must include the Direct3D 11 render backend (client API 2.6 or newer).

## 🧰 Platform Updates

- Built with Flutter 3.50.1, with updated desktop window handling and refreshed dependencies.
