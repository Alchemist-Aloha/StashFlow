import 'dart:io';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

Future<void> run(List<String> arguments) async {
  final result = await Process.run('cmake', arguments);
  if (result.exitCode != 0) {
    throw StateError('CMake failed: ${result.stdout}\n${result.stderr}');
  }
}

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    if (!input.config.buildCodeAssets) return;
    final os = input.config.code.targetOS;
    final arch = input.config.code.targetArchitecture;
    final buildDir = Directory.fromUri(input.outputDirectory.resolve('cmake/'));
    final source = Directory.fromUri(input.packageRoot.resolve('src/'));
    await for (final file in source.list()) {
      if (file is File) output.dependencies.add(file.uri);
    }
    final flags = <String>[];
    if (os == OS.android) {
      var ndk = File.fromUri(input.config.code.cCompiler!.compiler).parent;
      while (!File(
        '${ndk.path}/build/cmake/android.toolchain.cmake',
      ).existsSync()) {
        final parent = ndk.parent;
        if (parent.path == ndk.path) throw StateError('Android NDK not found');
        ndk = parent;
      }
      flags.addAll([
        '-DCMAKE_TOOLCHAIN_FILE=${ndk.path}/build/cmake/android.toolchain.cmake',
        '-DANDROID_ABI=${{Architecture.arm: 'armeabi-v7a', Architecture.arm64: 'arm64-v8a', Architecture.x64: 'x86_64'}[arch]}',
        '-DANDROID_PLATFORM=android-${input.config.code.android.targetNdkApi}',
        '-DANDROID_STL=c++_static',
      ]);
    } else if (os == OS.macOS || os == OS.iOS) {
      flags.add(
        '-DCMAKE_OSX_ARCHITECTURES=${arch == Architecture.arm64 ? 'arm64' : 'x86_64'}',
      );
      if (os == OS.iOS) {
        final sdk = input.config.code.iOS.targetSdk == IOSSdk.iPhoneSimulator
            ? 'iphonesimulator'
            : 'iphoneos';
        final result = await Process.run('xcrun', [
          '--sdk',
          sdk,
          '--show-sdk-path',
        ]);
        if (result.exitCode != 0) throw StateError('Apple SDK unavailable');
        flags.addAll([
          '-DCMAKE_SYSTEM_NAME=iOS',
          '-DCMAKE_OSX_SYSROOT=${result.stdout.toString().trim()}',
        ]);
      }
    } else if (os == OS.windows) {
      flags.addAll(['-A', arch == Architecture.arm64 ? 'ARM64' : 'x64']);
    } else if (os != OS.linux) {
      throw UnsupportedError(
        'On-device translation is unavailable for ${os.name}',
      );
    }
    await run([
      '-S',
      source.path,
      '-B',
      buildDir.path,
      '-DCMAKE_BUILD_TYPE=Release',
      ...flags,
    ]);
    await run([
      '--build',
      buildDir.path,
      '--config',
      'Release',
      '--target',
      'stashflow_translation',
      '--parallel',
      '4',
    ]);
    final name = os == OS.windows
        ? 'stashflow_translation.dll'
        : os == OS.macOS || os == OS.iOS
        ? 'libstashflow_translation.dylib'
        : 'libstashflow_translation.so';
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'stashflow_translation.dart',
        linkMode: DynamicLoadingBundled(),
        file: buildDir.uri.resolve('out/$name'),
      ),
    );
  });
}
