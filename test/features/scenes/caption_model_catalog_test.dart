import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_model_catalog.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/local_caption_model.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_options.dart';

class _Hub implements HttpClientAdapter {
  final requests = <Uri>[];
  final responses = <String, Object>{};
  final headers = <String, Map<String, List<String>>>{};
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    final full = '${options.uri.path}?${options.uri.query}';
    final key = responses.containsKey(full) ? full : options.uri.path;
    final value = responses[key];
    if (value == null) throw StateError('Unexpected request $key');
    final bytes = value is List<int> ? value : utf8.encode(jsonEncode(value));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        Headers.contentLengthHeader: ['${bytes.length}'],
        ...?headers[key],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'fixed source bypasses detection metadata; Auto uses detected language',
    () {
      expect(captionResultLanguage('<|de|>', 'en'), 'en');
      expect(captionResultLanguage('<|de|>', 'auto'), 'de');
      expect(captionResultLanguage('unrecognized', 'auto'), 'und');
      expect(captionResultLanguage('', 'zh'), 'zh');
    },
  );

  const revision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  late _Hub hub;
  late CaptionModelCatalog catalog;
  setUp(() {
    hub = _Hub();
    catalog = CaptionModelCatalog(Dio()..httpClientAdapter = hub);
  });
  tearDown(() => catalog.dio.close());

  Map<String, Object> blob(String name) => {
    'rfilename': name,
    'size': 100,
    'lfs': {'sha256': List.filled(64, 'b').join()},
  };
  void metadata(String repo, List<Map<String, Object>> files) {
    hub.responses['/api/models/$repo'] = {
      'id': repo,
      'sha': revision,
      'siblings': files,
    };
  }

  test(
    'catalog filters incompatible architectures and rejects foreign pagination',
    () async {
      hub.responses['/api/models'] = [
        {'id': 'upstream/sherpa-onnx-whisper-base'},
        {'id': 'upstream/sherpa-onnx-vits-en'},
        {'id': 'upstream/sherpa-onnx-streaming-zipformer-en'},
      ];
      hub.headers['/api/models'] = {
        'link': ['<https://evil.example/api/models>; rel="next"'],
      };
      await expectLater(catalog.list(false), throwsFormatException);
      expect(hub.requests.length, 1);
      hub.headers.clear();
      final models = await catalog.list(false);
      expect(models.map((m) => m.engine), ['transducer', 'whisper']);
    },
  );

  test('valid pagination merges and deduplicates all pages', () async {
    hub.responses['/api/models'] = [
      {'id': 'upstream/sherpa-onnx-whisper-tiny'},
    ];
    hub.headers['/api/models'] = {
      'link': ['<https://huggingface.co/api/models?cursor=page2>; rel="next"'],
    };
    hub.responses['/api/models?cursor=page2'] = [
      {'id': 'upstream/sherpa-onnx-whisper-tiny'},
      {'id': 'upstream/sherpa-onnx-whisper-base'},
    ];
    final result = await catalog.list(false);
    expect(result.length, 2);
    expect(hub.requests.length, 2);
  });

  test(
    'multilingual Whisper is not restricted to Japanese; .en is English-only',
    () {
      final multilingual = CaptionHubModel.fromJson({
        'id': 'upstream/sherpa-onnx-whisper-tiny',
      }, false)!;
      final english = CaptionHubModel.fromJson({
        'id': 'upstream/sherpa-onnx-whisper-tiny.en',
      }, false)!;
      expect(
        multilingual.languages,
        containsAll(['en', 'ja', 'de', 'ar', 'zh']),
      );
      expect(english.languages, ['en']);
      expect(LocalCaptionModel.find('whisper-ja')!.canDetectLanguage, isTrue);
      expect(
        LocalCaptionModel.find('whisper-ja')!.supportsSource('auto'),
        isTrue,
      );
    },
  );

  test(
    'Whisper inspection chooses matching INT8 files and tokens, preserves VAD',
    () async {
      const repo = 'upstream/sherpa-onnx-whisper-tiny-attention';
      metadata(repo, [
        for (final size in ['base', 'tiny']) ...[
          blob('$size-encoder.int8.onnx'),
          blob('$size-encoder.int8.onnx.data'),
          blob('$size-decoder.int8.onnx'),
          blob('$size-decoder.onnx'),
          blob('$size-tokens.txt'),
        ],
      ]);
      final entry = CaptionHubModel.fromJson({'id': repo}, false)!;
      final model = await catalog.resolve(entry);
      expect(model.files.take(3).map((f) => f.name), [
        'tiny-encoder.int8.onnx',
        'tiny-decoder.int8.onnx',
        'tiny-tokens.txt',
      ]);
      expect(model.files.last.name, 'silero_vad.onnx');
      expect(
        model.files.any((f) => f.name == 'tiny-encoder.int8.onnx.data'),
        isTrue,
      );
      expect(model.files.any((f) => f.name.startsWith('base')), isFalse);
      expect(model.canDetectLanguage, isTrue);
      expect(LocalCaptionModel.fromJson(model.toJson()).id, model.id);
      expect(hub.requests.every((uri) => uri.path.startsWith('/api/')), isTrue);
    },
  );

  for (final extension in ['json', 'txt']) {
    test(
      'Marian accepts $extension vocabulary, pins hashes and discovers Chinese target tags',
      () async {
        const repo = 'upstream/opus-mt-en-zh-ctranslate2';
        final config = utf8.encode(
          jsonEncode({'model_type': 'marian', 'add_source_eos': false}),
        );
        final vocabulary = utf8.encode(
          extension == 'json'
              ? '[">>cmn_Hans<<", ">>cmn_Hant<<"]'
              : '>>cmn_Hans<<\n>>cmn_Hant<<\n',
        );
        final vocabName = 'shared_vocabulary.$extension';
        metadata(repo, [
          blob('model.bin'),
          blob('source.spm'),
          blob('target.spm'),
          {'rfilename': 'config.json', 'size': config.length},
          {'rfilename': vocabName, 'size': vocabulary.length},
        ]);
        hub.responses['/$repo/resolve/$revision/config.json'] = config;
        hub.responses['/$repo/resolve/$revision/$vocabName'] = vocabulary;
        final model = await catalog.resolve(
          CaptionHubModel.fromJson({'id': repo}, true)!,
        );
        expect(model.supportsOutput('zh-Hant'), isTrue);
        expect(model.languageToken('zh-Hant'), '>>cmn_Hant<<');
        expect(
          model.files.firstWhere((f) => f.name == 'config.json').sha256,
          sha256.convert(config).toString(),
        );
        expect(hub.requests.any((u) => u.path.endsWith('/model.bin')), isFalse);
      },
    );
  }

  test('rejects wrong model type before downloading weights', () async {
    const repo = 'upstream/opus-mt-en-de';
    final config = utf8.encode('{"model_type":"nllb"}');
    metadata(repo, [
      blob('model.bin'),
      blob('source.spm'),
      blob('target.spm'),
      blob('shared_vocabulary.json'),
      {'rfilename': 'config.json', 'size': config.length},
    ]);
    hub.responses['/$repo/resolve/$revision/config.json'] = config;
    await expectLater(
      catalog.resolve(CaptionHubModel.fromJson({'id': repo}, true)!),
      throwsUnsupportedError,
    );
    expect(hub.requests.any((u) => u.path.endsWith('/model.bin')), isFalse);
  });

  test(
    'imported manifests reject traversal, external URLs, wrong identity and incomplete layouts',
    () {
      final valid = LocalCaptionModel.find('zipformer-en')!.toJson();
      for (final invalid in [
        {...valid, 'repository': '../private'},
        {...valid, 'id': 'hub-s-${List.filled(32, '0').join()}'},
        {
          ...valid,
          'files': [
            {
              'name': '../escape',
              'bytes': 1,
              'sha256': List.filled(64, 'b').join(),
            },
          ],
        },
        {
          ...valid,
          'files': [
            {
              'name': 'encoder.onnx',
              'bytes': 1,
              'sha256': List.filled(64, 'b').join(),
              'url': 'http://localhost/private',
            },
          ],
        },
        {...valid, 'files': <Object>[]},
      ]) {
        expect(
          () => LocalCaptionModel.fromJson(invalid),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'tuning JSON validates bounds and language codes without losing precision',
    () {
      const options = CaptionOptions(
        sourceLanguage: 'auto',
        outputLanguage: 'zh-Hant',
        threads: 4,
        windowSeconds: 8,
        speechThreshold: 0.35,
        delayMilliseconds: -1500,
        bilingual: true,
        translate: true,
      );
      expect(
        CaptionOptions.parse(jsonEncode(options.toJson()))!.toJson(),
        options.toJson(),
      );
      final legacy = options.toJson()..remove('translate');
      final restored = CaptionOptions.parse(jsonEncode(legacy))!;
      expect(restored.translate, isFalse);
      expect(restored.toJson(), {...legacy, 'translate': false});
      for (final invalid in [
        {...options.toJson(), 'translate': 'yes'},
        {...options.toJson(), 'translate': null},
        {...options.toJson(), 'threads': 0},
        {...options.toJson(), 'threads': 100},
        {...options.toJson(), 'window': 0},
        {...options.toJson(), 'window': 99},
        {...options.toJson(), 'threshold': -0.5},
        {...options.toJson(), 'delay': 6000},
        {...options.toJson(), 'source': 'made-up'},
        {...options.toJson(), 'output': 'auto'},
      ]) {
        expect(CaptionOptions.parse(jsonEncode(invalid)), isNull);
      }
    },
  );
}
