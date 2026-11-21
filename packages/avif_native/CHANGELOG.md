## 0.2.0

- Add `premultiplyAlpha` to `decodeAvif` and `AvifDecoder`. libavif now
  multiplies the colour channels by alpha during YUV-to-RGB conversion when
  requested, avoiding a separate pass over the frames in Dart. Frames are
  still straight alpha by default.
- `avif_native_decoder_create` gains a `premultiply_alpha` argument. Rebuild
  the native artifacts and update `native/manifest.json` before publishing.

## 0.1.1

- Make decode-only configuration default to the available dav1d decoder.
- Add integration coverage for every native codec profile.

## 0.1.0

- Add still and animated AVIF decoding and encoding.
- Add configurable native codec profiles through Dart build hooks.
- Add capability detection and stable ABI stubs for omitted features.
