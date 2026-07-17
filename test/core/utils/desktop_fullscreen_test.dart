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

  test(
    'delegates maximized Windows fullscreen state to window_manager',
    () async {
      final windowManagerCalls = <MethodCall>[];
      final appWindowCalls = <MethodCall>[];
      var isMaximized = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(appWindowChannel, (call) async {
            appWindowCalls.add(call);
            return null;
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowManagerChannel, (call) async {
            windowManagerCalls.add(call);
            switch (call.method) {
              case 'isMaximized':
                return isMaximized;
              case 'unmaximize':
                isMaximized = false;
                return true;
              case 'maximize':
                isMaximized = true;
                return true;
              case 'setFullScreen':
                return true;
            }
            fail('Unexpected window_manager call: ${call.method}');
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
      expect(appWindowCalls, isEmpty);
    },
  );
}
