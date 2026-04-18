
## 2024-05-28 - [Sync Deduplication in Flutter build()]
**Learning:** Performing deduplication *after* an async task within a Flutter `build` method is a performance trap. If a widget rebuilds rapidly (e.g., during scrolling), the async task won't complete before the next `build` fires, bypassing the deduplication check and spawning dozens of redundant async file system checks and network requests.
**Action:** Always maintain a synchronous `Set` of started/completed tasks to check *before* initiating expensive async operations or scheduling `addPostFrameCallback` from within `build()`.

## 2024-05-29 - [Hoist Invariant Layout Calculations from itemBuilder]
**Learning:** Performing invariant layout calculations (e.g., `MediaQuery.sizeOf(context)` or creating grid delegates) inside Flutter's `ListView.builder` or `GridView.builder` `itemBuilder` callbacks is an O(N) operation that applies significant GC pressure during scrolling.
**Action:** Always hoist invariant variables and layout calculations out of `itemBuilder` loops up to the `build` method.
## 2024-05-30 - [Hoist Invariant Calculations from SliverMasonryGrid itemBuilder]
**Learning:** Just like with ListView.builder, performing invariant calculations like MediaQuery.sizeOf(context) inside SliverMasonryGrid.count's itemBuilder causes an O(N) performance bottleneck during fast scroll events due to continuous redundant math operations and inherited widget lookups.
**Action:** Always hoist invariant layout variables out of the itemBuilder and into the parent build method to ensure O(1) performance.
