# Setup

This component covers server profile creation, login testing, settings layout, credential migration, and profile storage.

## Issue: Server profile editing uses hard-coded English copy and unguarded async state updates

**Severity:** High  
**Category:** UX  
**Location:** `lib/features/setup/presentation/widgets/server_profile_drawer.dart`  
**Status:** Open

### Description
The drawer uses literal English strings for validation and connection-test status, and the async test flow calls `setState()` after awaits without a mounted check. That breaks localization policy and creates a lifecycle hazard.

### Evidence
The URL validator returns `URL is required`, the test flow sets `_testResult` to strings like `Attempting login...` and `Error: Login failed. Check credentials.`, and the final `setState()` calls in `_testConnection()` do not guard against the widget being dismissed mid-request.

### Impact
Non-English users get a partially localized setup flow, and closing the drawer during a test can still leave the state callback racing the widget lifecycle. Both issues damage confidence in the settings path.

### Suggested Fix
Move the user-facing copy into ARB keys and wrap every async `setState()` in `if (!mounted) return;`. If possible, convert the test flow to a provider state so the widget is not directly managing every async step.

### Validation
Switch app locale, trigger a test connection, and close the drawer mid-request to confirm the copy is localized and no late state update occurs.

## Issue: Credential persistence can leave orphaned secrets

**Severity:** Medium  
**Category:** Security  
**Location:** `lib/features/setup/presentation/widgets/server_profile_drawer.dart`, `lib/features/setup/presentation/providers/server_profiles_provider.dart`  
**Status:** Open

### Description
The save flow writes credentials before the profile entry itself is persisted, and legacy migration also writes credentials from a microtask. That creates a window where secrets can exist without a matching profile record.

### Evidence
`_save()` calls `updateProfileCredentials()` before `addProfile()` / `updateProfile()`. `ServerProfiles.build()` schedules `_migrateCredentials(profile)` via `Future.microtask`, so migration and profile reads are not synchronized.

### Impact
Failed saves or partially completed migrations can leave stale secrets behind. That complicates cleanup and makes profile state harder to reason about during startup or failure handling.

### Suggested Fix
Treat profile persistence and credential persistence as one transaction-like operation, or roll back credentials if profile save fails. Make migration explicit and awaitable instead of hiding it in a microtask.

### Validation
Force a save failure and verify no orphaned secrets remain in secure storage, then start from a legacy config and confirm migration is deterministic.

