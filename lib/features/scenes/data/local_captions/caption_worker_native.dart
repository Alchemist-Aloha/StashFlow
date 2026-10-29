import 'dart:isolate';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:stashflow_translation/stashflow_translation.dart';
import 'caption_cue.dart';
import 'local_caption_model.dart';

/// One isolate-confined ASR/translation engine per caption session. Calls are
/// serialized by CaptionSession; closing queues behind any pending inference.
class CaptionWorker {
  CaptionWorker._(this._isolate, this._commands);
  final Isolate _isolate;
  final SendPort _commands;

  static Future<CaptionWorker> start(
    LocalCaptionModel model,
    String directory, {
    LocalCaptionModel? translation,
    String? translationDirectory,
  }) async {
    final ready = ReceivePort();
    final isolate = await Isolate.spawn(_worker, (
      ready.sendPort,
      model,
      directory,
      translation,
      translationDirectory,
    ));
    try {
      final result = await ready.first.timeout(const Duration(seconds: 90));
      if (result is! SendPort) {
        throw StateError('Caption engine initialization failed');
      }
      return CaptionWorker._(isolate, result);
    } catch (_) {
      isolate.kill();
      rethrow;
    } finally {
      ready.close();
    }
  }

  Future<List<CaptionCue>> process(
    Float32List samples,
    Duration audioStart,
    Duration windowStart,
    Duration windowEnd,
  ) async {
    final response = await _request((
      samples,
      audioStart,
      windowStart,
      windowEnd,
    ));
    if (response is! List<CaptionCue>) {
      throw StateError('Caption inference failed');
    }
    return response;
  }

  Future<Object?> _request(Object? input) async {
    final reply = ReceivePort();
    try {
      _commands.send((input, reply.sendPort));
      return await reply.first.timeout(const Duration(seconds: 90));
    } finally {
      reply.close();
    }
  }

  Future<void> close() async {
    try {
      await _request(null);
    } finally {
      _isolate.kill();
    }
  }
}

Future<void> _worker(
  (SendPort, LocalCaptionModel, String, LocalCaptionModel?, String?) args,
) async {
  final (ready, model, directory, translation, translationDirectory) = args;
  sherpa.OnlineRecognizer? online;
  sherpa.OfflineRecognizer? offline;
  sherpa.VoiceActivityDetector? vad;
  MarianTranslator? translator;
  final commands = ReceivePort();
  try {
    sherpa.initBindings();
    if (model.engine == 'whisper') {
      offline = sherpa.OfflineRecognizer(
        sherpa.OfflineRecognizerConfig(
          model: sherpa.OfflineModelConfig(
            whisper: sherpa.OfflineWhisperModelConfig(
              encoder: p.join(directory, model.files[0].name),
              decoder: p.join(directory, model.files[1].name),
              language: model.source,
              task: 'transcribe',
            ),
            tokens: p.join(directory, model.files[2].name),
            numThreads: 2,
            debug: false,
          ),
        ),
      );
      vad = sherpa.VoiceActivityDetector(
        config: sherpa.VadModelConfig(
          sileroVad: sherpa.SileroVadModelConfig(
            model: p.join(directory, 'silero_vad.onnx'),
            minSilenceDuration: 0.3,
            maxSpeechDuration: 5,
          ),
          debug: false,
        ),
        bufferSizeInSeconds: 15,
      );
    } else {
      online = sherpa.OnlineRecognizer(
        sherpa.OnlineRecognizerConfig(
          model: sherpa.OnlineModelConfig(
            transducer: sherpa.OnlineTransducerModelConfig(
              encoder: p.join(directory, model.files[0].name),
              decoder: p.join(directory, model.files[1].name),
              joiner: p.join(directory, model.files[2].name),
            ),
            tokens: p.join(directory, 'tokens.txt'),
            modelType: model.engine,
            numThreads: 2,
            debug: false,
          ),
          enableEndpoint: false,
        ),
      );
    }
    if (translation != null) {
      translator = MarianTranslator(translationDirectory!);
    }
    ready.send(commands.sendPort);
    await for (final message in commands) {
      final (input, reply) = message as (Object?, SendPort);
      if (input == null) {
        // Acknowledge only after native memory has been released.
        online?.free();
        online = null;
        offline?.free();
        offline = null;
        vad?.free();
        vad = null;
        translator?.close();
        translator = null;
        reply.send(true);
        break;
      }
      try {
        final (samples, audioStart, windowStart, windowEnd) =
            input as (Float32List, Duration, Duration, Duration);
        final cues = <CaptionCue>[];
        if (online != null) {
          final stream = online.createStream();
          try {
            for (var offset = 0; offset < samples.length; offset += 3200) {
              stream.acceptWaveform(
                samples: Float32List.sublistView(
                  samples,
                  offset,
                  (offset + 3200).clamp(0, samples.length),
                ),
                sampleRate: 16000,
              );
              while (online.isReady(stream)) {
                online.decode(stream);
              }
            }
            stream.acceptWaveform(
              samples: Float32List(8000),
              sampleRate: 16000,
            );
            stream.inputFinished();
            while (online.isReady(stream)) {
              online.decode(stream);
            }
            final result = online.getResult(stream);
            cues.addAll(
              captionCuesFromTokens(
                tokens: result.tokens,
                timestamps: result.timestamps,
                audioStart: audioStart,
                windowStart: windowStart,
                windowEnd: windowEnd,
              ),
            );
          } finally {
            stream.free();
          }
        } else {
          vad!.reset();
          for (var offset = 0; offset < samples.length; offset += 512) {
            final chunk = Float32List(512);
            chunk.setRange(
              0,
              (samples.length - offset).clamp(0, 512),
              Float32List.sublistView(
                samples,
                offset,
                (offset + 512).clamp(0, samples.length),
              ),
            );
            vad.acceptWaveform(chunk);
          }
          vad.flush();
          while (!vad.isEmpty()) {
            final speech = vad.front();
            vad.pop();
            final stream = offline!.createStream();
            try {
              stream.acceptWaveform(samples: speech.samples, sampleRate: 16000);
              offline.decode(stream);
              final result = offline.getResult(stream);
              final start =
                  audioStart +
                  Duration(
                    microseconds: (speech.start * 1000000 / 16000).round(),
                  );
              // shortcut: this Whisper export lacks attention outputs; use VAD
              // phrase timing until attention-enabled weights are adopted.
              final end =
                  start +
                  Duration(
                    microseconds: (speech.samples.length * 1000000 / 16000)
                        .round(),
                  );
              final clippedStart = start < windowStart ? windowStart : start;
              final clippedEnd = end > windowEnd ? windowEnd : end;
              final text = result.text.trim();
              if (text.isNotEmpty && clippedStart < clippedEnd) {
                cues.add(CaptionCue(clippedStart, clippedEnd, text));
              }
            } finally {
              stream.free();
            }
          }
        }
        if (translator == null) {
          reply.send(cues);
        } else {
          reply.send(
            cues
                .map(
                  (cue) => CaptionCue(
                    cue.start,
                    cue.end,
                    translator!.translate(
                      cue.text,
                      languageToken: translation!.target == 'zh'
                          ? '>>cmn_Hans<<'
                          : '',
                    ),
                  ),
                )
                .toList(),
          );
        }
      } on Object catch (_) {
        reply.send('Caption inference failed');
      }
    }
  } on Object catch (_) {
    ready.send('Caption engine initialization failed');
  } finally {
    online?.free();
    offline?.free();
    vad?.free();
    translator?.close();
    commands.close();
  }
}
