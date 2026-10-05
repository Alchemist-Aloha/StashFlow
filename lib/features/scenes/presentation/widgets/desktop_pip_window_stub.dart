import 'package:flutter/foundation.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Playback state shared with the native desktop PiP window implementation.
class DesktopPipPlaybackSource {
  const DesktopPipPlaybackSource({
    required this.controller,
    required this.canPlayPrevious,
    required this.canPlayNext,
  });

  final VideoController controller;
  final bool canPlayPrevious;
  final bool canPlayNext;
}

/// Web has no separate native window for the desktop PiP implementation.
class DesktopPipWindowSession {
  static Future<bool> open({
    required DesktopPipPlaybackSource source,
    required double? aspectRatio,
    required VoidCallback onTogglePlayback,
    required Future<void> Function(Duration position) onSeek,
    required Future<void> Function() onPrevious,
    required Future<void> Function() onNext,
  }) async => false;

  static void updateSource(DesktopPipPlaybackSource source) {}

  static Future<bool> close() async => true;
}
