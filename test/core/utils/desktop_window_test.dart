import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

import 'package:stash_app_flutter/core/utils/desktop_window_native.dart';

class _FakeWindow extends Fake implements Window {
  final calls = <Symbol>[];
  final requests = <bool>[];
  FutureOr<void> Function(WindowEvent)? listener;
  bool fullscreen = false;
  bool failNext = false;
  int removedListeners = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    calls.add(invocation.memberName);
    return null;
  }

  @override
  bool get isFullScreen => fullscreen;

  @override
  set isFullScreen(bool value) {
    requests.add(value);
    if (failNext) {
      failNext = false;
      throw StateError('Native request failed');
    }
  }

  @override
  ListenerId addListener(FutureOr<void> Function(WindowEvent) callback) {
    listener = callback;
    return 1;
  }

  @override
  bool removeListener(ListenerId listenerId) {
    assert(listenerId == 1);
    listener = null;
    removedListeners++;
    return true;
  }

  void emit(WindowEvent event) {
    if (event is WindowEnteredFullScreenEvent) fullscreen = true;
    if (event is WindowExitedFullScreenEvent) fullscreen = false;
    final result = listener?.call(event);
    if (result is Future<void>) unawaited(result);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final platform in [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ]) {
    test('initializes only the bound main window on $platform', () async {
      debugDefaultTargetPlatformOverride = platform;
      final window = _FakeWindow();
      final controller = DesktopWindow.forWindow(window);

      await controller.initialize();

      expect(
        window.calls,
        platform == TargetPlatform.windows
            ? [#setSize, #maximize, #show, #focus]
            : [const Symbol('minimumSize='), #setSize, #maximize],
      );
    });
  }

  test('rejects missing Windows handles before calling FFI', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    const channel = MethodChannel('stash_app_flutter/fullscreen');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    for (final handle in <int?>[null, 0]) {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getWindowHandle');
        return handle;
      });
      await expectLater(
        DesktopWindow.forWindow(null).initialize(),
        throwsStateError,
      );
    }
  });

  test('requires startup binding before fullscreen', () async {
    await expectLater(
      DesktopWindow.forWindow(null).setFullScreen(true),
      throwsStateError,
    );
  });

  test(
    'awaits matching native events and ignores duplicate requests',
    () async {
      final window = _FakeWindow();
      final controller = DesktopWindow.forWindow(window);
      var completed = false;
      final enter = controller
          .setFullScreen(true)
          .then((_) => completed = true);

      window.emit(const WindowExitedFullScreenEvent(windowId: 1));
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);
      expect(window.listener, isNotNull);
      window.emit(const WindowEnteredFullScreenEvent(windowId: 1));
      await enter;
      expect(window.listener, isNull);

      await controller.setFullScreen(true);
      expect(window.requests, [true]);
      final exit = controller.setFullScreen(false);
      window.emit(const WindowExitedFullScreenEvent(windowId: 1));
      await exit;
      expect(window.requests, [true, false]);
      expect(window.removedListeners, 2);
    },
  );

  test('cleans listeners after a failed setter and permits retry', () async {
    final window = _FakeWindow()..failNext = true;
    final controller = DesktopWindow.forWindow(window);
    await expectLater(controller.setFullScreen(true), throwsStateError);
    expect(window.listener, isNull);

    final retry = controller.setFullScreen(true);
    window.emit(const WindowEnteredFullScreenEvent(windowId: 1));
    await retry;
    expect(window.requests, [true, true]);
    expect(window.removedListeners, 2);
  });

  test(
    'a closed window fails the transition and removes its listener',
    () async {
      final window = _FakeWindow();
      final controller = DesktopWindow.forWindow(window);
      final failed = expectLater(
        controller.setFullScreen(true),
        throwsStateError,
      );
      window.emit(const WindowClosedEvent(windowId: 1));
      await failed;
      expect(window.listener, isNull);
    },
  );

  testWidgets('times out and cleans up if the window manager never replies', (
    tester,
  ) async {
    final window = _FakeWindow();
    final controller = DesktopWindow.forWindow(window);
    final timedOut = expectLater(
      controller.setFullScreen(true),
      throwsA(isA<TimeoutException>()),
    );
    await tester.pump(const Duration(seconds: 10));
    await timedOut;
    expect(window.listener, isNull);
  });
}
