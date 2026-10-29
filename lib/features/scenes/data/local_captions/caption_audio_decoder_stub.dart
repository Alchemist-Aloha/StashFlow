import 'dart:io';
import 'dart:typed_data';

class CaptionAudioDecoder {
  Future<Float32List> read({
    required String url,
    required Map<String, String> headers,
    required Duration start,
    required Duration end,
    required String audioTrack,
    required Directory temporaryDirectory,
  }) => Future.error(UnsupportedError('Native audio required'));
  void cancel() {}
  void close() {}
}
