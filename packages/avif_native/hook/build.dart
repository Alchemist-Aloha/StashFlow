import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';

Future<void> main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;

    final features = _define(input, 'features', 'full');
    final profile = _profile(
      features: features,
      decoder: _define(
        input,
        'decoder',
        features == 'decode' ? 'dav1d' : 'aom',
      ),
      encoder: _define(input, 'encoder', 'aom'),
    );
    final target = _target(input.config.code);
    // StashFlow patch: ship no library on targets without a prebuilt binary
    // (e.g. Windows ARM64) instead of failing the app build. AVIF decode
    // calls then throw at runtime and callers show their error state.
    if (target == null) return;
    final key = '$target-$profile';
    final manifestUri = input.packageRoot.resolve('native/manifest.json');
    output.dependencies.add(manifestUri);

    final manifest =
        jsonDecode(await File.fromUri(manifestUri).readAsString())
            as Map<String, Object?>;
    final artifacts = manifest['artifacts'] as Map<String, Object?>;
    final artifact = artifacts[key] as Map<String, Object?>?;
    if (artifact == null) {
      throw UnsupportedError(
        'No avif_native artifact for $key. Supported profiles are '
        'decode-dav1d, encode-aom, full-aom-aom, and full-dav1d-aom.',
      );
    }

    final library = await _resolveArtifact(
      input: input,
      output: output,
      manifestUri: manifestUri,
      artifact: artifact,
    );
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'src/avif_ffi.dart',
        linkMode: DynamicLoadingBundled(),
        file: library,
      ),
    );
  });
}

String _define(HookInput input, String name, String fallback) {
  final value = input.userDefines[name];
  if (value == null) return fallback;
  if (value is String) return value;
  throw FormatException(
    'hooks.user_defines.avif_native.$name must be a string',
  );
}

String _profile({
  required String features,
  required String decoder,
  required String encoder,
}) {
  final profile = switch (features) {
    'decode' => 'decode-$decoder',
    'encode' => 'encode-$encoder',
    'full' || 'auto' => 'full-$decoder-$encoder',
    _ => throw FormatException(
      'avif_native features must be decode, encode, full, or auto',
    ),
  };
  const supported = {
    'decode-dav1d',
    'encode-aom',
    'full-aom-aom',
    'full-dav1d-aom',
  };
  if (!supported.contains(profile)) {
    throw UnsupportedError(
      'avif_native profile $profile is not available in this release',
    );
  }
  return profile;
}

String? _target(CodeConfig code) {
  final arch = code.targetArchitecture;
  return switch (code.targetOS) {
    OS.macOS when arch == Architecture.arm64 => 'macos-arm64',
    OS.macOS when arch == Architecture.x64 => 'macos-x64',
    OS.iOS
        when code.iOS.targetSdk == IOSSdk.iPhoneOS &&
            arch == Architecture.arm64 =>
      'ios-device-arm64',
    OS.iOS
        when code.iOS.targetSdk == IOSSdk.iPhoneSimulator &&
            arch == Architecture.arm64 =>
      'ios-simulator-arm64',
    OS.iOS
        when code.iOS.targetSdk == IOSSdk.iPhoneSimulator &&
            arch == Architecture.x64 =>
      'ios-simulator-x64',
    OS.android when arch == Architecture.arm64 => 'android-arm64',
    OS.android when arch == Architecture.arm => 'android-arm',
    OS.android when arch == Architecture.x64 => 'android-x64',
    OS.linux when arch == Architecture.arm64 => 'linux-arm64',
    OS.linux when arch == Architecture.x64 => 'linux-x64',
    OS.windows when arch == Architecture.x64 => 'windows-x64',
    _ => null,
  };
}

Future<Uri> _resolveArtifact({
  required HookInput input,
  required HookOutputBuilder output,
  required Uri manifestUri,
  required Map<String, Object?> artifact,
}) async {
  final fileName = artifact['fileName'];
  final libraryHash = artifact['librarySha256'];
  if (fileName is! String || libraryHash is! String) {
    throw const FormatException('Invalid avif_native manifest artifact');
  }

  final localPath = artifact['path'];
  if (localPath is String) {
    final library = manifestUri.resolve(localPath);
    output.dependencies.add(library);
    await _verify(File.fromUri(library), libraryHash, 'bundled library');
    return library;
  }

  final url = artifact['url'];
  final archiveHash = artifact['archiveSha256'];
  if (url is! String || archiveHash is! String) {
    throw const FormatException('Invalid avif_native download artifact');
  }

  final artifactUri = Uri.parse(url);
  if (artifactUri.scheme != 'https') {
    throw const FormatException('avif_native artifact URL must use HTTPS');
  }
  final cacheDirectory = Directory.fromUri(
    input.outputDirectoryShared.resolve('avif_native/'),
  )..createSync(recursive: true);
  final archive = File('${cacheDirectory.path}/$archiveHash.gz');
  if (!await _matches(archive, archiveHash)) {
    if (await archive.exists()) await archive.delete();
    await _download(artifactUri, archive);
    await _verify(archive, archiveHash, 'downloaded archive');
  }

  final library = File.fromUri(input.outputDirectory.resolve(fileName));
  await library.parent.create(recursive: true);
  final bytes = gzip.decode(await archive.readAsBytes());
  final actualHash = sha256.convert(bytes).toString();
  if (actualHash != libraryHash) {
    throw StateError(
      'avif_native library checksum mismatch: expected $libraryHash, '
      'got $actualHash',
    );
  }
  await library.writeAsBytes(bytes, flush: true);
  return library.uri;
}

Future<void> _download(Uri url, File destination) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    final request = await client
        .getUrl(url)
        .timeout(const Duration(seconds: 30));
    final response = await request.close().timeout(const Duration(seconds: 30));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Failed to download avif_native: HTTP ${response.statusCode}',
        uri: url,
      );
    }
    final temporary = File('${destination.path}.${pid}.tmp');
    final sink = temporary.openWrite();
    try {
      await response.timeout(const Duration(minutes: 2)).pipe(sink);
      try {
        await temporary.rename(destination.path);
      } on FileSystemException {
        if (!await destination.exists()) rethrow;
      }
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  } finally {
    client.close(force: true);
  }
}

Future<bool> _matches(File file, String expected) async =>
    await file.exists() &&
    sha256.convert(await file.readAsBytes()).toString() == expected;

Future<void> _verify(File file, String expected, String label) async {
  if (!await _matches(file, expected)) {
    throw StateError('avif_native $label checksum mismatch: ${file.path}');
  }
}
