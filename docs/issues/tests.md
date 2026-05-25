# Tests

This component covers the repository-wide test suite and the coverage gaps that matter most for this app's behavior.

## Issue: High-risk failure paths still lack direct tests

**Severity:** Medium  
**Category:** Testing  
**Location:** `test/`  
**Status:** Open

### Description
The suite is broad, but the most fragile flows are still underrepresented: GraphQL failure mapping, permission-denied save flows, lifecycle cleanup, and fullscreen navigation edge cases.

### Evidence
There are many widget and repository tests, including player and fullscreen coverage, but the scan did not turn up direct tests for timer disposal, async drawer dismissal during connection tests, or origin/rate-limit backend security behavior.

### Impact
Happy-path coverage can keep the app green while the error recovery and cleanup paths regress. Those regressions are the ones users notice first in a media app because they happen during navigation, playback, or saving.

### Suggested Fix
Add a few small tests aimed specifically at the failure modes identified in the component files: expired auth, save-permission denial, pagination error surfacing, and disposal of player-local resources.

### Validation
Run the new tests locally, confirm they fail before the fix, and verify they pass after the behavior is corrected.

## Issue: Cross-feature integration coverage is still thin

**Severity:** Medium  
**Category:** Testing  
**Location:** `test/integration_navigation_test.dart`, `test/features/scenes/*`, `test/features/setup/*`  
**Status:** Open

### Description
The project has many focused tests, but there is limited evidence of end-to-end coverage for the server-profile flow, navigation shell, and persistent player working together.

### Evidence
The test tree includes separate scene, setup, navigation, and player tests, but the highest-risk coupling happens at runtime when those systems interact inside `ShellPage` and the setup drawer.

### Impact
Integration regressions can slip through even when individual widgets and repositories still pass. That is especially relevant here because the app’s global state, router, and player share responsibility for the same user flow.

### Suggested Fix
Add one end-to-end test that covers server setup, scene entry, fullscreen entry, and back-navigation recovery. Keep it small, but let it exercise the whole stack once.

### Validation
Run the integration test on at least one real target platform and confirm the full setup-to-playback flow stays stable.
