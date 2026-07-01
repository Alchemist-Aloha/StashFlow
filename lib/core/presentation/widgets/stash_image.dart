import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../theme/app_theme.dart';
import '../../data/auth/dio_file_service.dart';
import '../../data/auth/auth_provider.dart';
import '../../data/graphql/media_headers_provider.dart';
import '../../data/graphql/url_resolver.dart';
import '../../data/graphql/graphql_client.dart';

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
      errorWidget: (context, url, error) {
        // Kick off async cleanup + retry; show the standard error UI immediately.
        _handleError();
        return Container(
          width: widget.width,
          height: widget.height,
          color: context.colors.surfaceVariant,
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: context.colors.onSurfaceVariant,
              size: 24 * context.dimensions.fontSizeFactor,
            ),
          ),
        );
      },
    );
  }
}

class StashImage extends ConsumerWidget {
  static final CacheManager cacheManager = CacheManager(
    Config(
      'stashImageCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
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
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl.contains('default=true')) {
      return;
    }

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
        excludeFromSemantics: true,
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

  Widget _buildError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.colors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: context.colors.onSurfaceVariant,
          size: 24 * context.dimensions.fontSizeFactor,
        ),
      ),
    );
  }
}
