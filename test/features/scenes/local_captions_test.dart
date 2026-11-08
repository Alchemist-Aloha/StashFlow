import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_cue.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_model_store.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_session.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/local_caption_model.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.bytes);
  List<int> bytes;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(
    bytes,
    200,
    headers: {
      Headers.contentLengthHeader: ['${bytes.length}'],
    },
  );
  @override
  void close({bool force = false}) {}
}

void main() {
  test('catalog pins safe paths, sizes, revisions and SHA-256 digests', () {
    final ids = <String>{};
    for (final model in LocalCaptionModel.catalog) {
      expect(ids.add(model.id), isTrue);
      expect(model.revision, matches(RegExp(r'^[0-9a-f]{40}$')));
      expect(model.bytes, greaterThan(0));
      for (final file in model.files) {
        expect(file.name, isNot(contains('/')));
        expect(file.sha256, matches(RegExp(r'^[0-9a-f]{64}$')));
        expect(Uri.parse(model.url(file)).scheme, 'https');
      }
    }
    expect(LocalCaptionModel.find('unknown'), isNull);
  });

  group('verified model installation', () {
    late Directory root;
    late CaptionModelStore store;
    late _Adapter adapter;
    late LocalCaptionModel model;
    setUp(() async {
      root = await Directory.systemTemp.createTemp('caption-store-test-');
      adapter = _Adapter([1, 2, 3]);
      store = CaptionModelStore(root, Dio()..httpClientAdapter = adapter);
      model = LocalCaptionModel(
        id: 'test-model',
        repository: 'test/model',
        revision: 'pinned',
        source: 'en',
        engine: 'zipformer',
        files: [
          CaptionModelFile(
            'model.onnx',
            3,
            sha256.convert([1, 2, 3]).toString(),
          ),
        ],
      );
    });
    tearDown(() async {
      store.dio.close();
      await root.delete(recursive: true);
    });

    test(
      'only complete verified revisions are selectable and removable',
      () async {
        expect(await store.isInstalled(model), isFalse);
        await store.install(model, cancel: CancelToken(), onProgress: (_) {});
        expect(await store.isInstalled(model), isTrue);
        await File(
          '${store.directory(model).path}/.verified',
        ).writeAsString('older');
        expect(await store.isInstalled(model), isFalse);
        await store.delete(model);
        expect(await root.list().toList(), isEmpty);
      },
    );

    test(
      'checksum mismatch and truncated downloads leave no usable files',
      () async {
        for (final bytes in [
          [3, 2, 1],
          [1],
        ]) {
          adapter.bytes = bytes;
          await expectLater(
            store.install(model, cancel: CancelToken(), onProgress: (_) {}),
            throwsFormatException,
          );
          expect(await store.isInstalled(model), isFalse);
          expect(await root.list().toList(), isEmpty);
        }
      },
    );

    test('cancellation cleans staging and never publishes a model', () async {
      final cancel = CancelToken();
      await expectLater(
        store.install(
          model,
          cancel: cancel,
          onProgress: (_) => cancel.cancel('user'),
        ),
        throwsA(isA<DioException>()),
      );
      expect(await store.isInstalled(model), isFalse);
      expect(await root.list().toList(), isEmpty);
    });

    test(
      'downloaded Hub manifests restore offline without fetching the catalog',
      () async {
        const repo = 'test/sherpa-onnx-streaming-zipformer-en';
        const revision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        final snapshot = LocalCaptionModel(
          id: LocalCaptionModel.snapshotId(repo, revision, false),
          repository: repo,
          revision: revision,
          source: 'en',
          engine: 'transducer',
          files: [
            for (final name in [
              'encoder.onnx',
              'decoder.onnx',
              'joiner.onnx',
              'tokens.txt',
            ])
              CaptionModelFile(name, 3, sha256.convert([1, 2, 3]).toString()),
          ],
        );
        await store.install(
          snapshot,
          cancel: CancelToken(),
          onProgress: (_) {},
        );
        final restored = await store.readInstalled();
        expect(restored.single.id, snapshot.id);
        expect(restored.single.toJson(), snapshot.toJson());
      },
    );

    test('rejects path traversal before touching disk', () async {
      final unsafe = LocalCaptionModel(
        id: '../escape',
        repository: 'test/model',
        revision: 'pinned',
        source: 'en',
        engine: 'zipformer',
        files: model.files,
      );
      await expectLater(
        store.install(unsafe, cancel: CancelToken(), onProgress: (_) {}),
        throwsFormatException,
      );
      expect(await root.list().toList(), isEmpty);
    });
  });

  test(
    'timestamped cues decode subwords, split pauses and discard overlap',
    () {
      final cues = captionCuesFromTokens(
        tokens: ['▁before', '▁Hello', '▁world', '▁Again', '▁after'],
        timestamps: [0.5, 1, 1.5, 3, 7],
        audioStart: const Duration(seconds: 5),
        windowStart: const Duration(seconds: 6),
        windowEnd: const Duration(seconds: 12),
      );
      expect(cues.map((c) => c.text), ['Hello world', 'Again']);
      expect(cues.first.start, const Duration(seconds: 6));
      expect(cues.first.contains(cues.first.end), isFalse);
    },
  );

  test('invalid timestamps and special tokens do not become captions', () {
    final cues = captionCuesFromTokens(
      tokens: ['<blank>', 'bad', '日', '本'],
      timestamps: [0, double.nan, 1, 1.2],
      audioStart: Duration.zero,
      windowStart: Duration.zero,
      windowEnd: const Duration(seconds: 6),
    );
    expect(cues.single.text, '日本');
  });

  test('seeks reject late results and prioritize the new playhead', () async {
    var position = Duration.zero;
    final pending = Completer<List<CaptionCue>>();
    final requested = <Duration>[];
    final frames = <CaptionFrame>[];
    var cancels = 0;
    final session = CaptionSession(
      position: () => position,
      duration: () => const Duration(minutes: 5),
      cancelDecode: () => cancels++,
      onFrame: frames.add,
      process: (start, end) async {
        requested.add(start);
        if (start == Duration.zero) return pending.future;
        return [CaptionCue(start, end, 'new')];
      },
    );
    session.tick();
    position = const Duration(seconds: 60);
    session.tick();
    pending.complete([
      const CaptionCue(Duration.zero, Duration(seconds: 6), 'old'),
    ]);
    await Future<void>.delayed(Duration.zero);
    session.tick();
    await Future<void>.delayed(Duration.zero);
    session.tick();
    expect(requested.take(2), [Duration.zero, const Duration(seconds: 60)]);
    expect(frames.any((f) => f.text == 'old'), isFalse);
    expect(frames.last.text, 'new');
    expect(cancels, 1);
    await session.close();
  });

  test(
    'pause keeps media-timed cues, silence clears text, cache prevents rework',
    () async {
      var position = const Duration(seconds: 1);
      var requests = 0;
      final frames = <CaptionFrame>[];
      final session = CaptionSession(
        position: () => position,
        duration: () => const Duration(seconds: 6),
        cancelDecode: () {},
        onFrame: frames.add,
        process: (start, end) async {
          requests++;
          return [
            const CaptionCue(Duration.zero, Duration(seconds: 2), 'speech'),
          ];
        },
      );
      session.tick();
      await Future<void>.delayed(Duration.zero);
      session.tick();
      session.tick();
      expect(frames.last.text, 'speech');
      expect(requests, 1);
      position = const Duration(seconds: 3);
      session.tick();
      expect(frames.last.text, isEmpty);
      await session.close();
    },
  );

  test(
    'delay boundaries remain blank while look-ahead uses configured windows',
    () async {
      var position = const Duration(seconds: -3);
      final frames = <CaptionFrame>[];
      final starts = <Duration>[];
      final session = CaptionSession(
        position: () => position,
        duration: () => const Duration(seconds: 12),
        windowDuration: const Duration(seconds: 4),
        cancelDecode: () {},
        onFrame: frames.add,
        process: (start, end) async {
          starts.add(start);
          return [CaptionCue(start, end, 'speech', language: 'ja')];
        },
      );
      session.tick();
      await Future<void>.delayed(Duration.zero);
      session.tick();
      expect(frames.last.text, isEmpty);
      expect(frames.last.status, CaptionStatus.ready);
      expect(starts.first, Duration.zero);
      position = Duration.zero;
      session.tick();
      expect(frames.last.text, 'speech');
      expect(frames.last.language, 'ja');
      await Future<void>.delayed(Duration.zero);
      position = const Duration(seconds: 13);
      session.tick();
      expect(frames.last.text, isEmpty);
      expect(frames.last.status, CaptionStatus.ready);
      expect(starts, everyElement(lessThan(const Duration(seconds: 12))));
      await session.close();
    },
  );

  test(
    'closing suppresses pending results and extraction failures are explicit',
    () async {
      final frames = <CaptionFrame>[];
      final session = CaptionSession(
        position: () => Duration.zero,
        duration: () => const Duration(seconds: 6),
        cancelDecode: () {},
        onFrame: frames.add,
        process: (_, _) async => throw StateError('private URL'),
      );
      session.tick();
      await Future<void>.delayed(Duration.zero);
      expect(frames.last.status, CaptionStatus.failed);
      expect(frames.last.text, isEmpty);
      final count = frames.length;
      await session.close();
      session.tick();
      expect(frames.length, count);
    },
  );
}
