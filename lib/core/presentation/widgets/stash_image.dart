import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:cached_network_image_ce/cached_network_image.dart';
// shortcut: CE 4.13's public stub omits httpClientFactory; use its export once fixed.
// ignore: implementation_imports
import 'package:cached_network_image_ce/src/cache/default_cache_manager.dart'
    if (dart.library.js_interop) 'package:cached_network_image_ce/src/cache/default_cache_manager_web.dart'
    as image_cache;

// ignore: implementation_imports
import 'stash_image_loader_web.dart'
    if (dart.library.io) 'package:cached_network_image_ce/src/image_provider/_image_loader.dart';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../../data/auth/dio_image_client.dart';
import '../../data/auth/auth_provider.dart';
import '../../data/graphql/media_headers_provider.dart';
import '../../data/graphql/url_resolver.dart';
import '../../data/graphql/graphql_client.dart';
import '../../utils/app_log_store.dart';
import '../../utils/extra_image_codecs.dart';

/// [CachedNetworkImageProvider] that also renders AVIF and JPEG XL from the
/// same cached bytes once Flutter's engine codec rejects them.
class _StashCachedImageProvider extends CachedNetworkImageProvider {
  const _StashCachedImageProvider(
    super.url, {
    super.headers,
    super.cacheManager,
  });

  @override
  ImageStreamCompleter loadImage(
    CachedNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    final codecs = ImageLoader().loadImageAsync(
      url,
      cacheKey,
      chunkEvents,
      decode,
      cacheManager!,
      maxHeight,
      maxWidth,
      headers,
      imageRenderMethodForWeb,
      () {},
    );
    return MultiImageStreamCompleter(
      codec: _withExtraFormats(codecs, decode, key),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      minimumGifFrameDuration: key.minimumGifFrameDuration,
      animate: key.animate,
    );
  }

  static Stream<ui.Codec> _withExtraFormats(
    Stream<ui.Codec> codecs,
    ImageDecoderCallback decode,
    Object key,
  ) async* {
    try {
      try {
        await for (final codec in codecs) {
          yield codec;
        }
      } on UnsupportedImageFormatException catch (error) {
        final bmp = await transcodeExtraImageFormat(error.bytes);
        if (bmp == null) rethrow;
        // The engine decode keeps ResizeImage and memCache sizing intact.
        yield await decode(await ui.ImmutableBuffer.fromUint8List(bmp));
      }
    } on Object {
      // Replaces the loader's own eviction, which this wrapper owns.
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      rethrow;
    }
  }

  // The base equality accepts any CachedNetworkImageProvider; keep the plain
  // widget provider and this one from sharing an ImageCache entry.
  @override
  bool operator ==(Object other) =>
      other is _StashCachedImageProvider && super == other;

  @override
  int get hashCode => Object.hash(super.hashCode, _StashCachedImageProvider);
}

// Small stateful wrapper which retries a failed cached image load by
// removing the local cache entry and forcing a re-download. This helps
// recover from corrupted/partial files that would otherwise produce
// "invalid image data" Flutter errors.
class _RetryingCachedImage extends StatefulWidget {
  const _RetryingCachedImage({
    required this.imageUrl,
    this.headers,
    this.cacheManager,
    this.width,
    this.height,
    this.fit,
    this.memCacheWidth,
    this.memCacheHeight,
    this.frameBuilder,
    this.placeholderAsset,
  });

  final String imageUrl;
  final Map<String, String>? headers;
  final CacheManager? cacheManager;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final ImageFrameBuilder? frameBuilder;
  final String? placeholderAsset;
  static const int maxRetries = 2;
  static const retryBackoff = Duration(seconds: 30);
  static const maxBackoffEntries = 256;
  static final LinkedHashMap<String, DateTime> _retryAfter =
      LinkedHashMap<String, DateTime>();

  static bool isBackedOff(String imageUrl) {
    final retryAfter = _retryAfter[imageUrl];
    if (retryAfter == null) return false;
    if (retryAfter.isAfter(DateTime.now())) return true;
    _retryAfter.remove(imageUrl);
    return false;
  }

  static void backOff(String imageUrl) {
    _retryAfter.remove(imageUrl);
    if (_retryAfter.length >= maxBackoffEntries) {
      _retryAfter.remove(_retryAfter.keys.first);
    }
    _retryAfter[imageUrl] = DateTime.now().add(retryBackoff);
  }

  @override
  State<_RetryingCachedImage> createState() => _RetryingCachedImageState();
}

class _RetryingCachedImageState extends State<_RetryingCachedImage> {
  int _attempt = 0;
  int _retryGeneration = 0;
  bool _retrying = false;

  @override
  void didUpdateWidget(_RetryingCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        !mapEquals(oldWidget.headers, widget.headers) ||
        oldWidget.cacheManager != widget.cacheManager) {
      _attempt = 0;
      _retryGeneration++;
      _retrying = false;
    }
  }

  Future<void> _handleError() async {
    if (_retrying) return;
    if (_attempt >= _RetryingCachedImage.maxRetries) {
      _RetryingCachedImage.backOff(widget.imageUrl);
      return;
    }
    final generation = _retryGeneration;
    final imageUrl = widget.imageUrl;
    final cacheManager = widget.cacheManager;
    _retrying = true;
    _attempt++;

    try {
      // Remove possibly-corrupted cached file and force re-download.
      if (cacheManager != null) {
        await cacheManager.removeFile(imageUrl);
      }
    } on Exception catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'handleError',
        error,
        stackTrace,
        source: 'stash_image',
      );
    }

    // Small delay to avoid tight retry loops and allow cache manager state to settle.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mounted && generation == _retryGeneration) setState(() {});
    if (generation == _retryGeneration) _retrying = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_RetryingCachedImage.isBackedOff(widget.imageUrl)) {
      return _buildError(context);
    }
    return CachedNetworkImage(
      key: ValueKey('${widget.imageUrl}::$_attempt'),
      imageUrl: widget.imageUrl,
      httpHeaders: widget.headers,
      cacheManager: widget.cacheManager,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      imageBuilder: widget.frameBuilder == null
          ? null
          : (context, provider) => Image(
              image: ResizeImage.resizeIfNeeded(
                widget.memCacheWidth,
                widget.memCacheHeight,
                provider,
              ),
              excludeFromSemantics: true,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              frameBuilder: widget.frameBuilder,
              errorBuilder: (context, error, stackTrace) =>
                  _buildError(context),
            ),
      placeholder: (context, url) => Container(
        color: context.colors.surfaceVariant,
        child: Center(
          child: SizedBox(
            width: 48 * context.dimensions.fontSizeFactor,
            height: 48 * context.dimensions.fontSizeFactor,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.outline.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
      unsupportedImageBuilder: (context, url, bytes) {
        if (sniffExtraImageFormat(bytes) == null) return _retryOrError(context);
        return Image(
          image: ResizeImage.resizeIfNeeded(
            widget.memCacheWidth,
            widget.memCacheHeight,
            _StashCachedImageProvider(
              widget.imageUrl,
              headers: widget.headers,
              cacheManager: widget.cacheManager,
            ),
          ),
          excludeFromSemantics: true,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          frameBuilder: widget.frameBuilder,
          errorBuilder: (context, error, stackTrace) => _buildError(context),
        );
      },
      errorBuilder: (context, error, stackTrace) => _retryOrError(context),
    );
  }

  Widget _retryOrError(BuildContext context) {
    // Kick off async cleanup + retry; show the standard error UI immediately.
    unawaited(_handleError());
    return _buildError(context);
  }

  Widget _buildError(BuildContext context) => _errorBox(
    context,
    width: widget.width,
    height: widget.height,
    placeholderAsset: widget.placeholderAsset,
  );
}

/// Bundled placeholder art (white on transparent), tinted with [color].
Widget _placeholder(
  String asset, {
  double? width,
  double? height,
  required Color color,
}) => asset.endsWith('.svg')
    ? SvgPicture.asset(
        asset,
        width: width,
        height: height,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        excludeFromSemantics: true,
      )
    : Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
        color: color,
        excludeFromSemantics: true,
      );

/// Failed-image fallback: [placeholderAsset] tinted to the theme, or an icon.
Widget _errorBox(
  BuildContext context, {
  double? width,
  double? height,
  String? placeholderAsset,
}) => Container(
  width: width,
  height: height,
  color: context.colors.surfaceVariant,
  child: placeholderAsset != null
      ? _placeholder(
          placeholderAsset,
          width: width,
          height: height,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
        )
      : Center(
          child: Icon(
            Icons.broken_image,
            color: context.colors.onSurfaceVariant,
            size: 24 * context.dimensions.fontSizeFactor,
          ),
        ),
);

class StashImage extends ConsumerWidget {
  static final CacheManager cacheManager = image_cache.DefaultCacheManager(
    stalePeriod: const Duration(days: 7),
    // Shared by grid thumbnails and full-size viewer originals; the package
    // bounds file count only, so the 7-day stale period also caps disk use.
    maxNrOfCacheObjects: 1000,
    httpClientFactory: DioImageClient.new,
  );

  const StashImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.frameBuilder,
    this.placeholderAsset,
    super.key,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// Optionally decorates decoded image frames without changing cache or retry
  /// ownership. The child excludes image semantics on both native and web.
  final ImageFrameBuilder? frameBuilder;

  /// Bundled image shown instead of the broken-image icon when the URL is
  /// missing, fails, or is Stash's SVG default (`default=true`), which Flutter
  /// cannot decode.
  final String? placeholderAsset;

  /// Returns an [ImageProvider] for the given [imageUrl], applying web-specific
  /// authentication fallbacks (apikey query parameter) when running on the web.
  static ImageProvider provider(
    WidgetRef ref,
    String imageUrl, {
    Map<String, String>? headers,
  }) {
    if (imageUrl.isEmpty) {
      return const AssetImage('asset/icon_original.png');
    }

    if (kIsWeb) {
      final authState = ref.read(authProvider);
      final apiKey = ref.read(serverApiKeyProvider);
      final serverUrl = ref.read(serverUrlProvider);

      final effectiveUrl = applyWebMediaAuthFallback(
        url: imageUrl,
        authMode: authState.mode,
        apiKey: apiKey,
        graphqlEndpoint: Uri.tryParse(serverUrl),
      );

      return NetworkImage(effectiveUrl, headers: headers);
    }

    return _StashCachedImageProvider(
      imageUrl,
      headers: headers,
      cacheManager: cacheManager,
    );
  }

  static final Set<String> _prefetching = <String>{};
  static final Queue<Completer<void>> _prefetchWaiters =
      Queue<Completer<void>>();
  static const int defaultPrefetchDistance = 20;
  static const int _maxConcurrentPrefetch = 6;
  static int _ongoingPrefetches = 0;

  static Future<void> _acquirePrefetchSlot() async {
    if (_ongoingPrefetches < _maxConcurrentPrefetch) {
      _ongoingPrefetches++;
      return;
    }

    final waiter = Completer<void>();
    _prefetchWaiters.addLast(waiter);
    await waiter.future;
  }

  static void _releasePrefetchSlot() {
    if (_prefetchWaiters.isNotEmpty) {
      _prefetchWaiters.removeFirst().complete();
    } else {
      _ongoingPrefetches--;
    }
  }

  static Future<void> prefetch(
    BuildContext context, {
    required String? imageUrl,
    Map<String, String>? headers,
    int? memCacheWidth,
    int? memCacheHeight,
  }) async {
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.contains('default=true')) {
      return;
    }

    final dedupeKey = '$imageUrl|w${memCacheWidth ?? 0}h${memCacheHeight ?? 0}';
    if (!_prefetching.add(dedupeKey)) return;

    var acquiredSlot = false;
    try {
      await _acquirePrefetchSlot();
      acquiredSlot = true;
      if (!context.mounted) return;

      final baseProvider = _StashCachedImageProvider(
        imageUrl,
        headers: headers,
        cacheManager: cacheManager,
      );

      final ImageProvider provider;
      if (memCacheWidth != null || memCacheHeight != null) {
        provider = ResizeImage(
          baseProvider,
          width: memCacheWidth,
          height: memCacheHeight,
        );
      } else {
        provider = baseProvider;
      }

      await precacheImage(provider, context);
    } on Exception catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'prefetch',
        error,
        stackTrace,
        source: 'stash_image',
      );
      // A visible image load can retry through the normal widget path.
    } finally {
      if (acquiredSlot) _releasePrefetchSlot();
      _prefetching.remove(dedupeKey);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl == null ||
        imageUrl!.isEmpty ||
        (placeholderAsset != null && imageUrl!.contains('default=true'))) {
      return _buildError(context);
    }

    final headers = ref.watch(mediaHeadersProvider);

    if (kIsWeb) {
      final authState = ref.watch(authProvider);
      final apiKey = ref.watch(serverApiKeyProvider);
      final serverUrl = ref.watch(serverUrlProvider);

      final effectiveUrl = applyWebMediaAuthFallback(
        url: imageUrl!,
        authMode: authState.mode,
        apiKey: apiKey,
        graphqlEndpoint: Uri.tryParse(serverUrl),
      );

      return Image.network(
        excludeFromSemantics: true,
        effectiveUrl,
        headers: headers,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: frameBuilder,
        errorBuilder: (context, error, stackTrace) => _buildError(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(context);
        },
      );
    }

    return _RetryingCachedImage(
      imageUrl: imageUrl!,
      headers: headers,
      cacheManager: cacheManager,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      frameBuilder: frameBuilder,
      placeholderAsset: placeholderAsset,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: context.colors.surfaceVariant,
      child: Center(
        child: SizedBox(
          width: 48 * context.dimensions.fontSizeFactor,
          height: 48 * context.dimensions.fontSizeFactor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.outline.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) => _errorBox(
    context,
    width: width,
    height: height,
    placeholderAsset: placeholderAsset,
  );
}
