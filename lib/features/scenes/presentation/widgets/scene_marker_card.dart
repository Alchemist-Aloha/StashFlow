import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene_marker.dart';
import 'scene_card.dart';

class SceneMarkerCard extends StatelessWidget {
  const SceneMarkerCard({
    required this.marker,
    required this.isGrid,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  final SceneMarkerSummary marker;
  final bool isGrid;
  final int? memCacheWidth;
  final int? memCacheHeight;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: isGrid ? EdgeInsets.zero : GridUtils.defaultPadding(context),
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openMarker(context),
        child: isGrid
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarkerImage(
                    imageUrl: imageUrl,
                    range: _formatRange(),
                    memCacheWidth: memCacheWidth,
                    memCacheHeight: memCacheHeight,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimensions.spacingSmall,
                      vertical: context.dimensions.spacingSmall / 2,
                    ),
                    child: _MarkerDetails(marker: marker),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: context.dimensions.spacingLarge * 6.25,
                    child: _MarkerImage(
                      imageUrl: imageUrl,
                      range: _formatRange(),
                      memCacheWidth: memCacheWidth,
                      memCacheHeight: memCacheHeight,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(context.dimensions.spacingMedium),
                      child: _MarkerDetails(marker: marker),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MarkerImage extends StatelessWidget {
  const _MarkerImage({
    required this.imageUrl,
    required this.range,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String? imageUrl;
  final String range;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl?.isNotEmpty == true)
            StashImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: memCacheWidth,
              memCacheHeight: memCacheHeight,
            )
          else
            ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.bookmark_outline_rounded,
                color: context.colors.onSurfaceVariant,
                size: context.dimensions.spacingLarge,
              ),
            ),
          Positioned(
            right: context.dimensions.spacingSmall,
            bottom: context.dimensions.spacingSmall,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.dimensions.spacingSmall,
                vertical: context.dimensions.spacingSmall / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                range,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerDetails extends ConsumerWidget {
  const _MarkerDetails({required this.marker});

  final SceneMarkerSummary marker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          marker.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.dimensions.cardTitleFontSize,
          ),
        ),
        SizedBox(height: context.dimensions.spacingSmall / 4),
        Text(
          marker.sceneTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (ref.watch(showPerformerAvatarsProvider) &&
            marker.performerNames.isNotEmpty) ...[
          SizedBox(height: context.dimensions.spacingSmall / 2),
          ScenePerformerAvatarRow(
            performerImagePaths: marker.performerImagePaths,
            performerNames: marker.performerNames,
            performerIds: marker.performerIds,
          ),
        ],
      ],
    );
  }
}
