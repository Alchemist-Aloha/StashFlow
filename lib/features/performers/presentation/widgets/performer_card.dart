import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/performer.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class PerformerCard extends ConsumerWidget {
  final Performer performer;
  final VoidCallback? onTap;
  final int? memCacheWidth;

  const PerformerCard({
    required this.performer,
    this.onTap,
    this.memCacheWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: EdgeInsets.all(context.dimensions.spacingSmall / 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
                  return Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: ClipOval(
                        child: StashImage(
                          imageUrl: performer.imagePath ?? '',
                          fit: BoxFit.cover,
                          memCacheWidth: memCacheWidth ?? 300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: context.dimensions.spacingSmall),
            Text(
              performer.name,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.dimensions.cardTitleFontSize *
                    context.dimensions.fontSizeFactor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
