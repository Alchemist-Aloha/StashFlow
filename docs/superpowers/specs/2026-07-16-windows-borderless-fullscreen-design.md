# Windows Borderless Fullscreen Design

## Goal

Make image and video fullscreen on Windows cover the entire current monitor with no title bar, caption buttons, resizing frame, or system border, including when fullscreen starts from a maximized window. Exiting fullscreen must restore the exact pre-fullscreen normal or maximized state.

## Root Cause

`DesktopFullscreen` currently delegates Windows transitions to `window_manager` 0.5.2. That plugin records whether the window was maximized, but its Windows implementation only switches the window to its frameless mode when the pre-fullscreen window was not maximized. When fullscreen starts maximized, the caption style remains active, so resizing the window to monitor bounds does not produce a true borderless fullscreen window.

The previous Dart-side maximize, unmaximize, and retry approaches also split ownership of the transition across asynchronous calls. That changes or races the native state which must be captured atomically before fullscreen entry.

## Architecture

`DesktopFullscreen` remains the single Dart API used by the image and video viewers. On Windows it invokes a dedicated `stash_app_flutter/window_fullscreen` method channel with `enter` and `exit` methods. On Linux and macOS it continues delegating to `windowManager.setFullScreen`.

The Windows runner owns one `WindowsFullscreenController` for the top-level `HWND`. The controller is implemented in focused `windows_fullscreen_controller.h` and `.cpp` files rather than mixing Win32 state management into `FlutterWindow`. `FlutterWindow` only registers the channel and converts controller failures into Flutter platform errors.

All Win32 calls run synchronously on Flutter's Windows platform thread. The controller is the sole owner of the Windows fullscreen transition; Dart must not separately maximize, unmaximize, resize, hide the title bar, or retry with delays.

## Entering Fullscreen

If already fullscreen, `Enter()` succeeds without changing state. Otherwise it:

1. Captures a complete `WINDOWPLACEMENT` with `GetWindowPlacement`.
2. Captures the current `GWL_STYLE` and `GWL_EXSTYLE` values.
3. Resolves the nearest display using `MonitorFromWindow(..., MONITOR_DEFAULTTONEAREST)` and obtains its full `rcMonitor` bounds with `GetMonitorInfo`.
4. Removes `WS_OVERLAPPEDWINDOW` from the regular style. This clears `WS_CAPTION`, `WS_THICKFRAME`, `WS_SYSMENU`, `WS_MINIMIZEBOX`, and `WS_MAXIMIZEBOX`, guaranteeing that the Windows title bar and frame disappear.
5. Removes extended edge styles which can draw residual non-client borders: `WS_EX_DLGMODALFRAME`, `WS_EX_WINDOWEDGE`, `WS_EX_CLIENTEDGE`, and `WS_EX_STATICEDGE`.
6. Applies the styles with `SetWindowLongPtr`, then uses `SetWindowPos` with `SWP_FRAMECHANGED` to cover the monitor's physical-pixel bounds.

The window is raised with `HWND_TOP`, not `HWND_TOPMOST`. Fullscreen therefore covers the taskbar during active playback without making StashFlow permanently topmost, changing display resolution, or using exclusive display mode.

If any mutation fails, the controller immediately makes a best-effort rollback to the captured styles and placement and returns an error. It does not report itself as fullscreen unless entry completes.

## Exiting Fullscreen

If not fullscreen, `Exit()` succeeds without changing state. Otherwise it:

1. Restores the exact saved `GWL_STYLE` and `GWL_EXSTYLE` values.
2. Restores the saved `WINDOWPLACEMENT`, including `SW_SHOWMAXIMIZED` when fullscreen began from a maximized window and the exact restored rectangle when it began from a normal window.
3. Calls `SetWindowPos` with `SWP_FRAMECHANGED`, `SWP_NOMOVE`, `SWP_NOSIZE`, and `SWP_NOZORDER` so Windows recalculates the non-client area and redraws the original title bar and frame.

Exit attempts every restoration operation even if one fails. The controller retains the captured state after an incomplete restoration so a subsequent exit request can retry safely. Captured state is cleared only after complete restoration.

## Errors and Lifecycle

Native failures return a `fullscreen_error` platform error containing the failed Win32 operation and `GetLastError()` value. Dart propagates the error to the existing viewer lifecycle, which already logs transition failures. There is no automatic fallback to `window_manager` on Windows because mixing two fullscreen owners could overwrite or lose the saved placement.

The channel handler is removed before the Flutter controller and native fullscreen controller are destroyed. Repeated `enter` and `exit` calls are idempotent.

## Verification

Automated Dart tests must prove:

- Windows `enter` and `exit` invoke only the app-owned channel.
- Linux and macOS retain `window_manager.setFullScreen(true/false)`.
- Native platform errors are propagated rather than followed by plugin fallback calls.
- Both the image viewer and video overlay continue using `DesktopFullscreen`.

Windows-native source/build checks must prove:

- `WS_OVERLAPPEDWINDOW` is removed before monitor-sized placement, which necessarily removes `WS_CAPTION` and the title bar.
- Both normal and extended styles plus `WINDOWPLACEMENT` are saved and restored.
- Full monitor bounds use `rcMonitor`, not `rcWork`.
- `HWND_TOPMOST` is not used.
- The new controller sources are part of the Windows runner target.

Manual Windows acceptance must cover:

1. Start maximized, enter video fullscreen: no title bar or frame is visible and content covers the taskbar; exit returns maximized.
2. Start in a normal window, enter and exit: the original size and position return exactly.
3. Repeat both cases for image fullscreen.
4. Enter fullscreen on a secondary monitor: that monitor is covered and exit restores the window on the same monitor.
5. Toggle fullscreen repeatedly and use Alt+Tab while fullscreen: transitions remain stable and the window is not permanently topmost.

## Scope

This change adds no dependency, display-mode switch, exclusive fullscreen mode, global window-style policy, or non-Windows behavior change. It does not fork `window_manager`; that dependency remains responsible for non-Windows fullscreen and other window-management features.
