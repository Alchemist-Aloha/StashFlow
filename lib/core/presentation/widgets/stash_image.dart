import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../data/graphql/media_headers_provider.dart';

// Lightweight in-file shimmer placeholder — avoids an extra package dependency.
class _Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _Shimmer({
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }
}

class StashImage extends ConsumerWidget {
  static final CacheManager cacheManager = CacheManager(
    Config(
      'stashImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 300,
      fileService: HttpFileService(),
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

  static final Set<String> _prefetched = <String>{};
  static const int defaultPrefetchDistance = 20;
  static const int _maxConcurrentPrefetch = 4;
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

    _prefetched.add(dedupeKey);
    // Throttle concurrent prefetches to avoid saturating network / IO.
    while (_ongoingPrefetches >= _maxConcurrentPrefetch) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
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
      // ignore prefetch failures; user experience should fall back gracefully.
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

    // Start prefetch early to improve perceived loading for subsequent child requests.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        StashImage.prefetch(
          context,
          imageUrl: imageUrl,
          headers: headers,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
        );
      }
    });

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      httpHeaders: headers,
      cacheManager: cacheManager,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
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
      errorWidget: (context, url, error) => _buildError(context),
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
