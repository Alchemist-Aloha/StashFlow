import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/utils/pip_mode.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/desktop_pip_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const windowManagerChannel = MethodChannel('window_manager');
  final mainWindowCalls = <MethodCall>[];

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    PipMode.isInPipMode.value = false;
    PipMode.clearWindowedHandlers();
    mainWindowCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (call) async {
          mainWindowCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    PipMode.clearWindowedHandlers();
    PipMode.isInPipMode.value = false;
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
  });

  test(
    'delegates desktop PiP to a separate window without changing main window',
    () async {
      double? receivedAspectRatio;
      var exitCalls = 0;
      PipMode.configureWindowedHandlers(
        enter: (aspectRatio) async {
          receivedAspectRatio = aspectRatio;
          return true;
        },
        exit: () async {
          exitCalls++;
          return true;
        },
      );

      expect(await PipMode.enterIfAvailable(aspectRatio: 2), isTrue);
      expect(receivedAspectRatio, 2);
      expect(PipMode.isInPipMode.value, isTrue);
      expect(mainWindowCalls, isEmpty);

      expect(await PipMode.exitIfAvailable(), isTrue);
      expect(exitCalls, 1);
      expect(PipMode.isInPipMode.value, isFalse);
      expect(mainWindowCalls, isEmpty);
    },
  );

  test('supports windowed PiP on every desktop platform', () {
    for (final platform in <TargetPlatform>[
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ]) {
      debugDefaultTargetPlatformOverride = platform;

      expect(PipMode.isWindowed, isTrue, reason: platform.name);
      expect(PipMode.isSupported, isTrue, reason: platform.name);
    }
  });

  test('does not create duplicate desktop PiP windows', () async {
    var enterCalls = 0;
    PipMode.configureWindowedHandlers(
      enter: (_) async {
        enterCalls++;
        return true;
      },
      exit: () async => true,
    );

    expect(await PipMode.enterIfAvailable(), isTrue);
    expect(await PipMode.enterIfAvailable(), isTrue);
    expect(enterCalls, 1);
  });

  test(
    'reports unavailable until the desktop window owner is registered',
    () async {
      expect(await PipMode.enterIfAvailable(), isFalse);
      expect(await PipMode.exitIfAvailable(), isFalse);
      expect(PipMode.isInPipMode.value, isFalse);
    },
  );

  test('window close notification clears shared PiP state', () async {
    PipMode.configureWindowedHandlers(
      enter: (_) async => true,
      exit: () async => true,
    );
    await PipMode.enterIfAvailable();

    PipMode.windowedWindowClosed();

    expect(PipMode.isInPipMode.value, isFalse);
  });

  test('desktop PiP size follows a sanitized aspect ratio', () {
    expect(desktopPipWindowSize(2), const Size(600, 300));
    expect(
      desktopPipWindowSize(double.nan).aspectRatio,
      closeTo(16 / 9, 0.001),
    );
    expect(sanitizeDesktopPipAspectRatio(100), 4);
  });

  test('desktop PiP minimum stays on the video aspect ratio', () {
    final wide = desktopPipMinimumSize(2);
    expect(wide.height, kDesktopPipMinimumShortSide);
    expect(wide.width / wide.height, closeTo(2, 0.001));

    final tall = desktopPipMinimumSize(9 / 16);
    expect(tall.width, kDesktopPipMinimumShortSide);
    expect(tall.width / tall.height, closeTo(9 / 16, 0.001));
    // The old 16:9 minimum forced this portrait window to 240x427.
    expect(tall.height, lessThan(240));

    final fallback = desktopPipMinimumSize(double.nan);
    expect(fallback.width / fallback.height, closeTo(16 / 9, 0.001));
  });
}
