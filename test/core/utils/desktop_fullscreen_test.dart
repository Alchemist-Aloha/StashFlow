import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/utils/desktop_fullscreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const windowManagerChannel = MethodChannel('window_manager');

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
  });

  test(
    'shrinks a maximized Windows window before fullscreen and remaximizes it',
    () async {
      final windowManagerCalls = <MethodCall>[];
      final setBoundsCalls = <Map<Object?, Object?>>[];
      var isMaximized = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowManagerChannel, (call) async {
            windowManagerCalls.add(call);
            switch (call.method) {
              case 'isMaximized':
                return isMaximized;
              case 'getBounds':
                return isMaximized
                    ? <String, double>{
                        'x': 0,
                        'y': 0,
                        'width': 1920,
                        'height': 1080,
                      }
                    : <String, double>{
                        'x': 200,
                        'y': 120,
                        'width': 1100,
                        'height': 760,
                      };
              case 'unmaximize':
                isMaximized = false;
                return true;
              case 'setBounds':
                setBoundsCalls.add(
                  Map<Object?, Object?>.from(
                    call.arguments as Map<Object?, Object?>,
                  ),
                );
                return true;
              case 'setFullScreen':
                return true;
              case 'maximize':
                isMaximized = true;
                return true;
            }
            fail('Unexpected window_manager call: ${call.method}');
          });

      await DesktopFullscreen.instance.enter();
      await DesktopFullscreen.instance.exit();

      expect(windowManagerCalls.map((call) => call.method), [
        'isMaximized',
        'getBounds',
        'unmaximize',
        'isMaximized',
        'getBounds',
        'setBounds',
        'setFullScreen',
        'setFullScreen',
        'setBounds',
        'maximize',
        'isMaximized',
      ]);
      expect(setBoundsCalls, hasLength(2));
      expect(setBoundsCalls.first, containsPair('x', 16.0));
      expect(setBoundsCalls.first, containsPair('y', 16.0));
      expect(setBoundsCalls.first, containsPair('width', 1888.0));
      expect(setBoundsCalls.first, containsPair('height', 1048.0));
      expect(setBoundsCalls.last, containsPair('x', 200.0));
      expect(setBoundsCalls.last, containsPair('y', 120.0));
      expect(setBoundsCalls.last, containsPair('width', 1100.0));
      expect(setBoundsCalls.last, containsPair('height', 760.0));
      expect(isMaximized, isTrue);
    },
  );

  test('does not maximize a Windows window that started smaller', () async {
    final windowManagerCalls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          windowManagerCalls.add(call);
          switch (call.method) {
            case 'isMaximized':
              return false;
            case 'setFullScreen':
              return true;
          }
          fail('Unexpected window_manager call: ${call.method}');
        });

    await DesktopFullscreen.instance.enter();
    await DesktopFullscreen.instance.exit();

    expect(windowManagerCalls.map((call) => call.method), [
      'isMaximized',
      'setFullScreen',
      'setFullScreen',
    ]);
    final fullscreenCalls = windowManagerCalls.where(
      (call) => call.method == 'setFullScreen',
    );
    expect(
      fullscreenCalls.map(
        (call) => (call.arguments as Map<Object?, Object?>)['isFullScreen'],
      ),
      [true, false],
    );
  });

  test('keeps direct window_manager fullscreen on non-Windows', () async {
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
  });

  test('propagates window_manager errors', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          throw PlatformException(
            code: 'fullscreen_error',
            message: 'setFullScreen failed',
          );
        });

    await expectLater(
      DesktopFullscreen.instance.enter(),
      throwsA(isA<PlatformException>()),
    );
  });
}
