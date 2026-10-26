# StashFlow v1.40.0

## 🎬 Playback Progress

- Added thin playback-progress bars below scene thumbnails in grid, list, masonry, and horizontal-strip views, making saved resume positions visible while browsing.
- Progress updates live while a scene continues playing in the mini-player, PiP, or a cast session, including after seeking. The last observed position remains visible after stopping or switching scenes.
- Progress bars are enabled by default and can be hidden through **Settings → Interface → Show scene playback progress**. This preference is included in configuration backups.

## 🖼️ Browsing

- Added an optional **Images** navigation tab with its own browsing state. Enable or reorder it in navigation settings; it is hidden by default, and existing image links still work.
- Hold **Ctrl** and use the mouse wheel in supported grids to adjust the number of columns. Wheel up makes cards larger; wheel down adds columns. Changes are saved to the corresponding Interface setting.
- Scene lists on performer, studio, tag, and group pages now default to Random when no sort is saved. Preview strips and scene-detail “More From” rows follow the same sorting and random order as their expanded lists.
- Fixed portrait and square thumbnails in horizontal scene strips to stay within consistent 16:9 frames without overlapping titles and metadata.

## 📱 Gallery Details

- The expanded title and metadata section now waits until touch scrolling settles at the top after release, avoiding grid resizing beneath your finger. The expand button remains immediate, and mouse-wheel and keyboard behavior is unchanged.

## 📦 Desktop Downloads

- Added native ARM64 release packaging for Windows and Linux alongside x64 builds. Windows includes ZIP bundles and installers; Linux includes ZIP, Debian, AppImage, and pacman packages.
- macOS release packaging now produces separate Apple Silicon and Intel ZIP downloads.
- Desktop packaging checks bundled executables and playback libraries against the target architecture to catch missing or mismatched binaries before publishing.
