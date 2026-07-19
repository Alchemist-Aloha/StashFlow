import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class DesktopFullscreen {
  DesktopFullscreen._();

  static final instance = DesktopFullscreen._();
  static const _windowInset = 16.0;
  static const _statePollInterval = Duration(milliseconds: 16);
  static const _statePollAttempts = 12;

  Future<void>? _activeTransition;
  bool _restoreMaximizedOnExit = false;
  Rect? _normalBounds;

  Future<void> enter() => _serialize(_enter);

  Future<void> exit() => _serialize(_exit);

  Future<void> _enter() async {
    if (defaultTargetPlatform != TargetPlatform.windows) {
      await windowManager.setFullScreen(true);
      return;
    }

    _restoreMaximizedOnExit = await windowManager.isMaximized();
    _normalBounds = null;
    if (!_restoreMaximizedOnExit) {
      await windowManager.setFullScreen(true);
      return;
    }

    try {
      final maximizedBounds = await windowManager.getBounds();
      await windowManager.unmaximize();
      await _ensureMaximizedState(false);
      _normalBounds = await windowManager.getBounds();
      await windowManager.setBounds(_slightlySmaller(maximizedBounds));
      await windowManager.setFullScreen(true);
    } catch (error, stackTrace) {
      try {
        await _restoreMaximizedWindow();
      } catch (_) {}
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _exit() async {
    await windowManager.setFullScreen(false);
    await _restoreMaximizedWindow();
  }

  Future<void> _restoreMaximizedWindow() async {
    if (!_restoreMaximizedOnExit) return;

    final normalBounds = _normalBounds;
    if (normalBounds != null) {
      await windowManager.setBounds(normalBounds);
    }
    await windowManager.maximize();
    await _ensureMaximizedState(true);
    _restoreMaximizedOnExit = false;
    _normalBounds = null;
  }

  Future<void> _ensureMaximizedState(bool expected) async {
    if (await _waitForMaximizedState(expected)) return;

    if (expected) {
      await windowManager.maximize();
    } else {
      await windowManager.unmaximize();
    }
    if (!await _waitForMaximizedState(expected)) {
      throw StateError(
        'Window did not become ${expected ? 'maximized' : 'unmaximized'}',
      );
    }
  }

  Future<bool> _waitForMaximizedState(bool expected) async {
    for (var attempt = 0; attempt < _statePollAttempts; attempt++) {
      if (await windowManager.isMaximized() == expected) return true;
      await Future<void>.delayed(_statePollInterval);
    }
    return false;
  }

  Rect _slightlySmaller(Rect bounds) {
    if (bounds.width <= _windowInset * 2 || bounds.height <= _windowInset * 2) {
      return bounds;
    }
    return Rect.fromLTRB(
      bounds.left + _windowInset,
      bounds.top + _windowInset,
      bounds.right - _windowInset,
      bounds.bottom - _windowInset,
    );
  }

  Future<void> _serialize(Future<void> Function() operation) async {
    while (_activeTransition != null) {
      try {
        await _activeTransition;
      } catch (_) {}
    }

    final current = operation();
    _activeTransition = current;
    try {
      await current;
    } finally {
      if (identical(_activeTransition, current)) {
        _activeTransition = null;
      }
    }
  }
}
