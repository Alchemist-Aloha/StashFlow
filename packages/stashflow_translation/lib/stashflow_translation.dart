import 'dart:ffi';
import 'package:ffi/ffi.dart';

@Native<Pointer<Void> Function(Pointer<Char>, Pointer<Pointer<Char>>)>(
  symbol: 'sf_translation_open',
)
external Pointer<Void> _open(
  Pointer<Char> directory,
  Pointer<Pointer<Char>> error,
);
@Native<
  Pointer<Char> Function(
    Pointer<Void>,
    Pointer<Char>,
    Pointer<Char>,
    Pointer<Pointer<Char>>,
  )
>(symbol: 'sf_translation_run')
external Pointer<Char> _run(
  Pointer<Void> handle,
  Pointer<Char> text,
  Pointer<Char> languageToken,
  Pointer<Pointer<Char>> error,
);
@Native<Void Function(Pointer<Void>)>(symbol: 'sf_translation_close')
external void _close(Pointer<Void> handle);
@Native<Void Function(Pointer<Void>)>(symbol: 'sf_translation_free')
external void _free(Pointer<Void> text);

/// Synchronous, isolate-confined inference. Keep this off Flutter's UI isolate.
/// Call [close] after the last request to release native model memory.
class MarianTranslator {
  MarianTranslator(String directory) {
    final path = directory.toNativeUtf8();
    final error = calloc<Pointer<Char>>();
    try {
      _handle = _open(path.cast(), error);
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

  String translate(String text, {String languageToken = ''}) {
    if (_handle == nullptr) throw StateError('Translator is closed');
    final input = text.toNativeUtf8();
    final token = languageToken.toNativeUtf8();
    final error = calloc<Pointer<Char>>();
    Pointer<Char> result = nullptr;
    try {
      result = _run(_handle, input.cast(), token.cast(), error);
      if (result == nullptr) throw StateError('Local translation failed');
      return result.cast<Utf8>().toDartString();
    } finally {
      calloc.free(input);
      calloc.free(token);
      _free(result.cast());
      _free(error.value.cast());
      calloc.free(error);
    }
  }

  void close() {
    _close(_handle);
    _handle = nullptr;
  }
}
