import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../data/graphql/media_headers_provider.dart';

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

  static Future<void> prefetch(
    BuildContext context, {
    required String? imageUrl,
    Map<String, String>? headers,
  }) async {
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        _prefetched.contains(imageUrl)) {
      return;
    }

    _prefetched.add(imageUrl);
    try {
      final provider = CachedNetworkImageProvider(
        imageUrl,
        headers: headers,
        cacheManager: cacheManager,
      );
      await precacheImage(provider, context);
    } catch (_) {
      // ignore prefetch failures; user experience should fall back gracefully.
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
        StashImage.prefetch(context, imageUrl: imageUrl, headers: headers);
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
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
