# Windows Window Initialization and Fullscreen Design

## Goal

Initialize the Windows window through `window_manager`'s documented ready-to-show lifecycle and make both image and video fullscreen viewers enter true OS fullscreen when the app was maximized.

## Design

Windows startup will create a `WindowOptions` value with the existing 800×600 size and minimum size, then use `waitUntilReadyToShow`. Its callback will maximize, show, and focus the window. Linux and macOS retain their current initialization behavior.

Both fullscreen viewers delegate desktop transitions to the shared `DesktopFullscreen` singleton. The helper calls `windowManager.setFullScreen(true)` and `windowManager.setFullScreen(false)` directly on every desktop platform. On Windows, `window_manager` owns the native transition: it records the current maximized state, frame, and window style when fullscreen begins and restores them when fullscreen ends. The app must not unmaximize first or separately maximize afterward, because doing so changes the state that the plugin records and restores.

## Verification

- A startup source check covers `WindowOptions`, `waitUntilReadyToShow`, maximize, show, and focus.
- A shared-helper test verifies that fullscreen enter and exit delegate only to `window_manager.setFullScreen` without separate maximize, unmaximize, or custom runner calls.
- Existing image and video viewer checks continue proving that both call `DesktopFullscreen.instance.enter()` and `.exit()`.
- Flutter analysis and the focused tests must pass.

## Scope

No plugin fork, custom Windows method channel, new dependency, fullscreen state abstraction, or unrelated window behavior change.
