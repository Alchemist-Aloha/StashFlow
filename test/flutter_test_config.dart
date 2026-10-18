import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Supplies the native texture boundary without requiring a desktop renderer.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
  // Leave HTTP-only unit tests free of Flutter's mocked networking binding.
  if (BindingBase.debugBindingType() == null) return;
  final binding = TestWidgetsFlutterBinding.instance;
  const channel = MethodChannel('com.alexmercerind/media_kit_video');
  const codec = StandardMethodCodec();
  binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
    call,
  ) async {
    if (call.method == 'VideoOutputManager.Create') {
      final arguments = call.arguments as Map<Object?, Object?>;
      final handle = int.parse(arguments['handle']! as String);
      binding.channelBuffers.push(
        channel.name,
        codec.encodeMethodCall(
          MethodCall('VideoOutput.Resize', {
            'handle': handle,
            'id': handle,
            'rect': {'left': 0, 'top': 0, 'width': 1, 'height': 1},
          }),
        ),
        (_) {},
      );
    }
    return null;
  });
}
