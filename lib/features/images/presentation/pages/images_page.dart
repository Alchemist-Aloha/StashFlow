import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/image_list_provider.dart';
import '../widgets/image_card.dart';
import '../../domain/entities/image.dart' as entity;

enum _ImageSortOption { date, rating, title }

class ImagesPage extends ConsumerStatefulWidget {
  const ImagesPage({super.key});

  @override
  ConsumerState<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends ConsumerState<ImagesPage> {
  _ImageSortOption _sortOption = _ImageSortOption.date;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(imageSortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
          'date' => _ImageSortOption.date,
          'rating100' => _ImageSortOption.rating,
          'title' => _ImageSortOption.title,
          _ => _ImageSortOption.date,
        };
      });
    });
  }

  void _onSearchChanged(String query) {
    ref.read(imageSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_ImageSortOption option) {
    switch (option) {
      case _ImageSortOption.date:
        ref
            .read(imageListProvider.notifier)
            .setSort(sort: 'date', descending: true);
        break;
      case _ImageSortOption.rating:
        ref
            .read(imageListProvider.notifier)
            .setSort(sort: 'rating100', descending: true);
        break;
      case _ImageSortOption.title:
        ref
            .read(imageListProvider.notifier)
            .setSort(sort: 'title', descending: false);
        break;
    }
  }

  Widget _buildSortBar() {
    final filter = ref.watch(imageFilterStateProvider);
    const options = [
      (_ImageSortOption.date, 'Date'),
      (_ImageSortOption.rating, 'Rating'),
      (_ImageSortOption.title, 'Title'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
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
        ),
        if (filter.galleryId != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: Row(
              children: [
                InputChip(
                  label: const Text('Filtered by Gallery'),
                  onDeleted: () {
                    ref.read(imageFilterStateProvider.notifier).clear();
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imageListProvider);
    final viewType = ref.watch(mediaViewToggleProvider);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    int crossAxisCount = 2;
    if (isTablet) {
      crossAxisCount = 3;
    } else if (!isMobile) {
      crossAxisCount = 5;
    }

    return ListPageScaffold<entity.Image>(
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
      searchHint: 'Search images...',
      onSearchChanged: _onSearchChanged,
      provider: imagesAsync,
      onRefresh: () => ref.refresh(imageListProvider.future),
      onFetchNextPage: () =>
          ref.read(imageListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      customBody: imagesAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No images found'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(imageListProvider.future),
            child: CustomScrollView(
              controller: ref.watch(imageScrollControllerProvider),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingSmall),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppTheme.spacingSmall,
                    crossAxisSpacing: AppTheme.spacingSmall,
                    itemBuilder: (context, index) {
                      // Trigger next page load when reaching near end
                      if (index >= items.length - 5) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(imageListProvider.notifier).fetchNextPage();
                        });
                      }
                      return ImageCard(image: items[index]);
                    },
                    childCount: items.length,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
