import 'package:media_kit/media_kit.dart';

/// Applies runtime mpv options only to native playback sessions.
Future<void> applyPlayerMpvProperties(
  PlatformPlayer? platform,
  Map<String, String> options,
) async {
  if (platform is! NativePlayer) return;
  for (final entry in options.entries) {
    await platform.setProperty(entry.key, entry.value);
  }
}
