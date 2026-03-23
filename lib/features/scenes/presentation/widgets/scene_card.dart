import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';

/// A card widget that displays a summary of a [Scene].
///
/// This component is used throughout the app in lists and grids to show 
/// a thumbnail, title, studio, and duration. It supports:
/// * Two layout modes: [isGrid] = true (compact) and false (full-width list).
/// * Authenticated image loading using headers from [mediaHeadersProvider].
/// * Formatting of the scene duration (e.g., 'HH:mm:ss' or 'mm:ss').
/// * A contextual menu (long-press or more-vert icon).
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

  /// Displays the contextual action menu for the scene.
  void _showMenu(BuildContext context, WidgetRef ref) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        // No items for now, or add other items if needed
      ],
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
    final mediaHeaders = ref.watch(mediaHeadersProvider);
    final duration = scene.files.isNotEmpty ? scene.files.first.duration : null;

    if (isGrid) {
      return _buildGridCard(context, ref, mediaHeaders, duration);
    }
    return _buildListCard(context, ref, mediaHeaders, duration);
  }

  /// Builds the full-width list variant of the card.
  Widget _buildListCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> mediaHeaders,
    double? duration,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showMenu(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                children: [
                  Image.network(
                    scene.paths.screenshot ??
                        'https://via.placeholder.com/320x180',
                    headers: mediaHeaders,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 640,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white, size: 48),
                      ),
                    ),
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
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
  Widget _buildGridCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> mediaHeaders,
    double? duration,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showMenu(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                children: [
                  Image.network(
                    scene.paths.screenshot ??
                        'https://via.placeholder.com/320x180',
                    headers: mediaHeaders,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 320,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white, size: 32),
                      ),
                    ),
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
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
