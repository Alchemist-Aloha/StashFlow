import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'app_log_store.dart';

/// Serializes desktop fullscreen transactions across image and video viewers.
/// Windows restoration belongs to the runner, not to window_manager.
class DesktopFullscreen {
  DesktopFullscreen._();

  static final instance = DesktopFullscreen._();
  static const _channel = MethodChannel('stash_app_flutter/fullscreen');

  Future<void>? _activeTransition;

  Future<void> enter() => _serialize(() => _setFullScreen(true));

  Future<void> exit() => _serialize(() => _setFullScreen(false));

  Future<void> _setFullScreen(bool fullscreen) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _channel.invokeMethod<void>('setFullScreen', fullscreen);
      } else {
        await windowManager.setFullScreen(fullscreen);
      }
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        fullscreen ? 'enter' : 'exit',
        error,
        stackTrace,
        source: 'desktop_fullscreen',
      );
      rethrow;
    }
  }

  Future<void> _serialize(Future<void> Function() operation) async {
    while (_activeTransition != null) {
      try {
        await _activeTransition;
      } on Object catch (error, stackTrace) {
        AppLogStore.instance.addError(
          'serialize',
          error,
          stackTrace,
          source: 'desktop_fullscreen',
        );
        // A failed transition must not block the next attempt.
      }
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
