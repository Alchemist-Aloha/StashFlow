import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/gallery_list_provider.dart';
import '../../images/presentation/providers/image_list_provider.dart';
import '../../domain/entities/gallery.dart';

enum _GallerySortOption { title }

class GalleriesPage extends ConsumerStatefulWidget {
  const GalleriesPage({super.key});

  @override
  ConsumerState<GalleriesPage> createState() => _GalleriesPageState();
}

class _GalleriesPageState extends ConsumerState<GalleriesPage> {
  _GallerySortOption _sortOption = _GallerySortOption.title;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(gallerySortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
          'title' => _GallerySortOption.title,
          _ => _GallerySortOption.title,
        };
      });
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(gallerySearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_GallerySortOption option) {
    switch (option) {
      case _GallerySortOption.title:
        ref
            .read(galleryListProvider.notifier)
            .setSort(sort: 'title', descending: false);
        break;
    }
  }

  Widget _buildSortBar() {
    const options = [(_GallerySortOption.title, 'Title')];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option.$2),
              selected: _sortOption == option.$1,
              onSelected: (selected) {
                if (!selected) return;
                setState(() => _sortOption = option.$1);
                _applyServerSort(option.$1);
              },
            ),
            const SizedBox(width: AppTheme.spacingSmall),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleriesAsync = ref.watch(galleryListProvider);
    final viewType = ref.watch(mediaViewToggleProvider);

    return ListPageScaffold<Gallery>(
      title: 'Media',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ToggleButtons(
            isSelected: [
              viewType == MediaViewType.images,
              viewType == MediaViewType.galleries,
            ],
            onPressed: (index) {
              final newType = index == 0
                  ? MediaViewType.images
                  : MediaViewType.galleries;
              ref.read(mediaViewToggleProvider.notifier).setView(newType);
              if (newType == MediaViewType.images) {
                context.go('/media/images');
              } else {
                context.go('/media/galleries');
              }
            },
            borderRadius: BorderRadius.circular(20),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
            children: const [
              Icon(Icons.image, size: 18),
              Icon(Icons.folder, size: 18),
            ],
          ),
        ),
      ],
      searchHint: 'Search galleries...',
      onSearchChanged: _onSearchChanged,
      provider: galleriesAsync,
      onRefresh: () => ref.refresh(galleryListProvider.future),
      onFetchNextPage: () =>
          ref.read(galleryListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.spacingMedium,
        crossAxisSpacing: AppTheme.spacingMedium,
        childAspectRatio: 1.0,
      ),
      mobileCrossAxisCount: 2,
      tabletCrossAxisCount: 4,
      itemBuilder: (context, gallery) => InkWell(
        onTap: () {
          ref.read(imageFilterStateProvider.notifier).setGalleryId(gallery.id);
          ref
              .read(mediaViewToggleProvider.notifier)
              .setView(MediaViewType.images);
          context.go('/media/images');
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: context.colors.surfaceContainerHighest,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.folder,
                        size: 64,
                        color: context.colors.primary.withValues(alpha: 0.7),
                      ),
                      if (gallery.imageCount != null && gallery.imageCount! > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${gallery.imageCount}',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                child: Text(
                  gallery.title.isEmpty ? 'Untitled gallery' : gallery.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
