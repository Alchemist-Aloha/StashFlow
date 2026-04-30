import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  filesize,
  fileCount,
  date,
  resolution,
  title,
  path,
  rating,
  fileModTime,
  tagCount,
  performerCount,
  random,
  oCounter,
  createdAt,
  updatedAt,
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
          'filesize' => _ImageSortOption.filesize,
          'file_count' => _ImageSortOption.fileCount,
          'date' => _ImageSortOption.date,
          'resolution' => _ImageSortOption.resolution,
          'title' => _ImageSortOption.title,
          'path' => _ImageSortOption.path,
          'rating100' || 'rating' => _ImageSortOption.rating,
          'file_mod_time' => _ImageSortOption.fileModTime,
          'tag_count' => _ImageSortOption.tagCount,
          'performer_count' => _ImageSortOption.performerCount,
          'random' => _ImageSortOption.random,
          'o_counter' => _ImageSortOption.oCounter,
          'created_at' => _ImageSortOption.createdAt,
          'updated_at' => _ImageSortOption.updatedAt,
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
      _ImageSortOption.filesize => 'filesize',
      _ImageSortOption.fileCount => 'file_count',
      _ImageSortOption.date => 'date',
      _ImageSortOption.resolution => 'resolution',
      _ImageSortOption.title => 'title',
      _ImageSortOption.path => 'path',
      _ImageSortOption.rating => 'rating',
      _ImageSortOption.fileModTime => 'file_mod_time',
      _ImageSortOption.tagCount => 'tag_count',
      _ImageSortOption.performerCount => 'performer_count',
      _ImageSortOption.random => 'random',
      _ImageSortOption.oCounter => 'o_counter',
      _ImageSortOption.createdAt => 'created_at',
      _ImageSortOption.updatedAt => 'updated_at',
    };
    ref
        .read(imageListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  String _sortOptionLabel(_ImageSortOption option) {
    return switch (option) {
      _ImageSortOption.filesize => context.l10n.sort_filesize,
      _ImageSortOption.fileCount => context.l10n.common_image_count,
      _ImageSortOption.date => context.l10n.common_date,
      _ImageSortOption.resolution => context.l10n.common_resolution,
      _ImageSortOption.title => context.l10n.common_title,
      _ImageSortOption.path => context.l10n.common_filepath,
      _ImageSortOption.rating => context.l10n.common_rating,
      _ImageSortOption.fileModTime => context.l10n.sort_file_mod_time,
      _ImageSortOption.tagCount => context.l10n.sort_tag_count,
      _ImageSortOption.performerCount => context.l10n.sort_performers_count,
      _ImageSortOption.random => context.l10n.common_random,
      _ImageSortOption.oCounter => context.l10n.sort_o_count,
      _ImageSortOption.createdAt => context.l10n.sort_created_at,
      _ImageSortOption.updatedAt => context.l10n.sort_updated_at,
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
                padding: EdgeInsets.all(context.dimensions.spacingLarge),
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
                    SizedBox(height: context.dimensions.spacingMedium),
                    Text(
                      context.l10n.common_sort_method,
                      style: context.textTheme.labelLarge,
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
                          // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
                          maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              vertical: context.dimensions.spacingSmall,
                            ),
                            child: Wrap(
                              spacing: context.dimensions.spacingSmall,
                              runSpacing: context.dimensions.spacingSmall,
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
                    SizedBox(height: context.dimensions.spacingMedium),
                    Text(
                      context.l10n.common_direction,
                      style: context.textTheme.labelLarge,
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
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
                    SizedBox(height: context.dimensions.spacingLarge),
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
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_sort),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
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
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_save_default),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingMedium),
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

    return ListPageScaffold<entity.Image>(
      title: context.l10n.images_title,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      useResponsiveGrid: false,
      useMasonry: true,
      imageUrlBuilder: (img) => img.paths.thumbnail,
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
              tooltip: context.l10n.common_filter,
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
        itemBuilder: (context, image, memCacheWidth, memCacheHeight) =>
          ImageCard(image: image, memCacheWidth: memCacheWidth),
        loadingItemBuilder: (context, isGrid, index) => ImageCard.skeleton(
        memCacheWidth: 300,
        ),
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
              padding: EdgeInsets.symmetric(
                horizontal: context.dimensions.spacingMedium,
                vertical: context.dimensions.spacingSmall,
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
      scrollController: ref.watch(imageScrollControllerProvider),
      padding: EdgeInsets.all(context.dimensions.spacingSmall),
    );
  }
}
