import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

import '../../domain/entities/scene.dart';
import 'stash_player.dart';

/// Web media must use URL/browser authentication, never custom HTTP headers.
///
/// [duration] is the scene's full length, which [StashPlayer] reports for
/// live transcodes that cannot provide it themselves.
Media createPlaybackMedia(
  String url, {
  Map<String, String>? httpHeaders,
  Duration? start,
  Duration? duration,
  bool isWeb = kIsWeb,
}) => Media(
  url,
  httpHeaders: isWeb ? null : httpHeaders,
  start: start,
  extras: duration == null
      ? null
      : {stashDurationExtra: duration.inMilliseconds},
);

/// The scene's primary file duration, or null when unknown.
Duration? sceneFileDuration(Scene scene) {
  final seconds = scene.files.firstOrNull?.duration;
  return seconds == null || seconds <= 0
      ? null
      : Duration(milliseconds: (seconds * 1000).round());
}
