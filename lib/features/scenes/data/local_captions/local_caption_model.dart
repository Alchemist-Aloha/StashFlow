import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'caption_options.dart';

/// A resolved, revision-pinned model snapshot, independent of the live catalog.
class LocalCaptionModel {
  const LocalCaptionModel({
    required this.id,
    required this.repository,
    required this.revision,
    required this.source,
    this.target,
    required this.engine,
    required this.files,
    this.languages = const [],
    this.displayName,
    this.license,
    this.targetPrefixes = const {},
  });
  final String id, repository, revision, source, engine;
  final String? target;
  final List<CaptionModelFile> files;
  final List<String> languages;
  final String? displayName, license;
  final Map<String, String> targetPrefixes;
  bool get isTranslation => target != null;
  List<String> get sourceLanguages {
    if (languages.isNotEmpty) return languages;
    if (engine == 'whisper' && !repository.contains('.en')) {
      return captionLanguageCodes
          .where((c) => c != 'yue' || repository.contains('large-v3'))
          .toList();
    }
    return [source];
  }

  bool get canDetectLanguage =>
      (engine == 'whisper' && sourceLanguages.length > 1) ||
      engine == 'sensevoice';
  bool supportsSource(String code) => code == 'auto'
      ? canDetectLanguage
      : sourceLanguages.contains(code) || sourceLanguages.contains('und');
  bool supportsOutput(String code) =>
      target == code ||
      targetPrefixes.containsKey(code) ||
      (!id.startsWith('hub-') && target == 'zh' && code == 'zh-Hant');
  String languageToken(String output) =>
      targetPrefixes[output] ??
      (!id.startsWith('hub-') && target == 'zh'
          ? output == 'zh-Hant'
                ? '>>cmn_Hant<<'
                : output == 'zh'
                ? '>>cmn_Hans<<'
                : ''
          : '');
  String get tokensFile =>
      files.firstWhere((f) => f.name.endsWith('tokens.txt')).name;

  bool get _validLayout {
    final names = files.map((f) => f.name).toSet();
    if (isTranslation) {
      final vocabulary =
          names.contains('shared_vocabulary.json') ||
          names.contains('shared_vocabulary.txt') ||
          (names.any((n) => n.startsWith('source_vocabulary.')) &&
              names.any((n) => n.startsWith('target_vocabulary.')));
      return names.containsAll([
            'model.bin',
            'config.json',
            'source.spm',
            'target.spm',
          ]) &&
          vocabulary;
    }
    if (!names.any((n) => n.endsWith('tokens.txt'))) return false;
    if ([
          'whisper',
          'sensevoice',
          'paraformer',
          'offline-transducer',
        ].contains(engine) &&
        !names.contains('silero_vad.onnx')) {
      return false;
    }
    if (engine == 'sensevoice' || engine == 'paraformer') {
      return files.first.name.endsWith('.onnx');
    }
    return files.length >= (engine == 'whisper' ? 3 : 4) &&
        files[0].name.contains('encoder') &&
        files[1].name.contains('decoder') &&
        (engine == 'whisper' || files[2].name.contains('joiner'));
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'repository': repository,
    'revision': revision,
    'source': source,
    'target': target,
    'engine': engine,
    'languages': languages,
    'name': displayName,
    'license': license,
    'prefixes': targetPrefixes,
    'files': files
        .map(
          (f) => {
            'name': f.name,
            'bytes': f.bytes,
            'sha256': f.sha256,
            'url': f.downloadUrl,
          },
        )
        .toList(),
  };

  static String snapshotId(
    String repository,
    String revision,
    bool translation,
  ) =>
      'hub-${translation ? 't' : 's'}-${sha256.convert(utf8.encode('$repository@$revision')).toString().substring(0, 32)}';
  static bool validSelection(String id, bool translation) =>
      RegExp('^hub-${translation ? 't' : 's'}-[0-9a-f]{32}\$').hasMatch(id) ||
      catalog.any((m) => m.id == id && m.isTranslation == translation);

  /// Validates imported/on-disk manifests before any network or native operation.
  static LocalCaptionModel fromJson(Map<String, dynamic> json) {
    final model = LocalCaptionModel(
      id: json['id'] as String,
      repository: json['repository'] as String,
      revision: json['revision'] as String,
      source: json['source'] as String,
      target: json['target'] as String?,
      engine: json['engine'] as String,
      languages: (json['languages'] as List? ?? []).cast<String>(),
      displayName: json['name'] as String?,
      license: json['license'] as String?,
      targetPrefixes: (json['prefixes'] as Map? ?? {}).cast<String, String>(),
      files: (json['files'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (f) => CaptionModelFile(
              f['name'] as String,
              f['bytes'] as int,
              f['sha256'] as String,
              downloadUrl: f['url'] as String?,
            ),
          )
          .toList(),
    );
    final legacy = find(model.id);
    if (!RegExp(
          r'^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*$',
        ).hasMatch(model.repository) ||
        !RegExp(r'^[0-9a-f]{40}$').hasMatch(model.revision) ||
        model.id !=
                snapshotId(
                  model.repository,
                  model.revision,
                  model.isTranslation,
                ) &&
            !(legacy?.repository == model.repository &&
                legacy?.revision == model.revision &&
                legacy?.engine == model.engine) ||
        ![
          'zipformer',
          'zipformer2',
          'transducer',
          'offline-transducer',
          'whisper',
          'sensevoice',
          'paraformer',
          'marian',
        ].contains(model.engine) ||
        model.isTranslation != (model.engine == 'marian') ||
        ![...captionLanguageCodes, 'auto', 'und'].contains(model.source) ||
        model.target != null && !captionLanguageCodes.contains(model.target) ||
        model.languages.any(
          (c) => ![...captionLanguageCodes, 'und'].contains(c),
        ) ||
        model.targetPrefixes.entries.any(
          (e) =>
              !captionOutputLanguages.contains(e.key) ||
              !RegExp(r'^>>[A-Za-z0-9_]+<<$').hasMatch(e.value),
        ) ||
        model.files.isEmpty ||
        model.files.length > 32 ||
        !model._validLayout ||
        model.files.map((f) => f.name).toSet().length != model.files.length ||
        model.files.any(
          (f) =>
              !RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]*$').hasMatch(f.name) ||
              f.bytes <= 0 ||
              f.bytes > 8000000000 ||
              !RegExp(r'^[0-9a-f]{64}$').hasMatch(f.sha256) ||
              f.downloadUrl != null &&
                  !(f.name == 'silero_vad.onnx' &&
                      f.bytes == sileroVad.bytes &&
                      f.sha256 == sileroVad.sha256 &&
                      f.downloadUrl == sileroVad.downloadUrl),
        )) {
      throw const FormatException('Invalid caption model manifest');
    }
    return model;
  }

  static List<LocalCaptionModel> parseManifests(String? value) {
    if (value == null) return [];
    if (value.length > 1000000) {
      throw const FormatException('Model manifests too large');
    }
    final list = jsonDecode(value) as List;
    if (list.length > 128) {
      throw const FormatException('Too many model manifests');
    }
    return list
        .map((m) => fromJson((m as Map).cast<String, dynamic>()))
        .toList();
  }

  static bool validManifests(String value) {
    try {
      parseManifests(value);
      return true;
    } on Object {
      return false;
    }
  }

  static const sileroVad = CaptionModelFile(
    'silero_vad.onnx',
    643854,
    '9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6',
    downloadUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx',
  );
  int get bytes => files.fold(0, (sum, file) => sum + file.bytes);
  String url(CaptionModelFile file) =>
      file.downloadUrl ??
      'https://huggingface.co/$repository/resolve/$revision/${file.name}';
  static LocalCaptionModel? find(String? id) {
    for (final model in catalog) {
      if (model.id == id) return model;
    }
    return null;
  }

  // Migration snapshots only. The picker discovers models from the live Hub API.
  static const catalog = <LocalCaptionModel>[
    LocalCaptionModel(
      id: 'zipformer-en',
      repository: 'csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-06-26',
      revision: '672fbf1b30579d6585301139bb363f42a0ad4a24',
      source: 'en',
      target: null,
      engine: 'zipformer2',
      files: [
        CaptionModelFile(
          'encoder-epoch-99-avg-1-chunk-16-left-128.int8.onnx',
          71083163,
          '563fde436d16cf7607cf408cd6b30909819d03162652ef389c2450ced3f45ac1',
        ),
        CaptionModelFile(
          'decoder-epoch-99-avg-1-chunk-16-left-128.onnx',
          2092621,
          '7bf787f90b194b307e5a4ad6a34fadb4e748304c35f78a8d66358a05b13ee6ef',
        ),
        CaptionModelFile(
          'joiner-epoch-99-avg-1-chunk-16-left-128.int8.onnx',
          259335,
          'd944208d660d67c8d72cd2acaeac971fa5ceb8c80e76c1968148846fedd6e297',
        ),
        CaptionModelFile(
          'tokens.txt',
          5048,
          '49e3c2646595fd907228b3c6787069658f67b17377c60aeb8619c4551b2316fb',
        ),
        CaptionModelFile(
          'README.md',
          216,
          'c914dd28e23310a6dd345ea10495003d3e4820d2ed987181e4c2d67e501b6b76',
        ),
      ],
    ),
    LocalCaptionModel(
      id: 'zipformer-zh',
      repository:
          'csukuangfj/sherpa-onnx-streaming-zipformer-zh-14M-2023-02-23',
      revision: '204ad334e2e683fd295359930cc16fc0432a23ac',
      source: 'zh',
      target: null,
      engine: 'zipformer',
      files: [
        CaptionModelFile(
          'encoder-epoch-99-avg-1.int8.onnx',
          21621684,
          '1c556ea57cec304e55ec4b72e52c1cc098bb01476ed7d90f3de939fe126487b1',
        ),
        CaptionModelFile(
          'decoder-epoch-99-avg-1.onnx',
          7509745,
          '5ee0f03a2768ff1d5c83ef3a493243c7935d316cd41280037b14783a3467cc78',
        ),
        CaptionModelFile(
          'joiner-epoch-99-avg-1.int8.onnx',
          1795562,
          'a7cf9d82757bdcf786059454495a9ca95e4bd7347f72473fc08d794475c36169',
        ),
        CaptionModelFile(
          'tokens.txt',
          48697,
          '8b294db9045d6e5f94647f4c1eec1af4da143a75053c399611444b378ff966ac',
        ),
        CaptionModelFile(
          'README.md',
          226,
          '515751f07faad368f0863ae41773ff09635eba5920122d549abb8e45d5c88282',
        ),
      ],
    ),
    LocalCaptionModel(
      id: 'whisper-ja',
      repository: 'csukuangfj/sherpa-onnx-whisper-tiny',
      revision: '65176e2deb88badc814a94058666cadccc29b61c',
      source: 'ja',
      target: null,
      engine: 'whisper',
      files: [
        CaptionModelFile(
          'tiny-encoder.int8.onnx',
          12937772,
          'd24fb083ae3b1041fc24e97971d60e280c9342201fbb67b0ab428a8b4a51a434',
        ),
        CaptionModelFile(
          'tiny-decoder.int8.onnx',
          89855401,
          'd2fece8dd42771f1df975c6c0445770d0c292bf7547c2cae04a6c0cc57540925',
        ),
        CaptionModelFile(
          'tiny-tokens.txt',
          816730,
          'b34b360dbb493e781e479794586d661700670d65564001f23024971d1f2fa126',
        ),
        CaptionModelFile(
          'silero_vad.onnx',
          643854,
          '9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6',
          downloadUrl:
              'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx',
        ),
      ],
    ),
    LocalCaptionModel(
      id: 'marian-en-zh',
      repository: 'gaudi/opus-mt-en-zh-ctranslate2',
      revision: 'dcd22168f08b99dd34c62bc2195e31dc2f04e90b',
      source: 'en',
      target: 'zh',
      engine: 'marian',
      files: [
        CaptionModelFile(
          'model.bin',
          155502615,
          'f24c2bb82368f7de0196882de1d8b644d2aa54ae2439c3142f263de8a64ea2a9',
        ),
        CaptionModelFile(
          'config.json',
          215,
          'ce02c0c0d02f285d2ff34c80b0867ccb5c4a3b250a275e6d1d2884f5499a6e46',
        ),
        CaptionModelFile(
          'shared_vocabulary.json',
          1303887,
          '37314a6abb25ed8f8497498aeeb31fcea98de892bf00ff7c2e8c966b26fe0b82',
        ),
        CaptionModelFile(
          'source.spm',
          806435,
          '5775ddc9e3ff2fae91554da56468ad35ff56edaba870fea74447bc7234bfdaa8',
        ),
        CaptionModelFile(
          'target.spm',
          804600,
          '81dc94efa84e4025ef38d25d5d07429fe41e3eb29d44003f1db6fe98487b0052',
        ),
        CaptionModelFile(
          'README.md',
          6720,
          'e26c20de87b00a2a1330f6736a59e0f2d8b4aae3109064da1b8433242f213679',
        ),
      ],
    ),
    LocalCaptionModel(
      id: 'marian-zh-en',
      repository: 'gaudi/opus-mt-zh-en-ctranslate2',
      revision: '05d8fc158397bae0c65b8d46c858b6c18e094c12',
      source: 'zh',
      target: 'en',
      engine: 'marian',
      files: [
        CaptionModelFile(
          'model.bin',
          155502615,
          'a188bc45bce24635a1eb0cc42ad0b43afdad806b86af9beb3065bba11f3b212c',
        ),
        CaptionModelFile(
          'config.json',
          215,
          'ce02c0c0d02f285d2ff34c80b0867ccb5c4a3b250a275e6d1d2884f5499a6e46',
        ),
        CaptionModelFile(
          'shared_vocabulary.json',
          1303998,
          'acbf13516c56af2bb78ebdb770c2e4648fd8232ddd17af75298119cbfa7ee33d',
        ),
        CaptionModelFile(
          'source.spm',
          804677,
          'e27a3a1b539f4959ec72ea60e453f49156289f95d4e6000b29332efc45616203',
        ),
        CaptionModelFile(
          'target.spm',
          806530,
          '6a881f4717cd7265f53fea54fd3dc689c767c05338fac7a4590f3088cb2d7855',
        ),
        CaptionModelFile(
          'README.md',
          6720,
          'e1995ec81dac199158d5836224864b6e297ddd920bf611c9dc0d78bea197c0d4',
        ),
      ],
    ),
    LocalCaptionModel(
      id: 'marian-ja-en',
      repository: 'gaudi/opus-mt-ja-en-ctranslate2',
      revision: '599e1e01d8e539db0eb9270e329bc5969803c20e',
      source: 'ja',
      target: 'en',
      engine: 'marian',
      files: [
        CaptionModelFile(
          'model.bin',
          151106205,
          'fcc505f9a24b43caf3514e5bc3fc1581bbe0b17cbf99d4eff136b7b5af4997e1',
        ),
        CaptionModelFile(
          'config.json',
          215,
          'ce02c0c0d02f285d2ff34c80b0867ccb5c4a3b250a275e6d1d2884f5499a6e46',
        ),
        CaptionModelFile(
          'shared_vocabulary.json',
          1208862,
          'c6e7f9988e5fe15c59ed331ce2d7c3dd551e70add8efc09f839f5a48168da4d6',
        ),
        CaptionModelFile(
          'source.spm',
          781853,
          'd0b5c3b10b5959f056ff2c86e2f2356129242ff1fc72d3a4a34d6a8c0eee4e57',
        ),
        CaptionModelFile(
          'target.spm',
          801883,
          '35d89c704e270d441fade716a3931d49c43179400682edcca7f180694982a2f6',
        ),
        CaptionModelFile(
          'README.md',
          6720,
          '9006142dc1858f00f6443d338e9bf24099c9496e4494cd65619bf76fd9a88633',
        ),
      ],
    ),
  ];
}

class CaptionModelFile {
  const CaptionModelFile(
    this.name,
    this.bytes,
    this.sha256, {
    this.downloadUrl,
  });
  final String? downloadUrl;
  final String name;
  final int bytes;
  final String sha256;
}
