# Agent Start Guide

## 1) Understand the current baseline

1. Read known issues first: `docs/KNOWNISSUES.md`.
2. Scan architecture map: `docs/ARCHITECTURE_MAP.md`.
3. Check project health quickly:
   - `flutter analyze`
   - `flutter test`

## 2) Configuration expectations

- Runtime server settings are stored in SharedPreferences:
  - `server_base_url`
  - `server_api_key`
  - `prefer_scene_streams`
  - `scene_grid_layout`
- URL normalization is required when user inputs host/path without scheme.
- Media requests may require `ApiKey` header even if GraphQL works.

## 3) Safe change flow

1. Reproduce problem.
2. Identify owner layer (UI, provider, repository, GraphQL, platform).
3. Make minimal code edits.
4. Verify with analyze/tests and, if relevant, `flutter build apk`.
5. Update docs if behavior or debugging guidance changed.

## 4) Common high-value checks

- Android networking in release depends on INTERNET permission in main manifest.
- Stream startup issue may be server warm-up related, not MIME mismatch.
- Relative media paths should be resolved against GraphQL endpoint.

## 5) Definition of done for bugfixes

- Repro case before and after is documented.
- No analyzer errors.
- No test regressions in touched area.
- Any new toggle/setting is persisted and visible in settings UI.

## 6) Current UI conventions

- List pages use `ListPageScaffold` where possible.
- Sort/filter controls should use app bar actions + bottom sheets.
- Random discovery actions should use floating action buttons on list pages.

<!-- UI_GUIDELINE_REF -->

## UI Guideline Reference
See [UIGUIDELINE.md](UIGUIDELINE.md) for current UI standards.
