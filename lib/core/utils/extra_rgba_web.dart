import 'dart:typed_data';

// Web StashImage uses the browser decoder, so these are never reached there.

/// Native-only; see `extra_rgba_native.dart`.
(int, int, Uint8List) decodeAvifRgba(Uint8List bytes) =>
    throw UnsupportedError('AVIF fallback decoding is native-only');

/// Native-only; see `extra_rgba_native.dart`.
(int, int, Uint8List) decodeJxlRgba(Uint8List bytes) =>
    throw UnsupportedError('JPEG XL fallback decoding is native-only');
