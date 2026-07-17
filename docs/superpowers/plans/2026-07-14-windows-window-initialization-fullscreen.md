# Windows Window Initialization and Fullscreen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Correction (2026-07-16):** The original app-managed unmaximize/restore workaround was superseded after Windows testing showed that it prevented `window_manager` from recording the maximized pre-fullscreen state. The corrected Task 2 below delegates the entire runtime transition to `window_manager`.

**Goal:** Initialize the Windows window through `window_manager`'s ready-to-show lifecycle and make image and video viewers enter true OS fullscreen from a maximized window.

**Architecture:** Keep startup configuration in `main.dart` and route runtime desktop fullscreen requests through the existing shared `DesktopFullscreen` singleton. The singleton delegates directly to `window_manager`, whose Windows implementation records and restores the native maximized state, frame, and style.

**Tech Stack:** Flutter, Dart, `window_manager` 0.5.2, Flutter test

## Global Constraints

- Preserve the existing 800×600 initial and minimum window sizes.
- Do not unmaximize or maximize around fullscreen; preserve `window_manager` ownership of the native transition.
- Both image and video fullscreen viewers must continue using `DesktopFullscreen`.
- Add no dependency, plugin fork, abstraction, or unrelated window behavior.

---

### Task 1: Windows ready-to-show startup

**Files:**
- Modify: `test/main_test.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `windowManager.ensureInitialized()`, `WindowOptions`, and `windowManager.waitUntilReadyToShow(...)` from `window_manager`.
- Produces: Windows startup that maximizes, shows, and focuses only after window options are applied.

- [ ] **Step 1: Write the failing startup test**

Replace the existing desktop startup source test with:

```dart
test('Windows startup waits until the configured window is ready', () {
  final source = File('lib/main.dart').readAsStringSync();

  expect(source, contains('const windowOptions = WindowOptions('));
  expect(source, contains('minimumSize: Size(800, 600)'));
  expect(source, contains('windowManager.waitUntilReadyToShow('));
  expect(source, contains('await windowManager.maximize()'));
  expect(source, contains('await windowManager.show()'));
  expect(source, contains('await windowManager.focus()'));
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `rtk flutter test test/main_test.dart --plain-name "Windows startup waits until the configured window is ready"`

Expected: FAIL because `lib/main.dart` does not contain `WindowOptions` or `waitUntilReadyToShow`.

- [ ] **Step 3: Implement the documented Windows lifecycle**

In the desktop initialization block in `main()`, keep `ensureInitialized()` for all desktop platforms, use the ready-to-show lifecycle on Windows, and retain the current direct setup elsewhere:

```dart
await windowManager.ensureInitialized();
try {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    const windowOptions = WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(800, 600),
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.setSize(const Size(800, 600));
    await windowManager.maximize();
  }
} catch (e) {
  debugPrint('Failed to set initial window size: $e');
}
```

- [ ] **Step 4: Run the focused test and verify GREEN**

Run: `rtk flutter test test/main_test.dart --plain-name "Windows startup waits until the configured window is ready"`

Expected: PASS.

- [ ] **Step 5: Commit Task 1**

```bash
rtk git add test/main_test.dart lib/main.dart
rtk git commit -m "fix: initialize Windows window when ready"
```

### Task 2: Delegate fullscreen state restoration to `window_manager`

**Files:**
- Modify: `test/core/utils/desktop_fullscreen_test.dart`
- Modify: `test/features/scenes/fullscreen_mode_test.dart`
- Modify: `lib/core/utils/desktop_fullscreen.dart`
- Modify: `windows/runner/flutter_window.cpp`
- Modify: `windows/runner/flutter_window.h`
- Verify: `test/features/images/presentation/pages/image_fullscreen_page_test.dart`

**Interfaces:**
- Consumes: `DesktopFullscreen.instance.enter()` and `.exit()` calls already made by both fullscreen viewers.
- Produces: direct `windowManager.setFullScreen(true)` and `windowManager.setFullScreen(false)` calls, allowing the plugin to preserve Windows native state.

- [ ] **Step 1: Write the failing plugin-delegation test**

Add a method-channel test that starts from a simulated maximized Windows state, calls `enter()` and `exit()`, and requires the complete `window_manager` call sequence to be only:

```dart
['setFullScreen', 'setFullScreen']
// isFullScreen arguments: [true, false]
```

Also require that the app-specific Windows method channel receives no calls.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `rtk flutter test test/core/utils/desktop_fullscreen_test.dart`

Expected: FAIL because the old helper also calls `isMaximized`, `unmaximize`, `maximize`, and the custom runner channel.

- [ ] **Step 3: Restore direct plugin ownership**

Replace `lib/core/utils/desktop_fullscreen.dart` with:

```dart
import 'package:window_manager/window_manager.dart';

class DesktopFullscreen {
  DesktopFullscreen._();

  static final instance = DesktopFullscreen._();

  Future<void> enter() => windowManager.setFullScreen(true);

  Future<void> exit() => windowManager.setFullScreen(false);
}
```

Remove the `stash_app_flutter/window` transition channel and its DWM transition toggling from the Windows runner. `window_manager` remains the sole native fullscreen owner.

- [ ] **Step 4: Run image and video fullscreen tests and verify GREEN**

Run: `rtk flutter test test/core/utils/desktop_fullscreen_test.dart test/features/scenes/fullscreen_mode_test.dart test/features/images/presentation/pages/image_fullscreen_page_test.dart`

Expected: PASS.

- [ ] **Step 5: Run static analysis**

Run: `rtk flutter analyze`

Expected: No issues found.

- [ ] **Step 6: Commit Task 2**

```bash
rtk git add lib/core/utils/desktop_fullscreen.dart windows/runner/flutter_window.cpp windows/runner/flutter_window.h test/core/utils/desktop_fullscreen_test.dart test/features/scenes/fullscreen_mode_test.dart
rtk git commit -m "fix: delegate Windows fullscreen restoration"
```

### Task 3: Final regression verification

**Files:**
- Verify only: `lib/main.dart`
- Verify only: `lib/core/utils/desktop_fullscreen.dart`
- Verify only: `windows/runner/flutter_window.cpp`
- Verify only: `windows/runner/flutter_window.h`
- Verify only: `test/main_test.dart`
- Verify only: `test/core/utils/desktop_fullscreen_test.dart`
- Verify only: `test/features/scenes/fullscreen_mode_test.dart`
- Verify only: `test/features/images/presentation/pages/image_fullscreen_page_test.dart`

**Interfaces:**
- Consumes: the completed startup and shared fullscreen behavior.
- Produces: evidence that the focused regression suite and formatting pass together.

- [ ] **Step 1: Format changed Dart files**

Run: `rtk dart format lib/main.dart lib/core/utils/desktop_fullscreen.dart test/main_test.dart test/core/utils/desktop_fullscreen_test.dart test/features/scenes/fullscreen_mode_test.dart`

Expected: all Dart files formatted successfully.

- [ ] **Step 2: Run focused regression suite**

Run: `rtk flutter test test/main_test.dart test/core/utils/desktop_fullscreen_test.dart test/features/scenes/fullscreen_mode_test.dart test/features/images/presentation/pages/image_fullscreen_page_test.dart`

Expected: PASS.

- [ ] **Step 3: Check the final diff**

Run: `rtk git diff --check`

Expected: no output and exit code 0.
