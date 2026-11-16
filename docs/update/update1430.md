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

## 🖼️ Gallery Details

- Gallery details now scroll together with the image grid, so galleries with many chapters, performers, or linked scenes no longer leave only a small area for browsing images. Drag anywhere on the page to scroll.
- Once the details scroll out of view, a compact summary with the title, rating, and image count stays pinned at the top. Its arrow button scrolls back to the full details.
- Galleries with chapters now show them as a chip row in the header. Tap a chapter to open the viewer at its first image, regardless of the grid's current sort.

## 🔐 Server Sign-in

- Password-based server profiles now sign in again with the saved credentials when activated, including at app startup, instead of reusing a possibly expired session.
- Fixed sign-in attempts that could fail when started before saved credentials had finished loading, and results from a previous profile can no longer apply after switching servers.
- When saving the active server profile fails to sign in, the editor stays open with your entries and shows an error, so you can correct them and retry.
