# Windows Window Initialization and Fullscreen Design

## Goal

Initialize the Windows window through `window_manager`'s documented ready-to-show lifecycle and make both image and video fullscreen viewers enter true OS fullscreen when the app was maximized.

## Design

Windows startup will create a `WindowOptions` value with the existing 800×600 size and minimum size, then use `waitUntilReadyToShow`. Its callback will maximize, show, and focus the window. Linux and macOS retain their current initialization behavior.

Both fullscreen viewers already delegate desktop transitions to the shared `DesktopFullscreen` singleton. On Windows, that helper will remember whether the window is maximized, request unmaximize, wait for the native unmaximize event, and only then call `setFullScreen(true)`. Exiting fullscreen will call `setFullScreen(false)` and restore maximized state when necessary. Other desktop platforms will continue calling `setFullScreen` directly.

The wait will have a short timeout so a missing native event cannot block fullscreen indefinitely. If entering fullscreen fails after unmaximizing, the helper will restore the prior maximized state before rethrowing.

## Verification

- A startup source check covers `WindowOptions`, `waitUntilReadyToShow`, maximize, show, and focus.
- A shared-helper source check covers the Windows unmaximize synchronization and maximized restoration.
- Existing image and video viewer checks continue proving that both call `DesktopFullscreen.instance.enter()` and `.exit()`.
- Flutter analysis and the focused tests must pass.

## Scope

No plugin fork, new dependency, fullscreen state abstraction, or unrelated window behavior change.
