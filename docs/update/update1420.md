# StashFlow v1.42.0

## 🪟 Desktop Picture-in-Picture

- PiP windows now honor your configured playback shortcuts for play/pause, seeking, previous/next scene, and exiting PiP, even while the on-screen controls are hidden. The defaults include Left/Right for 5-second seeks and J/L for 10-second seeks.
- Fixed keyboard focus on Linux when opening PiP or switching between PiP and the main window, so shortcuts work without first clicking a control.
- Fixed pauses from PiP and the mini-player being undone by background playback recovery while the main app is inactive. Explicitly resuming playback restores normal recovery behavior.

## 🐧 Linux Media Controls

- Updated Linux media-service integration and explicitly enabled play, pause, previous, and next controls so desktop media widgets retain their transport buttons with the newer audio-service dependencies.

## 📦 Desktop Builds and Downloads

- Windows ZIP bundles and installers now reuse a single release build, avoiding a second full compilation during packaging. Architecture checks remain in place for both x64 and ARM64 downloads.
- Intel macOS releases now cross-compile on Apple Silicon runners instead of using the slower Intel runners, and macOS builds no longer repeat the configuration-only step. Separate Intel and Apple Silicon downloads are retained.
- Fixed macOS builds failing with a CocoaPods sandbox or missing `Podfile.lock` error caused by missing build settings.
- Simplified downloads to stable releases and nightly builds. Pushes to `main` no longer publish release-candidate builds.

## 🤖 Android Builds

- Updated the Android build toolchain to Gradle 9.9.0, Android Gradle Plugin 9.5.1, and Kotlin 2.4.21, and added checksum verification for the Gradle download. Building from source continues to require Java 21.
