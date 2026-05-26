# Images

This component covers gallery browsing, fullscreen image viewing, slideshow controls, save-to-gallery workflows, and image-specific pagination and prefetching.

## Issue: Saving an image buffers the entire response before permission checks

**Severity:** Medium  
**Category:** Performance  
**Location:** `lib/features/images/presentation/pages/image_fullscreen_page.dart`  
**Status:** Open

### Description
The save flow downloads the full image into memory and only then checks gallery access on non-Linux platforms. That order is expensive when permissions are denied or when the asset is large.

### Evidence
`_saveImageToGallery()` uses `Dio().get<List<int>>()` to fetch the full response bytes, writes them to a temp file, and only then calls `Gal.hasAccess()` / `Gal.requestAccess()`. Similar video-save code in scenes follows the same general pattern.

### Impact
Denied-permission cases still pay the network and memory cost of the full download. Large images can also spike memory because the entire body is buffered before being written out.

### Suggested Fix
Request gallery permission before downloading and prefer streaming to disk when possible. Keep temp-file creation after the access check so rejected saves do not do unnecessary work.

### Validation
Deny gallery permission and confirm no download occurs, then save a large image and confirm memory stays bounded.

## Issue: Adjacent image prefetching can overheat the cache

**Severity:** Medium  
**Category:** Performance  
**Location:** `lib/features/images/presentation/pages/image_fullscreen_page.dart`  
**Status:** Open

### Description
Every page change eagerly precaches the next two and previous one image. That is a useful UX optimization, but it has no visible budgeting or throttling.

### Evidence
`_prefetchAdjacent()` calls `precacheImage()` multiple times on every navigation event using the same cache-backed network provider. There is no adaptive limit for device memory or gallery size.

### Impact
High-resolution galleries can churn the image cache and cause memory spikes during fast swipes. On lower-end devices that can translate into jank or background eviction of useful resources.

### Suggested Fix
Add a small prefetch budget and throttle prefetch frequency based on viewport size or device memory class. Keep the optimization, but make it adaptive.

### Validation
Swipe quickly through a large gallery while monitoring memory and confirm the cache does not balloon unexpectedly.

## Issue: Gallery rating target lookup repeats network work in the dialog

**Severity:** Low  
**Category:** Maintainability  
**Location:** `lib/features/images/presentation/pages/image_fullscreen_page.dart`  
**Status:** Open

### Description
When the rating dialog switches to gallery mode, it fetches the gallery again to populate the slider. That fetch can happen multiple times during a single dialog session.

### Evidence
`_showRatingDialog()` loads the gallery rating when the target changes to gallery and repeats that logic on each selection change. The dialog does not reuse a cached gallery snapshot.

### Impact
Repeated fetches add latency and make a simple rating interaction feel heavier than it needs to be. They also make the dialog code harder to reason about because state is split between the modal and repository calls.

### Suggested Fix
Pass the gallery snapshot into the fullscreen page or cache the gallery rating in provider state before opening the dialog.

### Validation
Switch targets repeatedly inside the dialog and verify the gallery is not refetched each time.
