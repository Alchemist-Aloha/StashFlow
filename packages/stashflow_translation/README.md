# StashFlow on-device translation

A small, isolate-confined Dart FFI bridge to **CTranslate2 4.6.0** and
**SentencePiece 0.2.1**, built from pinned upstream commits by a Dart build hook.
The app downloads compatible Marian/OPUS-MT weights separately. No Python,
network inference, Google services or executable FFmpeg is required at runtime.

## Build requirements

CMake 3.22+, Git and a C++17 compiler are required on the build host. First builds
fetch the pinned sources/submodules; subsequent builds reuse the hook cache.
Android uses Flutter's configured NDK, static libc++, 16 KB ELF alignment and
all three release ABIs. ARMv7 uses CT2 scalar elementwise kernels and Ruy's
supported matrix kernels; performance on 32-bit devices is not guaranteed.
The Android compatibility header declines explicit pthread affinity, an
unavailable Bionic API; the app never requests thread pinning.

The hook configures native Linux, Windows and Apple builds. Only platforms
actually built/tested in the handoff are verified; cross-host packaging and
device runtime require their own acceptance checks. Web uses an app-level stub.

## Ownership

Create, translate and close a `MarianTranslator` on the same worker isolate.
Requests on a handle must be serialized. `close()` releases native memory;
no Dart finalizer races inference. Native exceptions never cross the C ABI.
Returned text/error strings are freed by the same library that allocated them.
Inference input/output token counts are bounded.

The model directory contains `model.bin`, `config.json`,
`shared_vocabulary.json`, `source.spm` and `target.spm`.
Append Marian's source EOS explicitly. English→Chinese additionally requires
the `>>cmn_Hans<<` source language token. The app preserves model cards and
verifies every downloaded file before publishing an installation.

Licenses and model provenance are available in
[`asset/licenses/local_captions.txt`](../../asset/licenses/local_captions.txt)
and the application's licenses screen. Model cards remain with downloaded files.

## Verification

Normal focused tests (no downloaded weights):

```sh
rtk flutter test test/features/scenes/local_captions_test.dart
rtk flutter test test/features/scenes/local_caption_settings_test.dart
```

Optional host smoke tests use models downloaded from the pinned app catalog
under `build/caption-smoke-models/<model-id>/`. The English speech fixture is
the pinned Zipformer repository's `test_wavs/0.wav`, saved as
`zipformer-en/test.wav`. A standalone Flutter test runner does not bundle plugin
libraries: on Linux, put the installed `sherpa_onnx_linux/linux/x64` library
directory on `LD_LIBRARY_PATH` (use aarch64 on ARM64).

```sh
rtk flutter test test/features/scenes/local_captions_native_test.dart \
  --dart-define=RUN_LOCAL_CAPTION_NATIVE=true \
  --dart-define=CAPTION_MODEL_ROOT=build/caption-smoke-models
```

These test bounded PCM extraction/cleanup, actual offline translation, sherpa
recognition and worker teardown. The pinned Whisper export has no cross-attention
outputs: Japanese subtitles use VAD phrase timing, not token timestamps. The
English fixture also exercises this decoding path, without measuring Japanese
recognition quality. These checks do not establish sustained mobile
throughput, translation accuracy on scene dialogue, or remote playback support.
