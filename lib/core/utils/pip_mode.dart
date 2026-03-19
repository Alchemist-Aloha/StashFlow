import 'dart:io';

import 'package:flutter/services.dart';

class PipMode {
  PipMode._();

  static const MethodChannel _channel = MethodChannel('stash_app_flutter/pip');

  static Future<bool> enterIfAvailable() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('enterPictureInPicture');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
