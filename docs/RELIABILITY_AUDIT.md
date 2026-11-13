# Reliability and Performance Audit

**Date:** 2026-11-11
**Branch:** `dev`
**App version:** 1.42.0+115
**Method:** Code reading of the data layer, caches, auth, list paging, playback
tracking, app lock, tagger, dedup, casting, captions, and config restore.
Assumed load: one person per device, a library of a few thousand items.
Findings are from source review; items marked *unverified* were not
reproduced on a device.

## Fixed

- **Stale list and detail data.** One-shot `cacheAndNetwork` queries returned
  the cached answer and discarded the network answer, so refresh showed old
  data. Entity lists and scene details now use `networkOnly`.
- **Cache cleanup touched shared temp folders.** On Linux and Windows the
  cleanup scanned generic `cache` and video folder names in the shared system
  temp directory. It now touches only app-owned image cache folders there.
- **Feed counted plays twice.** `TiktokSceneItem` tracked play count and play
  time on the same player the global `PlaybackActivityTracker` already tracks.
  The duplicate tracking was removed. *Device check pending.*
- **App lock showed the library on launch.** Lock flags loaded asynchronously,
  so the gate rendered unlocked first. Flags are now read synchronously.
- **"Clear database cache" deleted `.hive`/`.lock` files in Documents.** On
  desktop the app documents directory is the user's `~/Documents`. Legacy
  cleanup now only removes the graphql default box files.
- **Background lock relied on a timer.** A frozen background app could not fire
  it, and resume cancelled it. The gate now compares elapsed time on resume.
  *Unverified on device.*
- **Lists stopped at page one when it fit on screen.** Paging only reacted to
  scroll events. Layout metric changes now also trigger the next page.
- **Paging stopped only on an empty page.** All list providers now treat a page
  shorter than `perPage` as the last one, on first load and on later pages.

## Open

1. **Auth state changes rebuild the GraphQL client and every list**
   (`lib/core/data/graphql/graphql_client.dart`). `login()` changes auth state
   several times, and each change creates a new client, repository, and list
   reload. Old `http.Client` instances are never closed. Watch only the
   header-relevant auth fields and close the client in `ref.onDispose`.
2. **Image disk cache holds only 100 files**
   (`lib/core/presentation/widgets/stash_image.dart`). Fewer than three pages of
   cards fit, so thumbnails re-download. Raise `maxNrOfCacheObjects` and rely on
   the MB limit.
3. **Editing the active profile URL keeps the old server's cache**
   (`server_profiles_provider.dart` `updateProfile`). Cache keys such as
   `Scene:42` collide across servers. Reset the GraphQL store when the active
   profile's `baseUrl` changes.
4. **Expired password sessions are not renewed**
   (`lib/core/data/graphql/graphql_exception.dart`). `unauthorized` is
   classified but not acted on. Re-run `login()` once in password mode.
5. **Nine copies of paging state.** Every list provider repeats page, has-more,
   loading, and generation handling. Move it to one mixin in
   `lib/core/utils/pagination.dart`.
6. **Failed page loads are silent.** `fetchNextPage` only logs errors. Keep the
   last page error and show a retry row in `ListPageScaffold`.
7. **Tagger random mode keeps going when every request fails**
   (`scene_tagger_page.dart`). Stop after a few failures in a row and show the
   error.
8. **`setPerPage` is unused** in eight list providers. Delete it.
9. **Leftover per-frame profiling print** in `lib/main.dart` (profile builds).
10. **A new Dio client per notification cover** in
    `video_player_provider.dart`, never closed.
11. **Dedup deletes one scene per request.** The schema has `scenesDestroy`
    for bulk deletes.

## Not reviewed

`native_video_controls.dart`, the caption worker isolate and audio decoder,
the router, cast session internals, and native Android and desktop code.
