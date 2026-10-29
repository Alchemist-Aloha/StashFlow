import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_audio_decoder.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_worker.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/local_caption_model.dart';
import 'package:stashflow_translation/stashflow_translation.dart';

const _native = bool.fromEnvironment('RUN_LOCAL_CAPTION_NATIVE');
const _models = String.fromEnvironment(
  'CAPTION_MODEL_ROOT',
  defaultValue: 'build/caption-smoke-models',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final id in ['zipformer-zh', 'whisper-ja']) {
    test('native $id loads and silence produces no subtitles', () async {
      final model = LocalCaptionModel.find(id)!;
      final worker = await CaptionWorker.start(
        model,
        Directory('$_models/$id').absolute.path,
      );
      try {
        expect(
          await worker.process(
            Float32List(16000),
            Duration.zero,
            Duration.zero,
            const Duration(seconds: 1),
          ),
          isEmpty,
        );
        if (id == 'whisper-ja') {
          // Exercise Whisper's VAD-timed speech path too; this English fixture
          // checks the API pipeline, not Japanese recognition quality.
          sherpa.initBindings();
          final wave = sherpa.readWave('$_models/zipformer-en/test.wav');
          final cues = await worker.process(
            wave.samples,
            Duration.zero,
            const Duration(seconds: 1),
            const Duration(seconds: 3),
          );
          expect(cues, isNotEmpty);
          expect(
            cues.every(
              (cue) =>
                  cue.start >= const Duration(seconds: 1) &&
                  cue.end <= const Duration(seconds: 3) &&
                  cue.start < cue.end &&
                  cue.text.isNotEmpty,
            ),
            isTrue,
          );
        }
      } finally {
        await worker.close();
      }
    }, skip: !_native);
  }
  for (final (id, input) in [
    ('marian-zh-en', '你好，你好吗？'),
    ('marian-ja-en', 'こんにちは。お元気ですか？'),
  ]) {
    test('native $id translates to English locally', () {
      final translator = MarianTranslator(
        Directory('$_models/$id').absolute.path,
      );
      try {
        expect(translator.translate(input), matches(RegExp('[a-zA-Z]')));
      } finally {
        translator.close();
      }
    }, skip: !_native);
  }
  test(
    'native decoder produces bounded 16 kHz mono PCM and removes temporary audio',
    () async {
      MediaKit.ensureInitialized();
      final dir = await Directory.systemTemp.createTemp('caption-native-test-');
      final bytes = ByteData(44 + 8 * 16000 * 2);
      void text(int offset, String value) => bytes.buffer
          .asUint8List()
          .setRange(offset, offset + value.length, value.codeUnits);
      text(0, 'RIFF');
      bytes.setUint32(4, bytes.lengthInBytes - 8, Endian.little);
      text(8, 'WAVEfmt ');
      bytes.setUint32(16, 16, Endian.little);
      bytes.setUint16(20, 1, Endian.little);
      bytes.setUint16(22, 1, Endian.little);
      bytes.setUint32(24, 16000, Endian.little);
      bytes.setUint32(28, 32000, Endian.little);
      bytes.setUint16(32, 2, Endian.little);
      bytes.setUint16(34, 16, Endian.little);
      text(36, 'data');
      bytes.setUint32(40, bytes.lengthInBytes - 44, Endian.little);
      for (var i = 0; i < 8 * 16000; i++) {
        bytes.setInt16(
          44 + 2 * i,
          (sin(i * 2 * pi * 440 / 16000) * 12000).round(),
          Endian.little,
        );
      }
      final wav = File('${dir.path}/input.wav');
      await wav.writeAsBytes(bytes.buffer.asUint8List());
      final decoder = CaptionAudioDecoder();
      try {
        final audio = await decoder.read(
          url: wav.path,
          headers: {},
          start: const Duration(seconds: 2),
          end: const Duration(seconds: 4),
          audioTrack: 'auto',
          temporaryDirectory: dir,
        );
        expect(audio.length, closeTo(32000, 1600));
        expect(audio.any((sample) => sample.abs() > 0.1), isTrue);
        expect((await dir.list().toList()).whereType<Directory>(), isEmpty);
      } finally {
        decoder.close();
        await dir.delete(recursive: true);
      }
    },
    skip: !_native,
  );

  test('Dart native assets load Marian and translate without a server', () {
    final translator = MarianTranslator(
      Directory('$_models/marian-en-zh').absolute.path,
    );
    try {
      final result = translator.translate(
        'Hello, how are you?',
        languageToken: '>>cmn_Hans<<',
      );
      expect(result, matches(RegExp(r'[\u4e00-\u9fff]')));
    } finally {
      translator.close();
    }
    expect(() => translator.translate('closed'), throwsStateError);
  }, skip: !_native);

  test(
    'persistent sherpa worker can transcribe English and close safely',
    () async {
      final model = LocalCaptionModel.find('zipformer-en')!;
      final worker = await CaptionWorker.start(
        model,
        Directory('$_models/zipformer-en').absolute.path,
      );
      try {
        final result = await worker.process(
          Float32List(16000),
          Duration.zero,
          Duration.zero,
          const Duration(seconds: 1),
        );
        expect(result, isEmpty);
        sherpa.initBindings();
        final wave = sherpa.readWave('$_models/zipformer-en/test.wav');
        final speech = await worker.process(
          wave.samples,
          Duration.zero,
          Duration.zero,
          Duration(
            microseconds: (wave.samples.length * 1000000 / wave.sampleRate)
                .round(),
          ),
        );
        expect(
          speech.map((cue) => cue.text).join(' ').toLowerCase(),
          contains('nightfall'),
        );
      } finally {
        await worker.close();
      }
    },
    skip: !_native,
  );
}
