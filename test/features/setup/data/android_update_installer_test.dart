import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stash_app_flutter/features/setup/data/android_update_installer.dart';

class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.bytes);

  final List<int> bytes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
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
  late Directory cache;
  final apkBytes = utf8.encode('fake apk payload');
  final apkSha256 = sha256.convert(apkBytes).toString();

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('stashflow_update_test');
  });

  tearDown(() async {
    if (await cache.exists()) await cache.delete(recursive: true);
  });

  AndroidUpdateInstaller installer() => AndroidUpdateInstaller(
    dio: Dio()..httpClientAdapter = _BytesAdapter(apkBytes),
    cacheDirectory: () async => cache,
  );

  test('downloads a verified APK into the update directory', () async {
    final stale = File(
      '${cache.path}/${AndroidUpdateInstaller.updateDirectoryName}/old.apk',
    );
    await stale.create(recursive: true);
    final progress = <int>[];

    final apk = await installer().download(
      url: 'https://example.test/app.apk',
      version: 'v2.0.0/rc',
      sha256: apkSha256.toUpperCase(),
      onProgress: (received, _) => progress.add(received),
    );

    expect(await apk.readAsBytes(), apkBytes);
    expect(p.equals(apk.parent.path, stale.parent.path), isTrue);
    expect(apk.uri.pathSegments.last, 'StashFlow-v2.0.0_rc.apk');
    expect(await stale.exists(), isFalse);
    expect(progress.last, apkBytes.length);
  });

  test('rejects and removes an APK whose digest does not match', () async {
    await expectLater(
      installer().download(
        url: 'https://example.test/app.apk',
        version: '2.0.0',
        sha256: '0' * 64,
      ),
      throwsA(isA<ApkVerificationException>()),
    );

    final directory = Directory(
      '${cache.path}/${AndroidUpdateInstaller.updateDirectoryName}',
    );
    expect(await directory.list().toList(), isEmpty);
  });
}
