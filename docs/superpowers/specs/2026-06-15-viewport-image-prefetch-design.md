# Viewport Image Prefetch Design

## Problem

Page grids currently schedule image work twice:

- `ListPageScaffold` manually calculates visible indices and calls
  `StashImage.prefetch`.
- Every `StashImage` performs another post-frame cache check and prefetch.

The item-based calculations are expensive, use a fixed minimum of 40 items,
and approximate masonry layouts using one measured item height.

## Design

- Use each vertical scrollable's pixel-based `cacheExtent` as the only
  page-level preloading mechanism.
- Set the extent to one viewport height.
- Let `ListView`, `GridView`, and `MasonryGridView` build children in that
  region. Each built `StashImage` then loads normally through
  `CachedNetworkImageProvider`.
- Grid density is handled by layout: more columns naturally build more items
  inside the same pixel extent.
- Keep `memCacheWidth` sizing based on the active grid column count.
- Remove page-level index tracking and explicit image prefetch loops.
- Remove `StashImage`'s automatic post-frame prefetch. Keep corrupt cached-file
  recovery in the image loading retry path.
- Preserve explicit prefetching for independent horizontal strips.
- Keep backend pagination independent from image preloading. Page-size
  calculation may still use responsive item capacity, but must not schedule
  image requests.

## Verification

- Page list, fixed grid, and masonry grid expose a one-viewport `cacheExtent`.
- A denser fixed grid builds more cached-ahead children for the same viewport.
- Page scaffolds no longer call `StashImage.prefetch`.
- `StashImage` no longer schedules its own post-frame prefetch.
- Horizontal strip prefetch behavior remains unchanged.
