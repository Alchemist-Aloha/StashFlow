import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../providers/gallery_details_provider.dart';
import '../providers/gallery_list_provider.dart';

class GalleryDetailsPage extends ConsumerWidget {
  final String galleryId;

  const GalleryDetailsPage({required this.galleryId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryDetailsProvider(galleryId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.details_gallery)),
      body: galleryAsync.when(
        data: (gallery) => RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(galleryRepositoryProvider)
                .getGalleryById(galleryId, refresh: true);
            ref.invalidate(galleryDetailsProvider(galleryId));
            return ref.read(galleryDetailsProvider(galleryId).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      color: context.colors.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gallery.displayName,
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
                          if (gallery.date != null)
                            _buildChip(context, gallery.date!),
                          if (gallery.imageCount != null)
                            _buildChip(
                              context,
                              '${gallery.imageCount} ${context.l10n.common_image}',
                            ),
                          if (gallery.rating100 != null)
                            _buildChip(
                              context,
                              context.l10n.images_rating(
                                (gallery.rating100! / 20).toStringAsFixed(1),
                              ),
                              icon: Icons.star,
                              iconColor: context.colors.ratingColor,
                            ),
                        ],
                      ),
                      if (gallery.details != null &&
                          gallery.details!.isNotEmpty) ...[
                        Divider(
                          height: 32,
                          color: context.colors.outline.withValues(alpha: 0.2),
                        ),
                        SectionHeader(
                          title: context.l10n.common_details,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          gallery.details!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: context.l10n.common_error(err.toString()),
          onRetry: () => ref.refresh(galleryDetailsProvider(galleryId)),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Chip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: iconColor ?? context.colors.onSurfaceVariant,
            )
          : null,
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
