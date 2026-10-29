import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'caption_options.dart';
import 'local_caption_model.dart';

/// Lightweight live Hub entry. We inspect and pin files only after selection.
class CaptionHubModel {
  const CaptionHubModel(
    this.repository,
    this.engine,
    this.source,
    this.target,
    this.languages,
    this.license,
  );
  final String repository, engine, source;
  final String? target, license;
  final List<String> languages;
  bool get isTranslation => target != null;

  static CaptionHubModel? fromJson(
    Map<String, dynamic> json,
    bool translation,
  ) {
    final id = json['id'] as String? ?? '';
    if (!RegExp(
          r'^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*$',
        ).hasMatch(id) ||
        (json['gated'] != null && json['gated'] != false)) {
      return null;
    }
    final name = id.split('/').last.toLowerCase();
    final card = json['cardData'] is Map
        ? json['cardData'] as Map
        : const <String, Object?>{};
    final license = card['license'] is String
        ? card['license'] as String
        : null;
    if (translation) {
      final pair = RegExp(
        r'opus-mt-(?:tc-big-)?([a-z]{2,3})-([a-z]{2,3})(?:-|$)',
      ).firstMatch(name);
      if (pair == null ||
          !captionLanguageCodes.contains(pair[1]) ||
          !captionLanguageCodes.contains(pair[2])) {
        return null;
      }
      return CaptionHubModel(id, 'marian', pair[1]!, pair[2], [
        pair[1]!,
      ], license);
    }
    if (!name.contains('sherpa-onnx')) return null;
    final engine = name.contains('whisper')
        ? 'whisper'
        : name.contains('sense-voice') || name.contains('sensevoice')
        ? 'sensevoice'
        : name.contains('paraformer') && !name.contains('streaming')
        ? 'paraformer'
        : name.contains('zipformer') && !name.contains('ctc')
        ? name.contains('streaming')
              ? 'transducer'
              : 'offline-transducer'
        : name.contains('streaming') && name.contains('lstm')
        ? 'transducer'
        : null;
    if (engine == null ||
        name.contains('rknn') ||
        name.contains('qnn') ||
        name.contains('ncnn')) {
      return null;
    }
    final rawLanguages = card['language'];
    var languages = (rawLanguages is List ? rawLanguages : [rawLanguages])
        .whereType<String>()
        .where(captionLanguageCodes.contains)
        .toSet()
        .toList();
    if (engine == 'whisper') {
      languages = name.contains('.en')
          ? ['en']
          : captionLanguageCodes
                .where((c) => c != 'yue' || name.contains('large-v3'))
                .toList();
    } else if (engine == 'sensevoice') {
      languages = ['zh', 'en', 'ja', 'ko', 'yue'];
    } else if (languages.isEmpty) {
      languages = name
          .split(RegExp(r'[-_.]'))
          .where(captionLanguageCodes.contains)
          .toSet()
          .toList();
    }
    if (languages.isEmpty) languages = ['und'];
    return CaptionHubModel(
      id,
      engine,
      languages.first,
      null,
      languages,
      license,
    );
  }
}

/// Public model metadata only: never uses Stash authentication or sends media/text.
class CaptionModelCatalog {
  CaptionModelCatalog(this.dio);
  final Dio dio;

  Future<List<CaptionHubModel>> list(bool translation) async {
    Uri? next = Uri.https('huggingface.co', '/api/models', {
      'search': translation ? 'opus-mt' : 'sherpa-onnx',
      if (translation) 'filter': 'ctranslate2',
      'limit': '1000',
      'sort': 'downloads',
      'direction': '-1',
      'full': 'true',
    });
    final models = <String, CaptionHubModel>{};
    var pages = 0;
    while (next != null) {
      if (++pages > 20 ||
          next.scheme != 'https' ||
          next.host != 'huggingface.co' ||
          next.path != '/api/models') {
        throw const FormatException('Invalid Hub pagination');
      }
      final response = await dio.getUri<List<dynamic>>(next);
      for (final entry in response.data ?? []) {
        final model = CaptionHubModel.fromJson(
          (entry as Map).cast<String, dynamic>(),
          translation,
        );
        if (model != null) models[model.repository] = model;
      }
      final link = response.headers.value('link') ?? '';
      final match = RegExp(r'<([^>]+)>;\s*rel="next"').firstMatch(link);
      next = match == null ? null : Uri.parse(match[1]!);
    }
    final result = models.values.toList()
      ..sort((a, b) => a.repository.compareTo(b.repository));
    return result;
  }

  Future<LocalCaptionModel> resolve(
    CaptionHubModel entry, {
    CancelToken? cancel,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      'https://huggingface.co/api/models/${entry.repository}',
      queryParameters: {'blobs': 'true'},
      cancelToken: cancel,
    );
    final info = response.data!;
    if (info['id'] != entry.repository) {
      throw const FormatException('Repository identity changed');
    }
    final details =
        CaptionHubModel.fromJson(info, entry.isTranslation) ??
        (throw UnsupportedError('Model is unavailable'));
    final revision = info['sha'] as String;
    if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(revision)) {
      throw const FormatException('Invalid revision');
    }
    final files = <String, Map<String, dynamic>>{
      for (final file
          in (info['siblings'] as List).cast<Map<String, dynamic>>())
        if (!(file['rfilename'] as String).contains('/'))
          file['rfilename'] as String: file.cast<String, dynamic>(),
    };
    final names = files.keys.toList();
    String choose(Iterable<String> candidates, {bool quantized = true}) {
      final list = candidates.toList();
      list.sort((a, b) {
        final aq = a.contains('int8') == quantized ? 0 : 1;
        final bq = b.contains('int8') == quantized ? 0 : 1;
        return aq != bq
            ? aq.compareTo(bq)
            : a.length != b.length
            ? a.length.compareTo(b.length)
            : a.compareTo(b);
      });
      if (list.isEmpty) throw UnsupportedError('Model layout is not supported');
      return list.first;
    }

    final selected = <String>[];
    final metadata = <String, Uint8List>{};
    Future<Uint8List> smallFile(String name) async {
      final size = files[name]?['size'] as int? ?? 0;
      if (size <= 0 || size > 8000000) {
        throw UnsupportedError('Model metadata too large');
      }
      final token = cancel ?? CancelToken();
      final data = await dio.get<List<int>>(
        'https://huggingface.co/${entry.repository}/resolve/$revision/$name',
        cancelToken: token,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, _) {
          if (received > size) token.cancel('Unexpected metadata size');
        },
      );
      final bytes = Uint8List.fromList(data.data!);
      if (bytes.length != size) {
        throw const FormatException('Truncated metadata');
      }
      metadata[name] = bytes;
      return bytes;
    }

    final prefixes = <String, String>{};
    if (entry.isTranslation) {
      for (final name in [
        'model.bin',
        'config.json',
        'source.spm',
        'target.spm',
      ]) {
        if (!files.containsKey(name)) {
          throw UnsupportedError('Not a compatible Marian model');
        }
        selected.add(name);
      }
      String vocabulary(String base) =>
          choose(['$base.json', '$base.txt'].where(files.containsKey));
      final String sourceVocabulary;
      if (files.containsKey('shared_vocabulary.json') ||
          files.containsKey('shared_vocabulary.txt')) {
        sourceVocabulary = vocabulary('shared_vocabulary');
        selected.add(sourceVocabulary);
      } else {
        sourceVocabulary = vocabulary('source_vocabulary');
        selected.addAll([sourceVocabulary, vocabulary('target_vocabulary')]);
      }
      final configBytes = await smallFile('config.json');
      // Marian models may omit model_type in older CT2 conversions.
      final config = jsonDecode(utf8.decode(configBytes)) as Map;
      if (config['model_type'] != null && config['model_type'] != 'marian') {
        throw UnsupportedError('Only Marian translation models are supported');
      }
      if (entry.target == 'zh') {
        final vocab = String.fromCharCodes(await smallFile(sourceVocabulary));
        if (vocab.contains('>>cmn_Hans<<')) prefixes['zh'] = '>>cmn_Hans<<';
        if (vocab.contains('>>cmn_Hant<<')) {
          prefixes['zh-Hant'] = '>>cmn_Hant<<';
        }
      }
    } else if (entry.engine == 'sensevoice' || entry.engine == 'paraformer') {
      selected.add(
        choose(
          names.where((n) => n.endsWith('.onnx') && n.startsWith('model')),
        ),
      );
      selected.add(choose(names.where((n) => n.endsWith('tokens.txt'))));
    } else {
      var encoders = names.where(
        (n) => n.endsWith('.onnx') && n.contains('encoder'),
      );
      if (entry.engine == 'whisper') {
        final size = RegExp(
          r'whisper-((?:tiny|base|small|medium)(?:\.en)?|large-v[123](?:-turbo)?|large)',
        ).firstMatch(entry.repository.toLowerCase())?[1];
        final preferred = encoders.where(
          (n) => size != null && n.startsWith(size),
        );
        if (preferred.isNotEmpty) encoders = preferred;
      }
      final encoder = choose(encoders);
      final suffix = encoder
          .replaceFirst('encoder', '')
          .replaceAll('.int8', '');
      selected.add(encoder);
      selected.add(
        choose(
          names.where(
            (n) =>
                n.contains('decoder') &&
                n.endsWith('.onnx') &&
                n.replaceFirst('decoder', '').replaceAll('.int8', '') == suffix,
          ),
          quantized: entry.engine == 'whisper',
        ),
      );
      if (entry.engine != 'whisper') {
        selected.add(
          choose(
            names.where(
              (n) =>
                  n.contains('joiner') &&
                  n.endsWith('.onnx') &&
                  n.replaceFirst('joiner', '').replaceAll('.int8', '') ==
                      suffix,
            ),
          ),
        );
      }
      final tokenCandidates = names.where((n) => n.endsWith('tokens.txt'));
      final prefix = encoder.substring(0, encoder.indexOf('encoder'));
      final matchingTokens = tokenCandidates.where((n) => n.startsWith(prefix));
      selected.add(
        choose(matchingTokens.isEmpty ? tokenCandidates : matchingTokens),
      );
    }
    // Large ONNX exports may keep tensor data beside the graph files.
    for (final graph in selected.where((n) => n.endsWith('.onnx')).toList()) {
      selected.addAll(
        names.where(
          (n) =>
              n == '$graph.data' ||
              n == '${graph}_data' ||
              n == '${graph.substring(0, graph.length - 5)}.data',
        ),
      );
    }
    if (files.containsKey('README.md')) selected.add('README.md');
    if (files.containsKey('LICENSE')) selected.add('LICENSE');
    final manifestFiles = <CaptionModelFile>[];
    for (final name in selected.toSet()) {
      final file = files[name]!;
      final size = file['size'] as int;
      final lfs = file['lfs'];
      final digest = lfs is Map ? lfs['sha256'] as String? : null;
      final hash =
          digest ??
          sha256.convert(metadata[name] ?? await smallFile(name)).toString();
      manifestFiles.add(CaptionModelFile(name, size, hash));
    }
    if ([
      'whisper',
      'sensevoice',
      'paraformer',
      'offline-transducer',
    ].contains(entry.engine)) {
      manifestFiles.add(LocalCaptionModel.sileroVad);
    }
    final model = LocalCaptionModel(
      id: LocalCaptionModel.snapshotId(
        entry.repository,
        revision,
        entry.isTranslation,
      ),
      repository: entry.repository,
      revision: revision,
      source: entry.source,
      target: entry.target,
      engine: entry.engine,
      files: manifestFiles,
      languages: details.languages,
      displayName: entry.repository.split('/').last,
      license: details.license,
      targetPrefixes: prefixes,
    );
    return LocalCaptionModel.fromJson(model.toJson());
  }
}
