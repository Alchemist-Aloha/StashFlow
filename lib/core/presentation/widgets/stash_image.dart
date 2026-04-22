import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../data/auth/dio_file_service.dart';
import '../../data/auth/auth_provider.dart';
import '../../data/graphql/media_headers_provider.dart';
import '../../data/graphql/url_resolver.dart';
import '../../data/graphql/graphql_client.dart';

// Lightweight in-file shimmer placeholder — avoids an extra package dependency.
class _Shimmer extends StatefulWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
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
  });

  final String imageUrl;
  final Map<String, String>? headers;
  final CacheManager? cacheManager;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  static const int maxRetries = 2;

  @override
  State<_RetryingCachedImage> createState() => _RetryingCachedImageState();
}

class _RetryingCachedImageState extends State<_RetryingCachedImage> {
  int _attempt = 0;

  Future<void> _handleError() async {
    if (_attempt >= _RetryingCachedImage.maxRetries) return;
    _attempt++;

    try {
      // Remove possibly-corrupted cached file and force re-download.
      if (widget.cacheManager != null) {
        await widget.cacheManager!.removeFile(widget.imageUrl);
      }
    } catch (_) {}

    // Small delay to avoid tight retry loops and allow cache manager state to settle.
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
      placeholder: (context, url) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: _Shimmer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // Kick off async cleanup + retry; show the standard error UI immediately.
        _handleError();
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[800],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54),
          ),
        );
      },
    );
  }
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!kIsWeb) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              final double progress = _controller.value;
              final double center = progress * 2 - 0.5; // move across
              return LinearGradient(
                begin: Alignment(-1, 0),
                end: Alignment(1, 0),
                colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade700,
                  Colors.grey.shade800,
                ],
                stops: [
                  (center - 0.3).clamp(0.0, 1.0),
                  center.clamp(0.0, 1.0),
                  (center + 0.3).clamp(0.0, 1.0),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class StashImage extends ConsumerWidget {
  static final CacheManager cacheManager = CacheManager(
    Config(
      'stashImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 300,
      fileService: DioFileService(),
    ),
  );

  const StashImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

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

    return CachedNetworkImageProvider(
      imageUrl,
      headers: headers,
      cacheManager: cacheManager,
    );
  }

  static final Set<String> _prefetched = <String>{};
  static final Set<String> _cacheCheckedUrls = <String>{};
  static const int defaultPrefetchDistance = 40;
  static const int _maxConcurrentPrefetch = 10;
  static int _ongoingPrefetches = 0;

  static Future<void> prefetch(
    BuildContext context, {
    required String? imageUrl,
    Map<String, String>? headers,
    int? memCacheWidth,
    int? memCacheHeight,
  }) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    final dedupeKey = '$imageUrl|w${memCacheWidth ?? 0}h${memCacheHeight ?? 0}';
    if (_prefetched.contains(dedupeKey)) return;

    // Optimistically mark as prefetched to prevent concurrent attempts
    // from queuing up while we wait on the throttle limit or IO
    _prefetched.add(dedupeKey);

    // Throttle concurrent prefetches to avoid saturating network / IO.
    while (_ongoingPrefetches >= _maxConcurrentPrefetch) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (!context.mounted) return;
    _ongoingPrefetches++;
    try {
      final baseProvider = CachedNetworkImageProvider(
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
    } catch (_) {
      // If it failed to prefetch, allow future attempts to try again
      _prefetched.remove(dedupeKey);
    } finally {
      _ongoingPrefetches--;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl == null || imageUrl!.isEmpty) {
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
        effectiveUrl,
        headers: headers,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildError(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(context);
        },
      );
    }

    // Ensure we only schedule the costly cache-check once per imageUrl during lifetime

    if (!_cacheCheckedUrls.contains(imageUrl)) {
      _cacheCheckedUrls.add(imageUrl!);

      // Start prefetch early to improve perceived loading for subsequent child requests.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        final url = imageUrl;
        if (url == null || url.isEmpty) return;

        // Remove obviously-corrupt cached files (very small size) before
        // attempting to prefetch or render. This prevents persistent
        // "Invalid image data" errors when cache contains truncated files.
        () async {
          try {
            final info = await cacheManager.getFileFromCache(url);
            if (info != null) {
              final file = info.file;
              if (await file.exists()) {
                final len = await file.length();
                if (len < 64) {
                  await cacheManager.removeFile(url);
                }
              } else {
                await cacheManager.removeFile(url);
              }
            }
          } catch (_) {}

          if (context.mounted) {
            StashImage.prefetch(
              context,
              imageUrl: url,
              headers: headers,
              memCacheWidth: memCacheWidth,
              memCacheHeight: memCacheHeight,
            );
          }
        }();
      });
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
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: _Shimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }
}
