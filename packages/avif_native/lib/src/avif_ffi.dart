import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

final class _NativeDecoder extends Opaque {}

final class _NativeEncoder extends Opaque {}

@Native<Uint32 Function()>(symbol: 'avif_native_capabilities', isLeaf: true)
external int _nativeCapabilities();

class AvifNativeCapabilities {
  const AvifNativeCapabilities._(this._bits);

  final int _bits;

  bool get canDecode => _bits & 1 != 0;
  bool get canEncode => _bits & 2 != 0;
}

AvifNativeCapabilities get avifNativeCapabilities =>
    AvifNativeCapabilities._(_nativeCapabilities());

@Native<
  Int32 Function(
    Pointer<Uint8>,
    IntPtr,
    Pointer<Pointer<_NativeDecoder>>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
    Pointer<Int32>,
    Int32,
  )
>(symbol: 'avif_native_decoder_create')
external int _decoderCreate(
  Pointer<Uint8> data,
  int size,
  Pointer<Pointer<_NativeDecoder>> decoder,
  Pointer<Int32> width,
  Pointer<Int32> height,
  Pointer<Int32> frameCount,
  Pointer<Double> durationSeconds,
  Pointer<Int32> repetitionCount,
  int premultiplyAlpha,
);

@Native<
  Int32 Function(
    Pointer<_NativeDecoder>,
    Pointer<Pointer<Uint8>>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
  )
>(symbol: 'avif_native_decoder_next')
external int _decoderNext(
  Pointer<_NativeDecoder> decoder,
  Pointer<Pointer<Uint8>> rgba,
  Pointer<Int32> width,
  Pointer<Int32> height,
  Pointer<Double> durationSeconds,
);

@Native<Int32 Function(Pointer<_NativeDecoder>)>(
  symbol: 'avif_native_decoder_reset',
)
external int _decoderReset(Pointer<_NativeDecoder> decoder);

@Native<Void Function(Pointer<_NativeDecoder>)>(
  symbol: 'avif_native_decoder_destroy',
)
external void _decoderDestroy(Pointer<_NativeDecoder> decoder);

@Native<
  Int32 Function(
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Uint64,
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Pointer<Uint8>,
    IntPtr,
    Pointer<Pointer<_NativeEncoder>>,
  )
>(symbol: 'avif_native_encoder_create')
external int _encoderCreate(
  int width,
  int height,
  int frameCount,
  int maxThreads,
  int speed,
  int timescale,
  int minQuantizer,
  int maxQuantizer,
  int minQuantizerAlpha,
  int maxQuantizerAlpha,
  int repetitionCount,
  Pointer<Uint8> exif,
  int exifSize,
  Pointer<Pointer<_NativeEncoder>> encoder,
);

@Native<
  Int32 Function(Pointer<_NativeEncoder>, Pointer<Uint8>, IntPtr, Uint64)
>(symbol: 'avif_native_encoder_add_frame')
external int _encoderAddFrame(
  Pointer<_NativeEncoder> encoder,
  Pointer<Uint8> rgba,
  int rgbaSize,
  int durationInTimescales,
);

@Native<
  Int32 Function(
    Pointer<_NativeEncoder>,
    Pointer<Pointer<Uint8>>,
    Pointer<IntPtr>,
  )
>(symbol: 'avif_native_encoder_finish')
external int _encoderFinish(
  Pointer<_NativeEncoder> encoder,
  Pointer<Pointer<Uint8>> data,
  Pointer<IntPtr> size,
);

@Native<Void Function(Pointer<_NativeEncoder>)>(
  symbol: 'avif_native_encoder_destroy',
)
external void _encoderDestroy(Pointer<_NativeEncoder> encoder);

@Native<Void Function(Pointer<Uint8>)>(symbol: 'avif_native_free', isLeaf: true)
external void _nativeFree(Pointer<Uint8> data);

/// A decoded AVIF frame as tightly packed RGBA bytes.
///
/// Alpha is straight (non-premultiplied) unless the decoder was created with
/// `premultiplyAlpha: true`.
class AvifFrame {
  final Uint8List rgba;
  final int width;
  final int height;
  final Duration duration;

  AvifFrame({
    required this.rgba,
    required this.width,
    required this.height,
    required this.duration,
  });
}

class AvifImageData {
  final int width;
  final int height;
  final List<AvifFrame> frames;
  final Duration duration;
  final int repetitionCount;

  AvifImageData({
    required this.width,
    required this.height,
    required this.frames,
    required this.duration,
    required this.repetitionCount,
  });
}

/// Decodes an AVIF image frame by frame.
///
/// Frames contain straight (non-premultiplied) alpha by default. Renderers
/// that expect premultiplied pixels, such as Flutter's
/// `ui.PixelFormat.rgba8888`, should pass `premultiplyAlpha: true` so libavif
/// multiplies the colour channels by alpha during YUV-to-RGB conversion.
class AvifDecoder {
  AvifDecoder._(
    this._handle, {
    required this.width,
    required this.height,
    required this.frameCount,
    required this.duration,
    required this.repetitionCount,
    required this.premultiplyAlpha,
  });

  final Pointer<_NativeDecoder> _handle;
  final int width;
  final int height;
  final int frameCount;
  final Duration duration;
  final int repetitionCount;

  /// Whether decoded frames have premultiplied alpha.
  final bool premultiplyAlpha;
  int _frameIndex = 0;
  bool _disposed = false;

  factory AvifDecoder(Uint8List bytes, {bool premultiplyAlpha = false}) {
    if (!avifNativeCapabilities.canDecode) {
      throw UnsupportedError(
        'AVIF decoding is not included in this build. Configure avif_native '
        'features as decode or full.',
      );
    }
    if (bytes.isEmpty) throw AvifDecodeException('input is empty');

    final data = calloc<Uint8>(bytes.length);
    final decoder = calloc<Pointer<_NativeDecoder>>();
    final width = calloc<Int32>();
    final height = calloc<Int32>();
    final frameCount = calloc<Int32>();
    final duration = calloc<Double>();
    final repetitionCount = calloc<Int32>();
    data.asTypedList(bytes.length).setAll(0, bytes);

    try {
      final result = _decoderCreate(
        data,
        bytes.length,
        decoder,
        width,
        height,
        frameCount,
        duration,
        repetitionCount,
        premultiplyAlpha ? 1 : 0,
      );
      if (result != 0) throw AvifDecodeException(_message(result));
      if (decoder.value == nullptr ||
          width.value <= 0 ||
          height.value <= 0 ||
          frameCount.value <= 0) {
        if (decoder.value != nullptr) _decoderDestroy(decoder.value);
        throw AvifDecodeException('decoder returned invalid image information');
      }
      return AvifDecoder._(
        decoder.value,
        width: width.value,
        height: height.value,
        frameCount: frameCount.value,
        duration: _duration(duration.value),
        repetitionCount: repetitionCount.value,
        premultiplyAlpha: premultiplyAlpha,
      );
    } finally {
      calloc.free(data);
      calloc.free(decoder);
      calloc.free(width);
      calloc.free(height);
      calloc.free(frameCount);
      calloc.free(duration);
      calloc.free(repetitionCount);
    }
  }

  AvifFrame getNextFrame() {
    _ensureOpen();
    if (_frameIndex >= frameCount) {
      throw StateError('no AVIF frames remaining; call reset()');
    }

    final rgba = calloc<Pointer<Uint8>>();
    final width = calloc<Int32>();
    final height = calloc<Int32>();
    final duration = calloc<Double>();
    try {
      final result = _decoderNext(_handle, rgba, width, height, duration);
      if (result != 0) throw AvifDecodeException(_message(result));
      if (rgba.value == nullptr || width.value <= 0 || height.value <= 0) {
        throw AvifDecodeException('decoder returned an invalid frame');
      }
      ++_frameIndex;
      return AvifFrame(
        rgba: Uint8List.fromList(
          rgba.value.asTypedList(width.value * height.value * 4),
        ),
        width: width.value,
        height: height.value,
        duration: _duration(duration.value),
      );
    } finally {
      if (rgba.value != nullptr) _nativeFree(rgba.value);
      calloc.free(rgba);
      calloc.free(width);
      calloc.free(height);
      calloc.free(duration);
    }
  }

  void reset() {
    _ensureOpen();
    final result = _decoderReset(_handle);
    if (result != 0) throw AvifDecodeException(_message(result));
    _frameIndex = 0;
  }

  void dispose() {
    if (_disposed) return;
    _decoderDestroy(_handle);
    _disposed = true;
  }

  void _ensureOpen() {
    if (_disposed) throw StateError('AVIF decoder has been disposed');
  }
}

/// Decodes every frame of an AVIF image.
///
/// Frames contain straight (non-premultiplied) alpha unless
/// [premultiplyAlpha] is true. See [AvifDecoder] for details.
AvifImageData decodeAvif(Uint8List bytes, {bool premultiplyAlpha = false}) {
  final decoder = AvifDecoder(bytes, premultiplyAlpha: premultiplyAlpha);
  try {
    final frames = [
      for (var i = 0; i < decoder.frameCount; ++i) decoder.getNextFrame(),
    ];
    return AvifImageData(
      width: decoder.width,
      height: decoder.height,
      frames: frames,
      duration: decoder.duration,
      repetitionCount: decoder.repetitionCount,
    );
  } finally {
    decoder.dispose();
  }
}

/// One frame to encode.
///
/// [rgba] must be straight (non-premultiplied) RGBA, matching the default
/// output of [decodeAvif].
class AvifEncodeFrame {
  final Uint8List rgba;
  final Duration duration;

  AvifEncodeFrame({required this.rgba, this.duration = Duration.zero});
}

class AvifEncodeOptions {
  final int maxThreads;
  final int speed;
  final int timescale;
  final int minQuantizer;
  final int maxQuantizer;
  final int minQuantizerAlpha;
  final int maxQuantizerAlpha;
  final int repetitionCount;

  const AvifEncodeOptions({
    this.maxThreads = 4,
    this.speed = 10,
    this.timescale = 1000,
    this.minQuantizer = 25,
    this.maxQuantizer = 40,
    this.minQuantizerAlpha = 25,
    this.maxQuantizerAlpha = 40,
    this.repetitionCount = -1,
  });
}

Uint8List encodeAvifFrames({
  required int width,
  required int height,
  required List<AvifEncodeFrame> frames,
  AvifEncodeOptions options = const AvifEncodeOptions(),
  Uint8List? exif,
}) {
  if (!avifNativeCapabilities.canEncode) {
    throw UnsupportedError(
      'AVIF encoding is not included in this build. Configure avif_native '
      'features as encode or full.',
    );
  }
  _validateEncode(width, height, frames, options);

  final encoder = calloc<Pointer<_NativeEncoder>>();
  final exifData = exif == null || exif.isEmpty
      ? nullptr.cast<Uint8>()
      : calloc<Uint8>(exif.length);
  if (exif != null && exif.isNotEmpty) {
    exifData.asTypedList(exif.length).setAll(0, exif);
  }

  try {
    final result = _encoderCreate(
      width,
      height,
      frames.length,
      options.maxThreads,
      options.speed,
      options.timescale,
      options.minQuantizer,
      options.maxQuantizer,
      options.minQuantizerAlpha,
      options.maxQuantizerAlpha,
      options.repetitionCount,
      exifData,
      exif?.length ?? 0,
      encoder,
    );
    if (result != 0) throw AvifEncodeException(_message(result));

    for (final frame in frames) {
      final pixels = calloc<Uint8>(frame.rgba.length);
      pixels.asTypedList(frame.rgba.length).setAll(0, frame.rgba);
      try {
        var ticks =
            (frame.duration.inMicroseconds * options.timescale + 500000) ~/
            1000000;
        if (ticks < 1) ticks = 1;
        final addResult = _encoderAddFrame(
          encoder.value,
          pixels,
          frame.rgba.length,
          ticks,
        );
        if (addResult != 0) {
          throw AvifEncodeException(_message(addResult));
        }
      } finally {
        calloc.free(pixels);
      }
    }

    final output = calloc<Pointer<Uint8>>();
    final outputSize = calloc<IntPtr>();
    try {
      final finishResult = _encoderFinish(encoder.value, output, outputSize);
      if (finishResult != 0) {
        throw AvifEncodeException(_message(finishResult));
      }
      return Uint8List.fromList(output.value.asTypedList(outputSize.value));
    } finally {
      if (output.value != nullptr) _nativeFree(output.value);
      calloc.free(output);
      calloc.free(outputSize);
    }
  } finally {
    if (encoder.value != nullptr) _encoderDestroy(encoder.value);
    if (exifData != nullptr) calloc.free(exifData);
    calloc.free(encoder);
  }
}

void _validateEncode(
  int width,
  int height,
  List<AvifEncodeFrame> frames,
  AvifEncodeOptions options,
) {
  if (width <= 0 || height <= 0 || frames.isEmpty) {
    throw AvifEncodeException('width, height, and frames must be non-empty');
  }
  final expectedBytes = width * height * 4;
  if (frames.any((frame) => frame.rgba.length != expectedBytes)) {
    throw AvifEncodeException(
      'every frame must contain width × height × 4 bytes',
    );
  }
  if (frames.length > 1 &&
      frames.any((frame) => frame.duration <= Duration.zero)) {
    throw AvifEncodeException('animated frames must have a positive duration');
  }
  if (options.maxThreads <= 0 ||
      options.speed < 0 ||
      options.speed > 10 ||
      options.timescale <= 0 ||
      options.minQuantizer < 0 ||
      options.minQuantizer > options.maxQuantizer ||
      options.maxQuantizer > 63 ||
      options.minQuantizerAlpha < 0 ||
      options.minQuantizerAlpha > options.maxQuantizerAlpha ||
      options.maxQuantizerAlpha > 63 ||
      options.repetitionCount < -2) {
    throw AvifEncodeException('invalid AVIF encoder options');
  }
}

Duration _duration(double seconds) =>
    Duration(microseconds: (seconds * Duration.microsecondsPerSecond).round());

String _message(int result) => 'libavif error ${-result}';

class AvifDecodeException implements Exception {
  final String message;
  AvifDecodeException(this.message);

  @override
  String toString() => 'AvifDecodeException: $message';
}

class AvifEncodeException implements Exception {
  final String message;
  AvifEncodeException(this.message);

  @override
  String toString() => 'AvifEncodeException: $message';
}
