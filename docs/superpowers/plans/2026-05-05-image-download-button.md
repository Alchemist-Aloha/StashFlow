# Image Download Button Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a download button to the image fullscreen view that opens the authenticated image URL in the system's default browser.

**Architecture:** Add a new `IconButton` to the `ImageFullscreenPage` overlay. Implement a `_downloadImage` method that constructs an authenticated URL using the `apikey` fallback and launches it via `url_launcher`. Update the existing slideshow button to use the same `filledTonal` style.

**Tech Stack:** Flutter, Riverpod, url_launcher.

---

### Task 1: Setup Imports and Logic

**Files:**
- Modify: `lib/features/images/presentation/pages/image_fullscreen_page.dart`

- [ ] **Step 1: Add necessary imports**

```dart
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
```

- [ ] **Step 2: Implement `_downloadImage` method**

Add this method to `_ImageFullscreenPageState`:

```dart
  Future<void> _downloadImage(entity.Image? image) async {
    if (image == null) return;

    final imageUrl = image.paths.image ?? image.paths.preview;
    if (imageUrl == null || imageUrl.isEmpty) return;

    final authState = ref.read(authProvider);
    final apiKey = ref.read(serverApiKeyProvider);
    final graphqlEndpoint = Uri.parse(ref.read(serverUrlProvider));

    final authenticatedUrl = applyWebMediaAuthFallback(
      url: imageUrl,
      authMode: authState.mode,
      apiKey: apiKey,
      username: authState.username,
      password: authState.password,
      graphqlEndpoint: graphqlEndpoint,
    );

    final uri = Uri.tryParse(authenticatedUrl);
    if (uri == null) return;

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.common_error(e.toString()))),
        );
      }
    }
  }
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/images/presentation/pages/image_fullscreen_page.dart
git commit -m "feat(images): add _downloadImage logic to ImageFullscreenPage"
```

### Task 2: Update UI Components

**Files:**
- Modify: `lib/features/images/presentation/pages/image_fullscreen_page.dart`

- [ ] **Step 1: Update Slideshow button style and add Download button**

Locate the slideshow button (around line 669) and update it, then add the download button next to it.

```dart
                          IconButton.filledTonal(
                            icon: const Icon(Icons.download_rounded),
                            onPressed: currentImage == null
                                ? null
                                : () => _downloadImage(currentImage),
                            tooltip: context.l10n.common_download,
                          ),
                          SizedBox(width: context.dimensions.spacingSmall),
                          IconButton.filledTonal(
                            icon: Icon(
                              _isSlideshowPlaying
                                  ? Icons.stop_rounded
                                  : Icons.slideshow_rounded,
                            ),
                            onPressed: () => _toggleSlideshow(loadedItemCount),
                            tooltip: _isSlideshowPlaying
                                ? context.l10n.common_pause
                                : context.l10n.images_slideshow_start_title,
                          ),
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/images/presentation/pages/image_fullscreen_page.dart
git commit -m "feat(images): add download button and update slideshow button style"
```

### Task 3: Verification

- [ ] **Step 1: Verify the build passes**

Run: `flutter build web` (or any other platform) to ensure no compilation errors.

- [ ] **Step 2: Manual verification instructions**

1. Launch the app.
2. Navigate to an image and open it in fullscreen.
3. Verify the new Download button (icon: `download_rounded`) is visible.
4. Verify both Download and Slideshow buttons use the `filledTonal` style.
5. Click the Download button.
6. Verify the system browser opens with the image URL.
7. Verify the URL contains the `apikey` if authenticated.
