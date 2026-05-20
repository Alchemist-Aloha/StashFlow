
## 2024-05-28 - [Sync Deduplication in Flutter build()]
**Learning:** Performing deduplication *after* an async task within a Flutter `build` method is a performance trap. If a widget rebuilds rapidly (e.g., during scrolling), the async task won't complete before the next `build` fires, bypassing the deduplication check and spawning dozens of redundant async file system checks and network requests.
**Action:** Always maintain a synchronous `Set` of started/completed tasks to check *before* initiating expensive async operations or scheduling `addPostFrameCallback` from within `build()`.

## 2024-05-29 - [Hoist Invariant Layout Calculations from itemBuilder]
**Learning:** Performing invariant layout calculations (e.g., `MediaQuery.sizeOf(context)` or creating grid delegates) inside Flutter's `ListView.builder` or `GridView.builder` `itemBuilder` callbacks is an O(N) operation that applies significant GC pressure during scrolling.
**Action:** Always hoist invariant variables and layout calculations out of `itemBuilder` loops up to the `build` method.
## 2024-05-30 - [Hoist Invariant Calculations from SliverMasonryGrid itemBuilder]
**Learning:** Just like with ListView.builder, performing invariant calculations like MediaQuery.sizeOf(context) inside SliverMasonryGrid.count's itemBuilder causes an O(N) performance bottleneck during fast scroll events due to continuous redundant math operations and inherited widget lookups.
**Action:** Always hoist invariant layout variables out of the itemBuilder and into the parent build method to ensure O(1) performance.

## 2024-05-31 - [MediaQuery Rebuild Optimization]
**Learning:** Using `MediaQuery.of(context).size` binds the widget to the entire `MediaQueryData` object, triggering an unnecessary rebuild whenever any unrelated property changes (like the keyboard appearing/disappearing or text scaling updates).
**Action:** Always use granular MediaQuery methods like `MediaQuery.sizeOf(context)`, `MediaQuery.paddingOf(context)`, etc. to isolate dependencies to only the properties the widget actually uses.

## 2024-06-25 - [O(N^2) Scroll Stutter via itemBuilder lookups]
**Learning:** Performing an `O(N)` list scan like `indexWhere` inside a Flutter `itemBuilder` callback causes massive O(N^2) scaling issues when the user scrolls through long lists. Similarly, evaluating fallbacks like `images ?? []` repeatedly causes needless GC pressure.
**Action:** Always pre-compute a lookup map (like `{for (var i=0; i<list.length; i++) list[i].id: i}`) in the parent `build` method before passing data to `itemBuilder`, ensuring O(1) lookups during the render phase. Hoist all possible allocations out of the builder.
## 2024-07-25 - [MediaQuery.of(context) Over-Rebuilding]
**Learning:** Using `MediaQuery.of(context).viewInsets` binds the widget to the entire `MediaQueryData` object, triggering an unnecessary rebuild whenever any unrelated property changes (like screen size or orientation).
**Action:** Always use granular MediaQuery methods like `MediaQuery.viewInsetsOf(context)` to isolate dependencies to only the properties the widget actually uses.

## 2024-08-01 - [MediaQuery.of(context) Over-Rebuilding in Padding]
**Learning:** Using `MediaQuery.of(context).padding.bottom` binds the widget to the entire `MediaQueryData` object, triggering an unnecessary rebuild whenever any unrelated property changes (like text scale factor, orientation, screen size).
**Action:** Always use granular MediaQuery methods like `MediaQuery.paddingOf(context).bottom` to isolate dependencies to only the properties the widget actually uses.

## 2024-05-30 - [Hoist MediaQuery & Delegates from Scroll Handlers]
**Learning:** Querying `MediaQuery.sizeOf(context)` or recalculating `SliverGridDelegate` inside `NotificationListener<ScrollNotification>` callbacks or list `builder` methods forces the framework to perform redundant O(1) inherited widget lookups and layout math on every single frame during a scroll event.
**Action:** Always hoist `screenWidth`, `isGrid`, and delegate calculations to the very top of the `build` method, caching them into local variables. Then pass these cached variables down into your scroll handlers (like `_handleScrollPrefetch`) or builder methods to guarantee O(1) performance and reduce GC pressure during rapid scrolling.
## 2026-05-06 - [Avoid Recomputing Layout Dimensions Inside Scroll Listeners]
**Learning:** In Flutter, `NotificationListener<ScrollNotification>` callbacks fire frequently during scrolling (up to 120 times per second). Querying `context.dimensions` or computing spacing boundaries dynamically within the `onNotification` callback triggers unnecessary layout math calculations and inherited widget lookups on every frame tick, degrading scroll performance.
**Action:** Always hoist invariant layout calculations, theme lookups, and boundary definitions (like `stride`, `contentPadding`, and `separatorWidth`) to the outer `build` scope before initializing the `NotificationListener`. Pass these precomputed primitives into the closure.
\n## 2026-05-06 - [Parallelize Independent Async Persistence]\n**Learning:** When a widget configuration panel dispatches multiple independent persistence operations (e.g., sequentially `await`ing multiple Riverpod Notifier `saveAsDefault` state updates that write to SharedPreferences), it needlessly blocks the UI thread for the sum of the durations of each operation. \n**Action:** Use `Future.wait([...])` to execute independent async persistence operations concurrently, cutting down wait time to the duration of the slowest operation and improving perceived UI responsiveness.
