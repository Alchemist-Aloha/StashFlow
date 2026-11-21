import 'package:flutter/foundation.dart';
import 'package:koni_jxl/koni_jxl.dart';

import 'avif_rgba_web.dart' if (dart.library.ffi) 'avif_rgba_native.dart';

/// Formats Flutter's engine codec cannot decode but StashFlow renders itself.
enum ExtraImageFormat { avif, jxl }

/// Detects AVIF (ISOBMFF `ftyp` with an `avif`/`avis` brand) or JPEG XL
/// (bare codestream or container) from the leading bytes.
ExtraImageFormat? sniffExtraImageFormat(Uint8List bytes) {
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0x0A) {
    return ExtraImageFormat.jxl;
  }
  if (bytes.length >= 12 &&
      _ascii(bytes, 0, 4) == '\x00\x00\x00\x0C' &&
      _ascii(bytes, 4, 8) == 'JXL ') {
    return ExtraImageFormat.jxl;
  }
  if (bytes.length < 16 || _ascii(bytes, 4, 8) != 'ftyp') return null;
  final boxEnd = (bytes[0] << 24 | bytes[1] << 16 | bytes[2] << 8 | bytes[3])
      .clamp(16, bytes.length);
  // Major brand at 8, then compatible brands after the minor version at 12.
  for (var i = 8; i + 4 <= boxEnd; i += i == 8 ? 8 : 4) {
    final brand = _ascii(bytes, i, i + 4);
    if (brand == 'avif' || brand == 'avis') return ExtraImageFormat.avif;
  }
  return null;
}

String _ascii(Uint8List bytes, int start, int end) =>
    String.fromCharCodes(bytes, start, end);

/// Transcodes AVIF or JPEG XL [bytes] to an uncompressed BMP that Flutter's
/// engine codec decodes, so the result flows through the normal
/// `ImageDecoderCallback` (resizing, image cache) like any other image.
///
/// Returns null when [bytes] are neither format. Work runs off the calling
/// isolate on native platforms.
Future<Uint8List?> transcodeExtraImageFormat(Uint8List bytes) async {
  final format = sniffExtraImageFormat(bytes);
  if (format == null) return null;
  return compute(_transcode, (format, bytes));
}

Uint8List _transcode((ExtraImageFormat, Uint8List) request) {
  final (format, bytes) = request;
  final (width, height, rgba) = switch (format) {
    ExtraImageFormat.avif => decodeAvifRgba(bytes),
    ExtraImageFormat.jxl => _decodeJxl(bytes),
  };
  return _bmp(width, height, rgba);
}

(int, int, Uint8List) _decodeJxl(Uint8List bytes) {
  final image = JxlDecoder.decode(bytes);
  return (image.width, image.height, image.toRgba8());
}

/// Wraps straight RGBA8 as a top-down 32-bit BMP with a V4 header, whose
/// channel masks carry alpha.
Uint8List _bmp(int width, int height, Uint8List rgba) {
  const headerSize = 14 + 108;
  final out = Uint8List(headerSize + rgba.length);
  ByteData.sublistView(out)
    ..setUint16(0, 0x4D42, Endian.little) // 'BM'
    ..setUint32(2, out.length, Endian.little)
    ..setUint32(10, headerSize, Endian.little)
    ..setUint32(14, 108, Endian.little)
    ..setInt32(18, width, Endian.little)
    ..setInt32(22, -height, Endian.little) // negative height = top-down rows
    ..setUint16(26, 1, Endian.little)
    ..setUint16(28, 32, Endian.little)
    ..setUint32(30, 3, Endian.little) // BI_BITFIELDS
    ..setUint32(34, rgba.length, Endian.little)
    ..setUint32(54, 0x000000FF, Endian.little) // red mask
    ..setUint32(58, 0x0000FF00, Endian.little) // green mask
    ..setUint32(62, 0x00FF0000, Endian.little) // blue mask
    ..setUint32(66, 0xFF000000, Endian.little) // alpha mask
    ..setUint32(70, 0x73524742, Endian.little); // 'sRGB' colour space
  // Masks match RGBA byte order, so pixels copy through unchanged.
  out.setRange(headerSize, out.length, rgba);
  return out;
}
