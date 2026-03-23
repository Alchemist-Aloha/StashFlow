import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A utility class for managing Android's native Picture-in-Picture (PiP) mode.
/// 
/// This class uses [MethodChannel] to communicate with the native Android 
/// activity to trigger PiP and listen for status changes.
class PipMode {
  PipMode._();

  static const MethodChannel _channel = MethodChannel('stash_app_flutter/pip');

  /// A notifier that tracks whether the app is currently in PiP mode.
  /// 
  /// UI components can listen to this to hide non-essential elements (like
  /// navigation bars and details panels) when in PiP.
  static final ValueNotifier<bool> isInPipMode = ValueNotifier<bool>(false);

  /// Initializes the PiP status listener. Should be called at app startup.
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipModeChanged') {
        isInPipMode.value = call.arguments as bool;
      }
    });
  }

  /// Attempts to enter Picture-in-Picture mode on the Android device.
  /// 
  /// [aspectRatio] should match the current video's dimensions to ensure
  /// the system window is sized correctly. Android enforces limits (0.418 to 2.39).
  static Future<bool> enterIfAvailable({double? aspectRatio}) async {
    if (!Platform.isAndroid) return false;
    try {
      final Map<String, dynamic> args = {};
      if (aspectRatio != null) {
        // Clamp aspect ratio to Android's supported range
        if (aspectRatio > 2.39) aspectRatio = 2.39; // Android max limit
        if (aspectRatio < 0.418) aspectRatio = 0.418; // Android min limit
        
        args['numerator'] = (aspectRatio * 1000).toInt();
        args['denominator'] = 1000;
      }

      final result = await _channel.invokeMethod<bool>('enterPictureInPicture', args);
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
