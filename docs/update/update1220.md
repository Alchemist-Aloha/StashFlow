# StashFlow v1.22.0

## ✨ New Features

### Mini Player Video Enhancement

The mini player can now render the actual scene video instead of a static thumbnail, keeping full playback controls visible.

- **`useActualSceneVideoInMiniPlayer`** setting added to [`PlayerSettings`](../../lib/features/scenes/presentation/providers/player_settings.dart) — defaults to `true`.
- The mini player in [`mini_player.dart`](../../lib/features/navigation/presentation/widgets/mini_player.dart) renders a live `PlayerSurface` when a video controller is available, with `StashImage` fallback.
- Preference is preserved across player stop/start cycles ([commit `2ae8cfc3`]).
- A new `showControls` option in [`native_video_controls.dart`](../../lib/features/scenes/presentation/widgets/native_video_controls.dart) lets consumers toggle the control overlay independently.

### Cast Service — Media Restart & Session Handling

Overhauled [`cast_service.dart`](../../lib/core/data/services/cast_service.dart) with:

- **Media restart on scene switch**: Cast sessions now automatically restart media when navigating to a different scene.
- **Improved session lifecycle**: Cleaner device discovery, session state transitions, and error recovery.
- **Position handoff**: Local resume position is transferred to the remote session on scene transitions.
- **Structured logging**: `logCastProcess` for debugging cast operations.
- Comprehensive tests in [`cast_service_test.dart`](../../test/core/data/services/cast_service_test.dart).

### Playback Startup Recovery

Resilient player initialization with retry logic in [`video_player_provider.dart`](../../lib/features/scenes/presentation/providers/video_player_provider.dart):

- When a player fails to initialize or starts slowly, the system retries with configurable delays instead of showing a blank screen.
- A new `PlaybackSessionController` ([`playback_session_controller.dart`](../../lib/features/scenes/presentation/providers/playback_session_controller.dart)) manages player/video-controller lifecycle, stream binding, and cleanup — supporting both owned and borrowed session patterns.
- Tests added in [`playback_session_controller_test.dart`](../../test/features/scenes/providers/playback_session_controller_test.dart).

### Viewport-based Image Prefetching

Greedy image prefetching replaced with viewport-aware logic:

- In [`scene_card.dart`](../../lib/features/scenes/presentation/widgets/scene_card.dart) and [`stash_image.dart`](../../lib/core/presentation/widgets/stash_image.dart), images are prefetched only when entering (or about to enter) the visible viewport, reducing memory pressure and network usage.
- Cache behavior optimized to avoid redundant fetches.
- Design doc at [`docs/plans/2026-06-15-viewport-image-prefetch-design.md`](../../docs/plans/2026-06-15-viewport-image-prefetch-design.md).

### Interaction-driven VTT Loading

VTT sprite sheets in [`vtt_service.dart`](../../lib/core/utils/vtt_service.dart) are now loaded on demand:

- Requests are deduplicated with an in-flight tracking map (`_inFlight`) to eliminate redundant network calls.
- Cached results are reused across lookups.
- Design rationale at [`docs/plans/2026-06-15-interaction-driven-vtt-loading-design.md`](../../docs/plans/2026-06-15-interaction-driven-vtt-loading-design.md).

### Sorting & Scroll Improvements

- **Random Seed Handling**: Refactored sorting providers for consistent sort ordering across list rebuilds ([`entity_sort_random_seed_test.dart`](../../test/features/entity_sort_random_seed_test.dart)).
- **Riverpod Scroll Controller KeepAlive**: Scroll controllers use `keepAlive` to preserve position across tab switches ([`entity_scroll_controller_provider_test.dart`](../../test/features/entity_scroll_controller_provider_test.dart)).
- **Multi-value Criteria Normalization**: Scene server payloads normalize multi-value filter criteria for reliable querying.

---

## ⚡ Performance

- **`itemExtent` for Horizontal Lists** (Bolt): Converted horizontal `ListView`s across gallery, image, performer, studio, and tag strips to use `itemExtent`, giving the layout engine fixed item sizes for optimization ([`media_strip.dart`](../../lib/core/presentation/widgets/media_strip.dart), [`scene_strip.dart`](../../lib/features/scenes/presentation/widgets/scene_strip.dart), [`gallery_strip.dart`](../../lib/features/galleries/presentation/widgets/gallery_strip.dart)).
- **Hoisted Inherited Widget Lookups** (Bolt): Moved `MediaQuery.of` / `Theme.of` calls out of `itemBuilder` in interface settings pages, eliminating repeated inherited-widget traversals per frame.
- **Increased Scroll Cache Extent**: Raised `cacheExtent` in list page scaffolds for smoother back-navigation and reduced rebuild overhead.

---

## 🎨 UI & UX Improvements

- **Material Style Filter Panels**: Replaced `Container` with `Material` across all entity filter panels ([scene_filter_panel.dart](../../lib/features/scenes/presentation/widgets/scene_filter_panel.dart), [image_filter_panel.dart](../../lib/features/images/presentation/widgets/image_filter_panel.dart), [gallery_filter_panel.dart](../../lib/features/galleries/presentation/widgets/gallery_filter_panel.dart), [performer_filter_panel.dart](../../lib/features/performers/presentation/widgets/performer_filter_panel.dart), [studio_filter_panel.dart](../../lib/features/studios/presentation/widgets/studio_filter_panel.dart), [tag_filter_panel.dart](../../lib/features/tags/presentation/widgets/tag_filter_panel.dart)).
- **TagFilterPanel Switch Refactor** (Palette): Redesigned the switch widget for improved UX and accessibility labelling.
- **Accessibility Labels for Loading Indicators** (Palette): Added semantic labels to loading spinners/indicators across the app.
- **Scene Card Refactor**: Simplified [`scene_card.dart`](../../lib/features/scenes/presentation/widgets/scene_card.dart) — removed `StashImage` overlays and redundant `loaded` state tracking in favor of viewport-aware `CachedNetworkImage`.
- **Gallery & Tag List Tuples**: Refactored [`list_page_scaffold.dart`](../../lib/core/presentation/widgets/list_page_scaffold.dart) to use `AsyncValue.preserve`, fixing `AsyncValue.when` count mismatches and ensuring null-safety for scene tag lists.

---

## 🛡️ Lifecycle Safety & Stability

A systematic pass was made to guard callbacks against unmounted `StatefulWidget` / Riverpod `Ref` state:

| Area | Fix |
|------|-----|
| Scrubbing preview | Guard unavailable callback (`scrubbing_preview.dart`) |
| Edit page picker | Guard picker result state updates (`scene_edit_page.dart`, `performer_edit_page.dart`) |
| Server profile drawer | Guard async updates (`server_profile_drawer.dart`) |
| Saved preset filters | Guard async updates (`saved_filter_dialog.dart`) |
| Temporary text controllers | Dispose controllers in dialogs |
| List page measurements | Guard measurement callbacks (`list_page_scaffold.dart`) |
| Strip prefetch | Guard initial prefetch callbacks (`media_strip.dart`) |
| Startup sort callbacks | Guard in list providers |
| Shell startup callback | Guard navigation shell |
| Fullscreen prefetch | Guard image fullscreen callback |
| Marquee scroll loops | Cancel stale loops (`marquee_text.dart`) |
| Unused focus listener | Remove in settings |
| Performer edit date controllers | Retain controllers across rebuilds |

Comprehensive lifecycle tests added for each fix (14+ lifecycle test files).

---

## 🌍 Localization

- **Locale Refinement**: Removed generic `zh` locale in favor of script-specific `zh_Hans` / `zh_Hant` for accurate Chinese-language support.
- **New Translation Keys**: Added 2 new keys (`miniplayer_use_actual_video`, `miniplayer_use_actual_video_subtitle`) across all 11 supported locales (DE, EN, ES, FR, IT, JA, KO, RU, ZH, ZH_Hans, ZH_Hant).
- Regenerated all `app_localizations_*.dart` files.

---

## 🔧 Dependencies & Tooling

- **`gql_code_builder`**: Updated versions in build configuration.
- **`screen_brightness`**: Updated package versions with Gradle-level overrides in [`build.gradle.kts`](../../android/build.gradle.kts) and ProGuard keep rules in [`proguard-rules.pro`](../../android/app/proguard-rules.pro) for Android compatibility.
- **GraphQL Fix**: `size` field type corrected from `String` to `int` in `FindDuplicateScenes` query ([`scenes.graphql.dart`](../../lib/features/scenes/data/graphql/scenes.graphql.dart)).
- **Bolt & Palette**: Continued use of automated AI workflows for accessibility (Palette) and performance (Bolt) improvements.

---