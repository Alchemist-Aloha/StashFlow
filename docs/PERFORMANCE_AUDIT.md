# Performance Audit — CPU & Memory Usage of UI Pages

**Date:** 2026-09-02
**Branch:** `dev`
**Builds audited:** Linux desktop, debug (`flutter run -d linux --debug`) and profile
(`flutter run -d linux --profile`)
**App version:** 1.32.0+104 (Flutter 3.47.2 / Dart 3.13.2)

---

## 1. Scope & Method

Goal: audit CPU and memory usage of the main UI pages and surface potential
performance bugs/bottlenecks.

How it was done:

1. Ran the real app against the configured Stash server (`stash.cai.co.im`,
   authenticated with the stored profile) on the Linux desktop device.
2. Forced the GTK window onto XWayland (`GDK_BACKEND=x11`) so it could be
   driven headlessly:
   - tab switching via the app's global key binds (`Ctrl+1..5`)
   - grid scrolling via synthetic X11 wheel events
   - state verification via window screenshots
3. Sampled:
   - **CPU** — `utime+stime` deltas from `/proc/<pid>/stat`
   - **RSS memory** — `VmRSS` from `/proc/<pid>/status` (+ `RssAnon/RssFile/RssShmem`)
   - **Dart heap** — VM service `getAllocationProfile.memoryUsage.heapUsage`
4. Cross-checked findings against the source (grid type, image decode sizing,
   cache limits, shell routing, image retry logic).

The per-tab "scroll burst" workload = **80 wheel events in ≈ 3.4 s** over the
grid center, after letting each page load.

---

## 2. Environment caveats (important)

- **Debug build** numbers are pessimistic (JIT, no AOT, unchecked debug
  allocations, larger Dart heap). Always re-check the important signals in a
  **profile** build (see §5).
- This machine has **no usable GPU/EGL for video**: `media_kit` logged
  `VideoOutput: EGL display or context is invalid. VideoOutput: S/W rendering.`
  Video decode/playback CPU is therefore inflated on this box.
- The shell uses `StatefulShellRoute.indexedStack`, so **all visited tabs stay
  alive**; RSS is cumulative across the walk (mirrors real usage).

---

## 3. Debug-build results

Fresh-restart baseline (Scenes loaded): **RSS ≈ 1,040 MB**, Dart heap ≈ 190 MB,
`RssAnon ≈ 720 MB`, `RssFile ≈ 230 MB`, `RssShmem ≈ 110 MB`.

| Page | Grid type | Idle CPU | Burst CPU | Burst cpu-ms | RSS before→after | RSS Δ |
|---|---|---|---|---|---|---|
| Scenes | Masonry | 0% | **136%** | 4,570 | 998→1,032 MB | **+33 MB** |
| Performers | Grid (fixed) | 0% | **120%** | 4,040 | ~1,057 MB | ~0 |
| Galleries | Masonry | ~0% | **120%** | 4,010 | 1,077→1,084 MB | +6 MB |
| Studios | List/grid (light) | 0% | 44% | 1,560 | ~1,064 MB | −2 |
| Tags | List (light) | 0% | 44% | 1,550 | ~1,066 MB | +8 MB |
| SceneDetails (video playing) | — | **~45–50% sustained** | — | — | **→ ~1.44 GB** | — |

Scenes scroll-cycle test (repeat down/up over same content): RSS crept
**1,040 → ~1,138 MB**; Dart heap 188→202 MB.

---

## 4. Profile-build results (comparison)

Fresh-restart baseline (Scenes loaded): **RSS ≈ 443 MB**, Dart heap ≈ 49 MB,
`RssAnon ≈ 375 MB`, `RssFile ≈ 225 MB`, `RssShmem ≈ 1 MB` (no video played).

| Page | Idle CPU | Burst CPU | Burst cpu-ms | RSS before→after | RSS Δ |
|---|---|---|---|---|---|
| Scenes | 0% | **86%** | 2,950 | 452→487 MB | +35 MB |
| Performers | 0% | **87%** | 3,000 | 512→527 MB | +16 MB |
| Galleries | ~0% | **79%** | 2,680 | 565→583 MB | +19 MB |
| Studios | 0% | 33% | 1,150 | 526→532 MB | +6 MB |
| Tags | 0% | 31% | 1,110 | 535→545 MB | +10 MB |
| Walk-end total RSS | | | | **~583 MB** | |

Scenes scroll-cycle test in profile: RSS **578 → 716 MB** across cycles while
**Dart heap stayed flat (~87–100 MB)** → the creep is native/engine memory
(decoded images / Impeller), not a Dart leak.

### Debug vs profile summary

| Page | Burst CPU debug | Burst CPU profile | Walk RSS debug | Walk RSS profile |
|---|---|---|---|---|
| Scenes | 136% | 86% | ~1,084 MB (end) | **~583 MB (end)** |
| Performers | 120% | 87% | | |
| Galleries | 120% | 79% | | |
| Studios | 44% | 33% | | |
| Tags | 44% | 31% | | |

Key takeaways from the comparison:

- **CPU ranking is identical in both builds** — image-heavy grids
  (Scenes/Performers/Galleries) are the hot pages; Studios/Tags are ~3× cheaper.
  AOT lowers burst CPU ~30% but Scenes/Performers/Galleries still reach
  **~80–87% of one core** on fast scroll → jank risk is real in production-like
  builds, not a debug artifact.
- **Total memory is ~halved in profile** (443 MB baseline / 583 MB walk-end vs
  1,040 / 1,084 MB), so the headline debug footprint was mostly debug overhead.
- **Per-scroll RSS growth did not shrink with AOT** (Scenes +35 MB in both
  builds) — decode-into-image-cache growth is inherent.

---

## 5. Findings & potential performance bugs

### F1 — Native memory grows while paging/scrolling (no Dart leak)
- Evidence: repeated full-range scrolling over the same content grows RSS
  (~+100–140 MB across cycles) in **both** debug and profile; Dart heap stays
  flat in profile. Cumulative memory also rises as each shell tab is opened
  (`indexedStack` keeps every branch alive).
- Code contributors:
  - `lib/main.dart` — `imageCache.maximumSize = 500`,
    `maximumSizeBytes = 200 MB` (large decoded-image budget).
  - `router.dart` — `StatefulShellRoute.indexedStack` keeps all tab grids
    mounted (lists, scroll positions, decoded images retained).
  - Default **`random`** sort (Scenes/Galleries prefs): each deep scroll fetches a
    fresh random page whose items are retained forever, so scrolling rarely
    reuses previously decoded/cached work → churn.
- Action: profile native memory in DevTools (Impeller surfaces / image cache);
  confirm the creep plateaus vs. grows unboundedly with total item count.

### F2 — Scroll CPU / jank on image-heavy grids
- Evidence: Scenes/Performers/Galleries hit 120–136% (debug) / 79–87% (profile)
  of one core per scroll burst.
- Code contributors:
  - Scenes, Galleries, Images, Markers render with **`MasonryGridView.builder`**
    (variable item heights → relayout on every scroll).
  - `lib/core/presentation/widgets/list_page_scaffold.dart` builds
    **2 extra viewports ahead** (`ScrollCacheExtent.viewport(2.0)`) for grids and
    lists; masonry adds a full-viewport `cacheExtent`.
  - Each card is a `ConsumerStatefulWidget` wrapping `CachedNetworkImage`
    (decode on the UI thread in debug).
- Action: measure frame timeline in DevTools; try uniform `GridView` + fixed
  aspect ratios, reduce cache extents to ~1 viewport, confirm frame budget.

### F3 — `memCacheWidth` hard-coded ×2 instead of DPR-aware
- Evidence: `scenes_page.dart` uses `memCacheWidth = (itemWidth * 2).toInt()`;
  `list_page_scaffold.dart` fallback uses `* 1.5`.
- Impact: on DPR-1 desktops each thumbnail decodes at ~2× display size
  (~4× pixels), inflating **image-cache memory** (F1).
- Note (measured, §8): making it DPR-aware did **not** reduce scroll CPU in this
  environment — image decoding runs on small worker threads, not the hot UI
  thread. It is still worth doing for the memory saving, not for scroll CPU.
- Fix: `(itemWidth * MediaQuery.devicePixelRatioOf(context)).round()`, capped.

### F4 — Image load errors churn during fast scroll
- Evidence: repeated `Invalid image data` exceptions while scrolling; cards
  stuck on placeholders.
- Code: `lib/core/presentation/widgets/stash_image.dart` `_RetryingCachedImage`
  deletes the cache file and re-downloads on every failed decode (150 ms delay +
  rebuild). Rapid scroll can abort partial downloads → re-download/re-decode
  loops.
- Mitigation (2026-09-04): after the existing two recovery attempts fail,
  retries for that URL are suppressed across card recreation for 30 seconds.
  The back-off table is capped at 256 URLs. Preventing incomplete cache writes
  remains cache-manager work if errors continue after this change.

### F5 — Notes / environment-specific
- SceneDetails with a playing video sustains ~45–50% CPU (this box software-
  decodes video) and pushes session RSS to ~1.4 GB (debug). Background playback
  keeps playing after leaving the page (`video_background_playback: true`) —
  intended, but consider pausing when the page is left on desktop.
- Repeated non-fatal `WakelockPlusLinuxPlugin` DBus errors on entering details
  in this environment.
- Minor UI overflow in `lib/core/presentation/widgets/section_header.dart`
  (`RenderFlex overflowed … 16/57 px`) at 945 px width — not perf.

---

## 6. Recommendations (priority order)

1. Fix **F3** (DPR-aware decode widths) for the **memory** saving; measured it
   does not change scroll CPU in this environment (see §8).
2. Profile **F2** with the DevTools frame timeline on a **GPU-backed** machine;
   under this environment's software rendering, scroll CPU is dominated by
   per-frame build/layout of image cards and did not respond to decode-size or
   cache-extent changes (see §8).
3. Investigate **F1** native growth with a DevTools memory snapshot (impeller /
   image cache) and review the 200 MB image-cache budget and `indexedStack`
   retention for low-memory devices.
4. Recheck image failures after the **F4** retry-storm mitigation; investigate
   incomplete cache writes only if invalid downloads still recur.

---

## 7. How to reproduce

```sh
# Debug
flutter run -d linux --debug
# Profile (realistic numbers)
flutter run -d linux --profile

# Deterministic headless list/grid/masonry regression benchmark
flutter test benchmark/common_surfaces.dart --reporter expanded
```

Drive the UI (5 default tabs via `Ctrl+1..5`, wheel-scroll the grids) while
sampling:

- CPU / RSS: `utime+stime` and `VmRSS` from `/proc/<pid>/{stat,status}`
- Dart heap: VM service `getAllocationProfile.memoryUsage.heapUsage`

Tooling used for this audit (kept outside the repo): an X11 input helper, a
sampling harness, and a minimal Dart VM-service JSON-RPC client
(`/tmp/xctl.py`, `/tmp/measure.py`, `/tmp/vmctl.dart`).

---

## 8. Iterative optimization loop (5-run statistics)

Follow-up experiment (2026-09-02): iterate code changes to reduce scroll CPU,
gating each on a **measured improvement + full test pass** (discard otherwise).

### 8.1 Method (what "the test" is)

- Target: **Scenes grid fast-scroll CPU**, the heaviest page, measured in the
  **profile** build (realistic numbers).
- Each "run" = **fresh app launch** (empty decoded-image cache), let the first
  screen settle, then scroll **104 wheel events** in paced batches (~4.6 s) and
  record **total process CPU (cpu-ms)** used during the burst (`/proc/<pid>`).
- Statistics over **5 runs** per variant (median / mean / stdev).

### 8.2 Baseline (current `dev` code)

| metric | median | mean | stdev | min | max |
|---|---|---|---|---|---|
| burst cpu-ms | **4,040** | 4,088 | 188 | 3,920 | 4,440 |
| burst cpu % (1 core) | 87.8 | 88.4 | 4.2 | 84.8 | 96.3 |
| RSS after (MB) | 521 | 518 | 17 | 485 | 537 |

Idle CPU on every run ≈ 0–1% (no background work).

Thread attribution during the burst: **UI thread ≈ 42%**, raster ≈ 18%,
image-decode IO workers ≈ small (<8%) → the cost is **per-frame Dart
build/layout of newly-entering cards**, not image decoding.

### 8.3 Attempts (all measured; none improved → all discarded per the gate)

| # | Change | cpu-ms median | cpu-ms mean | vs baseline | Result |
|---|---|---|---|---|---|
| 1 | DPR-aware `memCacheWidth` (decode at physical display size instead of fixed ×2/×1.5) | 4,190 | 4,088 | **no change** (decode isn't the bottleneck) | discarded |
| 2 | Reduce scroll cache extents (grid/list 2.0→1.0, masonry full→half viewport) | 4,390 | 4,390 | **+8.7% median (worse); also broke cache-extent contract tests** | discarded |
| 3 | Skip the disabled `Skeletonizer` wrapper for real `SceneCard`s | 4,390 | 4,400 | **+8.7% median (worse)** | discarded |
| 4 | Avoid a duplicate `mediaHeadersProvider` listener in each `SceneCard` | 4,330 | 4,362 | **+7.2% median (worse)** | discarded |
| 5 | Disable automatic keep-alive wrappers for masonry children | 4,360 | 4,312 | **+7.9% median (worse)** | discarded |

Working tree is clean (`dev`); no code committed because no variant produced a
measured CPU improvement while keeping all tests green.

### 8.4 Why the obvious levers didn't help (evidence)

- **Decode size** (attempt 1) is irrelevant to scroll CPU because image-decode
  worker threads are small; the UI thread (build/layout) dominates.
- **Cache extent** (attempt 2) made CPU *worse*: with less pre-built content the
  sliver must lay out items closer to the viewport during active scroll frames.
  The current `ScrollCacheExtent.viewport(2.0)` / full-viewport masonry cache is
  an intentional, test-locked smoothness contract.
- **Masonry vs uniform grid is NOT the driver**: Performers uses a plain uniform
  `GridView` yet measured ≈ the same CPU as masonry Scenes. The cost scales with
  the number of rich image cards materialized per scroll step (Scenes/Performers/
  Galleries have huge libraries; Studios/Tags are ~3× cheaper with fewer items).

### 8.5 Five-run data for attempts 3–5

All three variants passed the focused `SceneCard` and `ListPageScaffold` tests
and produced a Linux profile bundle before measurement. Their code changes
were discarded after the benchmark gate failed.

| Attempt | cpu-ms runs | median | mean | stdev | min | max |
|---|---|---:|---:|---:|---:|---:|
| 3 — skip disabled skeleton wrapper | 4,450, 4,450, 4,370, 4,340, 4,390 | **4,390** | 4,400 | 44 | 4,340 | 4,450 |
| 4 — remove duplicate header listener | 4,460, 4,250, 4,330, 4,440, 4,330 | **4,330** | 4,362 | 78 | 4,250 | 4,460 |
| 5 — disable masonry keep-alives | 4,400, 4,420, 4,080, 4,360, 4,300 | **4,360** | 4,312 | 123 | 4,080 | 4,420 |

| Attempt | CPU % median | CPU % mean | RSS-after median | RSS-after mean | RSS stdev |
|---|---:|---:|---:|---:|---:|
| 3 | 94.8% | 95.2% | 533.0 MB | 523.6 MB | 16.2 MB |
| 4 | 93.5% | 93.9% | 528.6 MB | 530.3 MB | 9.0 MB |
| 5 | 93.8% | 93.2% | 546.8 MB | 541.8 MB | 16.2 MB |

The narrower distributions in attempts 3–5 make the regression signal clearer
than the baseline's 188 cpu-ms standard deviation. None of the refactors
reduced the dominant per-frame card build/layout cost, so the original code was
restored after each measurement.

### 8.6 Final verification

- Full Flutter suite: **606 tests passed** (`flutter test`).
- Android release build: split ABI APKs built successfully for armeabi-v7a,
  arm64-v8a, and x86_64 (`flutter build apk --split-per-abi`).
- No performance code change was retained or committed because every measured
  variant failed the CPU-improvement gate.

### 8.7 Conclusion & recommendation

In this environment (profile AOT, **software rendering — no GPU/EGL**, live
remote server), the measured per-scroll CPU is dominated by per-frame
build/layout of content that is inherent to the app's UX. No appearance-
preserving, test-compatible change reduced it measurably, so **no performance
code was committed** (per the discard-if-not-improved gate).

To actually lower scroll CPU further would require product-level trade-offs,
e.g.:
- reduce per-card cost during scroll (simpler grid cards, less text/image
  chrome), or
- hardware-accelerated GL/Impeller on the target machine (biggest single factor
  for raster + video CPU here), or
- content/paging changes (larger pages, `AutomaticKeepAlive` strategies) —
  each needs maintainer sign-off and re-measuring on a GPU-backed desktop.

The recommended next concrete step remains profiling frame build/raster with
DevTools on a GPU-backed machine, where genuine hotspots (and fixes) will be
far easier to see than under software rendering.

---

## 9. Follow-up optimization pass

Follow-up experiment (2026-09-02): rerun the unchanged baseline to account for
machine/session drift, then evaluate additional changes against that new
baseline using the same five-launch workload from §8.1.

### 9.1 Repeated baseline

| metric | runs | median | mean | stdev | min | max |
|---|---|---:|---:|---:|---:|---:|
| burst cpu-ms | 4,670, 4,640, 4,020, 4,380, 4,410 | **4,410** | 4,424 | 233 | 4,020 | 4,670 |
| burst CPU % | 99.9, 100.6, 86.4, 95.3, 95.7 | **95.7** | 95.6 | 5.1 | 86.4 | 100.6 |
| RSS after (MB) | 525.9, 566.4, 498.8, 534.4, 511.7 | **525.9** | 527.4 | 23.0 | 498.8 | 566.4 |

The higher repeated baseline confirms that comparisons should use measurements
from the same session instead of the older 4,040 cpu-ms median alone.

### 9.2 Accepted intermediate approach — two masonry cache viewports

The earlier half-viewport experiment made active scrolling worse. The inverse
change increases the masonry cache from one viewport to two, matching the
existing fixed-grid/list policy and moving more card construction ahead of the
active scroll burst.

| metric | runs | median | mean | stdev | vs repeated baseline |
|---|---|---:|---:|---:|---:|
| burst cpu-ms | 4,010, 3,830, 4,170, 3,980, 4,100 | **4,010** | 4,018 | 115 | **−9.1% median / −9.2% mean** |
| burst CPU % | 87.2, 82.0, 89.9, 85.2, 88.5 | **87.2** | 86.6 | 2.8 | **−8.9% median** |
| RSS after (MB) | 503.5, 527.3, 559.7, 548.2, 518.4 | **527.3** | 531.4 | 20.2 | +1.4 MB median |

Result: **accepted**. The CPU improvement is clear in both median and mean,
while median RSS is effectively unchanged. The cache-extent contract test was
updated from 600 to 1,200 pixels for the 600-pixel test viewport.

Verification before commit:

- Focused `ListPageScaffold` and `SceneCard` tests: **23 passed**.
- Full Flutter suite: **606 tests passed**.
- Linux profile build succeeded.
- Android split-ABI release APKs built for armeabi-v7a, arm64-v8a, and x86_64.

### 9.3 Accepted approach — three masonry cache viewports

Increasing the cache from two to three viewports produced another large CPU
reduction during the same scroll workload, at a measurable memory cost.

| metric | runs | median | mean | stdev | vs two viewports | vs repeated baseline |
|---|---|---:|---:|---:|---:|---:|
| burst cpu-ms | 3,790, 3,240, 3,090, 3,460, 3,180 | **3,240** | 3,352 | 251 | **−19.2% median** | **−26.5% median** |
| burst CPU % | 81.5, 69.5, 66.2, 74.4, 68.7 | **69.5** | 72.1 | 5.4 | **−20.3% median** | **−27.4% median** |
| RSS after (MB) | 555.4, 579.1, 553.2, 572.8, 526.7 | **555.4** | 557.4 | 18.3 | +28.1 MB median | +29.5 MB median |

Result: **accepted**. CPU improved clearly in both median and mean. Median RSS
rose by about 5.3% versus two viewports, which is the expected cost of keeping
another viewport of rich cards ready ahead of the scroll position. The
cache-extent contract test now expects 1,800 pixels for a 600-pixel viewport.

Verification before commit:

- Focused `ListPageScaffold` and `SceneCard` tests: **23 passed**.
- Full Flutter suite: **606 tests passed**.
- Linux profile build succeeded.
- Android split-ABI release APKs built for armeabi-v7a, arm64-v8a, and x86_64.

### 9.4 Rejected approach — defer desktop VTT probing

This variant stopped `MouseRegion.onEnter` from probing VTT sprite metadata and
left probing to actual pointer movement or touch dragging. It was intended to
avoid work as cards pass beneath a stationary cursor during scrolling.

| metric | runs | median | mean | stdev | vs three viewports |
|---|---|---:|---:|---:|---:|
| burst cpu-ms | 3,070, 2,990, 3,560, 3,090, 4,110 | **3,090** | 3,364 | 423 | −4.6% median / **+0.4% mean** |
| burst CPU % | 66.2, 63.8, 77.0, 65.6, 88.6 | **66.2** | 72.2 | 9.4 | −4.7% median / +0.2% mean |
| RSS after (MB) | 590.2, 581.4, 570.1, 541.9, 603.2 | **581.4** | 577.4 | 20.8 | +26.0 MB median |

Result: **discarded**. The small median improvement was not supported by the
mean, run-to-run variance increased sharply, and memory rose. The original
hover behavior was restored.

---

## 10. Startup optimization pass

Follow-up experiment (2026-09-02): benchmark the current startup path, profile
its awaited stages, and retain only changes that improve five-run first-frame
statistics while preserving application behavior.

### 10.1 Method

- Target: Linux **profile** build, launched as a fresh process five times per
  variant under XWayland.
- Primary metric: elapsed time from Dart `main()` entry to Flutter's first
  rendered frame, using the existing startup stopwatch in `main.dart`.
- End-to-end cross-check: wall time from process spawn until that first-frame
  signal. Native window appearance was sampled separately to distinguish
  engine/process loading from application initialization.
- Each run used an isolated copy of SharedPreferences with diagnostic logging
  enabled only so the existing first-frame signal could be captured. The live
  profile and cache were not modified by the harness.

### 10.2 Baseline

| metric | runs (ms) | median | mean | stdev | min | max |
|---|---|---:|---:|---:|---:|---:|
| `main()` → first frame | 260, 224, 235, 240, 261 | **240.0** | 244.0 | 14.4 | 224.0 | 261.0 |
| process spawn → first frame | 660.7, 548.8, 582.3, 591.3, 584.2 | **584.2** | 593.5 | 36.7 | 548.8 | 660.7 |
| process spawn → native window | 260.1, 188.2, 201.7, 210.3, 183.4 | **201.7** | 208.7 | 27.4 | 183.4 | 260.1 |

Temporary stage timing attributed about **193 ms** of a representative 260 ms
startup to opening the 15 MB persistent GraphQL Hive cache. Desktop window
configuration took about 8 ms inside `main()`, while AudioService and
SharedPreferences together added about 1 ms in that run.

### 10.3 Attempts

| # | Change | `main()` median / mean | spawn median / mean | Result |
|---|---|---:|---:|---|
| 1 | Remove the pre-maximize 800×600 resize | 239.0 / 242.4 ms | 609.1 / 602.3 ms | **discarded** — app time was unchanged and end-to-end median regressed |
| 2 | Use only an in-memory GraphQL cache | 58.0 / 60.0 ms | 419.1 / 425.3 ms | diagnostic upper bound; replaced with the persistence-preserving approach below |
| 3 | Start with an in-memory GraphQL store, then attach and merge the existing Hive store after the first frame | **58.0 / 60.4 ms** | **434.0 / 432.4 ms** | **accepted** |
| 4 | Also defer cache-limit filesystem maintenance until after the frame | 61.0 / 63.2 ms | 430.6 / 427.2 ms | **discarded** — primary median and mean regressed; end-to-end change was mixed |
| 5 | Initialize MediaKit only on the first playback request | 60.0 / 61.0 ms | 438.4 / 433.0 ms | **discarded** — no improvement over accepted approach 3 |

The accepted implementation improves `main()` → first frame by **75.8% median
and 75.2% mean**. End-to-end process startup improves by **25.7% median and
27.2% mean**. `DeferredGraphqlStore` records early writes, deletes, and resets;
when Hive finishes opening, startup mutations are replayed over the persistent
cache so disk persistence remains available for the rest of the session.

### 10.4 Final retained-code confirmation

After restoring all rejected experiments and completing the deferred-store
tests, the exact retained code was rebuilt and measured for five more launches.
Each process remained alive for one second after its first frame so deferred
Hive attachment failures could be captured.

| metric | runs (ms) | median | mean | stdev | vs baseline median |
|---|---|---:|---:|---:|---:|
| `main()` → first frame | 63, 61, 57, 61, 58 | **61.0** | 60.0 | 2.2 | **−74.6%** |
| process spawn → first frame | 483.1, 385.7, 389.6, 376.9, 402.4 | **389.6** | 407.5 | 38.7 | **−33.3%** |

No persistent-cache initialization errors were observed in any confirmation
run. Full verification completed with **609 tests passing**; static analysis
introduced no new findings (one unrelated pre-existing warning remains in
`auth_provider.dart`).
