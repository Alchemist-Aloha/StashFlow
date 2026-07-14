import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class DesktopFullscreen with WindowListener {
  DesktopFullscreen._() {
    windowManager.addListener(this);
  }

  static final instance = DesktopFullscreen._();

  bool _restoreMaximized = false;
  Completer<void>? _unmaximized;

  Future<void> enter() async {
    try {
      _restoreMaximized =
          defaultTargetPlatform == TargetPlatform.windows &&
          await windowManager.isMaximized();
      if (_restoreMaximized) {
        _unmaximized = Completer<void>();
        await windowManager.unmaximize();
        await _unmaximized!.future.timeout(
          const Duration(milliseconds: 300),
          onTimeout: () {},
        );
        _unmaximized = null;
      }

      await windowManager.setFullScreen(true);
    } catch (_) {
      _unmaximized = null;
      await _restoreWindow();
      rethrow;
    }
  }

  Future<void> exit() async {
    await windowManager.setFullScreen(false);
    await _restoreWindow();
  }

  @override
  void onWindowUnmaximize() {
    final unmaximized = _unmaximized;
    if (unmaximized != null && !unmaximized.isCompleted) {
      unmaximized.complete();
    }
  }

  Future<void> _restoreWindow() async {
    if (!_restoreMaximized) return;
    _restoreMaximized = false;
    await windowManager.maximize();
  }
}
