import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/utils/desktop_fullscreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const windowManagerChannel = MethodChannel('window_manager');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
  });

  test('delegates fullscreen transitions to window_manager', () async {
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

  test('propagates window_manager errors', () async {
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
