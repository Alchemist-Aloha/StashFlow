import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'stash_image.dart';

/// A standardized card for displaying media items (Scenes, Performers, etc.).
///
/// Provides a consistent layout with an image, title, and optional metadata.
class MediaCard extends StatelessWidget {
  const MediaCard({
    required this.title,
    required this.imageUrl,
    this.onTap,
    this.subtitle,
    this.aspectRatio = 16 / 9,
    this.imageHeaders,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? subtitle;
  final double aspectRatio;
  final Map<String, String>? imageHeaders;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: StashImage(imageUrl: imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(context.dimensions.spacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: context.dimensions.spacingSmall / 2),
                    DefaultTextStyle(
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A standardized header for media detail pages.
///
/// Displays the primary title and optional secondary information (like studio).
class MediaHeader extends StatelessWidget {
  const MediaHeader({
    required this.title,
    this.secondaryTitle,
    this.onSecondaryTitleTap,
    super.key,
  });

  final String title;
  final String? secondaryTitle;
  final VoidCallback? onSecondaryTitleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        if (secondaryTitle != null) ...[
          SizedBox(height: context.dimensions.spacingSmall / 2),
          GestureDetector(
            onTap: onSecondaryTitleTap,
            child: Text(
              secondaryTitle!,
              style: context.textTheme.titleMedium?.copyWith(
                color: onSecondaryTitleTap != null
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                decoration: onSecondaryTitleTap != null
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
