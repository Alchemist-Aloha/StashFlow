# Plan

- Add avif support
- Add previous, next video navigation for cast player
- the scene card still show current time after dragging before the check of the VTT finished. After the check the drag will not work. change this behavior to make sure the current time only change after the VTT is verified.
- End cast when close the miniplayer sometime doesn't work, need to investigate and fix it.


Startup is blocked by too much initialization. [main.dart (line 39)](/home/likun/StashFlow/lib/main.dart:39) waits for window setup, temporary storage, Hive, AudioService, preferences, and credential migration before runApp(). Lazy-load audio and defer nonessential desktop/cache work until after the first frame.

Credentials can trigger duplicate startup requests. [auth_provider.dart (line 79)](/home/likun/StashFlow/lib/core/data/auth/auth_provider.dart:79) initially exposes empty credentials while secure storage hydrates asynchronously. [graphql_client.dart (line 65)](/home/likun/StashFlow/lib/core/data/graphql/graphql_client.dart:65) can therefore construct a client and load scenes before valid credentials arrive. Gate the GraphQL client behind one asynchronous credentials bootstrap provider.


Image prefetching is excessive and duplicated. [list_page_scaffold.dart (line 255)](/home/likun/StashFlow/lib/core/presentation/widgets/list_page_scaffold.dart:255) prefetches at least 40 items in both directions, while [stash_image.dart (line 333)](/home/likun/StashFlow/lib/core/presentation/widgets/stash_image.dart:333) also schedules per-image prefetching. Use one directional prefetch coordinator, approximately one viewport ahead, with a bounded priority queue.

Viewport calculation can cause a second initial fetch. The scaffold computes a page size after the first frame and calls setPerPage, which invalidates list providers. Keep backend page size stable and separate it from image prefetch distance.

Scene cards have confirmed responsive-layout problems. [scene_card.dart (line 542)](/home/likun/StashFlow/lib/features/scenes/presentation/widgets/scene_card.dart:542) overflowed at multiple mobile widths during tests. This can also increase repeated layout work.

There are redundant repaint boundaries. List/grid builders already add repaint boundaries, while the scaffold and SceneCard add more manually. Profile the layer tree and retain only one boundary per expensive card.
