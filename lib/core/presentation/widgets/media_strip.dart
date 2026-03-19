import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MediaStripItem {
  const MediaStripItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.onTap,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final VoidCallback onTap;
}

class MediaStrip extends StatelessWidget {
  const MediaStrip({
    super.key,
    required this.items,
    this.height = 160,
    this.itemWidth = 200,
    this.headers,
  });

  final List<MediaStripItem> items;
  final double height;
  final double itemWidth;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
        child: Text('No media available.'),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.spacingSmall),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: SizedBox(
              width: itemWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Image.network(
                      item.thumbnailUrl,
                      headers: headers,
                      width: itemWidth,
                      height: itemWidth * (9 / 16),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: itemWidth,
                        height: itemWidth * (9 / 16),
                        color: context.colors.surfaceVariant,
                        child: Icon(
                          Icons.movie,
                          color: context.colors.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
