# Entity Browsing

This component covers performers, studios, tags, galleries, and groups. The codebase repeats a lot of the same repository, filter, card, and list-page patterns across those entities.

## Issue: GraphQL repositories duplicate almost the same filter and sort wiring

**Severity:** Medium  
**Category:** Maintainability  
**Location:** `lib/features/performers/data/repositories/graphql_performer_repository.dart`, `lib/features/studios/data/repositories/graphql_studio_repository.dart`, `lib/features/galleries/data/repositories/graphql_gallery_repository.dart`, `lib/features/tags/data/repositories/graphql_tag_repository.dart`, `lib/features/groups/data/repositories/graphql_group_repository.dart`  
**Status:** Open

### Description
Each repository rebuilds nearly identical `Input$FindFilterType` and entity-specific filter translation logic. The only real differences are the entity fields and a few sort aliases.

### Evidence
The performer, studio, and gallery repositories all normalize sort names, build GraphQL filter inputs, retry old sort names, and then map generated GraphQL nodes into domain models. Tags and groups follow the same general pattern in their own modules.

### Impact
Any filter or sort behavior change has to be copied across several files, which increases divergence and bug risk. The code is also hard to audit because the same logic is spread across multiple almost-identical implementations.

### Suggested Fix
Extract shared query-builder helpers for sort normalization, error fallback, and criterion mapping. Keep entity-specific mapping small and declarative.

### Validation
Change one shared fallback or filter helper and confirm all entity pages pick up the behavior without copy-pasted updates.

## Issue: GraphQL endpoint fallbacks are inconsistent across repositories

**Severity:** Medium  
**Category:** Bug  
**Location:** entity repositories in `lib/features/*/data/repositories/`  
**Status:** Open

### Description
The repository helpers use different fallback endpoints when the client link is not an `HttpLink`. One repo falls back to `https://localhost/graphql`, another to `http://localhost:9999/graphql`.

### Evidence
`GraphQLPerformerRepository` and `GraphQLSceneRepository` default to an `https://localhost/graphql` parse fallback, while `GraphQLStudioRepository` uses `http://localhost:9999/graphql`. That inconsistency exists even though all of these repositories are meant to resolve media URLs in the same app.

### Impact
Media URL resolution can behave differently by feature and can hide bad configuration behind a localhost fallback. That makes environment-specific failures much harder to track down.

### Suggested Fix
Move endpoint resolution into a single shared helper or the GraphQL client itself and use one canonical fallback. Make the fallback explicit in tests so a bad client link is obvious.

### Validation
Run each entity page against a configured server and confirm the resolved media URLs all point to the same canonical endpoint behavior.

## Issue: Backend sort drift is masked by local retry logic

**Severity:** Low  
**Category:** Testing  
**Location:** entity repositories in `lib/features/*/data/repositories/`  
**Status:** Open

### Description
Several repositories retry around renamed sorts such as `scene_count`, `scenes_count`, and `rating100`, then silently fall back to local sorting if the server still rejects them. That keeps the UI working, but it also hides contract drift.

### Evidence
The performer, studio, and scene repositories all contain fallback blocks that inspect GraphQL error strings, retry with an alternate field name, or sort locally after a failed query.

### Impact
A schema mismatch can remain invisible in production because the app auto-recovers instead of reporting the mismatch. That makes backend regressions more likely to survive until users notice subtle ordering differences.

### Suggested Fix
Keep the fallback for compatibility, but emit a structured warning or telemetry event whenever it is used. This preserves behavior while making schema drift visible.

### Validation
Mock a rejected sort name and confirm the fallback path is recorded and test-covered.
