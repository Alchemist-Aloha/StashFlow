import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// Web media must use URL/browser authentication, never custom HTTP headers.
Media createPlaybackMedia(
  String url, {
  Map<String, String>? httpHeaders,
  Duration? start,
  bool isWeb = kIsWeb,
}) => Media(url, httpHeaders: isWeb ? null : httpHeaders, start: start);
