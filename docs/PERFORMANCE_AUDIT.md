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


---

## 11. Full-flow Linux & Android emulator audit against `stash-test-server`

**Date:** 2026-11-23
**Branch:** `dev`
**App version:** 1.43.0+116 (Flutter 3.50.1 / Dart 3.14.0)
**Test server:** `~/stash-test-server` (real Stash server seeded with deterministic fixture library: 10 scenes, 4 performers, 3 studios, 11 tags, 3 galleries, 20 images, API-key authentication).

### 11.1 Method & environments

Both platforms ran the identical 13-scenario end-to-end profile suite via `flutter drive --profile` (`LiveTestWidgetsFlutterBindingFramePolicy.fullyLive`), recording real Flutter engine `FrameTiming` (`buildDuration`, `rasterDuration`, `totalSpan`), `ProcessInfo.currentRss`, and `PaintingBinding.instance.imageCache` occupancy per scenario:

- **Linux desktop profile build:** `x64` CachyOS, `flutter drive --profile -d linux` against `http://127.0.0.1:9999`, hardware GLES3 `media_kit` video rendering (`H/W rendering with isolated GLES3 context in dedicated thread`).
- **Android emulator profile APK:** `Pixel_10_API_37_2` (`sdk_gphone16k_x86_64`, API 37, `1080×2424`, 420 dpi / DPR 2.625, SwiftShader software renderer), `flutter drive --profile -d emulator-5554` against `http://10.0.2.2:9999`, `media_kit` emulator S/W rendering with `SurfaceProducer` and looping playback (`playEndBehavior: loop`).
- **Scenarios:**
  - `00_startup_to_scenes` — authenticated cold start to first `SceneCard` rendered
  - `01_scenes_scroll` — 3× down + 3× up 60 Hz smooth drag bursts on Scenes masonry grid
  - `02_filter_sort_sheets` — opening and dismissing Filter and Sort bottom sheets
  - `03_scene_details_open` — tapping `Pocket Garden` and waiting for first decoded video frame
  - `04_scene_video_playback_idle` — 3 s of live video playback with zero user interaction
  - `05_scene_panel_drag` — dragging `scene_panel_handle` up/down during active video playback
  - `06_scene_details_scroll` — scrolling `scene_details_panel` during active video playback
  - `07_scenes_scroll_with_mini_player` — returning to `/scenes` with `MiniPlayer` active and scrolling the Scenes grid
  - `08–11` — switching to and scrolling Performers, Studios, Tags, and Galleries tabs
  - `12_images_tab_scroll` — navigating to `/images` and scrolling

### 11.2 Baseline results (Linux profile vs Android emulator profile APK)

#### Linux desktop (profile, HW GLES3)

`Startup: first frame rendered in 43 ms`; `00_startup_to_scenes`: **87 ms** (`RSS 335.3 MB`).

| Scenario | Frames | Build p50 / max (ms) | Raster p50 / p90 / max (ms) | Total p50 / p99 (ms) | Jank >16.7ms | RSS (MB) |
|---|---:|---:|---:|---:|---:|---:|
| `01_scenes_scroll` | 217 | 0.52 / 12.88 | 4.14 / 5.49 / 9.34 | 6.59 / 12.50 | 0.9% | 401.0 |
| `02_filter_sort_sheets` | 128 | 0.61 / **22.49** | 4.56 / 6.92 / 8.10 | 7.40 / 15.93 | 0.8% | 409.0 |
| `03_scene_details_open` | 33 | 0.40 / 9.26 | 1.12 / 5.68 / 12.01 | 4.41 / **365.99** | 6.1% | 531.7 |
| `04_scene_video_playback_idle` | 133 | **1.06** / 2.61 | **5.21** / 6.93 / 12.87 | **7.74 / 15.20** | 0.0% | 541.1 |
| `05_scene_panel_drag` | 76 | 0.99 / 6.70 | 4.37 / 6.31 / 7.64 | 7.21 / 10.68 | 0.0% | 538.8 |
| `06_scene_details_scroll` | 242 | 0.55 / 2.65 | 4.45 / 6.39 / 11.55 | 7.26 / 11.64 | 0.0% | 540.0 |
| `07_scenes_scroll_with_mini_player` | 243 | 0.68 / 13.46 | 4.41 / 6.18 / 10.33 | 7.19 / 12.68 | 0.4% | 542.1 |
| `08_performers_tab_scroll` | 225 | 0.83 / 12.10 | 3.55 / 4.28 / 7.08 | 6.09 / 13.45 | 0.0% | 499.4 |
| `09_studios_tab_scroll` | 215 | 0.82 / 8.07 | 3.27 / 3.84 / 7.02 | 5.68 / 10.75 | 0.0% | 506.1 |
| `10_tags_tab_scroll` | 213 | 0.82 / 11.12 | 4.00 / 4.58 / 13.99 | 6.54 / 13.92 | 0.5% | 508.9 |
| `11_galleries_tab_scroll` | 226 | 0.47 / 13.88 | 3.57 / 5.00 / 9.54 | 5.67 / 11.89 | 0.0% | 525.5 |
| `12_images_tab_scroll` | 261 | 0.24 / 5.24 | 1.32 / 1.66 / 5.21 | 3.32 / 7.00 | 0.0% | 518.0 |

#### Android emulator (profile APK, `Pixel_10_API_37_2`, SwiftShader)

`Startup: first frame rendered in 103 ms`; `00_startup_to_scenes`: **1,002 ms** (`RSS 283.0 MB`).

| Scenario | Frames | Build p50 / max (ms) | Raster p50 / p90 / max (ms) | Total p50 / p99 (ms) | Jank >16.7ms | RSS (MB) |
|---|---:|---:|---:|---:|---:|---:|
| `01_scenes_scroll` | 68 | 0.59 / 4.42 | 67.80 / 73.38 / 158.83 | 128.89 / 201.67 | 100.0% | 294.0 |
| `02_filter_sort_sheets` | 35 | 0.70 / 11.40 | 68.09 / 73.43 / 167.56 | 128.21 / 324.87 | 100.0% | 317.8 |
| `03_scene_details_open` | 6 | 5.26 / **19.82** | 85.69 / 207.95 / 207.95 | 114.01 / 311.45 | 100.0% | 355.9 |
| `04_scene_video_playback_idle` | 56 | 0.96 / 4.67 | **59.50** / 65.05 / 69.06 | **110.65 / 123.90** | 100.0% | 358.5 |
| `05_scene_panel_drag` | 24 | 0.96 / 9.59 | 60.96 / 66.48 / 79.54 | 114.68 / 135.06 | 100.0% | 358.1 |
| `06_scene_details_scroll` | 89 | 0.83 / 5.37 | 57.39 / 62.65 / 330.08 | 107.34 / 355.83 | 100.0% | 358.9 |
| `07_scenes_scroll_with_mini_player` | 52 | 0.77 / 5.84 | **101.81** / 109.16 / 111.96 | **194.15 / 218.06** | 100.0% | 361.8 |
| `08_performers_tab_scroll` | 96 | 0.63 / 8.50 | 61.74 / 69.43 / 192.03 | 117.05 / 240.32 | 100.0% | 330.3 |
| `09_studios_tab_scroll` | 92 | 0.51 / 7.82 | 59.97 / 65.18 / 70.88 | 113.74 / 127.89 | 100.0% | 330.7 |
| `10_tags_tab_scroll` | 83 | 0.32 / 6.99 | 63.37 / 68.11 / 75.20 | 117.21 / 138.17 | 100.0% | 330.7 |
| `11_galleries_tab_scroll` | 88 | 0.66 / 9.32 | 62.33 / 68.54 / 78.06 | 117.34 / 139.34 | 100.0% | 331.6 |
| `12_images_tab_scroll` | 176 | 0.15 / 9.52 | 18.12 / 49.60 / 65.76 | 35.28 / 109.22 | 83.0% | 347.4 |

### 11.3 Throttled UI render root causes identified

1. **Unshared `BackdropFilter` passes in `NativeVideoControls` & hidden frosted overlays:**
   - `NativeVideoControls` rendered two `_buildTimePill` `FrostedSurface`s plus `_buildSeekFeedbackOverlay` and `PlayerGestureFeedback` without a shared `BackdropGroup`.
   - Both `_buildSeekFeedbackOverlay` and `PlayerGestureFeedback` kept `FrostedSurface` (`ImageFilter.blur`) mounted inside `AnimatedOpacity(opacity: 0.0)`, and `_buildTimePill` kept blur active even when `_controlsVisible` was false.
   - Result: `04_scene_video_playback_idle` had the highest steady-state raster time on Linux (`5.21 ms` p50, `15.20 ms` total p99) and `59.50 ms` raster p50 on Android.
2. **High-frequency `position` stream rebuilds during idle video playback:**
   - `NativeVideoControls` subscribed to `player.stream.position` and `player.stream.duration` in `initState` / `didUpdateWidget` to call `_onVideoTick()`, which only checks `playingChanged`.
   - The time-pill `StreamBuilder<Duration>` rebuilt both frosted time pills on every raw `position` tick (~40–60 Hz) even though `formatClockDuration(position.inSeconds)` only changes at 1 Hz.
   - `VideoProgressBar` rebuilt `SliderTheme` + `Slider` on every raw `position` tick without a `RepaintBoundary` or throttling.
   - `PlayerSurface.build()` watched the full `playerStateProvider` and `castServiceProvider` instead of selecting only the fields it reads.
3. **Duplicate full-viewport `BackdropFilter` readback when `MiniPlayer` is visible:**
   - `MiniPlayer` sat in `ShellPage` outside `ListPageScaffold`'s `BackdropGroup`, causing two separate full-viewport backdrop readback + blur passes per scroll frame (`07_scenes_scroll_with_mini_player` jumped from `67.80 ms` → `101.81 ms` raster p50 on Android, **+34.0 ms/frame**).

### 11.4 Implemented fixes (retained — proved in benchmark)

- **`lib/features/scenes/presentation/widgets/native_video_controls.dart`:**
  - Wrapped the controls overlay `Stack` in a `BackdropGroup` so sibling frosted overlays share a single backdrop readback.
  - Dropped `blurSigma` to `0` on `_buildSeekFeedbackOverlay` when hidden and on `_buildTimePill` when `!_controlsVisible`.
  - Removed dead `position` and `duration` listeners from `_onVideoTick`.
  - Deduplicated time-pill updates to `1 Hz` (`stream.position.map((d) => d.inSeconds).distinct()`) and throttled non-scrubbing progress-bar updates to `200 ms` intervals (keeping scrubbing instant).
- **`lib/features/scenes/presentation/widgets/video_controls/player_gesture_feedback.dart`:**
  - Dropped `blurSigma` to `0` when `!visible`.
- **`lib/features/scenes/presentation/widgets/video_controls/video_progress_bar.dart`:**
  - Isolated the progress slider inside a `RepaintBoundary`.
- **`lib/features/scenes/presentation/widgets/player_surface.dart`:**
  - Switched `playerStateProvider` and `castServiceProvider` watches to focused `.select(...)` tuples.
- **`lib/features/navigation/presentation/shell_page.dart` & `lib/core/presentation/widgets/list_page_scaffold.dart`:**
  - Wrapped `ShellPage`'s `bodyContent` `Stack` in `BackdropGroup` and made `ListPageScaffold` join an ancestor `BackdropGroup` when present so the non-overlapping top app bar, floating action pill, and `MiniPlayer` share one backdrop readback per frame.

### 11.5 Before vs after benchmark results

#### Linux desktop (profile, HW GLES3)

| Scenario | Build p50 (ms) | Raster p50 (ms) | Total p50 (ms) | Total p99 (ms) |
|---|---:|---:|---:|---:|
| `04_scene_video_playback_idle` | 1.06 → **0.22 (−79%)** | 5.21 → **4.12 (−21%)** | 7.74 → **6.61 (−15%)** | 15.20 → **9.89 (−35%)** |
| `05_scene_panel_drag` | 0.99 → **0.64 (−35%)** | 4.37 → **3.53 (−19%)** | 7.21 → **6.13 (−15%)** | 10.68 → **10.60 (−1%)** |
| `06_scene_details_scroll` | 0.55 → **0.40 (−27%)** | 4.45 → **3.84 (−14%)** | 7.26 → **6.32 (−13%)** | 11.64 → **10.84 (−7%)** |
| `07_scenes_scroll_with_mini_player` | 0.68 → 0.80 | 4.41 → **4.34 (−2%)** | 7.19 → **7.17 (0%)** | 12.68 → 16.07 |

#### Android emulator (profile APK, `Pixel_10_API_37_2`, SwiftShader)

| Scenario | Build p50 (ms) | Raster p50 (ms) | Total p50 (ms) | Total p99 (ms) |
|---|---:|---:|---:|---:|
| `04_scene_video_playback_idle` | 0.96 → **0.31 (−68%)** | 59.50 → **47.06 (−21%)** | 110.65 → **88.17 (−20%)** | 123.90 → **101.33 (−18%)** |
| `05_scene_panel_drag` | 0.96 → 1.09 | 60.96 → **48.74 (−20%)** | 114.68 → **90.19 (−21%)** | 135.06 → **109.10 (−19%)** |
| `06_scene_details_scroll` | 0.83 → **0.55 (−34%)** | 57.39 → **46.95 (−18%)** | 107.34 → **88.06 (−18%)** | 355.83 → **348.54 (−2%)** |
| `07_scenes_scroll_with_mini_player` | 0.77 → 0.77 | 101.81 → **72.79 (−29%)** | 194.15 → **136.31 (−30%)** | 218.06 → **166.98 (−23%)** |

### 11.6 Remaining bottlenecks & unverified gaps

- **Full-viewport `BackdropGroup` on software/low-end rasterizers:** Even with one shared `BackdropGroup`, blurring the full-screen `ListPageScaffold` backdrop adds ~42–48 ms/frame under Android SwiftShader (~2.3 ms on Linux HW GPU). On real GPU-backed mobile hardware this is much smaller, but adding a user-facing or low-end option to disable frosted blur would be the next lever if physical-device traces show raster pressure.
- **Scene Details open stall (`~350 ms` total max on Linux and Android):** Driven by synchronous `media_kit` / native player creation on route open (`build_max < 20 ms`, `raster_max < 12 ms` on Linux, rest is vsync overhead).
- **Filter sheet first-frame build (`19–22 ms` max on Linux):** `SceneFilterPanel` eagerly instantiates all 7 `FilterSection` children before opening; lazily building collapsed sections is a future follow-up if needed.
- **Unverified in this pass:** Physical ARM Android hardware, hardware video decoding on Android, battery/thermal throttling, and long-session memory growth beyond the fixture library size.


---

## 12. Repeatable frame profile of Linux and Android builds (2026-11-24)

**Branch:** `dev` (from `dfdfa551`)
**App version:** 1.43.0+116 (Flutter 3.50.1)
**Test server:** `~/stash-test-server` (Stash v0.32.0, deterministic fixture:
10 scenes at 30 fps, 4 performers, 3 studios, 11 tags, 3 galleries, 20 images),
API-key profile.

### 12.1 Harness

The §11 numbers could not be reproduced because the harness was never checked
in. This pass adds it:

- `integration_test/perf_profile_test.dart` drives the real app through 23
  scenarios with `LiveTestWidgetsFlutterBindingFramePolicy.fullyLive` (real
  vsync frames). For each scenario it records engine `FrameTiming` (build,
  raster, total span; p50/p90/p99/max; jank = total span > 16.7 ms), process
  RSS, image-cache occupancy and, while a video plays, how far playback
  advanced. Debug runs also count rebuilt widget types per scenario
  (`debugOnRebuildDirtyWidget`).
- `test_driver/perf_driver.dart` writes the report to `build/$PERF_OUT.json`.
- Each scenario waits 1.2 s before and after its action, because
  profile engines report `FrameTiming` in roughly one-second batches.

```sh
set -a; source ../stash-test-server/stash-test-server.env; set +a
PERF_OUT=perf_linux flutter drive --profile -d linux \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/perf_profile_test.dart \
  --dart-define="STASH_URL=$STASH_URL" --dart-define="STASH_API_KEY=$STASH_API_KEY"
# Android emulator: -d emulator-5554 and STASH_URL=http://10.0.2.2:9999
```

Scenarios: profile→Scenes, idle Scenes, Scenes scroll (3 drags down + 3 up),
filter and sort sheets, Scene Details open to first decoded frame, idle video
with controls visible, idle video with controls auto-hidden, scene panel
drag, details-panel scroll, idle Scenes with the mini player, Scenes scroll
with the mini player, open and scroll for each of Performers, Studios, Tags
and Galleries, gallery details, rapid tab switching, the Images grid, and
image-viewer swipes.

### 12.2 Environments

- **Linux profile build:** x86_64 CachyOS desktop on Hyprland, with a
  144 Hz monitor and hardware GL. The window is 1259×1021 logical px at DPR 1.
- **Android profile APK:** `Pixel_10_API_37_2` AVD (API 37, x86_64,
  1080×2424, DPR 2.625). It rendered through the **host GPU** (Android
  Emulator OpenGL ES Translator on an RTX 3070), not the SwiftShader renderer
  §11 used, so absolute Android raster numbers are not comparable with §11.
  The host-GPU emulator went offline twice mid-session (gfxstream context
  errors in the emulator log, `adb: device offline` before the app launched).
  Those runs were discarded and repeated after a cold boot.
- Every variant was measured with **3 fresh launches per platform**; tables
  show the medians. Disk image caches stayed warm across runs.

### 12.3 Baseline (current `dev`, before fixes)

| Scenario | Frames | Build p50 / p90 | Raster p50 / p90 | Total p50 / p90 / p99 | Jank | RSS MB |
|---|---:|---:|---:|---:|---:|---:|
| `00_profile_to_scenes` | 2 | 0.32 / 0.32 | 6.20 / 6.20 | 8.72 / 8.72 / 8.72 | 0.0% | 372 |
| `01_scenes_idle` | 2 | 0.34 / 0.34 | 7.09 / 7.09 | 9.07 / 9.07 / 9.07 | 0.0% | 371 |
| `02_scenes_scroll` | 251 | 0.27 / 1.22 | 4.54 / 6.25 | 6.86 / 8.82 / 11.27 | 0.0% | 376 |
| `03_filter_sort_sheets` | 201 | 0.22 / 1.32 | 4.86 / 7.27 | 7.37 / 10.04 / 15.35 | 1.0% | 372 |
| `04_scene_details_open` | 97 | 0.24 / 1.29 | 3.49 / 6.19 | 6.26 / 8.74 / 45.28 | 3.1% | 522 |
| `05_video_idle_controls_visible` | 160 | 0.21 / 0.75 | 2.66 / 3.84 | 4.83 / 6.21 / 8.03 | 0.0% | 528 |
| `06_video_idle_controls_hidden` | 307 | 0.21 / 0.90 | 3.01 / 4.74 | 4.80 / 6.71 / 9.52 | 0.0% | 531 |
| `07_scene_panel_drag` | 276 | 0.24 / 1.07 | 2.73 / 3.91 | 4.50 / 6.29 / 7.85 | 0.0% | 534 |
| `08_scene_details_scroll` | 209 | 0.21 / 0.71 | 2.73 / 3.88 | 4.84 / 6.54 / 8.57 | 0.0% | 535 |
| `09_scenes_idle_with_mini_player` | 315 | 0.23 / 1.38 | 4.34 / 6.48 | 6.90 / 9.23 / 11.96 | 0.0% | 528 |
| `10_scenes_scroll_with_mini_player` | 325 | 0.67 / 1.61 | 4.18 / 6.35 | 6.93 / 9.73 / 13.20 | 0.6% | 535 |
| `11_performers_tab_open` | 69 | 0.25 / 1.72 | 3.03 / 3.93 | 5.36 / 7.45 / 16.19 | 1.4% | 507 |
| `12_performers_tab_scroll` | 221 | 0.65 / 1.47 | 3.16 / 4.22 | 5.51 / 7.20 / 10.29 | 0.0% | 498 |
| `13_studios_tab_open` | 69 | 0.22 / 1.80 | 2.78 / 3.72 | 4.94 / 6.85 / 16.46 | 1.4% | 504 |
| `14_studios_tab_scroll` | 224 | 0.62 / 1.44 | 2.90 / 3.63 | 5.14 / 6.72 / 9.56 | 0.0% | 503 |
| `15_tags_tab_open` | 69 | 0.21 / 1.88 | 2.92 / 4.32 | 5.28 / 7.28 / 9.77 | 0.0% | 508 |
| `16_tags_tab_scroll` | 220 | 0.63 / 1.50 | 3.49 / 4.67 | 5.86 / 7.56 / 11.23 | 0.0% | 503 |
| `17_galleries_tab_open` | 69 | 0.22 / 1.88 | 2.91 / 4.10 | 5.14 / 7.36 / 10.84 | 0.0% | 505 |
| `18_galleries_tab_scroll` | 195 | 0.26 / 1.18 | 3.12 / 4.19 | 5.36 / 6.82 / 9.80 | 0.0% | 505 |
| `19_gallery_details_open_scroll` | 218 | 0.24 / 1.26 | 3.04 / 3.96 | 5.15 / 6.63 / 10.19 | 0.5% | 512 |
| `20_tab_switch_churn` | 249 | 0.63 / 2.00 | 3.02 / 4.21 | 5.67 / 7.78 / 9.91 | 0.0% | 518 |
| `21_images_scroll` | 196 | 0.27 / 1.26 | 3.94 / 5.29 | 6.25 / 8.03 / 10.40 | 0.0% | 516 |
| `22_image_viewer_swipe` | 189 | 0.20 / 0.31 | 3.22 / 4.02 | 5.13 / 6.26 / 21.88 | 2.1% | 580 |

| Scenario | Frames | Build p50 / p90 | Raster p50 / p90 | Total p50 / p90 / p99 | Jank | RSS MB |
|---|---:|---:|---:|---:|---:|---:|
| `00_profile_to_scenes` | 7 | 0.26 / 2.64 | 16.35 / 17.54 | 21.24 / 21.62 / 22.21 | 85.7% | 321 |
| `01_scenes_idle` | 2 | 0.33 / 0.33 | 7.78 / 7.78 | 8.91 / 8.91 / 8.91 | 0.0% | 321 |
| `02_scenes_scroll` | 263 | 0.59 / 1.71 | 6.26 / 17.27 | 7.78 / 20.92 / 32.28 | 32.8% | 306 |
| `03_filter_sort_sheets` | 201 | 0.49 / 1.32 | 5.98 / 8.16 | 7.32 / 9.84 / 13.59 | 0.0% | 325 |
| `04_scene_details_open` | 85 | 0.18 / 0.73 | 1.58 / 3.48 | 1.90 / 8.21 / 20.30 | 8.8% | 357 |
| `05_video_idle_controls_visible` | 168 | 0.07 / 0.29 | 1.19 / 1.58 | 1.45 / 2.02 / 3.06 | 0.0% | 357 |
| `06_video_idle_controls_hidden` | 314 | 0.07 / 0.30 | 1.41 / 16.57 | 1.71 / 17.94 / 18.44 | 18.5% | 359 |
| `07_scene_panel_drag` | 273 | 0.08 / 0.38 | 1.32 / 1.93 | 1.69 / 2.42 / 3.57 | 0.0% | 361 |
| `08_scene_details_scroll` | 238 | 0.07 / 0.28 | 1.23 / 1.84 | 1.53 / 2.24 / 3.46 | 0.0% | 361 |
| `09_scenes_idle_with_mini_player` | 314 | 0.36 / 0.58 | 1.74 / 2.42 | 2.14 / 3.18 / 4.52 | 0.0% | 362 |
| `10_scenes_scroll_with_mini_player` | 327 | 0.42 / 0.65 | 1.73 / 2.48 | 2.25 / 3.24 / 5.30 | 0.0% | 363 |
| `11_performers_tab_open` | 70 | 0.58 / 1.28 | 16.53 / 18.02 | 20.66 / 21.75 / 22.70 | 95.7% | 333 |
| `12_performers_tab_scroll` | 251 | 0.36 / 1.91 | 4.98 / 6.96 | 6.41 / 9.04 / 14.25 | 0.0% | 333 |
| `13_studios_tab_open` | 69 | 0.55 / 1.33 | 4.76 / 6.25 | 5.98 / 7.60 / 8.73 | 0.0% | 333 |
| `14_studios_tab_scroll` | 249 | 0.35 / 1.67 | 4.99 / 6.49 | 6.10 / 8.12 / 11.49 | 0.0% | 330 |
| `15_tags_tab_open` | 69 | 0.45 / 1.39 | 5.29 / 6.72 | 6.55 / 7.88 / 11.72 | 0.0% | 330 |
| `16_tags_tab_scroll` | 258 | 0.37 / 1.69 | 5.74 / 7.78 | 6.82 / 9.26 / 17.71 | 1.9% | 332 |
| `17_galleries_tab_open` | 140 | 0.50 / 1.12 | 5.05 / 6.92 | 6.10 / 7.90 / 11.96 | 0.0% | 333 |
| `18_galleries_tab_scroll` | 254 | 0.33 / 1.83 | 5.07 / 6.93 | 6.51 / 8.79 / 13.73 | 0.0% | 334 |
| `19_gallery_details_open_scroll` | 307 | 0.35 / 1.50 | 5.79 / 17.21 | 7.36 / 21.72 / 23.36 | 40.4% | 338 |
| `20_tab_switch_churn` | 315 | 0.80 / 1.11 | 4.69 / 5.99 | 5.95 / 7.57 / 9.93 | 0.0% | 338 |
| `21_images_scroll` | 256 | 0.48 / 1.75 | 5.71 / 16.94 | 7.35 / 21.46 / 22.66 | 30.5% | 341 |
| `22_image_viewer_swipe` | 536 | 0.22 / 0.90 | 3.09 / 6.28 | 3.74 / 7.40 / 19.05 | 2.0% | 349 |

Readings:

- Scrolling, tab switching and sheets are healthy on Linux: jank of 1% or
  less, and total p99 of 16 ms or less, except the details-route open (45 ms
  p99, native player creation, as in §11).
- On the emulator, some scenarios swing between about 5 ms and 17 ms raster
  p90 from one run to the next (for example `02`, `06`, `19`, `21`, and the
  first frames of a tab or sheet). This is noise from the emulator's GPU
  translation layer; the same scenarios are stable on Linux. Android
  judgements below therefore rely on frame counts and Dart build cost, not
  raster time.
- **Over-rendering:** with no interaction and a 30 fps video,
  `06_video_idle_controls_hidden` produced about 307 frames in 4 s on Linux
  (about 76 fps) and `09_scenes_idle_with_mini_player` about 315 (about 78 fps).
  An idle Scenes page without video produces 2 frames.

### 12.4 Root causes of the idle over-rendering

1. **Per-tick card progress state.** `ScenePlaybackPosition.update` wrote the
   raw player position on every tick (about 24 Hz). Every Riverpod state
   change marks the root `UncontrolledProviderScope` dirty and schedules a
   frame. It also rebuilt `_ScenePlaybackProgress` and its
   `LinearProgressIndicator` on every matching scene card, including cards on
   hidden shell tabs. The debug run counted 94 rebuilds of each in 4 s of
   idle mini-player playback.
2. **Hidden video controls kept consuming position ticks.**
   `NativeVideoControls` fed the 1 Hz clock and the 200 ms progress-bar
   stream while its bottom bar was hidden behind `AnimatedOpacity(0)`. The
   hidden `Slider` subtree kept scheduling frames at close to display rate.
   Debug rebuild counts show only about 5 `Slider` rebuilds per second, so
   most of those frames were repaint-only. With the controls hidden, about
   300 Dart frames per 4 s were spent redrawing nothing visible.
3. **Not app-owned:** on Linux the mini player still renders about
   73–78 fps. With `debugPrintScheduleFrameStacks`, only 2 Dart-side
   `scheduleFrame` calls were made in 1 s of idle mini-player playback, so
   these frames come from the engine/native texture path (media_kit), not app
   Dart code. On Android, the video surface drives a full Flutter frame per
   texture update, so the frame count there (about 314 per 4 s) is set by the
   plugin and the engine.

### 12.5 Changes and results (both retained)

**Fix 1:** `lib/features/scenes/presentation/providers/scene_playback_position_provider.dart`.
Forward progress is published in whole-second steps. Backward seeks, restarts
at zero and the first observed position still apply immediately. A pause can
leave a card bar up to 1 s behind, which is invisible on a bar a few pixels
tall.

**Fix 2:** `lib/features/scenes/presentation/widgets/native_video_controls.dart`.
The time-pill and progress-bar streams ignore position ticks while the
controls are hidden, unless the user is scrubbing. The next tick after the
controls reappear refreshes them.

| Scenario | Frames | Build p50 (ms) | Build p90 (ms) | Total p90 (ms) |
|---|---:|---:|---:|---:|
| `02_scenes_scroll` | 251 → 254 → 246 | 0.27 → 0.26 → 0.26 | 1.22 → 1.25 → 1.14 | 8.82 → 9.04 → 9.15 |
| `05_video_idle_controls_visible` | 160 → 150 → 45 | 0.21 → 0.20 → 0.21 | 0.75 → 0.74 → 0.64 | 6.21 → 7.15 → 6.69 |
| `06_video_idle_controls_hidden` | 307 → 305 → 2 | 0.21 → 0.18 → 0.28 | 0.90 → 0.41 → 0.28 | 6.71 → 5.66 → 6.67 |
| `07_scene_panel_drag` | 276 → 270 → 231 | 0.24 → 0.23 → 0.25 | 1.07 → 1.07 → 1.10 | 6.29 → 6.29 → 7.25 |
| `08_scene_details_scroll` | 209 → 212 → 114 | 0.21 → 0.22 → 0.22 | 0.71 → 0.91 → 0.80 | 6.54 → 6.56 → 7.32 |
| `09_scenes_idle_with_mini_player` | 315 → 204 → 292 | 0.23 → 0.20 → 0.19 | 1.38 → 0.27 → 0.27 | 9.23 → 8.53 → 8.46 |
| `10_scenes_scroll_with_mini_player` | 325 → 267 → 262 | 0.67 → 0.27 → 0.29 | 1.61 → 1.31 → 1.33 | 9.73 → 9.55 → 9.36 |
| `12_performers_tab_scroll` | 221 → 221 → 225 | 0.65 → 0.61 → 0.72 | 1.47 → 1.56 → 1.59 | 7.20 → 7.39 → 7.95 |
| `21_images_scroll` | 196 → 195 → 197 | 0.27 → 0.26 → 0.28 | 1.26 → 1.36 → 1.32 | 8.03 → 7.89 → 8.41 |

| Scenario | Frames | Build p50 (ms) | Build p90 (ms) | Total p90 (ms) |
|---|---:|---:|---:|---:|
| `02_scenes_scroll` | 263 → 263 → 256 | 0.59 → 0.52 → 0.45 | 1.71 → 1.87 → 1.83 | 20.92 → 21.56 → 21.25 |
| `05_video_idle_controls_visible` | 168 → 161 → 166 | 0.07 → 0.07 → 0.07 | 0.29 → 0.32 → 0.13 | 2.02 → 17.80 → 1.95 |
| `06_video_idle_controls_hidden` | 314 → 314 → 314 | 0.07 → 0.07 → 0.06 | 0.30 → 0.20 → 0.09 | 17.94 → 2.12 → 1.94 |
| `07_scene_panel_drag` | 273 → 271 → 279 | 0.08 → 0.09 → 0.08 | 0.38 → 0.38 → 0.36 | 2.42 → 2.40 → 2.17 |
| `08_scene_details_scroll` | 238 → 241 → 235 | 0.07 → 0.07 → 0.08 | 0.28 → 0.37 → 0.12 | 2.24 → 2.57 → 2.14 |
| `09_scenes_idle_with_mini_player` | 314 → 314 → 313 | 0.36 → 0.07 → 0.07 | 0.58 → 0.10 → 0.11 | 3.18 → 2.81 → 2.86 |
| `10_scenes_scroll_with_mini_player` | 327 → 322 → 320 | 0.42 → 0.10 → 0.10 | 0.65 → 0.60 → 0.56 | 3.24 → 3.26 → 3.36 |
| `12_performers_tab_scroll` | 251 → 255 → 252 | 0.36 → 0.47 → 0.36 | 1.91 → 1.75 → 1.78 | 9.04 → 8.56 → 8.50 |
| `21_images_scroll` | 256 → 247 → 252 | 0.48 → 0.38 → 0.50 | 1.75 → 1.79 → 1.79 | 21.46 → 21.34 → 21.94 |

Evidence summary:

- **Fix 1:** idle mini-player build p90 went 1.38 → 0.27 ms on Linux (−80%)
  and 0.58 → 0.10 ms on Android (−83%). Mini-player scroll build p50 went
  0.67 → 0.27 ms on Linux (−60%) and 0.42 → 0.10 ms on Android (−76%).
  Linux idle mini-player frame counts are bimodal (fix 1 runs: 204, 198, 303)
  because the native texture path dominates, so the build-cost reduction is
  the reliable signal.
- **Fix 2:** idle video with hidden controls went **307 → 2 Dart frames** in
  4 s on Linux. Details-panel scroll went 209 → 114 frames, and the
  controls-visible window (which auto-hides partway through) went 160 → 45.
  Android frame counts are unchanged because the video surface drives frames
  there, but hidden-controls build p90 fell 0.30 → 0.09 ms and details-scroll
  build p90 fell 0.28 → 0.12 ms.
- **Video still presents** with fix 2: playback advanced 4,000 ms during the
  4 s hidden-controls window on both platforms. Three `grim` screenshots of
  the Linux window taken 1 s apart in that window differ by 13–20% of pixels,
  showing a moving video under hidden controls.
- On Linux, total-span p90 in `07` and `08` rose by about 1 ms with fix 2.
  Fix 2 removed many cheap idle frames, so the remaining frames are the
  costlier gesture frames. Per-frame build cost did not regress.
- Scenarios the fixes don't touch (`02`, `12`, `21` and the rest) stay within
  run-to-run noise.

### 12.6 Remaining findings (not changed)

- **Native texture frame rate (media_kit):** a 30 fps video keeps the app
  rendering at about 75 fps on Linux in the mini player and on Android
  everywhere a video is shown. Lowering it needs plugin or engine work.
- **Scene Details open stall:** total-span p99 is about 45 ms on Linux and the
  maximum is about 360 ms, from synchronous native player creation (as in
  §11).
- **Emulator first frames of sheets and tabs:** 16–18 ms raster on the first
  frames of `00`, `11` and `03` in some runs. Noisy on this emulator, and not
  reproduced on Linux.
- **Pre-existing e2e failure:** `integration_test/app_e2e_test.dart` fails at
  `scrollUntilVisible` on `scene_details_panel` (`Bad state: No element`,
  line 508), both with and without these changes. The test predates the
  recent Scene Details layout change and needs updating separately.

### 12.7 Verification

- `flutter analyze`: no issues.
- `flutter test`: all tests pass (1,570 passed, 33 skipped), including a new
  whole-second-step test for `ScenePlaybackPosition`.
- Profile harness: every retained-code run passed (Linux 3 + 1 check run;
  Android 3).
- **Unverified:** physical Android hardware, macOS, Windows and iOS, the
  mini player on a 60 Hz display, and casting. Casting goes through the same
  `ScenePlaybackPosition.update` throttle but was not exercised against a
  real receiver.
