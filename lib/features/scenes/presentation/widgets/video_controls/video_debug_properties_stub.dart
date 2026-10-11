import 'package:media_kit/media_kit.dart';

/// Native mpv diagnostics are unavailable on web.
Future<Map<String, String>> sampleVideoDebugProperties(
  PlatformPlayer? platform,
  Iterable<String> properties,
) async => <String, String>{};
