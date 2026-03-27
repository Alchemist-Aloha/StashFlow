import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../pages/scene_info_page.dart';

/// A card widget that displays a summary of a [Scene].
///
/// This component is used throughout the app in lists and grids to show
/// a thumbnail, title, studio, and duration. It supports:
/// * Three layout modes: Grid (compact), List (full-width), and TikTok (via TiktokScenesView).
/// * Authenticated image loading using headers from [mediaHeadersProvider].
/// * Dynamic aspect ratio in List mode to prevent image distortion.
/// * Consistent "BoxFit.cover" and "double.infinity" dimensions to ensure images
///   perfectly fill their allocated AspectRatio containers.
class SceneCard extends ConsumerWidget {
  const SceneCard({
    required this.scene,
    this.isGrid = false,
    this.onTap,
    super.key,
  });

  /// The scene data to display.
  final Scene scene;

  /// Whether to display in a compact grid format or a wide list format.
  final bool isGrid;

  /// Callback triggered when the card is tapped.
  final VoidCallback? onTap;

  /// Displays a custom scene info sheet for navigation actions.
  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SceneInfoSheet(scene: scene),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = scene.files.isNotEmpty ? scene.files.first.duration : null;

    // Use primary file's aspect ratio if available, default to 16/9.
    // This ensures the image container in List view adapts to the media,
    // preventing black bars or forced cropping of portrait/square content.
    final double? fileAspectRatio =
        (scene.files.isNotEmpty &&
            scene.files.first.width != null &&
            scene.files.first.height != null)
        ? scene.files.first.width!.toDouble() /
              scene.files.first.height!.toDouble()
        : null;

    if (isGrid) {
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
      onTap: onTap,
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
              child: Stack(
                children: [
                  StashImage(
                    imageUrl: scene.paths.screenshot,
                    // Use double.infinity for both dimensions with BoxFit.cover
                    // to ensure the image fills the AspectRatio container completely.
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 640,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      color: Colors.black.withAlpha(200),
                      child: Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                        scene.displayTitle,
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
                        '${scene.studioName ?? "Unknown Studio"} • ${scene.date.year}',
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
      onTap: onTap,
      onLongPress: () => _showMenu(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9, // Keep grid items consistent
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                children: [
                  StashImage(
                    imageUrl: scene.paths.screenshot,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 320,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      color: Colors.black.withAlpha(200),
                      child: Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
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
                        scene.displayTitle,
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
                        scene.studioName ?? 'Unknown Studio',
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
