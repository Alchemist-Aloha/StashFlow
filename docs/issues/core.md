# Core

This component covers app startup, authentication, GraphQL client setup, cache utilities, logging, and shared infrastructure used by most features.

## Issue: GraphQL failures are rethrown without normalization

**Severity:** High  
**Category:** Architecture  
**Location:** `lib/core/data/graphql/base_repository.dart`, repository implementations such as `graphql_scene_repository.dart` and `graphql_performer_repository.dart`  
**Status:** Open

### Description
Repositories throw `result.exception!` directly instead of mapping GraphQL and transport failures into typed app errors. `BaseRepository.validateResult()` exists, but it still just rethrows the raw exception and is not consistently used.

### Evidence
The scene, performer, studio, and gallery repositories all follow the same pattern: query, check `hasException`, then `throw result.exception!`. There is no shared layer that classifies auth, network, timeout, and schema errors.

### Impact
The UI cannot distinguish offline, unauthorized, and server-contract failures. That makes user-facing recovery harder and increases the chance that a transient backend problem becomes a generic crash or blank error state.

### Suggested Fix
Introduce a small error-mapping layer that converts `OperationException` into app-specific failures with categories. Make repositories return or throw the normalized type consistently and surface the category in the UI.

### Validation
Force a network failure and an auth failure separately, then confirm the app shows different recovery paths instead of one generic error.

## Issue: Startup errors are logged but not surfaced to the user

**Severity:** High  
**Category:** UX  
**Location:** `lib/main.dart`  
**Status:** Open

### Description
`FlutterError.onError` and `PlatformDispatcher.instance.onError` only write to `AppLogStore` and continue. That is useful for diagnostics, but it does not create a user-visible recovery path when startup or asynchronous initialization fails.

### Evidence
`main()` initializes window state, media handlers, local storage, and providers before `runApp()`. If one of those paths fails outside the logged `try/catch` blocks, the user gets no direct feedback beyond a silently broken app state.

### Impact
Users can be left with a screen that does not fully initialize and no explanation. That is especially risky for login, playback, and storage-related startup problems because the app looks alive while critical services are missing.

### Suggested Fix
Add a compact fatal-error fallback or recovery banner that appears when startup initialization fails. Keep the log entry, but also route the user to a retry or diagnostics flow.

### Validation
Inject a controlled failure in startup initialization and confirm the app shows a visible recovery path instead of only logging the error.

## Issue: Cache scans and clears run recursively on the UI isolate

**Severity:** Medium  
**Category:** Performance  
**Location:** `lib/core/data/cache/app_cache_service.dart`  
**Status:** Open

### Description
The cache service walks multiple directories recursively to compute sizes and clear files. Those scans happen serially in regular async code, which still executes on the main isolate.

### Evidence
`getImageCacheSizeMb()`, `getVideoCacheSizeMb()`, and `clear*Cache()` traverse temporary, application cache, and documents directories recursively. The logic is broad enough to touch large libraries or unrelated cache folders.

### Impact
Opening storage settings or clearing caches on a large library can freeze the UI for noticeable periods. The breadth of the directory search also increases the risk of deleting or scanning more than the feature actually owns.

### Suggested Fix
Move the filesystem-heavy parts to a background isolate or job queue and keep the UI-facing paths narrow and explicit. Cache the last known sizes so the settings screen does not rescan on every open.

### Validation
Measure settings-screen responsiveness before and after the change on a large library and confirm cache operations no longer block scrolling or navigation.

