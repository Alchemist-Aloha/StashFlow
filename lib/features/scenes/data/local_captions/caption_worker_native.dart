import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:stashflow_translation/stashflow_translation.dart';

import 'caption_cue.dart';
import 'caption_options.dart';
import 'local_caption_model.dart';

/// Marian models kept loaded at once, so auto-detected speech alternating
/// between two languages does not reload a model for every window.
const _maxTranslators = 2;

/// Isolate-confined ASR plus up to [_maxTranslators] lazily loaded Marian
/// models. Requests are serialized by CaptionSession; close queues behind
/// inference.
class CaptionWorker {
  CaptionWorker._(this._isolate, this._commands, this.speechProvider);
  final Isolate _isolate;
  final SendPort _commands;

  /// The sherpa-onnx provider the speech recognizer actually initialized with:
  /// `cpu` when acceleration is off, unsupported, or failed to initialize.
  final String speechProvider;

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
      if (result is! (SendPort, String)) {
        throw StateError('Caption engine initialization failed');
      }
      return CaptionWorker._(isolate, result.$1, result.$2);
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

const _offlineEngines = [
  'whisper',
  'sensevoice',
  'paraformer',
  'offline-transducer',
];

/// Builds the recognizer for [model] on [provider]. Throws when sherpa-onnx
/// cannot create it, so the caller can retry on the CPU.
(sherpa.OnlineRecognizer?, sherpa.OfflineRecognizer?) _recognizer(
  LocalCaptionModel model,
  String directory,
  String source,
  CaptionOptions options,
  String provider,
) {
  if (_offlineEngines.contains(model.engine)) {
    return (
      null,
      sherpa.OfflineRecognizer(
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
            provider: provider,
            debug: false,
          ),
        ),
      ),
    );
  }
  return (
    sherpa.OnlineRecognizer(
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
          provider: provider,
          debug: false,
        ),
        enableEndpoint: false,
      ),
    ),
    null,
  );
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
  // Map literals keep insertion order, which is recency order here: the first
  // entry is evicted first.
  final translators = <String, MarianTranslator>{};
  final commands = ReceivePort();

  MarianTranslator translatorFor(LocalCaptionModel pair, String path) {
    final cached = translators.remove(pair.id);
    if (cached != null) return translators[pair.id] = cached;
    while (translators.length >= _maxTranslators) {
      final oldest = translators.keys.first;
      translators.remove(oldest)!.close();
    }
    return translators[pair.id] = MarianTranslator(
      path,
      threads: options.threads,
    );
  }

  void release() {
    online?.free();
    online = null;
    offline?.free();
    offline = null;
    vad?.free();
    vad = null;
    for (final translator in translators.values) {
      translator.close();
    }
    translators.clear();
  }

  try {
    sherpa.initBindings();
    var provider = captionSpeechProvider(
      accelerate: options.accelerate,
      os: Platform.operatingSystem,
      graphFiles: model.files.map((file) => file.name),
    );
    try {
      (online, offline) = _recognizer(
        model,
        directory,
        source,
        options,
        provider,
      );
    } on Object {
      if (provider == 'cpu') rethrow;
      // Accelerator delegates can reject a model or a driver at session
      // creation. Fall back once and report the provider actually in use.
      provider = 'cpu';
      (online, offline) = _recognizer(
        model,
        directory,
        source,
        options,
        provider,
      );
    }
    if (offline != null) {
      // Silero VAD is tiny and runs per 32 ms chunk; accelerator dispatch
      // overhead would exceed its compute, so it always stays on the CPU.
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
    }
    ready.send((commands.sendPort, provider));
    await for (final message in commands) {
      final (input, reply) = message as (Object?, SendPort);
      if (input == null) {
        release();
        reply.send(true);
        break;
      }
      try {
        final (samples, audioStart, windowStart, windowEnd) =
            input as (Float32List, Duration, Duration, Duration);
        final cues = <CaptionCue>[];
        final streaming = online;
        if (streaming != null) {
          final stream = streaming.createStream();
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
              while (streaming.isReady(stream)) {
                streaming.decode(stream);
              }
            }
            stream.acceptWaveform(
              samples: Float32List(8000),
              sampleRate: 16000,
            );
            stream.inputFinished();
            while (streaming.isReady(stream)) {
              streaming.decode(stream);
            }
            final result = streaming.getResult(stream);
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
          final detector = vad!;
          final recognizer = offline!;
          detector.reset();
          final chunk = Float32List(512);
          for (var offset = 0; offset < samples.length; offset += 512) {
            final end = (offset + 512).clamp(0, samples.length);
            chunk
              ..setRange(0, end - offset, samples, offset)
              ..fillRange(end - offset, 512, 0);
            detector.acceptWaveform(chunk);
          }
          detector.flush();
          while (!detector.isEmpty()) {
            final speech = detector.front();
            detector.pop();
            final stream = recognizer.createStream();
            try {
              stream.acceptWaveform(samples: speech.samples, sampleRate: 16000);
              recognizer.decode(stream);
              final result = recognizer.getResult(stream);
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
        // Route every phrase first so a missing pair fails before any model
        // loads, then translate each pair's phrases in one native batch.
        final output = List<CaptionCue?>.filled(cues.length, null);
        final batches = <String, (LocalCaptionModel, String, List<int>)>{};
        for (var i = 0; i < cues.length; i++) {
          final language = cues[i].language ?? source;
          if (language == options.outputLanguage) {
            output[i] = cues[i];
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
          batches
              .putIfAbsent(pair.$1.id, () => (pair.$1, pair.$2, []))
              .$3
              .add(i);
        }
        for (final (pair, path, indices) in batches.values) {
          final texts = translatorFor(pair, path).translateAll([
            for (final i in indices) cues[i].text,
          ], languageToken: pair.languageToken(options.outputLanguage));
          for (var j = 0; j < indices.length; j++) {
            final cue = cues[indices[j]];
            output[indices[j]] = CaptionCue(
              cue.start,
              cue.end,
              options.bilingual ? '${cue.text}\n${texts[j]}' : texts[j],
              language: cue.language ?? source,
            );
          }
        }
        reply.send([for (final cue in output) cue!]);
      } on CaptionTranslationUnavailable catch (error) {
        reply.send(error);
      } on Object {
        reply.send('Caption inference failed');
      }
    }
  } on Object {
    ready.send('Caption engine initialization failed');
  } finally {
    release();
    commands.close();
  }
}
