import 'dart:typed_data';

import 'package:avif_native/avif_native.dart';

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
