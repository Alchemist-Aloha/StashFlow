# Windows Maximized Fullscreen Exit Design

## Goal

Make Windows video and image fullscreen reliably leave app-owned borderless fullscreen when the application entered fullscreen from a maximized window. A successful exit must return to a normal Windows-managed maximized window with its title bar, frame, work-area bounds, and taskbar behavior restored.

## Confirmed Failure

The Windows fullscreen controller saves `WINDOWPLACEMENT`, `GWL_STYLE`, and `GWL_EXSTYLE`, removes the overlapped-window frame, and expands the window to `MONITORINFO.rcMonitor`. When the source window is maximized, the fullscreen style still carries the native maximized state because removing `WS_OVERLAPPEDWINDOW` does not clear `WS_MAXIMIZE`.

The current exit path restores the saved styles and reapplies a saved `SW_SHOWMAXIMIZED` placement while Windows still considers the window maximized. This does not force a show-state transition, so the physical-monitor rectangle established for borderless fullscreen can remain in effect. `SetWindowPos(..., SWP_FRAMECHANGED)` then refreshes that stale maximized geometry instead of establishing a fresh system-managed maximized window.

The Dart video lifecycle compounds the failure by launching native exit without awaiting it and immediately marking fullscreen exited. A native platform error is therefore detached from the fullscreen state machine while the Flutter overlay disappears.

## Native Restore Contract

`WindowsFullscreenController` remains the sole owner of Windows fullscreen geometry and styles. Entry additionally captures whether `IsZoomed(window)` was true before any fullscreen mutation.

Exit restores the saved regular and extended styles first. It then follows one of two paths:

1. If the source window was normal, restore the saved `WINDOWPLACEMENT` directly.
2. If the source window was maximized, call `ShowWindow(window, SW_RESTORE)` to leave the still-active maximized state, restore the saved `WINDOWPLACEMENT`, and call `ShowWindow(window, SW_MAXIMIZE)` to establish a new Windows-managed maximized state.

After either path, call `SetWindowPos` with `SWP_FRAMECHANGED`, `SWP_NOMOVE`, `SWP_NOSIZE`, `SWP_NOZORDER`, and `SWP_NOOWNERZORDER` so Windows recalculates the non-client area without changing the newly restored geometry or z-order.

The maximized transition is synchronous and uses the saved normal rectangle through `WINDOWPLACEMENT`; it does not guess work-area coordinates, add delays, or delegate part of the transition to `window_manager`.

## Verification and Recovery

Native exit must read back `GWL_STYLE` and `GWL_EXSTYLE` after restoration. The values must match the captured styles. The final zoom state must match the captured state: `IsZoomed(window)` must be true for a previously maximized window and false for a previously normal window.

If a Win32 operation or read-back check fails, exit returns a `fullscreen_error`, retains the saved state, and enters the existing restore-pending state so a later exit can retry. Saved state is cleared only after every mutation and verification succeeds.

The controller must attempt all safe restore operations after a failure so a partial restoration has the best chance of returning chrome and useful geometry. Error reporting retains the first failure to identify the original fault.

## Flutter Lifecycle

The video overlay exit operation becomes an awaited `Future<void>`. It marks the provider fullscreen lifecycle exited only after `DesktopFullscreen.exit()` completes. Native failures are recorded in `AppLogStore` and the provider returns to fullscreen state so the overlay remains available for another exit attempt.

The image viewer continues to trigger native restoration from `dispose`, which cannot be asynchronous. Its detached future must handle and log errors so a failed restoration is observable rather than becoming an unhandled asynchronous error.

## Testing

Automated tests must cover:

- The pure Windows restore decision for normal and maximized source windows.
- Maximized restoration requiring a normalize-then-maximize transition.
- Native source preserving read-back verification and restore-pending behavior.
- Video fullscreen lifecycle awaiting native exit before marking exit complete.
- Video native-exit failures being logged and returned to a retryable fullscreen UI state.
- Image viewer detached exit failures being handled.
- Existing Windows channel routing and all non-Windows fullscreen behavior remaining unchanged.

Manual Windows acceptance must verify video and image fullscreen from both normal and maximized windows, repeated toggles, secondary-monitor placement, Alt+Tab, restored title-bar buttons, and taskbar behavior.

## Scope

This change adds no dependency, timer, exclusive display mode, topmost policy, or non-Windows window-management change. It does not replace the dedicated Windows method channel or mix `window_manager` calls into the native Windows transition.
