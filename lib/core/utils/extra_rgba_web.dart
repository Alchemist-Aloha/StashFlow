import 'dart:typed_data';

/// Browsers decode AVIF natively, so the web build never reaches this path.
(int, int, Uint8List) decodeAvifRgba(Uint8List bytes) =>
    throw UnsupportedError('AVIF fallback decoding is native-only');
