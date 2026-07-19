import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release build does not restrict Android resources to English', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('resConfigs("en")')));
  });

  test('release manifest does not request legacy external storage', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    expect(manifest, isNot(contains('requestLegacyExternalStorage')));
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
