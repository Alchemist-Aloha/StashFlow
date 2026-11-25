import 'dart:js_interop';
import 'dart:typed_data';

/// Native-only; see `extra_rgba_native.dart`.
(int, int, Uint8List) decodeAvifRgba(Uint8List bytes) =>
    throw UnsupportedError('AVIF fallback decoding is native-only');

/// Native-only; see `extra_rgba_native.dart`.
(int, int, Uint8List) decodeJxlRgba(Uint8List bytes) =>
    throw UnsupportedError('JPEG XL fallback decoding is native-only');

/// Decodes [bytes] of [mimeType] to straight RGBA8 with the browser's image
/// decoder.
///
/// Flutter's web engine rejects AVIF and JPEG XL before the browser sees them
/// (it requests an animated track that still AVIF lacks, and does not sniff
/// JPEG XL), although `createImageBitmap` decodes both where supported.
Future<(int, int, Uint8List)> decodeRgbaInBrowser(
  Uint8List bytes,
  String mimeType,
) async {
  final blob = _Blob([bytes.toJS].toJS, _BlobOptions(type: mimeType));
  final bitmap = await _createImageBitmap(blob).toDart;
  try {
    final (width, height) = (bitmap.width, bitmap.height);
    final context = _OffscreenCanvas(width, height).getContext('2d')!;
    context.drawImage(bitmap, 0, 0);
    final rgba = context.getImageData(0, 0, width, height).data.toDart;
    return (width, height, Uint8List.sublistView(rgba));
  } finally {
    bitmap.close();
  }
}

@JS('createImageBitmap')
external JSPromise<_ImageBitmap> _createImageBitmap(_Blob image);

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny> parts, _BlobOptions options);
}

extension type _BlobOptions._(JSObject _) implements JSObject {
  external factory _BlobOptions({String type});
}

extension type _ImageBitmap._(JSObject _) implements JSObject {
  external int get width;
  external int get height;
  external void close();
}

@JS('OffscreenCanvas')
extension type _OffscreenCanvas._(JSObject _) implements JSObject {
  external factory _OffscreenCanvas(int width, int height);
  external _Context2D? getContext(String contextId);
}

extension type _Context2D._(JSObject _) implements JSObject {
  external void drawImage(_ImageBitmap image, int dx, int dy);
  external _ImageData getImageData(int sx, int sy, int sw, int sh);
}

extension type _ImageData._(JSObject _) implements JSObject {
  external JSUint8ClampedArray get data;
}
