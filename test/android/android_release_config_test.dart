import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release build does not restrict Android resources to English', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('resConfigs("en")')));
  });

  test('release manifest does not request legacy external storage', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    expect(manifest, isNot(contains('requestLegacyExternalStorage')));
  });

  test('release preserves Kotlin types looked up by Dart JNI', () {
    final rules = File('android/app/proguard-rules.pro').readAsStringSync();
    // jni's Kotlin bridge uses these JVM names and member descriptors literally.
    for (final declaration in [
      'interface kotlin.coroutines.Continuation',
      'class kotlin.coroutines.intrinsics.CoroutineSingletons',
      'class kotlin.coroutines.intrinsics.IntrinsicsKt',
      'class kotlin.coroutines.intrinsics.IntrinsicsKt__IntrinsicsKt',
      'class kotlin.Result',
      r'class kotlin.Result$Failure',
      'class kotlin.Unit',
    ]) {
      expect(rules, contains('-keep $declaration { *; }'));
    }
  });

  test('release shrinker rules do not retain entire plugin packages', () {
    final rules = File('android/app/proguard-rules.pro').readAsStringSync();
    expect(rules, isNot(contains('-keep class io.flutter.plugins.** { *; }')));
    expect(
      rules,
      isNot(contains('-keep class com.ryanheise.audioservice.** { *; }')),
    );
  });
}
