# Design Spec: Save to Gallery with Gal

## Overview
Replace the "Open in Browser" download feature with a direct "Save to Gallery" feature for images. This will use the `gal` package to integrate with the system's photo library.

## User Interface
- **Button:** Keep the existing download button in `image_fullscreen_page.dart`.
- **Feedback:** 
  - Show a "Saving..." indicator or SnackBar.
  - Show "Saved to Gallery" SnackBar upon success.
  - Show error SnackBar upon failure.

## Data & Logic
- **Dependency:** Add `gal` package.
- **Authentication:** Use existing `mediaHeadersProvider` to fetch the image bytes via `dio`. This ensures images behind auth can be downloaded.
- **Process:**
  1. Resolve image URL.
  2. Get auth headers.
  3. Download image to a temporary file using `dio`.
  4. Check/Request gallery access permissions using `Gal`.
  5. Save the temporary file to the gallery using `Gal.putImage`.
  6. Delete the temporary file.

## Technical Implementation
- **Files to Modify:**
  - `pubspec.yaml`: Add `gal`.
  - `android/app/src/main/AndroidManifest.xml`: Add permissions and `requestLegacyExternalStorage`.
  - `lib/features/images/presentation/pages/image_fullscreen_page.dart`: Update `_downloadImage` (rename to `_saveImageToGallery`).

## Testing Strategy
- **Manual Verification:**
  - Click the download button on an image.
  - Check system notification/gallery for the saved image.
  - Verify it works for both authenticated and non-authenticated images.
  - Verify permission request pop-up appears on first use (Android).
