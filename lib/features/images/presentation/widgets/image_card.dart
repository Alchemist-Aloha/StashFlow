import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/image.dart' as entity;

class ImageCard extends ConsumerWidget {
  const ImageCard({required this.image, this.onTap, super.key});

  final entity.Image image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double aspectRatio =
        (image.files.isNotEmpty &&
            image.files.first.width > 0 &&
            image.files.first.height > 0)
        ? image.files.first.width.toDouble() /
              image.files.first.height.toDouble()
        : 1.0;

    return InkWell(
      onTap: onTap ?? () => context.push('/galleries/images/${image.id}'),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: AspectRatio(
          aspectRatio: aspectRatio.clamp(0.5, 2.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              StashImage(
                imageUrl: image.paths.thumbnail ?? image.paths.preview,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              if (image.rating100 != null && image.rating100! > 0)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          (image.rating100! / 20).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
