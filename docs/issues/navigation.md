# Navigation

This component covers GoRouter setup, the shell layout, fullscreen handoff, keyboard shortcuts, update prompts, and global tab switching.

## Issue: The router has dead redirect logic and an empty configuration listener

**Severity:** Medium  
**Category:** Maintainability  
**Location:** `lib/features/navigation/presentation/router.dart`  
**Status:** Open

### Description
`redirect` always returns `null`, and the `serverUrlProvider` listener has an empty body. That leaves two navigation hooks in place that do not affect behavior.

### Evidence
The router still documents redirection and configuration handling, but the current implementation only builds routes. The listener is present only to react to config changes and currently performs no action.

### Impact
Future maintainers will assume there is route-guard logic when there is not. That makes it easier to introduce inconsistent behavior around unauthenticated users or server-configuration changes.

### Suggested Fix
Remove the no-op hooks or implement the actual route policy they were intended to support. If the app no longer needs redirect logic, keep the router definition leaner.

### Validation
Open the app with and without a configured server and confirm the route behavior is explicit and test-covered rather than implicit.

## Issue: Fullscreen state relies on path substring matching

**Severity:** Medium  
**Category:** Bug  
**Location:** `lib/features/navigation/presentation/shell_page.dart`  
**Status:** Open

### Description
The shell decides whether the mini player should hide by checking whether the current path contains `/image/` or `/images/`. That is a heuristic, not a route contract.

### Evidence
`ShellPage.build()` computes `isFullscreenPath` from string checks against the current URI path. That same path string is then used to suppress the mini player and influence pop behavior.

### Impact
Any new route that happens to include the same substring can be misclassified as fullscreen. The result is unexpected control hiding or back-navigation behavior that is hard to diagnose.

### Suggested Fix
Use route metadata, a dedicated fullscreen provider, or explicit route names instead of string matching. Keep the shell state derived from a single source of truth.

### Validation
Add a route that contains the same substring but is not fullscreen and verify the mini player and back behavior remain correct.

## Issue: ShellPage owns too many global concerns

**Severity:** Low  
**Category:** Architecture  
**Location:** `lib/features/navigation/presentation/shell_page.dart`  
**Status:** Open

### Description
The shell widget handles update prompts, orientation locking, keyboard shortcuts, branch switching, fullscreen recovery, and the persistent player overlay in one build path.

### Evidence
The same stateful widget listens to startup update checks, player navigation intents, desktop keybinds, orientation changes, and fullscreen state. That makes the file one of the most coupled pieces in the app.

### Impact
Navigation regressions become harder to isolate because unrelated behavior shares the same lifecycle. It also makes focused testing difficult because any widget test has to account for several global behaviors at once.

### Suggested Fix
Move listeners and special-case shell concerns into smaller providers or coordinator widgets. Keep the shell focused on layout and branch selection.

### Validation
Split out one concern at a time and add small tests for each extracted unit without changing the user-visible shell behavior.
