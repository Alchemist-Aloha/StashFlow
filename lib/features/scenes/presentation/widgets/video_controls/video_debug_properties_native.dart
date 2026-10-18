import 'package:media_kit/media_kit.dart';

/// Samples supported mpv diagnostics without waiting on player initialization.
Future<Map<String, String>> sampleVideoDebugProperties(
  PlatformPlayer? platform,
  Iterable<String> properties,
) async {
  final values = <String, String>{};
  if (platform is NativePlayer) {
    for (final property in properties) {
      try {
        values[property] = await platform.getProperty(
          property,
          waitForInitialization: false,
        );
      } on Object {
        // Properties may be absent or the session may be disposing.
      }
    }
  }
  return values;
}
