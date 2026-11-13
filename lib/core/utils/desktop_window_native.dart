import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'pip_mode.dart';

/// Retains the main native window instead of following focus into desktop PiP.
class DesktopWindow {
  DesktopWindow._();

  /// Uses an existing window without querying native focus during tests.
  @visibleForTesting
  DesktopWindow.forWindow(this._window);

  static final instance = DesktopWindow._();
  static const _channel = MethodChannel('stash_app_flutter/fullscreen');

  Window? _window;

  /// Binds the runner's main window before secondary windows can be opened.
  Future<void> initialize() async {
    if (_window == null) {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        // GetCurrent uses GetActiveWindow, but the runner's HWND is still hidden.
        final handle = await _channel.invokeMethod<int>('getWindowHandle');
        if (handle == null || handle == 0) {
          throw StateError('The runner did not provide a main window handle');
        }
        _window = Window.createWithNativeWindow(
          Pointer<Void>.fromAddress(handle),
        );
        // Initialize native observation while the main window is still hidden.
        // Lazy initialization during fullscreen's style change can re-enter the
        // native singleton through its initial occlusion scan and deadlock.
        _window = WindowManager.instance.get(_window!.id) ?? _window;
      } else {
        _window = WindowManager.instance.getCurrent();
      }
    }
    final window = _window;
    if (window == null) {
      throw StateError('The main desktop window is unavailable');
    }

    // Windows keeps its main-only minimum in the runner, independent of PiP.
    if (defaultTargetPlatform != TargetPlatform.windows) {
      window.minimumSize = kDesktopMinimumWindowSize.toNative();
    }
    window.setSize(kDesktopMinimumWindowSize.toNative(), false);
    window.maximize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      window.show();
      window.focus();
    }
  }

  /// Completes after the bound Linux/macOS window reports its new native state.
  Future<void> setFullScreen(bool fullscreen) async {
    final window = _window;
    if (window == null) {
      throw StateError('The main desktop window is not initialized');
    }
    if (window.isFullScreen == fullscreen) return;

    final completed = Completer<void>();
    final listener = window.addListener((event) {
      if (completed.isCompleted) return;
      if ((fullscreen && event is WindowEnteredFullScreenEvent) ||
          (!fullscreen && event is WindowExitedFullScreenEvent)) {
        completed.complete();
      } else if (event is WindowClosedEvent) {
        completed.completeError(StateError('The main desktop window closed'));
      }
    });
    try {
      window.isFullScreen = fullscreen;
      await completed.future.timeout(const Duration(seconds: 10));
    } finally {
      window.removeListener(listener);
    }
  }
}
