import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/rating_control.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../images/presentation/pages/images_page.dart';
import '../../../images/presentation/providers/image_list_provider.dart';
import '../../domain/entities/gallery.dart';
import '../providers/gallery_details_provider.dart';
import '../providers/gallery_list_provider.dart';
import '../widgets/gallery_details_bottom_sheet.dart';

/// Browses a gallery's images with compact, scroll-collapsing gallery details.
class GalleryDetailsPage extends ConsumerStatefulWidget {
  const GalleryDetailsPage({required this.galleryId, super.key});

  final String galleryId;

  @override
  ConsumerState<GalleryDetailsPage> createState() => _GalleryDetailsPageState();
}

class _GalleryDetailsPageState extends ConsumerState<GalleryDetailsPage> {
  late final ScrollController _scrollController;
  var _detailsCollapsed = false;
  var _collapseOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _scheduleGalleryImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collapseOffset = context.dimensions.spacingLarge * 2;
  }

  @override
  void didUpdateWidget(covariant GalleryDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.galleryId == widget.galleryId) return;
    _scheduleGalleryImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _scheduleGalleryImages() {
    final galleryId = widget.galleryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || galleryId != widget.galleryId) return;
      ref.read(imageFilterStateProvider.notifier).setGalleryId(galleryId);
    });
  }

  void _handleScroll() {
    final shouldCollapse = _scrollController.offset > _collapseOffset;
    if (shouldCollapse == _detailsCollapsed || !mounted) return;
    setState(() => _detailsCollapsed = shouldCollapse);
  }

  Future<void> _refresh() async {
    await ref
        .read(galleryRepositoryProvider)
        .getGalleryById(widget.galleryId, refresh: true);
    ref.invalidate(galleryDetailsProvider(widget.galleryId));
    await Future.wait([
      ref.read(galleryDetailsProvider(widget.galleryId).future),
      ref.read(imageListProvider.notifier).refresh(),
    ]);
  }

  Future<void> _updateRating(Gallery gallery, int rating) async {
    try {
      final repository = ref.read(galleryRepositoryProvider);
      await repository.updateGalleryRating(gallery.id, rating);
      final updatedGallery = await repository.getGalleryById(
        gallery.id,
        refresh: true,
      );
      if (!mounted) return;
      ref
          .read(galleryListProvider.notifier)
          .updateGalleryInList(updatedGallery);
      ref.invalidate(galleryDetailsProvider(gallery.id));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.details_failed_update_rating('$error')),
        ),
      );
    }
  }

  void _expandDetails() {
    if (!_detailsCollapsed) return;
    setState(() => _detailsCollapsed = false);
  }

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(galleryDetailsProvider(widget.galleryId));

    return ImagesPage(
      title: context.l10n.details_gallery,
      showAppBarTitle: false,
      topContent: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: galleryAsync.when(
          data: (gallery) => _detailsCollapsed
              ? _CollapsedGalleryDetails(
                  key: const Key('gallery_details_collapsed'),
                  gallery: gallery,
                  onExpand: _expandDetails,
                  onRatingSelected: (rating) => _updateRating(gallery, rating),
                )
              : _CompactGalleryDetails(
                  key: const Key('gallery_details_expanded'),
                  gallery: gallery,
                  onRatingSelected: (rating) => _updateRating(gallery, rating),
                ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stack) => ErrorStateView(
            message: context.l10n.common_error(error.toString()),
            onRetry: () =>
                ref.invalidate(galleryDetailsProvider(widget.galleryId)),
          ),
        ),
      ),
      scrollController: _scrollController,
      onRefresh: _refresh,
    );
  }
}

class _CollapsedGalleryDetails extends StatelessWidget {
  const _CollapsedGalleryDetails({
    required this.gallery,
    required this.onExpand,
    required this.onRatingSelected,
    super.key,
  });

  final Gallery gallery;
  final VoidCallback onExpand;
  final ValueChanged<int> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final colors = Theme.of(context).colorScheme;
    final subtitle = [
      if (gallery.studioName?.trim().isNotEmpty == true) gallery.studioName!,
      if (gallery.date?.trim().isNotEmpty == true) gallery.date!,
    ].join(' • ');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dims.spacingSmall,
        dims.spacingSmall,
        dims.spacingSmall,
        dims.spacingMedium,
      ),
      child: Material(
        color: colors.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(dims.spacingSmall),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gallery.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: dims.spacingSmall * 0.25),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: dims.spacingSmall * 0.25),
                    Text(
                      '${gallery.imageCount ?? 0} ${context.l10n.images_title}',
                      key: const Key('gallery_image_count'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: dims.spacingSmall),
              RatingButton(
                key: const Key('gallery_action_rating'),
                rating100: gallery.rating100,
                onRatingSelected: onRatingSelected,
              ),
              IconButton.filledTonal(
                tooltip: context.l10n.details_show_more,
                onPressed: onExpand,
                icon: const Icon(Icons.expand_more_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactGalleryDetails extends StatelessWidget {
  const _CompactGalleryDetails({
    required this.gallery,
    required this.onRatingSelected,
    super.key,
  });

  final Gallery gallery;
  final ValueChanged<int> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          dims.spacingSmall,
          dims.spacingSmall,
          dims.spacingSmall,
          dims.spacingMedium,
        ),
        child: Material(
          color: colors.surfaceContainerLow,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              dims.spacingMedium,
              dims.spacingMedium,
              dims.spacingMedium,
              dims.spacingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gallery.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (gallery.studioName?.trim().isNotEmpty == true) ...[
                      SizedBox(height: dims.spacingSmall * 0.5),
                      TextButton(
                        key: const Key('gallery_studio_link'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: gallery.studioId == null
                            ? null
                            : () => context.push(
                                '/studios/studio/${gallery.studioId}',
                              ),
                        child: Text(
                          gallery.studioName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: gallery.studioId == null
                                ? colors.onSurfaceVariant
                                : colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: dims.spacingSmall),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: dims.spacingSmall,
                  runSpacing: dims.spacingSmall * 0.5,
                  children: [
                    if (gallery.date?.trim().isNotEmpty == true)
                      _metadataBadge(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: gallery.date!,
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RatingButton(
                          key: const Key('gallery_action_rating'),
                          rating100: gallery.rating100,
                          onRatingSelected: onRatingSelected,
                        ),
                        SizedBox(width: dims.spacingSmall),
                        IconButton(
                          key: const Key('gallery_action_info'),
                          tooltip: context.l10n.common_details,
                          onPressed: () =>
                              GalleryDetailsBottomSheet.show(context, gallery),
                          icon: const Icon(Icons.info_outline_rounded),
                        ),
                      ],
                    ),
                    SizedBox(
                      key: const Key('gallery_image_count'),
                      child: _metadataBadge(
                        context,
                        icon: Icons.image_rounded,
                        label: '${gallery.imageCount ?? 0}',
                      ),
                    ),
                  ],
                ),
                if (gallery.details?.trim().isNotEmpty == true) ...[
                  SizedBox(height: dims.spacingMedium),
                  Text(
                    gallery.details!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                if (gallery.performerNames.isNotEmpty) ...[
                  SizedBox(height: dims.spacingMedium),
                  Divider(height: 1, color: colors.outlineVariant),
                ],
                if (gallery.performerNames.isNotEmpty) ...[
                  SizedBox(height: dims.spacingMedium),
                  SectionHeader(
                    title: context.l10n.performers_title,
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: dims.spacingSmall),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (
                          var index = 0;
                          index < gallery.performerNames.length;
                          index++
                        ) ...[
                          if (index > 0) SizedBox(width: dims.spacingSmall),
                          ActionChip(
                            avatar: _performerAvatar(context, index),
                            label: Text(gallery.performerNames[index]),
                            onPressed: index < gallery.performerIds.length
                                ? () => context.push(
                                    '/performers/performer/${gallery.performerIds[index]}',
                                  )
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metadataBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label, style: context.textTheme.bodySmall),
    );
  }

  Widget _performerAvatar(BuildContext context, int index) {
    final dims = context.dimensions;
    final imagePath = index < gallery.performerImagePaths.length
        ? gallery.performerImagePaths[index]
        : null;
    final hasImage =
        imagePath?.trim().isNotEmpty == true &&
        !imagePath!.contains('default=true');
    if (!hasImage) return const Icon(Icons.person_rounded);

    return ClipOval(
      child: SizedBox.square(
        dimension: dims.performerAvatarSize * 1.5,
        child: StashImage(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          memCacheWidth: 96,
        ),
      ),
    );
  }
}
