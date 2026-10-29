import 'dart:typed_data';
import 'caption_cue.dart';
import 'local_caption_model.dart';

class CaptionWorker {
  static Future<CaptionWorker> start(
    LocalCaptionModel model,
    String directory, {
    LocalCaptionModel? translation,
    String? translationDirectory,
  }) => Future.error(UnsupportedError('Native inference required'));
  Future<List<CaptionCue>> process(
    Float32List samples,
    Duration audioStart,
    Duration windowStart,
    Duration windowEnd,
  ) => Future.error(UnsupportedError('Native inference required'));
  Future<void> close() async {}
}
