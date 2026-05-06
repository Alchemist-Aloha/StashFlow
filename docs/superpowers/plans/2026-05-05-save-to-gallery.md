# Save to Gallery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement direct "Save to Gallery" for images using the `gal` package.

**Architecture:** Use `dio` for authenticated download to temp storage, then `gal` for system gallery integration.

**Tech Stack:** Flutter, gal, dio, path_provider.

---

### Task 1: Project Setup

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add `gal` dependency**

```yaml
dependencies:
  gal: ^2.5.0
```

- [ ] **Step 2: Run `flutter pub get`**

- [ ] **Step 3: Update Android permissions**

In `android/app/src/main/AndroidManifest.xml`:
- Add `WRITE_EXTERNAL_STORAGE` permission.
- Add `android:requestLegacyExternalStorage="true"` to `<application>`.

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                 android:maxSdkVersion="29" />

<application
    ...
    android:requestLegacyExternalStorage="true">
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml android/app/src/main/AndroidManifest.xml
git commit -m "chore: add gal dependency and android permissions"
```

### Task 2: Implement Save Logic

**Files:**
- Modify: `lib/features/images/presentation/pages/image_fullscreen_page.dart`

- [ ] **Step 1: Update imports**

```dart
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
```

- [ ] **Step 2: Implement `_saveImageToGallery` method**

Replace `_downloadImage` with this new implementation.

```dart
  Future<void> _saveImageToGallery(entity.Image? image) async {
    if (image == null) return;

    final imageUrl = image.paths.image ?? image.paths.preview;
    if (imageUrl == null || imageUrl.isEmpty) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving to gallery...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final headers = ref.read(mediaHeadersProvider);
      final tempDir = await getTemporaryDirectory();
      // Extract extension or default to jpg
      final extension = imageUrl.split('.').last.split('?').first;
      final fileName = '${image.id}.$extension';
      final tempPath = '${tempDir.path}/$fileName';

      await Dio().download(
        imageUrl,
        tempPath,
        options: Options(headers: headers),
      );

      // Check for access
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (hasAccess) {
        await Gal.putImage(tempPath);
        
        // Cleanup
        final file = File(tempPath);
        if (await file.exists()) {
          await file.delete();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to gallery')),
          );
        }
      } else {
        throw Exception('Gallery access denied');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    }
  }
```

- [ ] **Step 3: Update UI button call**

Change the `onPressed` to call `_saveImageToGallery`.

- [ ] **Step 4: Commit**

```bash
git add lib/features/images/presentation/pages/image_fullscreen_page.dart
git commit -m "feat(images): implement direct save to gallery using gal"
```

### Task 3: Verification

- [ ] **Step 1: Build the app**

Run: `flutter build apk --debug`

- [ ] **Step 2: Manual verification on device**

1. Open an image in fullscreen.
2. Click the download button.
3. Verify "Saving to gallery..." snackbar.
4. Verify "Saved to gallery" snackbar.
5. Check the system gallery for the new image.
