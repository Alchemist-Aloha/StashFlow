# StashFlow Product and Design Specifications

Current, category-based contracts for agents working in this repository.
Implementation history belongs in Git; this file describes the product and
architecture that should remain true after a change.

## How to use this document

- Start with the relevant category below, then verify named symbols in code.
- Treat goals, invariants, ownership boundaries, and acceptance criteria as the
  specification. File paths are navigation hints and may move during refactors.
- Update an existing category when behavior changes. Add a new section only
  when no current section owns the behavior.
- Keep implementation plans, commit narratives, and one-off bug investigations
  out of this file.
- Current code wins when a path or symbol has moved, but an intentional behavior
  change must update this document in the same change.

### Category index

- [Foundation and design system](#foundation-and-design-system)
- [Navigation and interaction](#navigation-and-interaction)
- [Lists, filtering, and discovery](#lists-filtering-and-discovery)
- [Scenes, images, and galleries](#scenes-images-and-galleries)
- [Video playback and media sessions](#video-playback-and-media-sessions)
- [Settings, authentication, and local data](#settings-authentication-and-local-data)
- [Platform and build behavior](#platform-and-build-behavior)
- [Testing and verification](#testing-and-verification)

## Foundation and design system

### Application architecture

StashFlow uses feature-oriented layers under `lib/features/`:

- `domain/` owns immutable entities and filter/configuration contracts.
- `data/` owns GraphQL documents, response mapping, and repositories.
- `presentation/` owns Riverpod state, pages, and widgets.
- `lib/core/` contains only cross-feature infrastructure with multiple proven
  consumers.

Repositories validate GraphQL results consistently and expose domain objects.
Providers own loading, pagination, refresh, and UI state. Widgets must not make
raw GraphQL calls or persist preferences directly when a provider/service owns
that concern.

Do not recreate removed generic abstractions such as `BaseRepository`,
`MediaCard`, `MediaHeader`, `DataMapper`, or `MediaStrip`. Prefer focused feature
components and existing shared primitives such as `ListPageScaffold`, filter
sheets, saved-filter UI, `StashImage`, and common state views.

### Material 3 and responsive layout

- Follow Material 3 expressive patterns with readable hierarchy, soft shapes,
  consistent interaction states, and accessible contrast.
- Use `context.dimensions.spacingSmall`, `spacingMedium`, and `spacingLarge` for
  padding, margins, and gaps.
- Use `context.dimensions.buttonHeight` for component height and multiply manual
  icon sizes by `context.dimensions.fontSizeFactor`.
- Do not introduce hardcoded layout spacing or static `AppTheme` dimension
  constants.
- Layout must react immediately to `appGlobalScaleProvider` changes without
  overflow at supported scale extremes.
- Use capability and available-width checks instead of assuming mobile behavior
  from a platform name.

Canonical implementation:

- `lib/core/presentation/theme/app_theme.dart`
- `lib/core/presentation/providers/layout_settings_provider.dart`
- `lib/core/utils/responsive.dart`

### Theme personalization

The app supports light/dark/system theme modes, a persisted Material seed color,
and a True Black option for dark themes. Theme changes apply without restart.
True Black may replace dark surfaces with black, but text, outlines, disabled
states, and overlays must retain accessible contrast.

### Localization and accessibility

- User-visible strings must use ARB keys; never ship new plain strings.
- Maintain de, es, fr, it, ja, ko, ru, zh, zh_Hans, and zh_Hant alongside
  English.
- Preserve placeholders exactly across locales.
- Run `flutter gen-l10n` after ARB changes and validate translations with the
  scripts under `scripts/`.
- Interactive icons require a tooltip or semantic label.
- Keyboard focus order, touch targets, screen-reader labels, and disabled-state
  meaning must remain clear at every supported scale.

## Navigation and interaction

### Application shell and routes

`ShellPage` and the GoRouter configuration own top-level navigation. The shell
must preserve feature state while switching branches and keep the global player
outside individual route lifecycles.

The customizable navigation model contains six tab types:

- Scenes
- Performers
- Studios
- Tags
- Galleries
- Groups

Groups is hidden by default. Users may reorder tabs and change visibility, but
at least one usable destination must remain. UI indices must map explicitly to
the router's fixed branch indices. Re-selecting an active top-level destination
scrolls its primary list to the top rather than duplicating the route.

Canonical implementation:

- `lib/features/navigation/presentation/router.dart`
- `lib/features/navigation/presentation/shell_page.dart`
- `lib/features/setup/presentation/providers/navigation_tabs_provider.dart`

### Random navigation

Random navigation is available for supported entity lists and details pages.
One global preference controls whether floating random actions are visible.
Scene random navigation has a separate preference controlling whether the
active filter is respected.

Random selection must:

- exclude the current entity when another candidate exists;
- use the current repository/filter contract rather than shuffling visible
  widgets;
- handle empty and single-result sets without navigation loops;
- preserve the originating list/filter context when practical;
- avoid duplicate requests from repeated taps.

### Desktop and web interaction

Desktop-like behavior is capability-gated through the desktop capability and
settings providers. It includes hover feedback, keyboard navigation, player
shortcuts, and pointer-appropriate controls without weakening touch behavior.

Global shortcuts are suppressed while the user edits text. Keybinds are
persisted, resettable, and grouped into global-navigation, video-player, and
image-viewer contexts. Conflicts are rejected within overlapping contexts while
safe reuse across non-overlapping media contexts is allowed.

The keybinding UI must support capture cancellation, invalid-key feedback,
conflict explanation, unbinding, reset confirmation, and keyboard focus
traversal.

Canonical implementation:

- `lib/core/presentation/providers/desktop_capabilities_provider.dart`
- `lib/core/presentation/providers/desktop_settings_provider.dart`
- `lib/core/presentation/providers/keybinds_provider.dart`
- `lib/features/setup/presentation/pages/settings/keybind_settings_page.dart`

## Lists, filtering, and discovery

### Shared list behavior

Primary entity pages use `ListPageScaffold` or an equivalent shared contract for
search, loading, empty/error states, pull-to-refresh, pagination, layout choice,
and scroll ownership.

List invariants:

- Initial load, explicit refresh, and pagination are distinct states.
- Pagination appends without resetting the current scroll position or active
  playback context.
- Duplicate fetches are coalesced or ignored while the same page is in flight.
- Empty and error states provide an appropriate recovery action.
- Grid/list layout and supported column preferences persist.
- Cards receive decode-size hints so image memory use tracks rendered size.

### Sorting and filtering

Each feature owns a typed filter entity and maps it to the server's criteria in
its repository. Filter UI edits a temporary value and commits only on Apply;
canceling a sheet must not mutate the active query.

Sort/filter sheets must:

- remain usable at small heights and large UI scales;
- keep primary actions reachable;
- show the active-filter count accurately;
- support reset and persisted defaults where offered;
- preserve search, sort direction, and feature-specific criteria together;
- use shared filter widgets when their semantics match.

Do not force every entity into the Scene filter shape. Performer, studio, tag,
group, image, gallery, scene, and marker criteria remain feature-specific.

### Saved presets

Scenes, performers, studios, tags, groups, images, galleries, and scene markers
may expose server-backed saved filters where the server mode supports them.

A saved preset contains the effective query state:

- search text;
- sort method and direction;
- active typed filter values;
- mode-specific values required to reproduce the result.

Loading a preset updates local state as one logical operation and refreshes the
list once. Saving, renaming, and deleting display progress and recoverable
errors. Shared behavior belongs in `GraphQLSavedFilterRepository`,
`SavedFilterDialog`, and the saved-filter config contract; feature adapters own
serialization differences.

### Image and preview loading

- `StashImage` is the common authenticated/cached image boundary.
- List and strip callers provide appropriate `memCacheWidth`/height hints.
- Prefetch only the visible region plus a small forward buffer.
- Deduplicate concurrent requests for the same URL and decode size.
- Scene VTT sprites load only after a hover/scrub-capable interaction begins.
- A scene card without a usable VTT must not intercept horizontal pan gestures.
- Randomized strip ordering must remain stable across unrelated rebuilds.

## Scenes, images, and galleries

### Scene cards

Scene cards support grid/list layouts, localized metadata, duration/rating
overlays, context actions, and optional performer avatars. The avatar count is
controlled by `maxPerformerAvatarsProvider`; avatar size follows dynamic UI
scaling.

Hover scrubbing is enabled only for pointer-capable environments and only when
sprite data is available. Touch scrolling and card activation must remain
reliable when scrubbing is unavailable.

### Scene details

Scene details combine identity, playback, metadata, related media, and editing
without duplicating repository state.

Layout contract:

- Below 768 logical pixels, content uses a mobile vertical composition.
- At 768 logical pixels and above, identity, actions, and supporting metadata
  use the responsive large-screen composition.
- Header actions remain reachable without crowding the title or studio.
- Metadata visibility follows the user's setting.
- Editing and scraping entry points appear only when their prerequisites are
  available.
- Loading or failure of a secondary section must not hide the primary scene.

The scene media section exposes cover and preview content only when available.
Cover images open the dedicated fullscreen cover viewer with zoom/pan and a
predictable exit gesture/action.

Performer rows may display age derived from the performer's birthdate and the
scene date. Age is calculated at the scene date, not the current date; invalid,
missing, or pre-birth dates omit the suffix without triggering extra performer
requests.

### Scene rating and metadata mutation

Scene rating and metadata edits go through the scene repository. Successful
mutations update or invalidate both details and affected lists. Failed mutations
leave the last confirmed value visible and provide localized feedback.

### Images and galleries

Images and Galleries are separate top-level features with independent filters,
sorting, pagination, and layout state.

The fullscreen image viewer supports:

- previous/next navigation with correct endpoint behavior;
- zoom and pan;
- authenticated original-image loading;
- download/save actions with platform-appropriate permission handling;
- prefetch of nearby images without loading the entire result set.

Saving through `gal` must request only required access, use a recognizable
StashFlow album where supported, and report success/failure without exposing
credentials or internal URLs.

Entity details may show related galleries and gallery images through scoped
gallery filters. These views must not overwrite the user's top-level Gallery or
Image filter state. The entity image-filter-method preference controls the
server strategy and refreshes only the affected scoped view.

## Video playback and media sessions

### Player ownership and rendering

StashFlow uses one global media-kit playback session. A scene may render that
session inline, in TikTok mode, or in the root fullscreen overlay, but multiple
widgets must never compete for ownership.

Responsibilities:

- `video_player_provider.dart` owns session lifecycle and global player state.
- `SceneVideoPlayer` decides when an inline scene may acquire playback.
- `PlayerSurface` owns shared visual rendering, controls, transforms, subtitles,
  buffering, and casting placeholders.
- `GlobalFullscreenOverlay` owns overlay visibility and platform fullscreen
  effects while rendering the active global scene.
- `TransformableVideoSurface` owns pinch zoom and free rotation.

The UI talks directly to media-kit state. Do not restore the removed
video-player compatibility adapters or route-owned fullscreen player.

### Playback queues

`PlaybackQueue` retains contextual queues keyed by `PlaybackQueueIds`. The main
scene list and entity-specific strips/media views keep independent sequences and
current indices.

Queue invariants:

- Fresh query state replaces the relevant sequence; pagination appends to it.
- Selecting a scene activates the queue that supplied it.
- Next/previous uses the active queue order.
- Queue indices stay synchronized with TikTok swipes and direct scene changes.
- A failed stream resolution/open must not leave the active scene and queue
  index disagreeing.
- End-of-list behavior follows the user's playback-end setting and must not
  navigate repeatedly.

Do not collapse contextual queues into one global sequence or reintroduce the
removed manual-queue design.

### Fullscreen and transforms

Fullscreen always renders `playerState.activeScene`. Entering from details must
first establish that the page scene owns the global player. Exit cleanup must
pair with every successful enter path and remain retryable after a platform
failure.

Mobile fullscreen applies the configured gravity/aspect orientation behavior
and restores the main-page orientation policy on exit. Desktop and web use
their platform fullscreen boundaries without applying mobile system UI calls.

Pinch/rotate behavior:

- begins from the current transform without jumping;
- clamps scale to a usable range;
- permits free rotation;
- supports an explicit reset to identity;
- does not steal taps and drags intended for playback controls.

### Casting

Casting discovery and session control are owned by the cast service. The player
surface displays a remote-playback state while a cast session is active. Local
and remote position/state changes must synchronize without starting duplicate
sessions. Disconnect and load failures return to a coherent local state and are
logged without leaking authenticated URLs.

### Background playback and Android media session

Background playback follows the persisted preference:

- when enabled, playback may continue while the app is backgrounded and the
  media notification remains synchronized;
- when disabled, an active global player pauses on backgrounding unless the app
  is entering an allowed picture-in-picture path;
- preview/local auxiliary players do not inherit global background ownership.

The Android media session publishes current title, artwork, duration, position,
playing state, and supported actions. Notification seeking performs true player
seeks and keeps position/duration synchronized. Playback completion follows the
configured end behavior. The notification intentionally has no Stop action.

Artwork caching must avoid deletion races while notification metadata still
references a file.

## Settings, authentication, and local data

### Settings information architecture

The Settings hub links to focused pages for server, appearance, interface,
playback, storage, security, keybinds, developer options, and support.

Settings pages use the shared shell and panel components in
`lib/features/setup/presentation/widgets/settings_page_shell.dart`. They share
dynamic spacing, section hierarchy, loading/error presentation, and navigation
behavior. Server Settings may keep its specialized profile-list interactions,
but must retain the same overall visual language.

New settings require:

- a documented owner/provider;
- a stable persisted key when persistence is needed;
- migration or fallback behavior for renamed keys;
- localized label, description, and feedback;
- inclusion in configuration backup only when safe and user-facing.

### Server profiles and authentication

Users can maintain multiple server profiles and switch the active profile.
Profile metadata is stored in SharedPreferences; credentials and the app-lock
passcode are stored in secure storage.

Supported authentication modes are:

- API key;
- password with session cookies;
- HTTP Basic;
- bearer token.

GraphQL, images, downloads, and video resolution must derive authentication
from the same active profile. Switching profiles flushes or invalidates
profile-bound clients, media headers, lists, details, caches, and playback URLs
so data cannot leak across servers.

Server URL input accepts a user-friendly base address and normalizes it at the
network boundary. Validation errors must not echo credentials.

### Cache management

`AppCacheService` and cache state providers own image, video, and GraphQL cache
measurement and clearing. Storage Settings displays sizes, clear actions, and
supported limits.

- Cache work must remain asynchronous and tolerate missing/locked files.
- Clearing one cache type must not delete unrelated user settings or active
  media required for playback.
- Size displays refresh after clear/limit changes.
- Media limits apply to their documented cache only; do not imply a strict
  database limit when none exists.
- Errors are localized for users and detailed safely in logs.

### Application configuration backup

Configuration backup exports and replaces user-facing app configuration through
the allowlist in `AppConfigSettingsRegistry`.

Backup content may include:

- allowlisted typed SharedPreferences settings;
- server profile metadata;
- optional credentials and app-lock secret only after explicit opt-in.

Backup invariants:

- Credentials are excluded by default.
- Including credentials shows a clear unencrypted-plain-text warning.
- Imports are parsed and validated before mutation and show a replacement
  preview/confirmation.
- Replacement is atomic from the user's perspective: failures attempt rollback
  and report whether rollback succeeded.
- Missing credentials in an imported replacement remove old credentials rather
  than silently retaining them.
- Unknown preference/secure-storage keys are never imported.
- Size, structure, type, profile-reference, and schema-version limits are
  enforced.
- Backup bytes, credentials, and secret-bearing errors are never logged.
- Document adapters preserve bytes and filename/MIME metadata across desktop,
  mobile, and web flows.

Encryption and cloud synchronization are outside the current backup scope.

## Platform and build behavior

### Android

- Application ID and namespace are `io.github.alchemistaloha.stashflow`.
- Minimum Android SDK is 24.
- Release APK verification uses `flutter build apk --split-per-abi`.
- Java/Gradle/plugin versions must remain compatible with the checked-in build
  configuration and CI.
- Manifest permissions must be justified by current features; do not restore
  removed broad storage or obsolete permissions.
- Audio service, PiP, and notification behavior must continue to work after
  build or lifecycle changes.

There is no current F-Droid flavor or Fastlane metadata. Adding a store-specific
flavor requires a fresh dependency/license and reproducible-build audit; it is
not an existing supported build target.

### Windows fullscreen

Windows uses the dedicated native fullscreen transition and window-manager
coordination. It must preserve normal versus maximized restore state, window
bounds, monitor placement, title-bar controls, and taskbar behavior.

Entering and exiting fullscreen are asynchronous transactions. Flutter must not
mark exit complete before native restoration succeeds. Failures return to a
coherent, retryable state and are logged. Repeated toggles, Alt+Tab, secondary
monitors, and entry from a maximized window must remain safe.

Do not mix a second independent `window_manager` fullscreen transition into the
native Windows path.

### Linux desktop

The runner resolves its icon/resource path relative to the executable rather
than the process working directory. Installed and directly launched builds must
show the same icon and start successfully from arbitrary working directories.

### Web and GitHub Pages

Web builds use the correct `/StashFlow/` base href for GitHub Pages. Release,
release-candidate, and nightly workflows publish the built web artifact with the
permissions and branch behavior defined in `.github/workflows/`.

Deployment verification includes asset loading without 404s, application
startup, routing/refresh behavior under the subpath, and basic authenticated UI
interaction where browser security permits it.

## Testing and verification

### Test structure

- Unit tests cover domain mapping, filter serialization, providers, services,
  queue behavior, and pure platform helpers.
- Widget tests cover page states, settings interactions, cards, filters, player
  controls, fullscreen surfaces, keyboard focus, and localization.
- Integration/host tests cover navigation and native contracts where a unit or
  widget test cannot provide confidence.
- Shared helpers live under `test/helpers/`; feature-specific fakes stay near
  their tests when reuse is not established.

### Required regression areas

Changes should select focused coverage from these areas:

- loading, empty, error, refresh, and pagination states;
- search/sort/filter persistence and saved-preset round trips;
- navigation tab mapping, scroll-to-top, random navigation, and key conflicts;
- scene details responsive layout, metadata mutation, and performer age;
- queue selection, next/previous, playback-end behavior, and failed transitions;
- inline/fullscreen/TikTok player ownership and cleanup;
- background playback, PiP, notification metadata, and seeking;
- cache clearing and configuration import rollback;
- Windows fullscreen restoration and Linux icon path resolution.

### Verification commands

For documentation-only edits, run structural/link checks and `git diff --check`.
For code changes, run the narrowest relevant tests first, then broaden according
to risk:

```bash
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --split-per-abi
```

Platform-specific changes also require their host tests or a documented manual
acceptance pass. If a command cannot run on the current host, report that gap
instead of implying verification.

## Updating this specification

When behavior changes:

1. Edit the owning category rather than adding a dated duplicate.
2. Keep the goal and invariants concise; link to canonical code only when it
   materially improves navigation.
3. Remove requirements that are intentionally retired.
4. Put migration steps in an issue, plan, or pull request—not this document.
5. Verify headings, internal links, referenced local paths, and the final diff.
