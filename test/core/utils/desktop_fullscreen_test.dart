import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/utils/desktop_fullscreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const windowManagerChannel = MethodChannel('window_manager');
  const windowsFullscreenChannel = MethodChannel(
    'stash_app_flutter/window_fullscreen',
  );

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowsFullscreenChannel, null);
  });

  test('uses the app-owned fullscreen channel on Windows', () async {
    final windowsCalls = <MethodCall>[];
    final windowManagerCalls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowsFullscreenChannel, (call) async {
          windowsCalls.add(call);
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          windowManagerCalls.add(call);
          return true;
        });

    await DesktopFullscreen.instance.enter();
    await DesktopFullscreen.instance.exit();

    expect(windowsCalls.map((call) => call.method), ['enter', 'exit']);
    expect(windowManagerCalls, isEmpty);
  });

  test('keeps window_manager fullscreen on non-Windows desktop', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final windowManagerCalls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          windowManagerCalls.add(call);
          return true;
        });

    await DesktopFullscreen.instance.enter();
    await DesktopFullscreen.instance.exit();

    expect(windowManagerCalls.map((call) => call.method), [
      'setFullScreen',
      'setFullScreen',
    ]);
    expect(
      windowManagerCalls.map(
        (call) => (call.arguments as Map<Object?, Object?>)['isFullScreen'],
      ),
      [true, false],
    );
  });

  test('propagates Windows native errors without plugin fallback', () async {
    final windowManagerCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowsFullscreenChannel, (call) async {
          throw PlatformException(
            code: 'fullscreen_error',
            message: 'SetWindowPos failed',
          );
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          windowManagerCalls.add(call);
          return true;
        });

    await expectLater(
      DesktopFullscreen.instance.enter(),
      throwsA(isA<PlatformException>()),
    );
    expect(windowManagerCalls, isEmpty);
  });
}
