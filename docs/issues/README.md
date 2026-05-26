# StashFlow Issue Review

## Project Overview
StashFlow is a Flutter client for a Stash server, with a separate Go backend checked into the same repository under `stash/`. The app is organized around `lib/core` infrastructure and feature modules under `lib/features`, with heavy use of Riverpod, GoRouter, GraphQL code generation, media playback, and local persistence.

## Analyzed Components
- `core` infrastructure
- `navigation` shell and routing
- `scenes` browsing and playback
- `images` fullscreen and gallery workflows
- `setup` server/profile/settings flows
- `entity-browsing` repositories and list pages for performers, studios, tags, galleries, and groups
- `backend` Go server and API middleware
- `tests` coverage and regression gaps

## Severity Summary
- High: authentication/session handling, server exposure, error propagation, and setup flow reliability
- Medium: playback lifecycle, performance, navigation heuristics, and duplicated repository logic
- Low: dead code and cleanup items that still add maintenance drag

## Prioritized Issue List
1. [backend.md](backend.md) - missing throttling is the highest security risk.
2. [setup.md](setup.md) - server profile editing mixes async state changes with unlocalized copy and fragile persistence.
3. [core.md](core.md) - GraphQL error handling and startup error visibility are too thin for a networked app.
4. [scenes.md](scenes.md) - video playback owns local resources that need tighter lifecycle management.
5. [navigation.md](navigation.md) - fullscreen and routing behavior are coupled to path-string heuristics and dead redirect code.
6. [tests.md](tests.md) - the suite is broad, but the highest-risk failure paths still lack direct coverage.

## Component Files
- [core.md](core.md)
- [navigation.md](navigation.md)
- [scenes.md](scenes.md)
- [images.md](images.md)
- [setup.md](setup.md)
- [entity-browsing.md](entity-browsing.md)
- [backend.md](backend.md)
- [tests.md](tests.md)
