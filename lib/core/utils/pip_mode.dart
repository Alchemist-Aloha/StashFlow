import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PipMode {
  PipMode._();

  static const MethodChannel _channel = MethodChannel('stash_app_flutter/pip');

  static final ValueNotifier<bool> isInPipMode = ValueNotifier<bool>(false);

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipModeChanged') {
        isInPipMode.value = call.arguments as bool;
      }
    });
  }

  static Future<bool> enterIfAvailable({double? aspectRatio}) async {
    if (!Platform.isAndroid) return false;
    try {
      final Map<String, dynamic> args = {};
      if (aspectRatio != null) {
        // Convert double to rational numerator/denominator (simplified)
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
