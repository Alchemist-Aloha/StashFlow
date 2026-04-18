import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../providers/image_list_provider.dart';
import '../widgets/image_card.dart';
import '../../domain/entities/image.dart' as entity;

import '../widgets/image_filter_panel.dart';
import '../../domain/entities/image_filter.dart';
import '../../../../core/domain/entities/filter_options.dart';

enum _ImageSortOption {
  title,
  path,
  rating,
  date,
  random,
  createdAt,
  updatedAt,
  fileCount,
  fileModTime,
  filesize,
  id,
  oCounter,
  performerCount,
  resolution,
  tagCount,
}

class ImagesPage extends ConsumerStatefulWidget {
  const ImagesPage({super.key});

  @override
  ConsumerState<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends ConsumerState<ImagesPage> {
  _ImageSortOption _sortOption = _ImageSortOption.path;
  bool _sortDescending = false;

  /// Remembers the last random gallery ID to avoid consecutive duplicates.
  String? _lastRandomGalleryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(imageSortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
          'date' => _ImageSortOption.date,
          'rating100' || 'rating' => _ImageSortOption.rating,
          'title' => _ImageSortOption.title,
          'path' => _ImageSortOption.path,
          'random' => _ImageSortOption.random,
          'created_at' => _ImageSortOption.createdAt,
          'updated_at' => _ImageSortOption.updatedAt,
          'file_count' => _ImageSortOption.fileCount,
          'file_mod_time' => _ImageSortOption.fileModTime,
          'filesize' => _ImageSortOption.filesize,
          'id' => _ImageSortOption.id,
          'o_counter' => _ImageSortOption.oCounter,
          'performer_count' => _ImageSortOption.performerCount,
          'resolution' => _ImageSortOption.resolution,
          'tag_count' => _ImageSortOption.tagCount,
          _ => _ImageSortOption.path,
        };
        _sortDescending = sortConfig.descending;
      });
    });
  }

  void _onSearchChanged(String query) {
    ref.read(imageSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort() {
    final sortKey = switch (_sortOption) {
      _ImageSortOption.date => 'date',
      _ImageSortOption.rating => 'rating',
      _ImageSortOption.title => 'title',
      _ImageSortOption.path => 'path',
      _ImageSortOption.random => 'random',
      _ImageSortOption.createdAt => 'created_at',
      _ImageSortOption.updatedAt => 'updated_at',
      _ImageSortOption.fileCount => 'file_count',
      _ImageSortOption.fileModTime => 'file_mod_time',
      _ImageSortOption.filesize => 'filesize',
      _ImageSortOption.id => 'id',
      _ImageSortOption.oCounter => 'o_counter',
      _ImageSortOption.performerCount => 'performer_count',
      _ImageSortOption.resolution => 'resolution',
      _ImageSortOption.tagCount => 'tag_count',
    };
    ref
        .read(imageListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  String _sortOptionLabel(_ImageSortOption option) {
    return switch (option) {
      _ImageSortOption.date => 'Date',
      _ImageSortOption.rating => 'Rating',
      _ImageSortOption.title => 'Title',
      _ImageSortOption.path => 'Filepath',
      _ImageSortOption.random => 'Random',
      _ImageSortOption.createdAt => 'Created At',
      _ImageSortOption.updatedAt => 'Updated At',
      _ImageSortOption.fileCount => 'File Count',
      _ImageSortOption.fileModTime => 'File Mod Time',
      _ImageSortOption.filesize => 'Filesize',
      _ImageSortOption.id => 'ID',
      _ImageSortOption.oCounter => 'O-Counter',
      _ImageSortOption.performerCount => 'Performer Count',
      _ImageSortOption.resolution => 'Resolution',
      _ImageSortOption.tagCount => 'Tag Count',
    };
  }

  /// Opens a random gallery's images.
  void _openRandomGallery() {
    final galleries = ref.read(galleryListProvider).value ?? [];
    if (galleries.isEmpty) return;

    // Choose a random gallery that wasn't the last one we picked.
    final random = Random();
    int index;
    do {
      index = random.nextInt(galleries.length);
    } while (galleries.length > 1 &&
        galleries[index].id == _lastRandomGalleryId);

    final gallery = galleries[index];
    _lastRandomGalleryId = gallery.id;

    // Set the filter and refresh.
    ref.read(imageFilterStateProvider.notifier).setGalleryId(gallery.id);
    context.go('/galleries/images');
  }

  void _showSortPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        _ImageSortOption tempOption = _sortOption;
        bool tempDescending = _sortDescending;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.images_sort_title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempOption = _ImageSortOption.path;
                              tempDescending = false;
                            });
                          },
                          child: Text(context.l10n.common_reset),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      context.l10n.common_sort_method,
                      style: context.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.35,
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingSmall,
                            ),
                            child: Wrap(
                              spacing: AppTheme.spacingSmall,
                              runSpacing: AppTheme.spacingSmall,
                              children: _ImageSortOption.values
                                  .map(
                                    (option) => ChoiceChip(
                                      label: Text(_sortOptionLabel(option)),
                                      selected: tempOption == option,
                                      onSelected: (selected) {
                                        if (!selected) return;
                                        setModalState(() {
                                          tempOption = option;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      context.l10n.common_direction,
                      style: context.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: true,
                            label: Text(context.l10n.common_descending),
                            icon: const Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text(context.l10n.common_ascending),
                            icon: const Icon(Icons.arrow_upward),
                          ),
                        ],
                        selected: {tempDescending},
                        onSelectionChanged: (value) =>
                            setModalState(() => tempDescending = value.first),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sortOption = tempOption;
                            _sortDescending = tempDescending;
                          });
                          _applyServerSort();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_sort),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          setState(() {
                            _sortOption = tempOption;
                            _sortDescending = tempDescending;
                          });
                          _applyServerSort();
                          await ref
                              .read(imageSortProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.images_sort_saved),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_save_default),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImageFilterPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imageListProvider);
    final gridColumns = ref.watch(imageGridColumnsProvider);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    final filterState = ref.watch(imageFilterStateProvider);
    final filterActive = ref.watch(
      imageFilterStateProvider.select((s) => s.filter != const ImageFilter()),
    );
    final organizedFilter = ref.watch(imageOrganizedOnlyProvider);
    final hasActiveFilters = filterActive || organizedFilter != OrganizedFilter.all;

    int crossAxisCount = gridColumns ?? (isTablet ? 3 : (isMobile ? 2 : 5));

    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    // Hoist invariant layout calculations out of the itemBuilder loop
    // to prevent O(N) redundant calculations during scroll events.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final memCacheWidth = (screenWidth / crossAxisCount * 1.5).toInt();

    return ListPageScaffold<entity.Image>(
      title: context.l10n.images_title,
      imageUrlBuilder: (img) => img.paths.thumbnail,
      // Pass the actual column count to the scaffold so scroll-sensed prefetch works correctly.
      // We use a dummy gridDelegate just to signal to ListPageScaffold that it's a grid.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      useResponsiveGrid: false,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.scenes_sort_tooltip,
              onPressed: _showSortPanel,
            ),
            if (_sortOption != _ImageSortOption.path || _sortDescending)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterPanel,
            ),
            if (hasActiveFilters)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
          ],
        ),
      ],
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: imagesAsync,
      onRefresh: () => ref.read(imageListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(imageListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(imageListProvider.notifier).setPerPage(pageSize),
      floatingActionButton: randomNavigationEnabled
          ? FloatingActionButton.small(
              heroTag: 'images_random_fab',
              onPressed: _openRandomGallery,
              tooltip: context.l10n.random_gallery,
              child: const Icon(Icons.casino_outlined),
            )
          : null,
      sortBar: filterState.galleryId != null
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
              child: Row(
                children: [
                  InputChip(
                    label: Text(context.l10n.images_filtered_by_gallery),
                    onDeleted: () {
                      ref
                          .read(imageFilterStateProvider.notifier)
                          .clearGalleryId();
                    },
                  ),
                ],
              ),
            )
          : null,
      customBody: CustomScrollView(
        controller: ref.watch(imageScrollControllerProvider),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppTheme.spacingSmall,
              crossAxisSpacing: AppTheme.spacingSmall,
              itemBuilder: (context, index) {
                final items = imagesAsync.value ?? [];
                if (index >= items.length) return const SizedBox.shrink();

                return RepaintBoundary(
                  child: ImageCard(
                    image: items[index],
                    memCacheWidth: memCacheWidth,
                  ),
                );
              },
              childCount: imagesAsync.value?.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
