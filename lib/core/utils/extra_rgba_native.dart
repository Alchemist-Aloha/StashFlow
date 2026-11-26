import 'dart:typed_data';

import 'package:avif_native/avif_native.dart';
import 'package:jxl_native/jxl_native.dart';

/// Decodes the first AVIF frame to straight RGBA8.
(int, int, Uint8List) decodeAvifRgba(Uint8List bytes) {
  final decoder = AvifDecoder(bytes);
  try {
    // shortcut: animated AVIF shows its first frame only; add a multi-frame
    // codec if Stash libraries start carrying animated AVIF.
    final frame = decoder.getNextFrame();
    return (frame.width, frame.height, frame.rgba);
  } finally {
    decoder.dispose();
  }
}

/// Decodes the first JPEG XL frame to straight RGBA8 with libjxl.
(int, int, Uint8List) decodeJxlRgba(Uint8List bytes) {
  final image = decodeJxl(bytes);
  return (image.width, image.height, image.rgba);
}

/// Web-only; see `extra_rgba_web.dart`.
Future<(int, int, Uint8List)> decodeRgbaInBrowser(
  Uint8List bytes,
  String mimeType,
) => throw UnsupportedError('Browser image decoding is web-only');
