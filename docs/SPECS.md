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
- Card titles use the already scaled `context.dimensions.cardTitleFontSize` once.
- Primary list-page app-bar titles keep the larger list title size. Performer,
  studio, tag, and gallery details omit the app-bar heading while keeping
  navigation and toolbar actions; their entity identity remains in the content.
  Other detail pages use the standard AppBar title style.
- View-all media grids for performers, studios, tags, and groups, and view-all
  gallery grids for performers, studios, and tags, use the owning entity name
  as the app-bar title. Resolve names from entity details for both nested and
  legacy direct routes; use localized Media or Galleries labels while the name
  is unavailable or blank.
- Entity view-all media and gallery grids and Gallery Details show search as
  their only app-bar action, alongside standard back navigation. Sort, filter,
  and saved-filter controls remain in the bottom action pill; these pages omit
  app-bar refresh, Tools, and Settings shortcuts while retaining pull-to-refresh.
- Use capability and available-width checks instead of assuming mobile behavior
  from a platform name.
- Translucent surfaces use the shared `FrostedSurface` recipe rather than
  hand-rolled `BackdropFilter` + `Container` pairs, and apply it only where
  content passes behind the surface. Opaque fills omit the backdrop blur layer
  while retaining their tint, clipping, border, shadow, and layout.
- A surface that floats over scrolling content must publish its height as an
  inset (scroll padding, or `MediaQuery` bottom padding) so no content is
  permanently hidden behind it.
- Floating list actions and pull-up panels clear the mini-player inset. The
  shell publishes its floating band in both bottom `padding` and `viewPadding`
  so default Scaffold FAB placement also clears it. Pages
  inherit the shell body's remaining safe area; system padding already consumed
  by the navigation bar must not be restored below their content or sheets.
- Interface Settings offers an off-by-default mini-player bottom spacer for
  taskbars that obscure bottom controls. Its 0–200 logical-pixel offset defaults
  to 64 and remains independent of the app UI scale. The shell moves the
  mini-player and publishes the same extra clearance through both bottom inset
  fields, preserving the gaps to action pills, random buttons, and filter/sort
  panels. The clearance also applies without active playback, but not in
  fullscreen. Disabling the spacer retains the selected offset. The layout
  providers own `mini_player_bottom_spacer_enabled` and
  `mini_player_bottom_offset`; both are included in configuration backups.

Canonical implementation:

- `lib/core/presentation/theme/app_theme.dart`
- `lib/core/presentation/providers/layout_settings_provider.dart`
- `lib/core/utils/responsive.dart`
- `lib/core/presentation/widgets/frosted_surface.dart`

### Theme personalization

The app supports light/dark/system theme modes, a persisted Material seed color,
and a True Black option for dark themes. Theme changes apply without restart.
Custom primary colors open a full-spectrum hue/saturation/brightness dialog with
synchronized hex input (6-digit RGB or 8-digit ARGB, optionally prefixed by `#`).
Apply persists the selected color; canceling does not change the active theme.
Invalid hex input disables Apply and displays localized guidance.
Appearance also offers System, Serif, Monospace, Manrope, Outfit, Space
Grotesk, Inter, Lora, and JetBrains Mono font families. The six named families
are bundled under the SIL Open Font License; missing glyphs use platform
fallback. The `appFontFamilyProvider` owns the `app_font_family` preference;
unknown or absent values fall back to System. Font changes apply immediately to
both themes.
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

The customizable navigation model contains eight tab types:

- Scenes
- Performers
- Studios
- Tags
- Galleries
- Groups
- Images
- Markers

Groups, Images, and Markers are hidden by default, including when absent from
an older saved configuration. Users may reorder tabs and change
visibility, but at least one usable destination must remain. UI indices must map
explicitly to the router's fixed branch indices. Selecting a destination first
unwinds trailing pages pushed from other features on the outgoing branch (for
example, a gallery and image viewer opened from performer details). Returning
to that branch restores its own details page and scroll state, not the borrowed
pages. Re-selecting the active destination after unwinding stops at its own top
page; re-selecting again resets it to the primary list and scrolls to the top.
Unwinding uses normal guarded pops, completes pushed-route futures, and lets
nested navigators reconcile between pops. A vetoed pop or superseding navigation
cancels the tab change; rapid repeated selections must not race the unwind.
Route ownership follows the configured branch routes, not URL prefixes.
Galleries opened outside the Galleries branch use that source branch's own
borrowed scoped route (`/galleries/from/<tab>/:id`, via `galleryLocation`), so
its nested Navigator never duplicates one kept open in another branch.
Android page transitions must ignore predictive back while their branch is
hidden (`BranchAwarePredictiveBackPageTransitionsBuilder`): Flutter commits a
back gesture on every accepting route, so a hidden branch's top page would
otherwise be popped behind go_router and lost on return.
The router survives preference changes and is disposed with its provider.
Edit routes without a correctly typed entity payload fall back to details.
Images reuses the existing `/galleries/images` list and fullscreen child routes
in its own shell branch, retaining saved tab order and existing image links.
When Images is hidden, those routes retain Galleries as the selected visible
navigation destination when available.
Markers likewise owns a shell branch at the existing `/scenes/markers` path;
when hidden, it selects Scenes when available. Its tab visibility and order
persist through Customize Tabs, and re-selecting it scrolls the list to the top.
The Scenes action-pill Markers shortcut and Galleries action-pill All Images
shortcut appear only while their corresponding tab is hidden. Changing tab
visibility updates these shortcuts without reopening the list page.
When their tab is hidden, the top-level Markers and All Images lists show an
app-bar back button to Scenes and Galleries respectively, including direct
links without a navigation history. System back gestures and hardware back
return to the same parent lists rather than exiting the app. Enabling the tab
removes that button and restores normal top-level back behavior reactively.
Fullscreen exits and child-route pops take precedence. Embedded gallery-detail
image browsing keeps its existing navigation.

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

Outside the web, the mouse Back button dispatches the app's normal Back action
across routes, dialogs, and fullscreen surfaces, respecting back interception.
At the root it does nothing rather than closing the app. Other mouse buttons
are unchanged; browsers retain their native mouse-button history handling.

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
- Entity list and scene-detail queries read from the network; the GraphQL cache
  is updated but never served as the one-shot answer, so refresh shows current
  server data.
- Pagination appends without resetting the current scroll position or active
  playback context.
- Pagination also reacts to layout changes, so a page that fits without
  scrolling still loads the next one.
- Duplicate fetches are coalesced or ignored while the same page is in flight.
- Empty and error states provide an appropriate recovery action.
- Grid/list layout and supported column preferences persist.
- In grids with a column setting, Ctrl+mouse wheel adjusts that category's
  persisted Interface setting by one column per event within the existing 1–10
  range. Wheel up reduces columns (larger cards); wheel down adds columns.
  Start from the displayed responsive count when the setting is automatic.
  Consume the shortcut without scrolling or platform zoom; ordinary scrolling,
  list/feed layouts, and horizontal strips keep their existing behavior.
- Cards receive decode-size hints so image memory use tracks rendered size.
- Shared list scroll padding reserves the measured floating action-pill height
  and its separation above the inherited mini-player inset. The final item must
  scroll fully clear of both surfaces, including after scale or action-size changes.

### Sorting and filtering

Each feature owns a typed filter entity and maps it to the server's criteria in
its repository. Filter UI edits a temporary value and commits only on Apply;
canceling a sheet must not mutate the active query. Applying sort or filters
refreshes the results automatically, including scoped entity media grids, and
resets pagination without appending responses from the previous query.

Sort/filter sheets must:

- remain usable at small heights and large UI scales;
- keep primary actions reachable;
- size sort sheets to their visible content, growing and shrinking as advanced
  options expand and collapse, up to 88% of the modal route's available height
  rather than the full `MediaQuery` screen height; overflow scrolls inside the
  panel while actions and the outside dismiss area remain reachable;
- show the active-filter count accurately;
- support reset and persisted defaults where offered;
- preserve search, sort direction, and feature-specific criteria together;
- use shared filter widgets when their semantics match;
- display names (or media titles) for selected entity criteria, including restored
  filters; retain IDs for queries/removal and as a fallback if a name is unavailable;
- use `FilterField` for consistently start-aligned labels, scaled outer spacing,
  and label-to-control gaps across text, numeric, chip, and entity criteria;
- use full-width `FilterDropdown` controls with the same scalable decoration
  and minimum touch height; place value inputs below operators so long localized
  options and large UI scales do not squeeze or overflow adjacent controls.

The scene library and performer, studio, tag, and group scene grids share one
sort catalogue, including server keys and localized labels. Common scene sorts
are Date, Title, Rating, Duration, Random, Updated At, and Last Played At.
The gallery library and entity gallery grids likewise share one full catalogue;
common gallery sorts are Date, Title, File Path, Rating, Image Count, Random,
and Updated At. Image browsing, including embedded and scoped image pages,
shows Date, Title, File Path, Rating, Resolution, Random, and Updated At as common.
Other sort fields remain available in an expandable advanced section; a selected
advanced field stays in the first group so its selection remains visible when
collapsed. Sharing catalogues does not share query state: entity sorts and saved
defaults remain scoped to their existing providers.
Entity scene media categories (performer, studio, tag, and group) default to
Random when no sort is saved. Their horizontal previews, including the scene
detail page's More From rows, follow the corresponding expanded list's sort
field and direction, sharing its random seed so random ordering also agrees.
Previews preserve server order while excluding the current scene where relevant.
Performer, studio, tag, and group list sort sheets also separate common choices
from advanced fields, retaining all fields and surfacing a selected advanced
field in the first group.

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

- `StashImage` is the common authenticated/cached image boundary. Native images
  and VTT sprite sheets share its `cached_network_image_ce` manager (7-day
  freshness, 100 entries) and Dio transport with persistent session cookies.
  Web display retains its existing `Image.network` authentication fallback.
- List and strip callers provide appropriate `memCacheWidth`/height hints.
- Prefetch only the visible region plus a small forward buffer.
- Deduplicate concurrent requests for the same URL and decode size.
- Scene VTT sprites load only after a hover/scrub-capable interaction begins.
- A scene card without a usable VTT must not intercept horizontal pan gestures.
- Randomized strip ordering must remain stable across unrelated rebuilds.

## Scenes, images, and galleries

### Scene cards

Scene cards support grid/list layouts, localized metadata, thumbnail badges,
context actions, and optional performer avatars. Scene and gallery cards share
`ThumbnailBadge`: rounded translucent corner badges with the rating (yellow
star) top-right; scenes show the O-count bottom-left and the length (or scrub
position) bottom-right, galleries the image count bottom-right. Rating and
count badges are omitted when empty. The avatar count is
controlled by `maxPerformerAvatarsProvider`; avatar size follows dynamic UI
scaling.

Grid, list, masonry, and horizontal-strip scene cards show a thin, accessible
playback-position bar directly below the thumbnail when the saved `resumeTime`
and primary file duration are finite and positive. The ratio is clamped to
0–100%; a saved position at or beyond the duration displays a full bar. Play
count alone does not imply completion. Unplayed scenes, unknown durations, and
loading skeletons show no bar. Interface Settings exposes the default-on toggle
owned by `showScenePlaybackProgressProvider` in `layout_settings_provider.dart`;
its persisted `show_scene_playback_progress` key is included in configuration
backups, with missing keys falling back to enabled.

Cards prefer the last locally observed playback position over stale list data.
`scenePlaybackPositionProvider` receives global local-player and cast position
updates, including seeks and pauses, so returning to any scene list while a
mini-player or PiP session continues updates the matching bar in real time.
Only the bar rebuilds on position ticks; browsing cards must not initialize a
player or fetch scene details. Observed positions survive card unmounts and
playback changes/stops for the current app session, and reset when the active
server profile changes. Server resume data remains the fallback for scenes not
played in this session; this display cache does not change activity-save timing.

Square-video scene thumbnails retain their native 1:1 frame in grid and list
layouts on all platforms. If the decoded cover image is also square, stretch
its painting vertically to 1:2 and crop the top and bottom to fill that frame;
image loading must not change the card's layout bounds. Non-square covers keep
their normal fit. Other uniform-grid thumbnails use 16:9; list and masonry
thumbnails follow the source proportions, clamped to the supported card range.
Horizontal scene strips always use fixed 16:9 thumbnail frames, including for
portrait and square media. Covers fill and crop inside the thumbnail bounds;
image painting must not overlap the title and metadata below.

Hover scrubbing is enabled only for pointer-capable environments and only when
sprite data is available. Touch scrolling and card activation must remain
reliable when scrubbing is unavailable.

### Scene details

Scene details combine identity, playback, metadata, related media, and editing
without duplicating repository state. The scene information panel opened from
card long-press or details shows the primary file's size in its technical
metadata, using readable byte units or a placeholder when unavailable.

Layout contract:

- Below 768 logical pixels, content uses a mobile vertical composition.
- At 768 logical pixels and above, identity, actions, and supporting metadata
  use the responsive large-screen composition.
- Header actions remain reachable without crowding the title or studio.
- Rating, add-O, details, download (where supported), and More share one action
  row directly on the page background, without a surrounding panel backdrop.
  The O-count button uses an unfilled icon-and-count treatment.
  At narrow widths or large UI scales, the row scrolls horizontally instead
  of wrapping or shrinking touch targets. Desktop-capable layouts at non-mobile
  widths (600 logical pixels and above) show add marker, edit, refresh, and delete
  directly in the row, without More. Smaller or touch-only layouts use More to
  open a bottom panel containing add marker, edit, delete, and desktop refresh;
  selecting an action closes the panel before opening its dialog or page.
- On touch, dragging the scene title previews previous/next navigation with
  title movement and a directional chevron; completing the swipe starts the
  adjacent scene in the active queue. At queue ends, the title resists the drag
  without navigating. Once per app launch, the title gives a brief directional
  hint when an adjacent scene exists; reduced-motion users do not see it.
- Metadata visibility follows the user's setting.
- Editing and scraping entry points appear only when their prerequisites are
  available.
- Loading or failure of a secondary section must not hide the primary scene.

Marker destinations, shortcuts, and image placeholders use a map-pin icon
(`Icons.place_rounded`), matching the official Stash web UI's `faMapMarkerAlt`;
creation actions use `Icons.add_location_alt_rounded`. Saved-filter bookmarks
remain distinct.

Scene marker rows jump playback to the marker's start time, preserving fractional
seconds. If the scene is not active, selecting a marker starts it at that time
instead of its saved resume position. The separate delete action only opens
confirmation and must not seek playback.

The scene media section exposes cover and preview content only when available.
Cover images open the dedicated fullscreen cover viewer with zoom/pan and a
predictable exit gesture/action.

Performer rows may display age derived from the performer's birthdate and the
scene date. Full birthdates account for whether the birthday had occurred;
year-only birthdates use calendar-year subtraction. Invalid, missing, or
pre-birth dates omit the suffix without triggering extra performer requests.

Performer and Studio Details group unfilled favorite, shared rating, and edit
buttons in a single row below the performer identity chips or studio name.
Header padding and action spacing follow the scaled theme dimensions. Aliases
sit close to the performer identity with half the small theme spacing. Rating
changes use the entity repository, refresh details, and invalidate affected
lists after confirmation; cancellation or failed saves retain the confirmed
value, with localized feedback on failure. Performer Details shows the first
five links, with a Show more/Show less action in the section header when there
are more.

### Scene rating and metadata mutation

Interactive rating entry points share `RatingButton` and `RatingPicker`. A single
star opens a popup editor with five stars, fractional-rating selection, Clear,
and Apply/Cancel. Ratings use the server's 0–100 scale; cancelling leaves the
confirmed rating unchanged. Image metadata panels, including card long-press
details, are read-only and omit rating controls. Scene, image, and gallery
metadata panels support text selection and copying. Image panels show the
primary visual file's size in readable byte units, or a placeholder when
unavailable. Fullscreen image rating retains
its image/gallery target selector.

Scene rating and metadata edits go through the scene repository. Successful
mutations update or invalidate both details and affected lists. Failed mutations
leave the last confirmed value visible and provide localized feedback.

### Images and galleries

Images and Galleries are separate top-level features with independent filters,
sorting, pagination, and layout state. Gallery Details and entity All Images
browsers additionally own route-lifetime image query sessions: search, filters,
organized state, sorting, random seed, pagination, fullscreen selection, and
scroll position never overwrite the Images library or another browser. They
start with empty optional filters/search and path-ascending order, enforce their
gallery/entity restriction on every page (including after Reset or preset Apply),
and dispose their session when popped or when the active server changes. Layout
preferences and repositories remain shared. Only the library may save image
filter/sort defaults; scoped browsers may still use saved filter presets.

Gallery cards, gallery strips, and random-gallery actions open Gallery Details
without changing the Images library query. The hidden Images-tab fallback opens
the existing library session without clearing its filters. Scoped fullscreen
routes remain within the originating browser so Back, keyboard navigation,
slideshow, pagination, rating targets, and return focus use that browser's query.
Confirmed image ratings update all live image lists without refetching or
reshuffling them. Existing library URLs (`/galleries/images`, `/image/:id`) remain
supported; a library deep link outside the loaded page resolves that image as a
single-image view. A missing scoped image shows an explicit dismissible state,
never an unrelated first image. In scoped browsers, system Back (including
Android predictive Back) dismisses an open image-details or filter sheet before
leaving the browser, preserving its route, query, and scroll state. Cancelling
the gesture keeps the sheet open; a later Back can leave the browser normally.

Gallery Details exposes the shared single-star rating button in both its expanded
and collapsed headers, including for unrated galleries. The expanded section
fills the available content width, retaining scaled theme padding. Both headers
show the title and metadata without a cover thumbnail beside the title. The unfilled
details button sits beside the rating button, with the image count immediately
after it in the expanded header's action row, wrapping when space is limited.
The section collapses after scrolling beyond its scaled threshold. During touch
or drag scrolling it stays collapsed until the grid settles at the top after
release, including any fling or overscroll rebound; merely crossing the collapse
threshold on the way back does not expand it. Wheel, keyboard, and programmatic
scrolls retain immediate threshold-based reveal. The explicit expand button
always responds immediately without changing the image scroll offset. Nested
and horizontal scrolling must not trigger header reveal.
Confirmed rating changes
refresh gallery details and update the gallery list without reshuffling it;
failures retain the confirmed value and show localized feedback. Gallery card
long-press and More actions open the same read-only metadata sheet as the details
page, with no rating editor in that sheet.

The fullscreen image viewer supports:

- platform-specific window modes: Android and iOS open without immersive
  system UI; desktop opens windowed and the header button or the image
  fullscreen keybind (default F) toggles fullscreen,
  leaving fullscreen on close only when the viewer entered it; web keeps
  requesting immersive system UI on open;
- previous/next navigation with correct endpoint behavior;
- responsive manual transitions independent of slideshow timing, with repeated
  keyboard input advancing from the intended destination and touch swipes
  resynchronizing navigation to the displayed page;
- pinch, double-tap, and mouse-wheel zoom with panning bounded by the fitted
  image; an unzoomed image yields one-finger drags to page swipes at any
  angle, while a zoomed image locks the pager and pans until a drag passes its
  edge, which then continues into the page swipe; a pinch that starts while a
  page transition is still animating zooms the page it settles on;
- authenticated original-image loading through the shared `StashImage` cache;
- download/save actions with platform-appropriate permission handling;
- prefetch of nearby images without loading the entire result set.

ImageClips are identified by the primary `visual_files` entry's `VideoFile`
type, not by URL extensions. GIFs are an exception: the source format or a
case-insensitive `.gif` source-file suffix keeps them in the animated-image
viewer and image-saving path, even when reported as `VideoFile`. GIFs have no
video controls or play indicator. Gallery/image grids retain static thumbnails
with a play indicator for clips. The fullscreen viewer loops the authenticated original clip with
a dedicated play/pause and seek row in a viewer-owned media-kit session, separate
from the scene queue. Clips fill the same viewport as still images beneath the
viewer overlays. A compact floating play/seek bar sits above the measured viewer
navigation when shown, or at the bottom safe area when hidden. Clearance follows
navigation size, UI scale, orientation, and system insets without resizing the
video or recreating its session. Short layouts compact the bar while retaining
48dp minimum touch targets. Scrubbing commits one seek on release, keeps the
preview position until completion, and neither pages nor toggles viewer chrome.
Recoverable decoder errors do not tear down the surface or repeatedly pause it.
Only the selected clip mounts a player; paging away or closing detaches the
surface before releasing it, even during startup. Backgrounding pauses it once
and foregrounding resumes only previously playing media. Clips are excluded from still-image prefetch and are
saved as videos with their source extension (or server-reported MP4/WebM type).
Still images retain zoom/pan and their existing loading behavior.

Saving through `gal` must request only required access, use a recognizable
StashFlow album where supported, and report success/failure without exposing
credentials or internal URLs.

Entity details may show related galleries and gallery images through scoped
gallery filters. These views must not overwrite the user's top-level Gallery or
Image filter state. The entity image-filter-method preference controls the
server strategy and refreshes only the affected scoped view.

Scene–gallery links are many-to-many. Scene Details shows a Galleries strip
(`GalleryStrip`, after Performers) and Gallery Details' expanded header shows a
Scenes strip (`SceneStrip`, own playback queue) for the first 24 linked items,
each hidden when there are none; tapping opens the linked details page. Each
page's pull-to-refresh also reloads its strip.
Scene and gallery strips size their row from the grid cards' shared text styles
(`MediaCardText`: 16:9 thumbnail, two-line title, subtitle, and for scenes the
resume bar) under the active UI and text scale, give every card the same
slot width, and omit performer avatars so cards neither clip nor leave a gap.
The row adds equal small-spacing padding above and below the cards; the
horizontal scrollbar sits in the bottom padding.
On details pages, a strip sits medium spacing below its section header.
Details-page scene and gallery strips keep the preview's server order, which
uses the same sort (including the random seed) and entity restriction as the
View all grid, and never reorder it client-side.
Pull-to-refresh on a View all grid draws a new random seed, so a random sort
reshuffles like the main lists; the matching details-page strip follows it.

## Video playback and media sessions

### Player ownership and rendering

StashFlow uses one global media-kit playback session. A scene may render that
session inline, in TikTok mode, or in the root fullscreen overlay, but multiple
widgets must never compete for ownership.

Responsibilities:

- `video_player_provider.dart` owns session lifecycle and global player state.
- `SceneVideoPlayer` decides when an inline scene may acquire playback.
  Inline containers are no wider than 16:9, including placeholders and loading
  states; narrower video ratios retain their existing sizing. Video and scene
  screenshots use contain fit against black, so wider content fits the player
  width without cropping and has black bars above and below. Fullscreen, feed,
  and PiP sizing are unchanged.
- Inactive inline players show the scene screenshot through `StashImage`, with
  a readable control scrim and the normal missing/failed-image fallback.
- Inactive inline placeholders keep the Back control in the active inline
  player's top-left position, including while playback starts.
- `PlayerSurface` owns shared visual rendering, controls, transforms, subtitles,
  buffering, and casting placeholders.
- `GlobalFullscreenOverlay` owns overlay visibility and platform fullscreen
  effects while rendering the active global scene.
- `TransformableVideoSurface` owns pinch zoom and free rotation.
- Feed page changes pause every inactive cached player, even while the next
  controller is loading. Feed completion is edge-deduplicated and owns auto-next
  only while its promoted session is visible; details, fullscreen, and PiP use
  global completion instead. Returning from global playback synchronizes the
  feed to the active scene after startup is ready, without restarting its decoder
  or resuming user-paused playback. Feed visibility uses the committed top route,
  not a retained parent route or browser URL, and reacts to both system Back and
  toolbar Back after fullscreen or details-route replacement.
- Feed title taps hide the metadata, action buttons, scrubbing bar, and overlay
  gradients. The next video tap restores these overlays without playing or
  pausing; subsequent video taps retain normal play/pause behavior. Visibility
  is shared across feed pages and remains manually controlled, with no timed
  auto-hide. Subtitles and playback continue independently of overlay visibility.
- Scene grid/list returns restore scroll position and keyboard focus to the
  active scene (or the saved playlist item for random returns). Restoration is
  driven by returning to the list route, waits for list data, and must not depend
  on the original details push completing: next-scene navigation can replace it.
- A feed pool lends its active controller to the global session. On pool
  unmount or eviction of the shared controller, lifetime ownership transfers to
  the global session so the surviving
  decoder is eventually disposed, not leaked or disposed during the handoff.

Browser media uses URL/browser authentication and never passes custom HTTP
headers to media-kit. This applies to global playback, feed preloads, and previews.

The UI talks directly to media-kit state. Do not restore the removed
video-player compatibility adapters or route-owned fullscreen player.
Inline and fullscreen player utility buttons share the same overlay treatment
at the top and bottom; mirrored edge gradients keep them legible over video.
The transport group has no shared backdrop or drop shadow.
Playback settings offer a horizontal slider from 1 to 10 seconds in one-second
steps for the player controls' auto-hide delay. Two seconds is the default when
no valid preference is saved; existing saved delays are preserved. The selected
delay applies to inline and fullscreen controls while video is playing; paused controls remain visible. The preference is
included in configuration backups.

The optional video debug overlay groups stream, active decoder/output, and
performance diagnostics in a bounded, scrollable panel. It follows controls
visibility and samples native mpv properties once per second only while visible.
It distinguishes source/output frame rates and decoder/output dropped frames;
unsupported metrics are shown as unavailable, not zero. Startup and prewarm
latencies retain their existing session meaning. The panel never displays media
URLs or authentication headers.

### On-device transcription and translation

Playback Settings provides searchable Hub catalogs, explicit cancellable downloads,
and installed-model selection/removal. Search results fill the available search
view, resizing above the mobile keyboard rather than using a fixed screen-height
fraction. Public repository discovery is paginated
and scoped to known sherpa-onnx Whisper, transducer, SenseVoice and Paraformer
export conventions, plus CTranslate2 Marian OPUS-MT language pairs; this is not
support for arbitrary Hugging Face architectures. Selecting a repository inspects
its layout and pins its revision, file sizes, SHA-256 hashes, languages and license
before download. Unsupported layouts are rejected; only complete, atomically
installed models are usable. Existing snapshots remain selectable offline, and
a repository already installed reuses that snapshot until removed. Model cards
remain with downloaded files; large models may exceed device memory. Selections,
validated manifests and inference options are backed up, never weights or text.

The subtitle menu offers one Transcribe action, opening a transcription dialog
with translation as an optional switch, not a separate mode selector or menu
action. Model management is available from the dialog and Playback Settings,
not as a subtitle-menu action. The dialog remains accessible without downloaded
models so users can reach model management; Apply requires installed models.
Source and output language lists support searching localized names and language
codes. Speech and translation models can be inspected and downloaded directly
inside the dialog using the shared catalog, with progress, cancellation and
error recovery. Downloads install weights but stage model selection in the
dialog until Apply; cancelling the dialog retains completed downloads, not
configuration changes. Apply is disabled while models are loading or a download
is in progress. The responsive dialog keeps speech and optional translation
controls separate from collapsed advanced tuning. Missing-model download panels
open automatically; clearly named panels distinguish speech from translation.
Expanded download sections stretch to the full form width with scalable vertical
padding, and the desktop dialog allows a wider model-management area. Their
height follows the model details and actions rather than a clipped fixed box.
Progress and cancellation remain available even if translation is collapsed.
Content, long labels, and actions adapt to narrow widths, large UI/system text,
landscape and keyboard insets. Actions stay below the scrollable form when
height permits and join its scroll area on short viewports. Model catalogs
scroll their loading/error/retry states as well as results.
The dialog stages speech-model, source/output-language, preferred downloaded
translation-model, ASR-thread (1–8), audio-window (4–12 seconds), VAD-threshold
(0.2–0.8), subtitle-delay (±5 seconds) and bilingual-display settings. Cancel
changes neither preferences nor active inference; Apply commits one configuration.
The next dialog restores the last applied models and inference options, including
the translation switch and preferred model when applying transcription; these
survive app restarts. Existing saved options without the switch default to
transcription without translation.
Multilingual Whisper, including tiny, detects language per VAD phrase when Auto
is selected; English-only `.en` exports do not. SenseVoice also supports detection
for its trained languages. Short/noisy/mixed-language phrases may need a fixed
language. A fixed source language disables automatic language detection and
its dialog status; recognizer metadata cannot override the chosen language or
translation routing. Selecting Auto enables detection again when applied.
Offline recognizers use phrase-level VAD timing, not token timestamps.
Translation lazily loads one downloaded Marian model matching each phrase's
source and selected output language. A missing pair stops with a localized recovery
message, never a wrong-language fallback; same-language output passes through.

The shared subtitle menu is available even without server captions, including
the feed. Transcription, with or without translation, is opt-in and session-scoped and disables
the selected server subtitle track. None or selecting a server track stops
generation. Web and casting cannot generate subtitles. Native inline,
fullscreen, feed and PiP surfaces share timed Flutter-rendered cues and existing
subtitle font, alignment and position preferences. Server and generated captions
use one shared text style and padding recipe; the configured font size is scaled
once by the UI scale, without a server-subtitle-only multiplier. Both use the
ambient system text scaler; media-kit's default viewport-relative subtitle
shrinking must be overridden so external SRT and generated captions retain the
same configured font size even in small video surfaces.

A separate, silent, untimed mpv PCM decoder reads bounded configured windows
with one-second context around them. It reuses the active media URL, headers
and audio-track ID; it never changes audible playback settings. PCM output must
be accepted before opening media. ASR (sherpa-onnx) and translation
(CTranslate2/Marian with SentencePiece) run on a worker isolate. No microphone,
cloud inference, Google ML Kit, or extra FFmpeg distribution is involved.
Initial generation and uncached seeks show preparation status; real-time
throughput and accuracy depend on hardware and models, not guaranteed latency.

Seeks invalidate pending results. Scene/controller, audio-track, server/auth or
model-selection or inference-option changes stop the session and clear cues; inline/fullscreen/PiP
handoffs of the same controller do not. At most 32 windows of text are kept in
session memory; temporary PCM is removed after each extraction. Native errors
are replaced with localized recovery messages, never authenticated URLs or
transcript logs. Model removal first stops inference and releases its resources.

The local `packages/stashflow_translation` package builds pinned CTranslate2
and SentencePiece sources using CMake and Dart code assets, with a CPU Ruy
backend, no Python runtime and no bundled weights. Android retains all three
release ABIs and its existing minimum SDK. Native changes require host smoke
tests and split-ABI APK builds; sustained performance, GPU/driver behavior,
mobile PiP and non-host platforms require device/platform acceptance.

### Native video output and decoding

- `media_kit` and `media_kit_video` come from the same revision of the
  `Alchemist-Aloha/media-kit` fork. Its core build hook downloads, verifies, and
  packages native playback libraries; do not add `media_kit_libs_*` packages.

- Playback settings persist `video_mpv_vo` and `video_mpv_hwdec`; `default`
  leaves media-kit's platform defaults unchanged. `hwdec=no` selects software
  decoding without disabling GPU rendering.
- Every newly created controller reads these preferences: global playback,
  TikTok feed, scene-info previews, and the scene tagger. Existing or preloaded
  controllers retain their configuration; restarting the app updates all of them.
- Android offers `gpu`, `gpu-next` (libplacebo), and `mediacodec_embed`; the
  pinned fork handles gpu-next surface output and all three bundled Android ABIs
  contain the renderer. GPU/driver compatibility still requires device testing.
  Desktop platforms use embedded `libmpv` output. Linux additionally offers
  `libmpv-software`, an app preference mapped to `vo=libmpv` with
  `enableHardwareAcceleration=false` (software render API). It is not an mpv
  driver name. Software rendering is slower and omits GPU rendering overrides.
  `gpu-next`, `gpu`, and standalone window outputs are not compatible with the
  current Linux render-API texture integration and must not be offered there.
  Web does not expose or apply mpv preferences.
- Linux decoder choices include `vaapi`, `vaapi-copy`, `nvdec`, `nvdec-copy`,
  and `vdpau-copy`, in addition to default, software and automatic modes. VA-API
  direct interop receives the X11/Wayland display through the pinned plugin;
  NVDEC direct interop depends on NVIDIA drivers. Copy-back modes also work with
  software output. Direct VDPAU is not offered because its X11/OpenGL requirements
  do not match the plugin's cross-session GLES integration. Hardware/driver
  availability determines whether decoding succeeds or falls back to software.
  These Linux-only choices are filtered out on other platforms and on web.
- Direct Android output requires `hwdec=mediacodec` and does not support mpv
  subtitle rendering or video filters. Selecting it sets the required decoder;
  selecting another decoder restores default output. Runtime loading also guards
  against incompatible pairs and platform-specific options imported from backups.
- Rendering selectors persist `video_mpv_<option>` for `interpolation`,
  `video-sync`, `tscale`, `scale`, `dscale`, `cscale`, and `deband`. `default`
  preserves native defaults. Interpolation supplies `video-sync=display-resample`
  unless synchronization is explicitly selected or overridden. Display timing in
  desktop render-API embedding may limit interpolation; it is not guaranteed.
- The final playback-settings section stores `video_mpv_conf`: a flat runtime
  mpv.conf subset, at most 16,384 characters, with `option=value`, bare enabled
  options, full-line `#` comments and single/double-quoted values. Duplicate
  options use the last value. Custom values override rendering selectors.
  Supported playback-tuning options are listed in the editor and allowlisted in
  `PlayerSettingsStore`; profiles, includes, scripts, paths, authentication and
  app-owned output/decoder/lifecycle options are rejected, including on import.
  Native mpv may ignore unsupported option values. Clearing and saving removes
  custom overrides, not selector choices.
- All four new-player paths await runtime option application before opening
  media. Web applies none. Direct MediaCodec and software render-API output
  omit rendering overrides but keep audio/cache tuning. Existing controllers retain their settings.
- Configuration backups include output, decoder, rendering and custom settings
  with validated keys/values. Verify
  persistence, effective controller configuration, platform filtering, and paired
  selection behavior in tests; hardware compatibility requires device testing.

### Playback queues

`PlaybackQueue` retains contextual queues keyed by `PlaybackQueueIds`. The main
scene list and entity-specific strips/media views keep independent sequences and
current indices.

Queue invariants:

- Fresh query state replaces the relevant sequence; pagination appends to it.
- Selecting a scene activates the queue that supplied it.
- Next/previous uses the active queue order.
- Playlist selection keeps one scene-details destination above the scene list
  or feed, clearing older scene-details history. Repeated playlist selections
  must return to the list/feed with one Back action after fullscreen exits,
  while retaining the selected queue and restoring active-scene focus.
- On desktop and web, play and queue navigation sit at the bottom left below
  the progress bar, with utility controls to the right, in both inline and
  fullscreen players. Mobile keeps transport centered over the video, separate
  from the bottom seek and utility controls. When either queue direction is
  available, both navigation buttons stay visible; the unavailable direction is disabled
  so play remains anchored between them. Navigation buttons have transparent
  backgrounds while play retains the primary filled treatment.
- Queue indices stay synchronized with TikTok swipes and direct scene changes.
- A failed stream resolution/open must not leave the active scene and queue
  index disagreeing. Successful navigation commits the target scene by ID to
  the queue that supplied it, without overwriting a newly selected queue.
- End-of-list behavior follows the user's playback-end setting and must not
  navigate repeatedly.
- Best-effort prewarming probes the scene after the active video, not the queue
  index before a navigation transaction commits. Feed decoder preloading does
  not also require a network probe. Stale resolutions and stopped sessions must
  not restart probes. Requests are cancellable during connection/header/body
  phases, limited to a 2 MB body budget even when Range is ignored, and bounded
  to five seconds. Prewarming does not cache video bytes for the decoder or
  guarantee gapless playback.

Do not collapse contextual queues into one global sequence or reintroduce the
removed manual-queue design.

### Fullscreen and transforms

Fullscreen always renders `playerState.activeScene`. Entering from details must
first establish that the page scene owns the global player. Exit cleanup must
pair with every successful enter path and remain retryable after a platform
failure. Exit navigates to the active scene's details only when the current
route (including pushed pages in any tab) is not already that scene, so a scene
opened from another entity's details keeps its tab and Back history.

Mobile fullscreen applies the configured gravity/aspect orientation behavior
and restores the main-page orientation policy on exit. Desktop and web use
their platform fullscreen boundaries without applying mobile system UI calls.

Pinch/rotate behavior:

- begins from the current transform without jumping;
- clamps scale to a usable range;
- permits free rotation;
- supports an explicit reset to identity;
- does not steal taps and drags intended for playback controls.

### Picture-in-picture

PiP is available where the platform provides it: Android uses the system PiP
window, while Windows, macOS, and Linux open a separate lightweight player
window and leave the main app window in place. Both paths share the same player
state, so entering PiP never restarts playback and leaving it restores the
presentation that was active before entering.

- The PiP surface omits navigation chrome, details, and the mini player. Desktop
  builds show only a transient minimal transport overlay over the video.
- Desktop PiP supplies its own page route factory because the multi-window
  shell captures `material_ui` as a `WidgetsApp`. Entering from the fullscreen
  player waits for native fullscreen restoration and the overlay's exit before
  opening the PiP window. A failed exit or PiP entry restores the previous
  presentation; closing PiP restores it through the normal fullscreen path.
  PiP window creation waits until the current Flutter frame has ended so its
  synchronous native frames cannot re-enter the rendering pipeline.
- The desktop PiP window is frameless, always on top where supported, and
  omitted from the taskbar, dock window collection, or equivalent. Closing it
  leaves the main window geometry and decoration untouched, and stopping
  playback also closes it so no empty player is left behind.
- The desktop PiP window follows the decoder's display aspect ratio (including
  pixel-aspect correction and rotation), updating its lock and minimum size when
  metadata arrives or the active playback controller changes. Missing metadata
  must not overwrite a known ratio with the initial fallback. It can be resized
  freely down to a small minimum, so the minimum never inflates the short side
  of portrait or ultra-wide videos. The main window's minimum remains independent
  of PiP: it is enforced by the Windows runner and by the bound main native
  window on Linux and macOS.
- Android PiP is entered through the system window and can only be left by the
  user. Preparing Android PiP's video-only presentation and displaying PiP must
  not change the activity's screen orientation. Fullscreen orientation policy
  resumes only after PiP exit; failed entry restores the previous presentation.
  Foreground entry hands off after a prepared video-only frame with controls
  hidden, rather than a fixed delay, a fullscreen slide, or an immersive-mode
  resize. PiP-only presentation also skips the fullscreen return slide.
  Background entry must not wait for suspended rendering; foreground frame
  preparation has a bounded fallback if rendering stops during a lifecycle change.
  While active, its system parameters follow decoder display-ratio changes
  (including metadata arrival, rotation, and auto-play-next) without re-entering
  PiP. Entry's initial ratio must not be resent unchanged. Ratios are clamped within Android's supported 1:2.39–2.39:1 range; missing
  or invalid metadata retains the last valid ratio. Desktop PiP is an ordinary
  window: `P` toggles it, and its minimal
  controls expose previous, play/pause, next, seeking, and exit-PiP actions.
  While focused, desktop PiP honors the configured player bindings for
  play/pause (Space), seeking (Left/Right by 5 seconds, J/L by 10 seconds),
  previous/next scene (Shift+P/Shift+N), and exit (P or Escape). Seeks stay
  within the known duration, and unavailable queue directions do nothing.
  These shortcuts remain available while the transport overlay is hidden.
  On Linux, native window focus/blur events are bridged to Flutter's per-view
  focus tree after its view frame mounts, so initial activation and switching
  between PiP and the main window route keyboard input to the active window
  without requiring a click on a control.
- Desktop window placement is best-effort. In particular, Wayland compositors
  choose window positions and may ignore always-on-top requests, so the PiP
  window may open where the compositor decides and can be dragged. Hyprland
  rules for `Picture-in-Picture — StashFlow` should float and pin the window
  without imposing a monitor-derived `size`: a generic PiP size rule overrides
  the video's requested proportions. GTK aspect hints and later client resize
  requests are also compositor-dependent on Wayland. The Linux runner removes
  PiP-only GTK decoration margins so the window dimensions describe the video
  client area. On Wayland, video-ratio changes briefly request equal minimum
  and maximum dimensions, wait for native resize confirmation, then restore
  free resizing and the ratio lock. Hyprland's `keep_aspect_ratio` rule preserves
  those proportions during edge dragging without a forced initial `size`.

The Windows PiP runtime smoke uses a local video of at least 30 seconds to check
inline and fullscreen handoffs, native window geometry, playback continuity,
keyboard transport, and window cleanup:

```powershell
flutter build windows --release --no-pub -t test/windows/pip_smoke.dart
python scripts/test_windows_pip.py build/windows/x64/runner/Release path/to/video.mp4
```

### Casting

Casting discovery and session control are owned by the cast service. The player
surface displays a remote-playback state while a cast session is active. Local
and remote position/state changes must synchronize without starting duplicate
sessions. Disconnect and load failures return to a coherent local state and are
logged without leaking authenticated URLs.

A seek must not change whether the remote is playing, so a seek issued while
paused re-asserts the pause even when the renderer resumes on its own. Resuming
a cast must actually resume the remote: a renderer whose transport stopped (or
that ignored `Play`) gets the current media re-pointed at the last known
position instead of another `Play`. Remote progress must keep advancing in the
app even when the underlying session stops reporting it, and the media session
follows the remote position and state while casting rather than the paused local
player.

Remote completion follows the configured playback-end behavior. Scene changes
from queue controls, keyboard or media actions, playlists, and contextual strips
switch the active cast session to the selected scene while preserving the active
queue and its previous/next navigation.

### Background playback and Android media session

Background playback follows the persisted preference:

- when enabled, playback may continue while the app is backgrounded and the
  media notification remains synchronized;
- explicit pause commands from system media controls, desktop PiP, and the
  mini player suppress background keepalive until an explicit Play or foreground
  resume, including while the app is inactive;
- controller initialization must not require a Flutter render frame, so
  notification queue changes and auto-next can start while frames are suspended;
- when disabled, an active global player pauses on backgrounding unless the app
  is entering an allowed picture-in-picture path;
- preview/local auxiliary players do not inherit global background ownership.

Android Playback Settings owns the independent `video_respect_audio_focus`
boolean through PlayerSettingsStore/PlayerState. Missing or invalid values default
to enabled, including existing installs; configuration backups include the key.
“Pause when other apps play media” requests audio focus before local scene/feed
playback and pauses on focus loss (including duck requests). Background keepalive,
seek restoration, and view handoffs must not undo that pause, even after foreground
resume. A temporary interruption may resume only the same previously playing
session, with no intervening manual pause/stop or session change, and only when
lifecycle/PiP policy permits. Permanent loss or a denied/failed request requires
explicit Play. Focus is released on pause, stop, casting, or disabling the setting.
Disabling it permits simultaneous playback but does not restart a paused video.
Casting and preloaded/auxiliary players do not acquire global session focus.
Android can still enforce interruptions regardless of this opt-out; background
focus requests are subject to OS foreground-service restrictions.

The Android media session publishes current title, artwork, duration, position,
playing state, and supported actions. Notification seeking performs true player
seeks and keeps position/duration synchronized. Playback completion follows the
configured end behavior. The notification intentionally has no Stop action.
Notification titles use the same scene display title as the app: trimmed title,
then the cleaned file-path stem, then the stream-path stem, then the default
scene label. Artwork publication and duration refreshes preserve this fallback.

Artwork caching must avoid deletion races while notification metadata still
references a file.

Linux uses the pinned `audio_service_mpris` 1.0.0-beta.3 with `wakelock_plus`
1.8.2 and their compatible D-Bus 0.8 dependency. Before `AudioService.init`,
Linux startup explicitly configures the existing D-Bus name and StashFlow
identity and enables play, pause, next, previous, and general media control;
the beta's disabled-by-default capabilities must not hide transport controls.
Other platforms retain their existing audio-service initialization.

## Settings, authentication, and local data

### Settings information architecture

The Settings hub links to focused pages for server, appearance, interface,
playback, storage, security, keybinds, developer options, and support.
Appearance Settings owns the app language choice alongside theme, color, font,
and scale preferences. On first launch (no server configured and no saved
language), the same language sheet opens before the server setup prompt. Interface Settings begins with navigation preferences.

Settings pages use the shared shell and panel components in
`lib/features/setup/presentation/widgets/settings_page_shell.dart`. They share
dynamic spacing, section hierarchy, loading/error presentation, and navigation
behavior. Server Settings may keep its specialized profile-list interactions,
but must retain the same overall visual language.
The hub matches the Tools list layout: a single column of full-width action
cards inside a shared section panel, with medium spacing between actions at
every window width and UI scale. Keyboard settings remain desktop-only.

New settings require:

- a documented owner/provider;
- a stable persisted key when persistence is needed;
- migration or fallback behavior for renamed keys;
- localized label, description, and feedback;
- inclusion in configuration backup only when safe and user-facing.

### Library maintenance tools

The Tools hub links to `/tools/library-scan` and `/tools/generate-content`.
Both use the shared Material 3 settings shell, expose the official web app's
library scan/generate options, and support the whole library or selected server
folders. Folder selection supports configured library roots, remote directory
browsing, manual paths, deduplication, and removal; an empty selection cannot run.

`LibraryTasksRepository` owns configuration, directory, and job operations through
the active profile's GraphQL client. Each page loads fresh server configuration;
`ui.taskDefaults.scan`/`generate` take precedence over legacy `defaults`, with the
official task fallbacks when neither exists. Each option change patches its task
branch using `configureUI(partial:)`, preserving unrelated UI/task settings.
Saves serialize interaction, failures restore the displayed value, and launching
is disabled until saving finishes. Generation fetches current general preview
parameters immediately before submission. Refresh reloads remote task defaults.
Task settings are remote, not part of local configuration backups.

Successful submission reports the queued job ID, not completion. The shared
server queue polls without overlapping requests while mounted, displays status,
progress, estimated remaining time, subtasks and failures, and supports stopping
one or all jobs. Switching profiles resets forms/queue and closes folder pickers;
stale responses cannot launch work on the newly selected server.

### Server profiles and authentication

Users can maintain multiple server profiles and switch the active profile.
Profile metadata is stored in SharedPreferences; credentials and the app-lock
passcode are stored in secure storage.
App-lock flags are read synchronously from SharedPreferences, so lock on
launch covers the very first frame. The background timeout is decided by
elapsed wall time on resume as well as a timer, so an app the OS froze in the
background still locks.
On Android devices with enrolled biometrics, Security Settings offers
fingerprint/face unlock through `local_auth` (`BiometricAuthService`). It
requires an enabled passcode lock, is confirmed by a successful prompt before
being saved, and only adds a prompt to the lock screen: the passcode always
remains the fallback. The prompt is shown automatically once per lock, only
while the app is in the foreground. `MainActivity` must stay a
`FlutterFragmentActivity` (via `AudioServiceFragmentActivity`) with an
AppCompat `LaunchTheme` for the system prompt to work.
Each profile can opt into accepting a self-signed HTTPS certificate for its own
host and port on native platforms. The option defaults to off, is included in
configuration backups, and cannot override browser certificate validation.

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
- Image accounting includes `cached_network_image_ce` and legacy image-cache
  directories. Clearing empties the shared manager before removing leftover
  image files; clearing and size-limit trimming must preserve its open Hive
  metadata files. Limits apply to image files, not metadata overhead. Old cache
  entries are not imported and may download again.
- Clearing one cache type must not delete unrelated user settings or active
  media required for playback.
- Linux and Windows temporary directories are shared with other programs, so
  measuring, trimming, and clearing there touch only app-owned image cache
  folders, never generic `cache` or video folder names.
- Size displays refresh after clear/limit changes.
- Media limits apply to their documented cache only; do not imply a strict
  database limit when none exists. Web skips filesystem media-limit enforcement;
  browser storage is not available through `path_provider`.
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

Stable and nightly builds share `.github/workflows/reusable-release.yml`.
Version-tag pushes (`v*`) publish stable releases; pushes to `dev` publish
nightly builds. Pushes to `main` do not create release candidates.
Android, Linux, web, and release jobs use Ubuntu 26.04. CI uses Flutter 3.47.9
and resolves dependencies with
`flutter pub get`
Pub fetches the media-kit fork rather than
using the ignored local `media-kit/` checkout. Linux installs system graphics/audio runtime
libraries, but mpv and FFmpeg are bundled by the fork's native-assets hook.

The app requires Flutter 3.47.9 or newer and Dart 3.13 or newer within Dart 3.x.
`msix` is a development dependency used only for packaging. `fastforge` runs as a
globally activated tool so its `archive` 3 pin stays out of app resolution.

Desktop window control uses the `window_manager` 0.6 native API, not its legacy
MethodChannel bridge.
Startup captures the main native window before PiP can open; later fullscreen
requests must use that same window rather than the
currently focused window. Windows obtains its initially hidden HWND from the
runner through `getWindowHandle` on `stash_app_flutter/fullscreen`, then sizes,
maximizes, shows, and focuses it. Linux and macOS set the main window's minimum,
size, and maximized state before the runner shows it. Web builds exclude the FFI
handle bridge. Linux native compilation requires GTK3, X11, and XInput headers
(`libgtk-3-dev`, `libx11-dev`, and `libxi-dev` on Debian/Ubuntu).

Stable release artifact filenames retain the full `pubspec.yaml` version,
including the build number, plus platform and architecture where applicable.
Rolling nightly artifact filenames use a fixed channel label without a version
or commit SHA, for example `StashFlow-nightly-linux-x64.AppImage`.
Successful rolling publications overwrite matching assets and then remove
obsolete assets not present in the new build.
The release title/body retains commit information. Concurrent runs for the same
rolling channel cancel older runs so older builds cannot publish over newer ones.
Linux distribution packages (AppImage, deb, and pacman) ship with adjacent
`.sha256` files referencing only the package basename, so downloads can be
verified together with `sha256sum -c <filename>.sha256`.

### macOS

The minimum deployment target is macOS 13, matching the native frameworks emitted
by the pinned Flutter SDK. While the Podfile remains, Debug and Release Flutter
xcconfigs must include the matching CocoaPods xcconfig before Flutter's generated
settings; Profile inherits Release. This supplies `PODS_ROOT` to CocoaPods build
phases even when plugins resolve through Swift Package Manager.

Stable and nightly workflows build both macOS artifacts on Apple Silicon
`macos-26` runners using native host Flutter/Dart tools, cross-compiling the
Intel artifact. They explicitly select `arm64` and `x86_64` through Flutter's
Xcode build settings, and align `CMAKE_APPLE_SILICON_PROCESSOR` with the target
so CTranslate2/Ruy select matching CPU kernels. The release build generates its
own ephemeral configuration; there is no separate configuration-only build.
ZIP filenames end in
`macos-arm64` or `macos-x86_64`, and upload artifact names are distinct.
Before packaging, the app executable and every bundled Mach-O binary must
contain the target architecture; embedded universal libraries are allowed.

### iOS

- Bundle identifier is `com.github.alchemistaloha.stashflow`; minimum iOS is 15.
- Debug and Release xcconfigs optionally include the CocoaPods xcconfig before
  Flutter's generated settings, matching macOS.
- `Info.plist` declares arbitrary loads, local-network, Face ID, photo-library,
  and background-audio usage required by server access, `local_auth`, `gal`,
  and `audio_service`.
- Stable and nightly workflows build on `macos-26` with
  `flutter build ios --release --no-codesign` and publish an unsigned
  `ios-unsigned.ipa` (`Payload/Runner.app`) for sideloading tools that re-sign
  on install. There is no App Store or TestFlight signing.

### Android

- Application ID and namespace are `io.github.alchemistaloha.stashflow`.
- Minimum Android SDK is 24.
- Compile SDK is 37; target SDK follows Flutter's supported default.
- Release APK verification uses `flutter build apk --split-per-abi`.
- R8 must preserve the Kotlin coroutine/result types and members referenced by
  Dart JNI using literal JVM names, including `Continuation` in shared-preferences
  method signatures. Keep rules remain scoped to these bridge types rather than
  entire plugin packages; release artifact inspection complements host tests.
- The Android build uses Java 21, Gradle 9.9.0 (with a verified distribution
  checksum), Android Gradle Plugin 9.5.1, and Kotlin 2.4.21. Toolchain upgrades
  must remain compatible with the checked-in build configuration and CI.
- Manifest permissions must be justified by current features; do not restore
  removed broad storage or obsolete permissions.
- Audio service, PiP, and notification behavior must continue to work after
  build or lifecycle changes.

There is no current F-Droid flavor or Fastlane metadata. Adding a store-specific
flavor requires a fresh dependency/license and reproducible-build audit; it is
not an existing supported build target.

### Windows build prerequisites

Stable and nightly workflows build Windows x64 and ARM64
ZIP bundles and EXE installers in separate jobs. ARM64 uses `windows-11-arm`
and bootstraps the pinned Flutter tag with native ARM64 Dart; the x64 release
archive must not determine the target architecture on the ARM runner. Artifact
filenames end in `windows-x64` or `windows-arm64`, and upload names are distinct.
ARM64 installers allow ARM64 systems and use 64-bit installation paths. Both
bundles must contain matching-architecture executables and DLLs, including the
Flutter engine and bundled mpv. Fastforge performs the only Windows release
build while creating the EXE installer; the ZIP then reuses that same Release
bundle. Architecture validation runs after Fastforge and before ZIP packaging
and artifact uploads; there is no separate standalone Windows build.

The on-device translation DLL and its static CTranslate2/SentencePiece
dependencies use the same static MSVC runtime. Windows ARM64 uses Ruy's fallback
CPU detection because the pinned cpuinfo does not support that platform; other
targets retain CPU detection.

The translation hook places Windows CMake intermediates under the repository's
`build/tr/<hook-cache-key>/` directory. This preserves configuration isolation
while avoiding MSBuild tracking-file path limits in nested Ruy targets.

Windows builds require the Visual Studio C++ desktop toolchain and C++ ATL
for the active MSVC toolset and target architecture (x86/x64 or ARM64).
The Windows secure-storage plugin includes `atlstr.h`; `flutter doctor` alone
does not establish that this optional component is installed. See
[`Building from Source`](wiki/Building-from-Source.md#windows-build-dependencies).

### Windows fullscreen

Windows uses the runner-owned `WindowsFullscreenController`, called through
`stash_app_flutter/fullscreen` by `DesktopFullscreen`. It saves the main HWND's
styles and `WINDOWPLACEMENT`, removes its frame/zoom state, and sizes it directly
to the current monitor's `rcMonitor` without an intermediate unmaximize or inset
resize. Exit restores the saved styles and placement. It must preserve normal
versus maximized restore state, window bounds, monitor placement, title-bar
controls, and taskbar behavior. Fullscreen frame messages bypass normal frame
handling only for the main HWND; separate PiP windows retain their own handling.

Startup initializes the native `WindowManager` observation using the bound main
window's ID before showing it. Deferring that initialization until a fullscreen
style change can recursively enter its initial occlusion scan and deadlock the
Windows message loop.

Entering and exiting fullscreen are asynchronous transactions. Flutter must not
mark exit complete before native restoration succeeds. Failures return to a
coherent, retryable state and are logged. Repeated toggles, Alt+Tab, secondary
monitors, and entry from a maximized window must remain safe.

Do not mix a second independent `window_manager` fullscreen transition into the
native Windows path. Linux and macOS use the bound `window_manager` native
window's fullscreen property and await its matching entered/exited event. The
listener is removed on success, failure, or a 10-second timeout; no native event
must leave the shared transition queue permanently blocked.

The standalone Win32 regression test in `test/windows/runner/` checks normal and
maximized restoration, repeated toggles, full-monitor client bounds, and every
attached monitor. Run it in a Windows desktop session:

```powershell
cmake -S test/windows/runner -B build/windows-fullscreen-test
cmake --build build/windows-fullscreen-test --config Debug
ctest --test-dir build/windows-fullscreen-test -C Debug --output-on-failure
```

The Flutter runtime smoke target exercises native observation startup,
image navigation, Escape, repeated entry, and normal/maximized
restoration. Its external watchdog detects native hangs that widget tests with a
mocked fullscreen channel cannot catch. Build and run it in a desktop session:

```powershell
flutter build windows --debug --no-pub -t test/windows/image_fullscreen_smoke.dart
python scripts/test_windows_image_fullscreen.py build/windows/x64/runner/Debug
```

Also manually verify Windows 11 Alt+Tab/minimize/restore, mixed-DPI monitor
changes, taskbar visibility, title-bar controls after exit, and desktop PiP.

### Linux desktop

Stable and nightly workflows build native Linux x64 and
ARM64 jobs on Ubuntu 26.04 runners. ARM64 bootstraps the pinned Flutter tag with
native Dart. Both architectures ship ZIP, deb, AppImage, and pacman packages,
with distinct artifact names and `linux-x64` or `linux-arm64` filenames. Debian
metadata uses `amd64`/`arm64`; pacman and AppImage use `x86_64`/`aarch64`.
The AppImage tool matches the native runner architecture; its wrapper overrides
Fastforge's fixed x64 environment. Validate ELF architectures for the runner,
Flutter, mpv, and bundled libraries, and verify package architecture metadata
and the AppImage runtime before publishing.

The main window hides its GTK header bar and window decorations in Hyprland and
niri sessions, detected by complete, case-insensitive tokens in the colon-separated
`XDG_CURRENT_DESKTOP` value. Window management uses compositor shortcuts there;
other desktops retain their existing title-bar behavior. Missing session metadata
retains decorations rather than guessing the compositor.

The runner resolves its icon/resource path relative to the executable rather
than the process working directory. Installed and directly launched builds must
show the same icon and start successfully from arbitrary working directories.
Fastforge's `stash_app_flutter` launcher executable must be copied from the
installed `StashFlow` binary after CMake fixes its RPATH to `$ORIGIN/lib`, not
from the build tree. AppImage validation checks both binaries match and that the
launcher resolves libraries relative to itself rather than CI build paths.

### Web and GitHub Pages

Web builds use the correct `/StashFlow/` base href for GitHub Pages. Stable and
nightly workflows publish the built web artifact with the permissions and branch
behavior defined in `.github/workflows/`.

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

`analysis_options.yaml` extends Flutter lints with strict typing, explicit future
handling (`unawaited_futures` and `discarded_futures`), `avoid_dynamic_calls`, and
`avoid_catching_errors`, `avoid_print`, `avoid_void_async`, `exhaustive_cases`, and
`avoid_catches_without_on_clauses`. Await work whose completion matters; use
`unawaited()` only for intentional background work, preserving its error handling.
Prefer typed exception catches. Intentional recovery boundaries that must also
handle cast, storage, or native-plugin errors use documented `on Object` catches.
Caught failures are recorded through `AppLogStore` when debug logging is enabled,
including recovery and cleanup paths. `addError` records the operation, exception
type, and stack trace, not raw exception payloads that can contain credentials,
authenticated URLs, or backup data. Cache workers forward their bounded log
entries to the main isolate so failures appear in the in-app log viewer. Native
Android recovery failures use the platform logger with their stack traces.
Access JSON through typed maps/lists rather than dynamic member calls.

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
