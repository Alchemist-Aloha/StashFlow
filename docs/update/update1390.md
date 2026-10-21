# StashFlow v1.39.0

## 🖱️ Navigation

- Added mouse Back button support for navigating pages, dismissing dialogs, and leaving fullscreen viewers in native apps. It respects existing Back handling and does nothing at the root page. Browsers continue to use their own history navigation.

## 🔀 Sorting

- Sort panels now fit their visible content and grow or shrink when advanced options expand or collapse. Long lists scroll within the panel, keeping action buttons and the outside dismiss area accessible on smaller screens and at larger interface scales.

## 🪟 Windows

- Improved image and video fullscreen transitions, removing the intermediate unmaximize and resize when entering from a maximized window. Exiting restores the previous window position, size, monitor, and maximized state.
- Failed fullscreen transitions retain a retryable state instead of leaving the interface out of sync with the window.
- Fixed Windows build linker errors introduced by the fullscreen changes and documented the C++ ATL component required when building from source.

## 🐧 Linux

- The main window now hides its title bar and window decorations in Hyprland and niri sessions, allowing the compositor to manage the window.
- Fixed the packaged launcher to find its bundled libraries instead of relying on paths from the build machine, improving AppImage compatibility.

## 📦 Downloads

- Stable release filenames now include the full version and build number. Nightly and release-candidate downloads retain fixed channel names, and obsolete files are removed after a successful update.
- Added SHA-256 checksum files for Linux AppImage, Debian, and pacman packages.
- Newer release runs cancel older runs for the same channel to prevent outdated builds from replacing newer downloads.
