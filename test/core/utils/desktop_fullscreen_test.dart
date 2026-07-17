import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/utils/desktop_fullscreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const windowManagerChannel = MethodChannel('window_manager');
  const appWindowChannel = MethodChannel('stash_app_flutter/window');

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appWindowChannel, null);
  });

  test('retries restoring a maximized window after fullscreen exit', () async {
    var isMaximized = true;
    var maximizeCalls = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appWindowChannel, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          switch (call.method) {
            case 'isMaximized':
              return isMaximized;
            case 'unmaximize':
              isMaximized = false;
              scheduleMicrotask(DesktopFullscreen.instance.onWindowUnmaximize);
              return true;
            case 'setFullScreen':
              return true;
            case 'maximize':
              maximizeCalls++;
              if (maximizeCalls > 1) {
                isMaximized = true;
                scheduleMicrotask(DesktopFullscreen.instance.onWindowMaximize);
              }
              return true;
          }
          fail('Unexpected window_manager call: ${call.method}');
        });

    await DesktopFullscreen.instance.enter();
    await DesktopFullscreen.instance.exit();

    expect(maximizeCalls, 2);
    expect(isMaximized, isTrue);
  });

  test('does not retry when the maximized window is restored', () async {
    var isMaximized = true;
    var maximizeCalls = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appWindowChannel, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          switch (call.method) {
            case 'isMaximized':
              return isMaximized;
            case 'unmaximize':
              isMaximized = false;
              scheduleMicrotask(DesktopFullscreen.instance.onWindowUnmaximize);
              return true;
            case 'setFullScreen':
              return true;
            case 'maximize':
              maximizeCalls++;
              isMaximized = true;
              scheduleMicrotask(DesktopFullscreen.instance.onWindowMaximize);
              return true;
          }
          fail('Unexpected window_manager call: ${call.method}');
        });

    await DesktopFullscreen.instance.enter();
    await DesktopFullscreen.instance.exit();

    expect(maximizeCalls, 1);
    expect(isMaximized, isTrue);
  });
}
