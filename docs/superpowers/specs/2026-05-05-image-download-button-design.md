# Design Spec: Image Download Button

## Overview
Add a download button to the image fullscreen view that allows users to download the current image by opening its authenticated URL in the system's default browser.

## User Interface
- **Location:** `lib/features/images/presentation/pages/image_fullscreen_page.dart` in the overlay footer.
- **Components:**
  - A new `IconButton` for downloading.
  - The existing Slideshow button will be updated to match the new style.
- **Styling:**
  - Both the **Slideshow** and **Download** buttons will use `IconButton.filledTonal`.
  - Download Icon: `Icons.download_rounded`.
  - Download Tooltip: `context.l10n.common_download`.

## Data & Logic
- **URL Resolution:**
  - The image URL will be resolved using `image.paths.image ?? image.paths.preview`.
  - Authentication will be handled by `applyWebMediaAuthFallback` from `url_resolver.dart`, which appends an API key if available.
- **Trigger:**
  - Uses `url_launcher` with `LaunchMode.externalApplication`.

## Technical Implementation
- Import `package:url_launcher/url_launcher.dart`.
- Import `../../../../core/data/graphql/url_resolver.dart`.
- Add a `_downloadImage` method to `_ImageFullscreenPageState`.
- Update the `build` method to include the new button and update the slideshow button style.

## Testing Strategy
- Manual verification:
  - Open an image in fullscreen.
  - Verify the new download button is present and styled correctly.
  - Verify the slideshow button style is updated.
  - Click the download button and verify it opens the correct image URL in the system browser.
  - Verify the image is accessible in the browser (authenticated via `apikey`).
