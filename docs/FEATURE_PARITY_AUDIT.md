# Feature Parity Audit: StashFlow vs Stash Web UI

Date: 2026-11-15. Server: Stash v0.32.0 (`9e9ad972`) at the test server.
Compared against the official web UI source at the same commit
(`ui/v2.5/src`), StashFlow `dev` at `26200c52` plus uncommitted work.
Settings pages are out of scope.

## Method

1. **API coverage:** every GraphQL query and mutation root field the web UI
   documents use, diffed against those StashFlow's `.graphql` files and inline
   Dart operations use. The web UI uses 55 queries and 111 mutations;
   StashFlow uses 30 and 23.
2. **Display coverage:** for each details page, the fields the web panels
   render (`*DetailPanel.tsx`, `*FileInfoPanel.tsx`, tabs) compared with
   StashFlow's fragments and the fields its pages read.
3. **List coverage:** sort options and filter criteria from
   `models/list-filter/*.ts` compared with StashFlow's sort enums and filter
   panels.
4. **Live checks:** test fixtures added on the server (listed at the end), then
   checked over GraphQL and in the Linux debug build of StashFlow.

**Limits.** I couldn't drive the web UI in a browser here, so the web side
comes from its source at the exact server commit. The StashFlow GUI pass
covered scene details and scene info only. It stopped when the second monitor
went away, to avoid taking over the active desktop. Every other StashFlow
finding comes from the code and was checked against its queries and pages.

Severity: **High** means data users have in Stash is invisible in StashFlow,
the same kind of gap as the earlier gallery chapters and linked scenes report.
**Medium** means a common web workflow is missing. **Low** means a niche or
power-user feature.

## High: data that exists but StashFlow never shows

| # | Area | Missing in StashFlow | Evidence |
|---|---|---|---|
| H1 | Scene details | **Groups the scene belongs to, and its number in each group.** The web shows a Groups tab with scene numbers. | `SlimSceneData`/`SceneData` don't fetch `groups { group scene_index }`. Screenshot of Sintel (in group "Lantern Archive: Sample Shorts 01" as #4): no Groups section. |
| H2 | Group list and details | **Group cover art (front and back images).** The list shows a generic icon tile and the details header shows a placeholder icon. | `GroupData` doesn't fetch `front_image_path`/`back_image_path`; `group_details_page.dart` header is `Icon(Icons.group_work)`; `groups_page.dart` tiles use `Icons.group_work`. |
| H3 | Group details | Studio, tags, aliases, duration, URLs; **sub-groups** and **containing groups** (with descriptions); a performers tab. | `GroupData` has only id, name, date, rating, director, synopsis, scene_count and sub_group_count. Fixture: "Audit Parent Collection" contains group 1. |
| H4 | Tag details | **Parent and child tags**, aliases, and related performers, studios, groups and **markers**. The page shows only description, media and galleries. | `TagData` has no `parents`/`children`/`aliases`; `tag_details_page.dart` has no related sections. Fixture: tag "Open Movie" now has parent "Demo" and alias "Audit Alias T3". |
| H5 | Studio details | Aliases, tags, multiple URLs (only the legacy `url`), and performers and groups tabs. | `StudioListData` fetches `url`, not `urls`/`aliases`/`tags`. Fixture studio already has 2 aliases, 2 tags and 3 URLs. |
| H6 | Performer details | Fetched but never rendered: weight, measurements, tattoos, piercings, death date, fake tits, penis length, circumcised. Not fetched: career length, O-count, custom fields, stash IDs. No **groups** or **appears with** tabs. | The fields exist on `Performer` but nothing in `performer_details_page.dart` or `studio_performer_info_sections.dart` reads them. The fixture performer has tattoos, piercings, measurements and career length set. |
| H7 | Image details | Tags, description, photographer, studio code, **containing galleries**, O-count, organized flag. | `ImageData` fetches none of these. Fixture: image 15 now has tag "Demo", details, photographer and code "IMG-AUDIT". |
| H8 | Scene details and info | Studio code, director (fetched but not shown), custom fields, created and updated dates, stash IDs, file fingerprints (fetched but not shown), last played time, play and O history. | Screenshots of scene 10's info sheet: URLs, path and technical data only. Scene 7 has `custom_fields.audit_scene_field`. |
| H9 | Group scenes | Order. The web sorts a group's scenes by scene number by default; StashFlow defaults to **random** and never shows the number. | `GroupScenesPanel.tsx` uses `defaultSort="group_scene_number"`; `EntityMediaSort` falls back to `'random'`. |

## Medium: missing workflows

| # | Area | Missing |
|---|---|---|
| M1 | Gallery editing | Add, edit and delete chapters (`galleryChapterCreate/Update/Destroy`). Edit gallery metadata (title, date, studio, performers, tags, linked scenes, URLs, photographer, code, organized). Add or remove images, set or reset cover, create or delete galleries. Only rating can be changed now. |
| M2 | Image editing | Edit metadata, change O-count (`imageIncrementO`/`DecrementO`/`ResetO`), toggle organized, delete images. Only rating can be changed now. |
| M3 | Tag and group editing | No edit page for tags or groups, and no group create. Can't merge or delete tags. Can't manage sub-groups (`addGroupSubGroups`, `reorderSubGroups`). |
| M4 | Scene O-count and history | No decrement or reset for O-count. No way to view or reset play history, resume time or play duration. |
| M5 | Scene edit fields | Studio code, director, organized, groups with scene number, linked galleries, stash IDs and custom fields can't be edited. Organized is display-only. |
| M6 | Markers | Can't edit a marker's title, times or tags (`sceneMarkerUpdate`); only create and delete. No bulk marker edit or delete. |
| M7 | Bulk actions | No multi-select on lists, so no bulk edit, delete, merge or generate for any entity (web: `bulk*Update`, `*Destroy`). |
| M8 | Performer and studio management | No performer merge or delete. No studio create or delete. |
| M9 | Scene actions | No "generate screenshot from current frame" (`sceneGenerateScreenshot`). Can't manage a scene's multiple files (set primary, delete file). |

## Low: niche or power-user gaps

| # | Area | Missing |
|---|---|---|
| L1 | Front page | Web home page with saved-filter recommendation rows. |
| L2 | Tools | Scene filename parser. Stash-box batch taggers for performers, studios and tags (StashFlow has the scene tagger only). Identify, auto tag and clean tasks. |
| L3 | Player | Per-scene video filter panel (brightness, contrast, gamma, saturation, hue, warmth, blur). StashFlow has gesture zoom and rotate plus global mpv properties instead. Interactive (Handy/funscript) playback sync (StashFlow can only filter and sort by it). |
| L4 | Display modes | Wall view for scenes, images and markers, and the table/list view. Markers have no wall or preview loop. |
| L5 | Filters | "Studio tags" criterion (scenes, images, galleries, groups) and "parent studios" (studios). Sort options and other criteria are at parity. |
| L6 | Stash-box | Submit fingerprints and scene or performer drafts. |
| L7 | Stats | "Scenes played" count. Everything else matches the web Stats page. |

## Already at parity (checked)

- Gallery chapters (display, open at chapter) and gallery ↔ scene links in both
  directions, which were the previously reported issues.
- Scene markers display, create and delete; markers page.
- Sort options for every entity; nearly all filter criteria; saved filters (find,
  save, delete); duplicate checker with merge; scene tagger; scan and generate
  tasks; stats panel; play queue; DLNA/cast.

## Suggested order

1. H1, H2, H9: one fragment field each plus a section or image. Highest
   visibility.
2. H3, H4, H5: related-entity sections on group, tag and studio details.
3. H6, H7, H8: render fields that are already fetched first, then add the
   missing ones.
4. M1 (chapter editing), then M4 and M2 (O-count parity).

## Server fixtures added for this audit

Revert these if the test data should stay pristine:

- Tag 3 "Open Movie": parent set to tag 1 "Demo"; alias "Audit Alias T3".
- New group 2 "Audit Parent Collection" (alias "APC") with sub-group 1
  ("Volume one").
- Scene marker 1 "Audit Marker" on scene 7, 0:30–0:45, primary tag "Demo",
  tag "Open Movie".
- Performer 49 custom field `audit_field: teal`; scene 7 custom field
  `audit_scene_field: yes`.
- Image 15: tag "Demo", details, photographer "Audit Photographer", code
  "IMG-AUDIT".
