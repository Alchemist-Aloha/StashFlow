import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Minimum window size the desktop layouts are designed around.
const Size kDesktopMinimumWindowSize = Size(800, 600);

typedef DesktopPipEnter = Future<bool> Function(double? aspectRatio);
typedef DesktopPipExit = Future<bool> Function();

/// Manages platform picture-in-picture (PiP) state.
///
/// Android delegates to the system PiP window over a [MethodChannel]. Desktop
/// platforms delegate to a separately registered multi-view window, so the
/// primary app window is never resized or redecorated.
class PipMode {
  PipMode._();

  static const MethodChannel _channel = MethodChannel('stash_app_flutter/pip');

  /// Tracks whether playback is currently presented in PiP.
  static final ValueNotifier<bool> isInPipMode = ValueNotifier<bool>(false);

  static DesktopPipEnter? _windowedEnter;
  static DesktopPipExit? _windowedExit;

  /// Whether PiP is available on the current platform.
  static bool get isSupported => isWindowed || (!kIsWeb && Platform.isAndroid);

  /// Whether the app can close its PiP window programmatically.
  static bool get canExit => isWindowed;

  /// Whether PiP uses a separate application-managed desktop window.
  static bool get isWindowed =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Registers the feature-owned desktop window lifecycle.
  static void configureWindowedHandlers({
    required DesktopPipEnter enter,
    required DesktopPipExit exit,
  }) {
    _windowedEnter = enter;
    _windowedExit = exit;
  }

  /// Removes desktop window handlers owned by a disposed player provider.
  static void clearWindowedHandlers() {
    _windowedEnter = null;
    _windowedExit = null;
  }

  /// Notifies shared player state that the desktop PiP window was closed by the
  /// window manager or one of its own controls.
  static void windowedWindowClosed() {
    if (isWindowed) isInPipMode.value = false;
  }

  /// Initializes the Android PiP status listener.
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipModeChanged') {
        isInPipMode.value = call.arguments as bool;
      }
    });
  }

  /// Attempts to enter picture-in-picture mode.
  static Future<bool> enterIfAvailable({double? aspectRatio}) async {
    if (isWindowed) {
      if (isInPipMode.value) return true;
      final enter = _windowedEnter;
      if (enter == null) return false;
      try {
        final entered = await enter(aspectRatio);
        if (entered) isInPipMode.value = true;
        return entered;
      } catch (_) {
        return false;
      }
    }

    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final Map<String, dynamic> args = {};
      if (aspectRatio != null) {
        // Android permits aspect ratios from 0.418 through 2.39.
        aspectRatio = aspectRatio.clamp(0.418, 2.39).toDouble();
        args['numerator'] = (aspectRatio * 1000).toInt();
        args['denominator'] = 1000;
      }

      final result = await _channel.invokeMethod<bool>(
        'enterPictureInPicture',
        args,
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Closes the application-managed desktop PiP window.
  static Future<bool> exitIfAvailable() async {
    if (!canExit || !isInPipMode.value) return false;
    final exit = _windowedExit;
    if (exit == null) return false;
    try {
      final exited = await exit();
      if (exited) isInPipMode.value = false;
      return exited;
    } catch (_) {
      return false;
    }
  }
}
