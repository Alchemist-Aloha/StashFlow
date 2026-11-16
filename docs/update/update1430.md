# StashFlow v1.43.0

## 🎞️ Stream Source Selection

- Added a stream source menu to inline, fullscreen, and feed video controls. Choose between Direct, MP4, WebM, HLS, and DASH streams offered by the server, and pick a resolution for transcoded sources.
- Switching streams reopens the video at the same position and play state, keeping the active external subtitle. The menu is unavailable while casting.
- Added **Settings → Playback → Default Stream Source** to choose the source used when playback starts. Direct remains the default, and an unavailable source falls back to Direct. Downloads always use the original file. The preference is included in configuration backups.
- MP4 and WebM transcodes now seek correctly and show the scene's full duration and accurate position, with subtitles kept in sync.

## ▶️ Playback & Feed

- Added an O-count button above the rating in feed mode. It shows the scene's O-count, and tapping it adds one.
- The feed's stream source and subtitle buttons now sit in the collapsible action menu, keeping the right side less crowded.
- Autoplay next is now on by default. If you never changed this setting, the next scene now plays automatically; a setting you chose yourself is kept.
- When the next scene starts while an image viewer, scene editor, or another page covers the scene details, that page now stays open instead of being replaced.

## 🧱 Grid Layouts

- Removed the list layout. Scenes, galleries, markers, and the media and gallery pages of performers, studios, tags, and groups now always use the grid. If you used list mode, set the column count to 1 for full-width cards.
- Performer, studio, tag, and group media pages now share the Scenes column count, and their gallery pages share the Galleries column count. The separate studio, tag, and group column settings are gone; the Performers setting now applies only to the Performers page.

## ⚡ Smoother Browsing

- List pages and performer, studio, tag, and group details now scroll underneath a frosted top bar instead of stopping below it.
- With **Hide top app bar while scrolling** on, the bar now slides away and back without shifting the list, so scrolling stays smooth and cards no longer jump while it moves.
- Scrolling list pages under their frosted top bar and bottom action bar takes less graphics work, and the app does less work when playback starts, pauses, or buffers.
- Thumbnails in scene and gallery strips and the scene grid now load at your screen's real pixel density: sharper on high-density phones, and less memory on standard-density desktop displays.

## 👋 First-Run Guide

- After setting up your first server, the Scenes page asks whether you prefer the grid or the feed, with a small preview of each.
- Short one-time tips explain the main gestures: long press a scene card for details; in the feed, long press to fast-forward, tap the title to hide the controls, and open the up arrow for more actions; on scene details, swipe the title to change scenes.
- Scene details also asks once whether to seek by double-tap or by dragging, and the image viewer asks once for vertical or horizontal swiping. Both can be changed later in Settings.
- Added **Settings → Develop → Reset First-Run Tips** to show these again.

## 🖼️ Gallery Details

- Gallery details now scroll together with the image grid, so galleries with many chapters, performers, or linked scenes no longer leave only a small area for browsing images. Drag anywhere on the page to scroll.
- Once the details scroll out of view, a compact summary with the title, rating, and image count stays pinned at the top. Its arrow button scrolls back to the full details.
- Galleries with chapters now show them as a chip row in the header. Tap a chapter to open the viewer at its first image, regardless of the grid's current sort.

## 🖼️ Image Viewer

- Added an O-count button to the viewer. Tap it to add one; confirmed counts update open image lists without changing their order. Failed updates leave the count unchanged and allow retrying.
- Rating, O-count, download, and details now sit in a collapsible row below the title. Its expanded state stays the same when changing images, running a slideshow, or hiding and showing the controls.
- Previous, slideshow, and next controls are evenly spaced along the bottom, with the desktop fullscreen button beside slideshow.
- Image details now show studio code, photographer, O-count, organized status, description, tags, and containing galleries. Tag and gallery links close the details sheet before navigating.

## 🎬 Scene Details

- Scene details now list the groups a scene belongs to, including its scene number in each group. Tap a group to open it.
- Scene info now shows studio code, director, last-played time, creation and update times, stash IDs, custom fields, and file fingerprints when available. Timestamps use your local time zone.

## 👤 Performers

- Performer details now show career dates, death date, weight, measurements, body details, tattoos, piercings, O-count, stash IDs, and custom fields when set. Attributes and biography share a compact section with **Show more / Show less**.
- Added related groups and an **Appears With** section for co-performers. Appears With initially shows five people and expands independently of the details section.
- Opening a performer for editing now retains their saved career start and end values.
- Performers without a photo now show Stash's default silhouettes, tinted to the app theme, instead of a broken-image icon. Each performer keeps the same silhouette, and male performers use the male set. The performer details page now shows it too, where the image area was previously hidden.

## 🗂️ Groups

- Group lists now show front covers, and group details show front and back covers when available.
- Group details now include duration, aliases, studio, tags, links, containing groups, and sub-groups, with descriptions for group relationships.
- Group media now defaults to ascending **Scene Number in Group** instead of Random, preserving the group's intended order. Saved sort choices are kept; resetting the sort restores scene-number order.

## 🔗 Tags & Studios

- Tag details now show aliases, parent and child tags, and related performers, studios, groups, and markers. Tap a related item to open it; markers open their scene.
- Studio details now show aliases, tags, all distinct links, and related performers and groups. Long link lists can be expanded with **Show more**.

## 🔐 Server Sign-in

- Password-based server profiles now sign in again with the saved credentials when activated, including at app startup, instead of reusing a possibly expired session.
- Fixed sign-in attempts that could fail when started before saved credentials had finished loading, and results from a previous profile can no longer apply after switching servers.
- When saving the active server profile fails to sign in, the editor stays open with your entries and shows an error, so you can correct them and retry.
