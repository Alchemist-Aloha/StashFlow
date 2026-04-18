import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/vtt_service.dart';
import '../../domain/entities/sprite_info.dart';

class ScrubbingPreview extends ConsumerStatefulWidget {
  const ScrubbingPreview({
    required this.vttUrl,
    required this.timeInSeconds,
    this.headers,
    this.width = 160,
    this.height = 90,
    super.key,
  });

  final String vttUrl;
  final double timeInSeconds;
  final Map<String, String>? headers;
  final double width;
  final double height;

  @override
  ConsumerState<ScrubbingPreview> createState() => _ScrubbingPreviewState();
}

class _ScrubbingPreviewState extends ConsumerState<ScrubbingPreview> {
  Future<List<SpriteInfo>?>? _spriteInfoFuture;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(ScrubbingPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vttUrl != widget.vttUrl) {
      _fetch();
    }
  }

  void _fetch() {
    final vttService = ref.read(vttServiceProvider);
    _spriteInfoFuture = vttService.fetchSpriteInfo(
      widget.vttUrl,
      widget.headers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SpriteInfo>?>(
      future: _spriteInfoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final sprites = snapshot.data!;
        SpriteInfo? activeSprite;

        // Find the sprite for the current time
        for (final sprite in sprites) {
          if (widget.timeInSeconds >= sprite.start &&
              widget.timeInSeconds < sprite.end) {
            activeSprite = sprite;
            break;
          }
        }

        if (activeSprite == null) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double targetW = widget.width.isFinite
                ? widget.width
                : constraints.maxWidth;
            final double targetH = widget.height.isFinite
                ? widget.height
                : constraints.maxHeight;

            return Container(
              width: targetW,
              height: targetH,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: _SpriteImage(
                  sprite: activeSprite!,
                  headers: widget.headers,
                  targetWidth: targetW,
                  targetHeight: targetH,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SpriteImage extends StatelessWidget {
  const _SpriteImage({
    required this.sprite,
    this.headers,
    required this.targetWidth,
    required this.targetHeight,
  });

  final SpriteInfo sprite;
  final Map<String, String>? headers;
  final double targetWidth;
  final double targetHeight;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: sprite.url,
      httpHeaders: headers,
      imageBuilder: (context, imageProvider) {
        final scaleX = targetWidth / sprite.w;
        final scaleY = targetHeight / sprite.h;

        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(-sprite.x * scaleX, -sprite.y * scaleY),
              child: Transform.scale(
                alignment: Alignment.topLeft,
                scaleX: scaleX,
                scaleY: scaleY,
                child: Image(
                  image: imageProvider,
                  alignment: Alignment.topLeft,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
        );
      },
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        AppLogStore.instance.add(
          'Error loading sprite sheet: $url, error: $error',
          source: 'SpriteImage',
        );
        return const Icon(Icons.error);
      },
    );
  }
}
