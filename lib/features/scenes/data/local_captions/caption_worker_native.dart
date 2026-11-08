import 'dart:isolate';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:stashflow_translation/stashflow_translation.dart';
import 'caption_cue.dart';
import 'caption_options.dart';
import 'local_caption_model.dart';

/// Isolate-confined ASR plus one lazily loaded Marian model at a time.
/// Requests are serialized by CaptionSession; close queues behind inference.
class CaptionWorker {
  CaptionWorker._(this._isolate, this._commands);
  final Isolate _isolate;
  final SendPort _commands;

  static Future<CaptionWorker> start(
    LocalCaptionModel model,
    String directory, {
    LocalCaptionModel? translation,
    String? translationDirectory,
    List<(LocalCaptionModel, String)> translations = const [],
    CaptionOptions options = const CaptionOptions(),
    bool translate = false,
  }) async {
    if (!options.isValid) throw ArgumentError('Invalid caption options');
    final ready = ReceivePort();
    final isolate = await Isolate.spawn(_worker, (
      ready.sendPort,
      model,
      directory,
      [
        ...translations,
        if (translation != null) (translation, translationDirectory!),
      ],
      options,
      translate || translation != null,
    ));
    try {
      final result = await ready.first.timeout(const Duration(seconds: 90));
      if (result is! SendPort) {
        throw StateError('Caption engine initialization failed');
      }
      return CaptionWorker._(isolate, result);
    } on Object {
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
    if (response is CaptionTranslationUnavailable) throw response;
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
  (
    SendPort,
    LocalCaptionModel,
    String,
    List<(LocalCaptionModel, String)>,
    CaptionOptions,
    bool,
  )
  args,
) async {
  final (ready, model, directory, translations, options, translate) = args;
  final source = options.sourceLanguage == 'auto' && !model.canDetectLanguage
      ? model.sourceLanguages.first
      : options.sourceLanguage;
  sherpa.OnlineRecognizer? online;
  sherpa.OfflineRecognizer? offline;
  sherpa.VoiceActivityDetector? vad;
  MarianTranslator? translator;
  String? activeTranslation;
  final commands = ReceivePort();
  try {
    sherpa.initBindings();
    if ([
      'whisper',
      'sensevoice',
      'paraformer',
      'offline-transducer',
    ].contains(model.engine)) {
      offline = sherpa.OfflineRecognizer(
        sherpa.OfflineRecognizerConfig(
          model: sherpa.OfflineModelConfig(
            whisper: model.engine == 'whisper'
                ? sherpa.OfflineWhisperModelConfig(
                    encoder: p.join(directory, model.files[0].name),
                    decoder: p.join(directory, model.files[1].name),
                    language: source == 'auto' ? '' : source,
                    task: 'transcribe',
                  )
                : const sherpa.OfflineWhisperModelConfig(),
            senseVoice: model.engine == 'sensevoice'
                ? sherpa.OfflineSenseVoiceModelConfig(
                    model: p.join(directory, model.files[0].name),
                    language: source == 'auto' ? 'auto' : source,
                  )
                : const sherpa.OfflineSenseVoiceModelConfig(),
            paraformer: model.engine == 'paraformer'
                ? sherpa.OfflineParaformerModelConfig(
                    model: p.join(directory, model.files[0].name),
                  )
                : const sherpa.OfflineParaformerModelConfig(),
            transducer: model.engine == 'offline-transducer'
                ? sherpa.OfflineTransducerModelConfig(
                    encoder: p.join(directory, model.files[0].name),
                    decoder: p.join(directory, model.files[1].name),
                    joiner: p.join(directory, model.files[2].name),
                  )
                : const sherpa.OfflineTransducerModelConfig(),
            tokens: p.join(directory, model.tokensFile),
            numThreads: options.threads,
            debug: false,
          ),
        ),
      );
      vad = sherpa.VoiceActivityDetector(
        config: sherpa.VadModelConfig(
          sileroVad: sherpa.SileroVadModelConfig(
            model: p.join(directory, 'silero_vad.onnx'),
            threshold: options.speechThreshold,
            minSilenceDuration: 0.3,
            maxSpeechDuration: (options.windowSeconds - 1)
                .clamp(2, 5)
                .toDouble(),
          ),
          debug: false,
        ),
        bufferSizeInSeconds: options.windowSeconds + 4,
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
            tokens: p.join(directory, model.tokensFile),
            modelType: model.engine == 'transducer' ? '' : model.engine,
            numThreads: options.threads,
            debug: false,
          ),
          enableEndpoint: false,
        ),
      );
    }
    ready.send(commands.sendPort);
    await for (final message in commands) {
      final (input, reply) = message as (Object?, SendPort);
      if (input == null) {
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
                language: source,
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
              final language = captionResultLanguage(result.lang, source);
              final start =
                  audioStart +
                  Duration(
                    microseconds: (speech.start * 1000000 / 16000).round(),
                  );
              // shortcut: plain Whisper exports lack attention outputs; VAD phrase
              // timing works until attention-enabled exports are adopted.
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
                cues.add(
                  CaptionCue(
                    clippedStart,
                    clippedEnd,
                    text,
                    language: language,
                  ),
                );
              }
            } finally {
              stream.free();
            }
          }
        }
        if (!translate) {
          reply.send(cues);
          continue;
        }
        final output = <CaptionCue>[];
        for (final cue in cues) {
          final language = cue.language ?? source;
          if (language == options.outputLanguage) {
            output.add(cue);
            continue;
          }
          final pair = translations
              .where(
                (p) =>
                    p.$1.source == language &&
                    p.$1.supportsOutput(options.outputLanguage),
              )
              .firstOrNull;
          if (pair == null) {
            throw CaptionTranslationUnavailable(
              language,
              options.outputLanguage,
            );
          }
          if (activeTranslation != pair.$1.id) {
            translator?.close();
            translator = null;
            translator = MarianTranslator(pair.$2);
            activeTranslation = pair.$1.id;
          }
          final text = translator!.translate(
            cue.text,
            languageToken: pair.$1.languageToken(options.outputLanguage),
          );
          output.add(
            CaptionCue(
              cue.start,
              cue.end,
              options.bilingual ? '${cue.text}\n$text' : text,
              language: language,
            ),
          );
        }
        reply.send(output);
      } on CaptionTranslationUnavailable catch (error) {
        reply.send(error);
      } on Object {
        reply.send('Caption inference failed');
      }
    }
  } on Object {
    ready.send('Caption engine initialization failed');
  } finally {
    online?.free();
    offline?.free();
    vad?.free();
    translator?.close();
    commands.close();
  }
}
