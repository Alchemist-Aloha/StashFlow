import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controls Android's system media volume.
class SystemMediaVolume {
  SystemMediaVolume._();

  static const MethodChannel _channel = MethodChannel(
    'stash_app_flutter/media_volume',
  );

  /// Adjusts system media volume by a normalized [delta] and returns its value.
  static Future<double?> adjustMediaVolume(double delta) async {
    if (kIsWeb || !Platform.isAndroid || !delta.isFinite) return null;
    try {
      return await _channel.invokeMethod<double>(
        'adjustMediaVolume',
        <String, double>{'delta': delta},
      );
    } on Exception catch (_) {
      return null;
    }
  }
}
