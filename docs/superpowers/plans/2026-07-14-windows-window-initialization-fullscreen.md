# Windows Window Initialization and Fullscreen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize the Windows window through `window_manager`'s ready-to-show lifecycle and make image and video viewers enter true OS fullscreen from a maximized window.

**Architecture:** Keep startup configuration in `main.dart` and all runtime desktop fullscreen state transitions in the existing shared `DesktopFullscreen` singleton. Both viewers already use that singleton, so one Windows-specific maximized-state workaround fixes both paths while other platforms remain direct pass-throughs.

**Tech Stack:** Flutter, Dart, `window_manager` 0.5.2, Flutter test

## Global Constraints

- Preserve the existing 800×600 initial and minimum window sizes.
- Apply the maximized-state workaround only on Windows.
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

### Task 2: Shared fullscreen transition from maximized Windows state

**Files:**
- Modify: `test/features/scenes/fullscreen_mode_test.dart`
- Modify: `lib/core/utils/desktop_fullscreen.dart`
- Verify: `test/features/images/presentation/pages/image_fullscreen_page_test.dart`

**Interfaces:**
- Consumes: `DesktopFullscreen.instance.enter()` and `.exit()` calls already made by both fullscreen viewers.
- Produces: `Future<void> DesktopFullscreen.enter()` and `Future<void> DesktopFullscreen.exit()` with Windows maximized-state preservation.

- [ ] **Step 1: Write the failing shared-helper test**

Replace the existing `leaves desktop window restoration to window_manager` test with:

```dart
test('synchronizes maximized Windows before shared desktop fullscreen', () {
  final overlaySource = File(
    'lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart',
  ).readAsStringSync();
  final imageSource = File(
    'lib/features/images/presentation/pages/image_fullscreen_page.dart',
  ).readAsStringSync();
  final desktopSource = File(
    'lib/core/utils/desktop_fullscreen.dart',
  ).readAsStringSync();

  expect(overlaySource, contains('await DesktopFullscreen.instance.enter()'));
  expect(overlaySource, contains('await DesktopFullscreen.instance.exit()'));
  expect(imageSource, contains('await DesktopFullscreen.instance.enter()'));
  expect(imageSource, contains('DesktopFullscreen.instance.exit()'));
  expect(desktopSource, contains('defaultTargetPlatform == TargetPlatform.windows'));
  expect(desktopSource, contains('await windowManager.isMaximized()'));
  expect(desktopSource, contains('await windowManager.unmaximize()'));
  expect(desktopSource, contains('void onWindowUnmaximize()'));
  expect(desktopSource, contains('await windowManager.maximize()'));
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `rtk flutter test test/features/scenes/fullscreen_mode_test.dart --plain-name "synchronizes maximized Windows before shared desktop fullscreen"`

Expected: FAIL because `DesktopFullscreen` does not detect, unmaximize, synchronize, or restore the Windows window.

- [ ] **Step 3: Restore the minimal synchronized shared helper**

Replace `lib/core/utils/desktop_fullscreen.dart` with:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class DesktopFullscreen with WindowListener {
  DesktopFullscreen._() {
    windowManager.addListener(this);
  }

  static final instance = DesktopFullscreen._();

  bool _restoreMaximized = false;
  Completer<void>? _unmaximized;

  Future<void> enter() async {
    try {
      _restoreMaximized =
          defaultTargetPlatform == TargetPlatform.windows &&
          await windowManager.isMaximized();
      if (_restoreMaximized) {
        _unmaximized = Completer<void>();
        await windowManager.unmaximize();
        await _unmaximized!.future.timeout(
          const Duration(milliseconds: 300),
          onTimeout: () {},
        );
        _unmaximized = null;
      }

      await windowManager.setFullScreen(true);
    } catch (_) {
      _unmaximized = null;
      await _restoreWindow();
      rethrow;
    }
  }

  Future<void> exit() async {
    await windowManager.setFullScreen(false);
    await _restoreWindow();
  }

  @override
  void onWindowUnmaximize() {
    final unmaximized = _unmaximized;
    if (unmaximized != null && !unmaximized.isCompleted) {
      unmaximized.complete();
    }
  }

  Future<void> _restoreWindow() async {
    if (!_restoreMaximized) return;
    _restoreMaximized = false;
    await windowManager.maximize();
  }
}
```

- [ ] **Step 4: Run image and video fullscreen tests and verify GREEN**

Run: `rtk flutter test test/features/scenes/fullscreen_mode_test.dart test/features/images/presentation/pages/image_fullscreen_page_test.dart`

Expected: PASS.

- [ ] **Step 5: Run static analysis**

Run: `rtk flutter analyze lib/main.dart lib/core/utils/desktop_fullscreen.dart`

Expected: No issues found.

- [ ] **Step 6: Commit Task 2**

```bash
rtk git add test/features/scenes/fullscreen_mode_test.dart lib/core/utils/desktop_fullscreen.dart
rtk git commit -m "fix: enter fullscreen from maximized Windows"
```

### Task 3: Final regression verification

**Files:**
- Verify only: `lib/main.dart`
- Verify only: `lib/core/utils/desktop_fullscreen.dart`
- Verify only: `test/main_test.dart`
- Verify only: `test/features/scenes/fullscreen_mode_test.dart`
- Verify only: `test/features/images/presentation/pages/image_fullscreen_page_test.dart`

**Interfaces:**
- Consumes: the completed startup and shared fullscreen behavior.
- Produces: evidence that the focused regression suite and formatting pass together.

- [ ] **Step 1: Format changed Dart files**

Run: `rtk dart format lib/main.dart lib/core/utils/desktop_fullscreen.dart test/main_test.dart test/features/scenes/fullscreen_mode_test.dart`

Expected: all four files formatted successfully.

- [ ] **Step 2: Run focused regression suite**

Run: `rtk flutter test test/main_test.dart test/features/scenes/fullscreen_mode_test.dart test/features/images/presentation/pages/image_fullscreen_page_test.dart`

Expected: PASS.

- [ ] **Step 3: Check the final diff**

Run: `rtk git diff --check`

Expected: no output and exit code 0.
