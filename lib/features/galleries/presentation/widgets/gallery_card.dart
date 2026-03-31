import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../../domain/entities/gallery.dart';

/// A card widget that displays a summary of a [Gallery].
///
/// Uses [GridCard] to maintain a consistent visual style across all grids.
class GalleryCard extends StatelessWidget {
  const GalleryCard({
    required this.gallery,
    this.onTap,
    this.thumbnailUrl,
    super.key,
  });

  /// The gallery data to display.
  final Gallery gallery;

  /// Callback triggered when the card is tapped.
  final VoidCallback? onTap;

  /// The URL for the thumbnail image.
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return GridCard(
      title: gallery.displayName,
      subtitle: '${gallery.imageCount ?? 0} images',
      imageUrl: thumbnailUrl,
      onTap: onTap,
      badge: (gallery.imageCount != null && gallery.imageCount! > 0)
          ? '${gallery.imageCount}'
          : null,
    );
  }
}
