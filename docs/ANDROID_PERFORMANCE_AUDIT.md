# Android emulator performance audit

## Scope

Continuation on 2026-10-19, checkout `09abb115` (profile frame-timing hook).
No performance fixes applied. Temporary five-second image-cache logging was
added for measurement and removed afterward; the existing committed frame hook
was preserved.

Device: `sf_perf`, Pixel 7 AVD, API 36, x86_64, 1080×2400,
420 dpi, 4 virtual CPUs, 2 GB guest RAM. This continuation used **SwiftShader**,
confirmed through `dumpsys SurfaceFlinger`. Build: Flutter profile APK.
Real configured server and existing authenticated profile; no content edits.

Earlier host-GPU runs repeatedly terminated in emulator gfxstream
`TextureResize`/`ColorBufferGl` native code. This is a host emulator failure,
not evidence of an application crash. Software-renderer frame times must not
be compared directly with those GPU runs or treated as physical-phone timings.

## Measurements

- Process memory: `adb shell dumpsys meminfo io.github.alchemistaloha.stashflow`.
- Image-cache occupancy: Flutter `ImageCache.currentSize`, `currentSizeBytes`,
  `liveImageCount`, `pendingImageCount`, sampled every five seconds.
- Deeper scrolling: three consecutive batches of ten upward swipes from
  `(540,1900)` to `(540,650)`, 400 ms each, 200 ms pauses, six seconds settling.
  The feed had already been visited and scrolled before the baseline.
- Pressure: `am send-trim-memory … RUNNING_CRITICAL`, then background via Home
  and `am send-trim-memory … COMPLETE`. These are synthetic notifications,
  **not** real system-wide low-memory or low-memory-killer tests.
- Launch: force-stop, two seconds wait, `am start -W`, five seconds settling,
  three repeats. Cold means process-cold, not cleared filesystem caches.

Raw evidence from this session is under `/tmp/sf_audit/continued/` (ephemeral,
not checked in).

### Scrolling and cache occupancy

Memory values below are MiB (raw Android KiB divided by 1024).

| Checkpoint | Process PSS | Image-cache bytes | Cached entries | Live entries |
|---|---:|---:|---:|---:|
| Before continuation batches | 236.3 | — | — | — |
| Batch 1 | 230.9 | 196.0 MiB | 130 | 67 |
| Batch 2 | 240.9 | 197.8 MiB | 149 | 81 |
| Batch 3 | 229.7 | 194.1 MiB | 201 | 59 |

Cache samples are the latest periodic samples near each checkpoint, not atomic
with PSS measurement. The configured cache budget is 200 MiB / 500 entries
(`lib/main.dart`). Occupancy approached the byte budget while entry counts
changed; PSS did not show monotonic growth over these batches. This bounded
sample does not prove absence of a long-session leak.

### Pressure and resume

| Checkpoint | Process PSS | Cache occupancy | Live entries |
|---|---:|---:|---:|
| Before pressure | 229.7 MiB | 194.1 MiB | 59 |
| Foreground critical notification | 225.8 MiB | 0 | 59 |
| Background complete notification | 219.1 MiB | 0 | 59 |
| Resumed | 223.3 MiB | 0 | 59 |

Hot resume reported 259 ms via `am start -W`.

The cache responded to pressure, but clearing its accounting did **not** release
194 MiB of process PSS. Live images remained referenced. Cache byte accounting
is not equivalent to resident memory: do not add it to PSS or interpret its
clear as an equal OS-memory reduction. The retained live images are an
investigation target, not proof of a leak.

### Process-cold launches

SwiftShader launch times: **1417 / 1510 / 1452 ms**, median **1452 ms**.
These are Android activity-launch measurements, not time until all network
content is ready. After the last launch: PSS **212.7 MiB**;
68 cached/live images, **106.7 MiB** cache accounting, no pending decodes.

## Conclusions and next checks

1. **No sustained growth demonstrated by the deeper-scroll sample.** Cache
   turnover stayed near its configured byte cap; PSS varied around 230–241 MiB.
2. **Memory-pressure eviction works, but recovery is modest.** About 10.6 MiB
   PSS was recovered after both notifications; 59 live images remained. Profile
   image ownership before assuming a smaller cache alone will solve memory use.
3. **Decode-size policy needs a physical-device comparison.** Scenes uses
   `itemWidth * 2` (`lib/features/scenes/presentation/pages/scenes_page.dart`),
   while this AVD has DPR 2.625. This is not DPR-aware; it can undersample on
   dense displays. Changing it may increase memory, so measure quality and
   memory together rather than blindly raising decode resolution.
4. **Do not infer device GPU jank from SwiftShader.** Earlier tab-switch samples
   included large software-raster times; they cannot establish a production
   rendering regression or a frame-drop rate.

Not verified: physical ARM hardware, hardware video decoding, real low-memory
process death, battery/thermal behavior, long-session leak behavior, or a
Perfetto presentation-timing trace. No application test suite was needed for
this measurement-only continuation; final source instrumentation cleanup and
documentation whitespace were checked separately.
