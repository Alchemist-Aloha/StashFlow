import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/gallery_details_provider.dart';

class GalleryDetailsPage extends ConsumerWidget {
  final String galleryId;

  const GalleryDetailsPage({required this.galleryId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryDetailsProvider(galleryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Details'),
      ),
      body: galleryAsync.when(
        data: (gallery) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                color: context.colors.surfaceVariant,
                child: Center(
                  child: Icon(
                    Icons.photo_library,
                    size: 72,
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gallery.title.isEmpty ? 'Untitled gallery' : gallery.title,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
                        if (gallery.date != null) _buildChip(context, gallery.date!),
                        if (gallery.imageCount != null) _buildChip(context, '${gallery.imageCount} images'),
                        if (gallery.rating100 != null)
                          _buildChip(
                            context,
                            'Rating: ${(gallery.rating100! / 20).toStringAsFixed(1)}',
                            icon: Icons.star,
                            iconColor: context.colors.ratingColor,
                          ),
                      ],
                    ),
                    if (gallery.details != null && gallery.details!.isNotEmpty) ...[
                      const Divider(height: 32, color: Colors.grey),
                      const SectionHeader(title: 'Details', padding: EdgeInsets.zero),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        gallery.details!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: 'Failed to load gallery details.\n$err',
          onRetry: () => ref.refresh(galleryDetailsProvider(galleryId)),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {IconData? icon, Color? iconColor}) {
    return Chip(
      avatar: icon != null ? Icon(icon, size: 16, color: iconColor ?? context.colors.onSurfaceVariant) : null,
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
