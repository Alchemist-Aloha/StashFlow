import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class DesktopFullscreen with WindowListener {
  DesktopFullscreen._() {
    windowManager.addListener(this);
  }

  static final instance = DesktopFullscreen._();
  static const _channel = MethodChannel('stash_app_flutter/window');

  bool _restoreMaximized = false;
  Completer<void>? _unmaximized;
  Completer<void>? _maximized;

  Future<void> enter() async {
    try {
      _restoreMaximized =
          defaultTargetPlatform == TargetPlatform.windows &&
          await windowManager.isMaximized();
      if (_restoreMaximized) {
        await _setTransitionsEnabled(false);
        try {
          _unmaximized = Completer<void>();
          await windowManager.unmaximize();
          await _unmaximized!.future.timeout(
            const Duration(milliseconds: 300),
            onTimeout: () {},
          );
          _unmaximized = null;
          await windowManager.setFullScreen(true);
        } finally {
          await _setTransitionsEnabled(true);
        }
        return;
      }

      await windowManager.setFullScreen(true);
    } catch (_) {
      _unmaximized = null;
      await _restoreWindow();
      rethrow;
    }
  }

  Future<void> exit() async {
    if (!_restoreMaximized) {
      await windowManager.setFullScreen(false);
      return;
    }

    await _setTransitionsEnabled(false);
    try {
      await windowManager.setFullScreen(false);
      await _restoreWindow();
    } finally {
      await _setTransitionsEnabled(true);
    }
  }

  @override
  void onWindowUnmaximize() {
    final unmaximized = _unmaximized;
    if (unmaximized != null && !unmaximized.isCompleted) {
      unmaximized.complete();
    }
  }

  @override
  void onWindowMaximize() {
    final maximized = _maximized;
    if (maximized != null && !maximized.isCompleted) maximized.complete();
  }

  Future<void> _restoreWindow() async {
    if (!_restoreMaximized) return;
    _restoreMaximized = false;
    _maximized = Completer<void>();
    await windowManager.maximize();
    await _maximized!.future.timeout(
      const Duration(milliseconds: 300),
      onTimeout: () {},
    );
    _maximized = null;
  }

  Future<void> _setTransitionsEnabled(bool enabled) =>
      _channel.invokeMethod('setTransitionsEnabled', enabled);
}
