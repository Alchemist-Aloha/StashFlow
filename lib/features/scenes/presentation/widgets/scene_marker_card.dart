import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene_marker.dart';

class SceneMarkerCard extends StatelessWidget {
  const SceneMarkerCard({
    required this.marker,
    required this.isGrid,
    super.key,
  });

  final SceneMarkerSummary marker;
  final bool isGrid;

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatRange() {
    final start = _formatDuration(marker.seconds);
    final end = marker.endSeconds;
    if (end == null) return start;
    return '$start - ${_formatDuration(end)}';
  }

  void _openMarker(BuildContext context) {
    context.push(
      '/scenes/scene/${marker.sceneId}?t=${marker.seconds}',
      extra: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = marker.screenshot?.isNotEmpty == true
        ? marker.screenshot
        : marker.preview;

    return Card(
      margin: isGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openMarker(context),
        child: isGrid
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarkerImage(imageUrl: imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    child: _MarkerDetails(
                      marker: marker,
                      range: _formatRange(),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 150, child: _MarkerImage(imageUrl: imageUrl)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: _MarkerDetails(
                        marker: marker,
                        range: _formatRange(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MarkerImage extends StatelessWidget {
  const _MarkerImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: imageUrl?.isNotEmpty == true
          ? StashImage(imageUrl: imageUrl, fit: BoxFit.cover)
          : ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.bookmark_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

class _MarkerDetails extends StatelessWidget {
  const _MarkerDetails({required this.marker, required this.range});

  final SceneMarkerSummary marker;
  final String range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTag = marker.primaryTagName?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          marker.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          range,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          marker.sceneTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        if (primaryTag != null && primaryTag.isNotEmpty) ...[
          const SizedBox(height: 6),
          Chip(
            label: Text(primaryTag),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ],
    );
  }
}
