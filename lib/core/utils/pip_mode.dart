import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart' show VideoParams;

/// Minimum window size the desktop layouts are designed around.
const Size kDesktopMinimumWindowSize = Size(800, 600);

/// Decoder display ratio, corrected for non-square pixels and rotation.
/// Returns null until usable display metadata is available.
double? pipDisplayAspectRatio(VideoParams params) {
  double? ratio;
  if ((params.dw ?? 0) > 0 && (params.dh ?? 0) > 0) {
    ratio = params.dw! / params.dh!;
  } else {
    ratio = params.aspect;
  }
  if (ratio == null || !ratio.isFinite || ratio <= 0) return null;
  return (params.rotate ?? 0) % 180 == 90 ? 1 / ratio : ratio;
}

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
  static bool get isSupported =>
      isWindowed ||
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

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

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final args = _androidAspectRatioArguments(aspectRatio ?? 16 / 9);
      if (args == null) return false;

      final result = await _channel.invokeMethod<bool>(
        'enterPictureInPicture',
        args,
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Updates Android's existing system PiP window without re-entering PiP.
  /// Invalid/missing metadata leaves its last known ratio unchanged.
  static Future<bool> updateAspectRatio(double? aspectRatio) async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        !isInPipMode.value) {
      return false;
    }
    final args = _androidAspectRatioArguments(aspectRatio);
    if (args == null) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'updatePictureInPictureAspectRatio',
            args,
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Map<String, int>? _androidAspectRatioArguments(double? ratio) {
    if (ratio == null || !ratio.isFinite || ratio <= 0) return null;
    // Rounding must stay inside Android's inclusive [1/2.39, 2.39] range.
    final numerator = (ratio.clamp(1 / 2.39, 2.39) * 1000).round().clamp(
      419,
      2390,
    );
    return {'numerator': numerator, 'denominator': 1000};
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
