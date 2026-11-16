import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene_marker.dart';
import 'scene_card.dart';
import '../../../../core/utils/format_duration.dart';

class SceneMarkerCard extends StatelessWidget {
  const SceneMarkerCard({
    required this.marker,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  final SceneMarkerSummary marker;
  final int? memCacheWidth;
  final int? memCacheHeight;

  String _formatRange() {
    final start = formatClockDuration(marker.seconds);
    final end = marker.endSeconds;
    if (end == null) return start;
    return '$start - ${formatClockDuration(end)}';
  }

  void _openMarker(BuildContext context) {
    unawaited(
      context.push(
        '/scenes/scene/${marker.sceneId}?t=${marker.seconds}',
        extra: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = marker.screenshot?.isNotEmpty == true
        ? marker.screenshot
        : marker.preview;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openMarker(context),
        child: Column(
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
                Icons.place_rounded,
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
