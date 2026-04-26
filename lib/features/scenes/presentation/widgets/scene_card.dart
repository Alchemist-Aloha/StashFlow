import 'package:flutter/foundation.dart';
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
import '../../../../core/presentation/providers/layout_settings_provider.dart';

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
    this.useMasonry = false,
    this.onTap,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  /// The scene data to display.
  final Scene scene;

  /// Whether to display in a compact grid format or a wide list format.
  final bool isGrid;

  /// Whether to use dynamic aspect ratio in grid mode (for masonry layouts).
  final bool useMasonry;

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
    String apiKey,
  ) {
    final isDesktop = kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS);
    final headers = ref.watch(mediaHeadersProvider);
    final totalDuration = widget.scene.files.isNotEmpty
        ? (widget.scene.files.first.duration ?? 0.0)
        : 0.0;

    final rawVttUrl = widget.scene.paths.vtt ?? '';
    final hasVtt = rawVttUrl.isNotEmpty;
    final vttUrl = appendApiKey(rawVttUrl, apiKey);

    Widget content = Stack(
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
        if (_isScrubbing && hasVtt)
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
          bottom: 0,
          left: 0,
          right: 0,
          child: _ThumbnailMetadataOverlay(
            count: widget.scene.oCounter,
            icon: Icons.water_drop_outlined,
            rating: widget.scene.rating100,
            duration: _isScrubbing
                ? _formatDuration(_scrubTime)
                : _formatDuration(duration),
            isGrid: widget.isGrid,
          ),
        ),
      ],
    );

    if (isDesktop && hasVtt) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isScrubbing = true),
        onExit: (_) => setState(() => _isScrubbing = false),
        onHover: (details) {
          final box = context.findRenderObject() as RenderBox;
          final localPos = details.localPosition;
          final relativePos = (localPos.dx / box.size.width).clamp(0.0, 1.0);
          setState(() {
            _scrubTime = relativePos * totalDuration;
          });
        },
        child: content,
      );
    }

    return Hero(
      tag: 'scene_player_${widget.scene.id}',
      child: GestureDetector(
        onPanStart: hasVtt
            ? (_) {
                setState(() {
                  _isScrubbing = true;
                });
              }
            : null,
        onPanUpdate: hasVtt
            ? (details) {
                if (_isScrubbing) {
                  final box = context.findRenderObject() as RenderBox;
                  final relativePos =
                      (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
                  setState(() {
                    _scrubTime = relativePos * totalDuration;
                  });
                }
              }
            : null,
        onPanEnd: hasVtt
            ? (_) {
                if (!isDesktop) {
                  setState(() {
                    _isScrubbing = false;
                  });
                }
              }
            : null,
        onPanCancel: hasVtt
            ? () {
                if (!isDesktop) {
                  setState(() {
                    _isScrubbing = false;
                  });
                }
              }
            : null,
        child: Material(
          color: Colors.transparent,
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(serverApiKeyProvider);
    final duration = widget.scene.files.isNotEmpty
        ? widget.scene.files.first.duration
        : null;

    // Use primary file's aspect ratio if available, default to 16/9.
    // This ensures the image container in List view adapts to the media,
    // preventing black bars or forced cropping of portrait/square content.
    double? fileAspectRatio = (widget.scene.files.isNotEmpty &&
            widget.scene.files.first.width != null &&
            widget.scene.files.first.height != null)
        ? widget.scene.files.first.width!.toDouble() /
            widget.scene.files.first.height!.toDouble()
        : null;

    // Force square videos to 9/16 portrait on mobile to avoid the "fat" look.
    if (fileAspectRatio != null &&
        (fileAspectRatio - 1.0).abs() < 0.01 &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      fileAspectRatio = 9 / 16;
    }

    if (widget.isGrid) {
      return _buildGridCard(
          context, ref, duration, fileAspectRatio ?? 16 / 9, apiKey);
    }
    return _buildListCard(
        context, ref, duration, fileAspectRatio ?? 16 / 9, apiKey);
  }

  /// Builds the full-width list variant of the card.
  ///
  /// Uses a dynamic [aspectRatio] to match the source media's proportions.
  Widget _buildListCard(
    BuildContext context,
    WidgetRef ref,
    double? duration,
    double aspectRatio,
    String apiKey,
  ) {
    final isDesktop = kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS);

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
              child: _buildThumbnail(context, duration, aspectRatio, apiKey),
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
                      if (isDesktop && widget.scene.performerNames.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _PerformerAvatarRow(
                          performerImagePaths: widget.scene.performerImagePaths,
                          performerNames: widget.scene.performerNames,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'More',
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
    String apiKey,
  ) {
    final isDesktop = kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS);

    return InkWell(
      onTap: widget.onTap,
      onLongPress: () => _showMenu(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: widget.useMasonry ? aspectRatio.clamp(0.5, 2.5) : 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: _buildThumbnail(
                context,
                duration,
                widget.useMasonry ? aspectRatio.clamp(0.5, 2.5) : 16 / 9,
                apiKey,
              ),
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
                      if (isDesktop && widget.scene.performerNames.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _PerformerAvatarRow(
                          performerImagePaths: widget.scene.performerImagePaths,
                          performerNames: widget.scene.performerNames,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'More',
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

class _ThumbnailMetadataOverlay extends StatelessWidget {
  const _ThumbnailMetadataOverlay({
    required this.count,
    required this.icon,
    required this.rating,
    required this.duration,
    required this.isGrid,
  });

  final int count;
  final IconData icon;
  final int? rating;
  final String duration;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(icon, count.toString()),
          if (rating != null)
            _buildItem(Icons.star, (rating! / 20.0).toStringAsFixed(1)),
          Text(
            duration,
            style: TextStyle(
              color: Colors.white,
              fontSize: isGrid ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: isGrid ? 10 : 12),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isGrid ? 10 : 12,
          ),
        ),
      ],
    );
  }
}

class _PerformerAvatarRow extends ConsumerWidget {
  const _PerformerAvatarRow({
    required this.performerImagePaths,
    required this.performerNames,
  });

  final List<String?> performerImagePaths;
  final List<String> performerNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limit = ref.watch(maxPerformerAvatarsProvider);
    final count = performerImagePaths.length;
    final displayCount = count > limit ? limit : count;
    final overflow = count > limit ? count - limit : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < displayCount; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Tooltip(
              message: performerNames[i],
              child: CircleAvatar(
                radius: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ClipOval(
                  child: StashImage(
                    imageUrl: performerImagePaths[i],
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        if (overflow > 0)
          Text(
            '+$overflow',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface.withValues(alpha: 0.75),
            ),
          ),
      ],
    );
  }
}
