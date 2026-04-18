import 'package:flutter/material.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../pages/scene_info_page.dart';
import 'scrubbing_preview.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';

/// A card widget that displays a summary of a [Scene].
///
/// This component is used throughout the app in lists and grids to show
/// a thumbnail, title, studio, and duration. It supports:
/// * Three layout modes: Grid (compact), List (full-width), and TikTok (via TiktokScenesView).
/// * Authenticated image loading using headers from [mediaHeadersProvider].
/// * Dynamic aspect ratio in List mode to prevent image distortion.
/// * Consistent "BoxFit.cover" and "double.infinity" dimensions to ensure images
///   perfectly fill their allocated AspectRatio containers.
class SceneCard extends ConsumerStatefulWidget {
  const SceneCard({
    required this.scene,
    this.isGrid = false,
    this.onTap,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  /// The scene data to display.
  final Scene scene;

  /// Whether to display in a compact grid format or a wide list format.
  final bool isGrid;

  /// Callback triggered when the card is tapped.
  final VoidCallback? onTap;

  /// Optional memory cache width for image optimization.
  final int? memCacheWidth;

  /// Optional memory cache height for image optimization.
  final int? memCacheHeight;

  @override
  ConsumerState<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends ConsumerState<SceneCard> {
  bool _isScrubbing = false;
  double _scrubTime = 0;

  /// Displays a custom scene info sheet for navigation actions.
  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SceneInfoPage(scene: widget.scene),
    );
  }

  /// Formats seconds into a human-readable duration string.
  String _formatDuration(double? duration) {
    if (duration == null) return '--:--';
    final seconds = duration.round();
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildThumbnail(
    BuildContext context,
    double? duration,
    double aspectRatio,
  ) {
    final headers = ref.watch(mediaHeadersProvider);
    final totalDuration = widget.scene.files.isNotEmpty
        ? (widget.scene.files.first.duration ?? 0.0)
        : 0.0;

    final rawVttUrl = widget.scene.paths.vtt ?? '';
    final apiKey = ref.read(serverApiKeyProvider);
    final vttUrl = appendApiKey(rawVttUrl, apiKey);

    return Hero(
      tag: 'scene_player_${widget.scene.id}',
      child: GestureDetector(
        onHorizontalDragStart: (_) {
          if (vttUrl.isNotEmpty) {
            setState(() {
              _isScrubbing = true;
            });
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_isScrubbing) {
            final box = context.findRenderObject() as RenderBox;
            final localPos = box.globalToLocal(details.globalPosition);
            final relativePos = (localPos.dx / box.size.width).clamp(0.0, 1.0);
            setState(() {
              _scrubTime = relativePos * totalDuration;
            });
          }
        },
        onHorizontalDragEnd: (_) {
          setState(() {
            _isScrubbing = false;
          });
        },
        onHorizontalDragCancel: () {
          setState(() {
            _isScrubbing = false;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              StashImage(
                imageUrl: widget.scene.paths.screenshot,
                memCacheWidth: widget.memCacheWidth,
                memCacheHeight: widget.memCacheHeight,
                // Use double.infinity for both dimensions with BoxFit.cover
                // to ensure the image fills the AspectRatio container completely.
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              if (_isScrubbing && vttUrl.isNotEmpty)
                Positioned.fill(
                  child: ScrubbingPreview(
                    vttUrl: vttUrl,
                    timeInSeconds: _scrubTime,
                    headers: headers,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              Positioned(
                bottom: widget.isGrid ? 4 : 8,
                right: widget.isGrid ? 4 : 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  color: Colors.black.withAlpha(200),
                  child: Text(
                    _isScrubbing
                        ? _formatDuration(_scrubTime)
                        : _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isGrid ? 10 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.scene.files.isNotEmpty
        ? widget.scene.files.first.duration
        : null;

    // Use primary file's aspect ratio if available, default to 16/9.
    // This ensures the image container in List view adapts to the media,
    // preventing black bars or forced cropping of portrait/square content.
    final double? fileAspectRatio =
        (widget.scene.files.isNotEmpty &&
            widget.scene.files.first.width != null &&
            widget.scene.files.first.height != null)
        ? widget.scene.files.first.width!.toDouble() /
              widget.scene.files.first.height!.toDouble()
        : null;

    if (widget.isGrid) {
      return _buildGridCard(context, ref, duration, fileAspectRatio ?? 16 / 9);
    }
    return _buildListCard(context, ref, duration, fileAspectRatio ?? 16 / 9);
  }

  /// Builds the full-width list variant of the card.
  ///
  /// Uses a dynamic [aspectRatio] to match the source media's proportions.
  Widget _buildListCard(
    BuildContext context,
    WidgetRef ref,
    double? duration,
    double aspectRatio,
  ) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: () => _showMenu(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            // Clamp aspect ratio to prevent extremely tall or wide items from
            // breaking the list layout flow.
            aspectRatio: aspectRatio.clamp(0.5, 2.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: _buildThumbnail(context, duration, aspectRatio),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scene.displayTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.colors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.scene.studioName ?? context.l10n.common_unknown} • ${widget.scene.date.year}',
                        style: TextStyle(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.75,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMenu(context, ref),
                  icon: const Icon(Icons.more_vert, size: 20, color: null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the compact grid variant of the card.
  ///
  /// Forces a 16:9 [aspectRatio] for the image to maintain a uniform grid appearance,
  /// relying on BoxFit.cover to fill the frame elegantly.
  Widget _buildGridCard(
    BuildContext context,
    WidgetRef ref,
    double? duration,
    double aspectRatio,
  ) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: () => _showMenu(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9, // Keep grid items consistent
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: _buildThumbnail(context, duration, 16 / 9),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scene.displayTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: context.colors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.scene.studioName ?? context.l10n.common_unknown,
                        style: TextStyle(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.75,
                          ),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMenu(context, ref),
                  icon: const Icon(Icons.more_vert, size: 16, color: null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
