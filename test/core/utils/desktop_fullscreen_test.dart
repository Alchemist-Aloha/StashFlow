import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/utils/desktop_fullscreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const nativeChannel = MethodChannel('stash_app_flutter/fullscreen');
  const windowManagerChannel = MethodChannel('window_manager');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    messenger.setMockMethodCallHandler(windowManagerChannel, (call) async {
      fail('Windows must not call window_manager: ${call.method}');
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(nativeChannel, null);
    messenger.setMockMethodCallHandler(windowManagerChannel, null);
  });

  test('delegates Windows entry and restoration to the runner', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      calls.add(call);
      return null;
    });

    await DesktopFullscreen.instance.enter();
    await DesktopFullscreen.instance.exit();

    expect(calls.map((call) => call.method), [
      'setFullScreen',
      'setFullScreen',
    ]);
    expect(calls.map((call) => call.arguments), [true, false]);
  });

  test('serializes entry, exit, and re-entry until native replies', () async {
    final firstReply = Completer<void>();
    final firstInvoked = Completer<void>();
    final calls = <bool>[];
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      calls.add(call.arguments as bool);
      if (calls.length == 1) {
        firstInvoked.complete();
        await firstReply.future;
      }
      return null;
    });

    final enter = DesktopFullscreen.instance.enter();
    await firstInvoked.future;
    final exit = DesktopFullscreen.instance.exit();
    final reenter = DesktopFullscreen.instance.enter();
    expect(calls, [true]);

    firstReply.complete();
    await Future.wait([enter, exit, reenter]);
    expect(calls, [true, false, true]);
    await DesktopFullscreen.instance.exit();
  });

  for (final failingEntry in [true, false]) {
    test(
      'propagates native ${failingEntry ? 'entry' : 'exit'} errors and retries',
      () async {
        var failNext = true;
        final calls = <bool>[];
        messenger.setMockMethodCallHandler(nativeChannel, (call) async {
          calls.add(call.arguments as bool);
          if (failNext) {
            failNext = false;
            throw PlatformException(
              code: 'fullscreen_error',
              message: 'failed',
            );
          }
          return null;
        });
        Future<void> transition() => failingEntry
            ? DesktopFullscreen.instance.enter()
            : DesktopFullscreen.instance.exit();

        await expectLater(transition(), throwsA(isA<PlatformException>()));
        await transition();
        expect(calls, [failingEntry, failingEntry]);
      },
    );
  }

  test('queued exit still runs after native entry fails', () async {
    final reply = Completer<void>();
    final invoked = Completer<void>();
    final calls = <bool>[];
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      calls.add(call.arguments as bool);
      if (call.arguments == true) {
        invoked.complete();
        await reply.future;
        throw PlatformException(code: 'fullscreen_error');
      }
      return null;
    });
    final enter = DesktopFullscreen.instance.enter();
    final failed = expectLater(enter, throwsA(isA<PlatformException>()));
    await invoked.future;
    final exit = DesktopFullscreen.instance.exit();
    reply.complete();
    await Future.wait([failed, exit]);
    expect(calls, [true, false]);
  });

  for (final platform in [TargetPlatform.linux, TargetPlatform.macOS]) {
    test('keeps window_manager fullscreen on $platform', () async {
      debugDefaultTargetPlatformOverride = platform;
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(nativeChannel, (call) async {
        fail('Non-Windows must not call the runner fullscreen channel');
      });
      messenger.setMockMethodCallHandler(windowManagerChannel, (call) async {
        calls.add(call);
        return null;
      });

      await DesktopFullscreen.instance.enter();
      await DesktopFullscreen.instance.exit();
      expect(calls.map((call) => call.method), [
        'setFullScreen',
        'setFullScreen',
      ]);
      expect(
        calls.map(
          (call) => (call.arguments as Map<Object?, Object?>)['isFullScreen'],
        ),
        [true, false],
      );
    });
  }
}
