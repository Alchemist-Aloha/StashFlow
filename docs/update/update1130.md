**Update 1.13.0 — Summary of changes since v1.12.0**

Release date: 2026-04-25

**Release Summary**

- **Scope**: Fixes and quality-of-life improvements for masonry grid thumbnails, scene details modal layout, and scene scrubber gestures. Several provider and utility improvements to ensure accurate thumbnail aspect ratios and robust sprite (VTT) handling.

**Highlights**

- **Masonry thumbnails:** Grid views that use masonry layout now show correct, variable-height thumbnails based on the underlying media's intrinsic width/height instead of a fixed 16:9 crop. This fixes inconsistent sizing across performer, studio, and tag media and gallery lists.
- **Scene details:** The scene details sheet (three-dots -> details) no longer leaves a large blank area. The sheet is now rendered with a bottom-sheet-friendly layout.
- **Scrubbing / gestures:** Scene thumbnail scrubbing now validates sprite (VTT) data before enabling scrub gestures. Pan/drag handling was replaced with horizontal-drag handlers and is gated by a tri-state sprite validity check to avoid interfering with vertical page scroll.

**Notable Fixes**

- **Correct aspect ratio propagation:** Provider mappings for media and galleries were updated to include `width` and `height` from GraphQL models so UI cards can compute `aspectRatio = width / height` for masonry layouts.
- **VTT/sprite resilience:** Added a caching VTT fetch-and-parse utility and improved validation to detect invalid or placeholder sprite assets and avoid enabling scrubbing when sprites are unusable.
- **Gesture interference resolved:** Replaced generic pan handlers with focused horizontal drag handlers and only enable them when validated sprite metadata exists, preventing accidental capture of vertical scroll gestures.

**Internal / Developer Changes**

- Grid card presentation now supports masonry-aware aspect ratios (limits applied to avoid extreme aspect values).
- New utility for fetching and parsing VTT sprite files with caching and robust fallbacks.
- Pages that use `GridCard` now compute and pass `aspectRatio` when masonry is enabled.

**Files changed (key items)**

- **Grid / UI:** [lib/core/presentation/widgets/grid_card.dart](lib/core/presentation/widgets/grid_card.dart)
- **Scene details / sheet:** [lib/features/scenes/presentation/pages/scene_info_page.dart](lib/features/scenes/presentation/pages/scene_info_page.dart)
- **Scene card / scrubber:** [lib/features/scenes/presentation/widgets/scene_card.dart](lib/features/scenes/presentation/widgets/scene_card.dart)
- **VTT utilities:** [lib/core/utils/vtt_service.dart](lib/core/utils/vtt_service.dart)
- **Providers (width/height mapping):**
  - [lib/features/performers/presentation/providers/performer_media_provider.dart](lib/features/performers/presentation/providers/performer_media_provider.dart)
  - [lib/features/performers/presentation/providers/performer_galleries_provider.dart](lib/features/performers/presentation/providers/performer_galleries_provider.dart)
  - [lib/features/studios/presentation/providers/studio_media_provider.dart](lib/features/studios/presentation/providers/studio_media_provider.dart)
  - [lib/features/studios/presentation/providers/studio_galleries_provider.dart](lib/features/studios/presentation/providers/studio_galleries_provider.dart)
  - [lib/features/tags/presentation/providers/tag_media_provider.dart](lib/features/tags/presentation/providers/tag_media_provider.dart)
  - [lib/features/tags/presentation/providers/tag_galleries_provider.dart](lib/features/tags/presentation/providers/tag_galleries_provider.dart)

**Upgrade / Migration Notes**

- No breaking API changes. The changes are internal and focused on presentation and data mapping. If you have any custom code that constructed media/gallery items manually, ensure your item objects provide `width` and `height` where available so `GridCard` can compute correct masonry aspect ratios.

