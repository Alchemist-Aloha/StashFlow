import 'dart:ffi';
import 'package:ffi/ffi.dart';

@Native<Pointer<Void> Function(Pointer<Char>, Int32, Pointer<Pointer<Char>>)>(
  symbol: 'sf_translation_open',
)
external Pointer<Void> _open(
  Pointer<Char> directory,
  int threads,
  Pointer<Pointer<Char>> error,
);
@Native<
  Int32 Function(
    Pointer<Void>,
    Pointer<Pointer<Char>>,
    Int32,
    Pointer<Char>,
    Pointer<Pointer<Char>>,
    Pointer<Pointer<Char>>,
  )
>(symbol: 'sf_translation_run_batch')
external int _runBatch(
  Pointer<Void> handle,
  Pointer<Pointer<Char>> texts,
  int count,
  Pointer<Char> languageToken,
  Pointer<Pointer<Char>> outputs,
  Pointer<Pointer<Char>> error,
);
@Native<Void Function(Pointer<Void>)>(symbol: 'sf_translation_close')
external void _close(Pointer<Void> handle);
@Native<Void Function(Pointer<Void>)>(symbol: 'sf_translation_free')
external void _free(Pointer<Void> text);

/// Synchronous, isolate-confined inference. Keep this off Flutter's UI isolate.
/// Call [close] after the last request to release native model memory.
class MarianTranslator {
  /// Loads the model in [directory]; [threads] (1-8) bounds CPU inference.
  MarianTranslator(String directory, {int threads = 2}) {
    final path = directory.toNativeUtf8();
    final error = calloc<Pointer<Char>>();
    try {
      _handle = _open(path.cast(), threads.clamp(1, 8), error);
      if (_handle == nullptr) {
        throw StateError('Local translation model could not be loaded');
      }
    } finally {
      calloc.free(path);
      _free(error.value.cast());
      calloc.free(error);
    }
  }
  Pointer<Void> _handle = nullptr;

  /// Largest batch accepted by one native call.
  static const maxBatch = 64;

  String translate(String text, {String languageToken = ''}) =>
      translateAll([text], languageToken: languageToken).single;

  /// Translates [texts] in batches of at most [maxBatch], preserving order.
  /// Batching amortizes encoder/decoder work across phrases of one window.
  List<String> translateAll(List<String> texts, {String languageToken = ''}) {
    if (_handle == nullptr) throw StateError('Translator is closed');
    final results = <String>[];
    for (var offset = 0; offset < texts.length; offset += maxBatch) {
      final end = (offset + maxBatch).clamp(0, texts.length);
      results.addAll(_run(texts.sublist(offset, end), languageToken));
    }
    return results;
  }

  List<String> _run(List<String> texts, String languageToken) {
    final count = texts.length;
    final inputs = calloc<Pointer<Char>>(count);
    final outputs = calloc<Pointer<Char>>(count);
    final token = languageToken.toNativeUtf8();
    final error = calloc<Pointer<Char>>();
    try {
      for (var i = 0; i < count; i++) {
        inputs[i] = texts[i].toNativeUtf8().cast();
      }
      if (_runBatch(_handle, inputs, count, token.cast(), outputs, error) !=
          1) {
        throw StateError('Local translation failed');
      }
      return [
        for (var i = 0; i < count; i++) outputs[i].cast<Utf8>().toDartString(),
      ];
    } finally {
      for (var i = 0; i < count; i++) {
        if (inputs[i] != nullptr) calloc.free(inputs[i]);
        _free(outputs[i].cast());
      }
      calloc.free(inputs);
      calloc.free(outputs);
      calloc.free(token);
      _free(error.value.cast());
      calloc.free(error);
    }
  }

  void close() {
    _close(_handle);
    _handle = nullptr;
  }
}
