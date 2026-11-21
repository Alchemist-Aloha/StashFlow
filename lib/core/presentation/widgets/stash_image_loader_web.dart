import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/painting.dart';

/// Web stand-in for the IO cache loader: web StashImage uses [NetworkImage],
/// so the cached provider that calls this is never resolved there.
class ImageLoader {
  Stream<ui.Codec> loadImageAsync(
    String url,
    String? cacheKey,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
    BaseCacheManager cacheManager,
    int? maxHeight,
    int? maxWidth,
    Map<String, String>? headers,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    VoidCallback evictImage,
  ) => throw UnsupportedError('Cached image loading is native-only');
}
