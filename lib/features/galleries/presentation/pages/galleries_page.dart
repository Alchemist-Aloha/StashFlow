import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/gallery_list_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';
import '../../domain/entities/gallery.dart';

import '../widgets/gallery_card.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';

import '../widgets/gallery_filter_panel.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';

enum _GallerySortOption {
  date,
  title,
  path,
  rating,
  fileModTime,
  tagCount,
  performerCount,
  random,
  imageCount,
  fileCount,
  createdAt,
  updatedAt,
}

class GalleriesPage extends ConsumerStatefulWidget {
  const GalleriesPage({super.key});

  @override
  ConsumerState<GalleriesPage> createState() => _GalleriesPageState();
}

class _GalleriesPageState extends ConsumerState<GalleriesPage> {
  _GallerySortOption _sortOption = _GallerySortOption.path;
  bool _sortDescending = false;

  /// Remembers the last random gallery ID to avoid consecutive duplicates.
  String? _lastRandomGalleryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sortConfig = ref.read(gallerySortProvider);
      setState(() {
        _sortOption = switch (sortConfig.sort) {
          'date' => _GallerySortOption.date,
          'title' => _GallerySortOption.title,
          'path' => _GallerySortOption.path,
          'rating100' || 'rating' => _GallerySortOption.rating,
          'file_mod_time' => _GallerySortOption.fileModTime,
          'tag_count' => _GallerySortOption.tagCount,
          'performer_count' => _GallerySortOption.performerCount,
          'random' => _GallerySortOption.random,
          'images_count' || 'image_count' => _GallerySortOption.imageCount,
          'zip_file_count' || 'file_count' => _GallerySortOption.fileCount,
          'created_at' => _GallerySortOption.createdAt,
          'updated_at' => _GallerySortOption.updatedAt,
          _ => _GallerySortOption.path,
        };
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort();
    });
  }

  void _onSearchChanged(String query) {
    ref.read(gallerySearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort() {
    final sortKey = switch (_sortOption) {
      _GallerySortOption.date => 'date',
      _GallerySortOption.title => 'title',
      _GallerySortOption.path => 'path',
      _GallerySortOption.rating => 'rating',
      _GallerySortOption.fileModTime => 'file_mod_time',
      _GallerySortOption.tagCount => 'tag_count',
      _GallerySortOption.performerCount => 'performer_count',
      _GallerySortOption.random => 'random',
      _GallerySortOption.imageCount => 'images_count',
      _GallerySortOption.fileCount => 'zip_file_count',
      _GallerySortOption.createdAt => 'created_at',
      _GallerySortOption.updatedAt => 'updated_at',
    };
    ref
        .read(galleryListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  /// Opens a random gallery image view.
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

    // Set the filter and navigate.
    ref.read(imageFilterStateProvider.notifier).setGalleryId(gallery.id);
    context.push('/galleries/images');
  }

  String _sortOptionLabel(_GallerySortOption option) {
    return switch (option) {
      _GallerySortOption.date => context.l10n.common_date,
      _GallerySortOption.title => context.l10n.common_title,
      _GallerySortOption.path => context.l10n.common_filepath,
      _GallerySortOption.rating => context.l10n.common_rating,
      _GallerySortOption.fileModTime => context.l10n.sort_file_mod_time,
      _GallerySortOption.tagCount => context.l10n.sort_tag_count,
      _GallerySortOption.performerCount => context.l10n.sort_performers_count,
      _GallerySortOption.random => context.l10n.common_random,
      _GallerySortOption.imageCount => context.l10n.common_image_count,
      _GallerySortOption.fileCount => context.l10n.sort_zip_file_count,
      _GallerySortOption.createdAt => context.l10n.sort_created_at,
      _GallerySortOption.updatedAt => context.l10n.sort_updated_at,
    };
  }

  void _showSortPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        _GallerySortOption tempOption = _sortOption;
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
                          context.l10n.galleries_sort_title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempOption = _GallerySortOption.path;
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
                          // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
                          // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
                          maxHeight: MediaQuery.sizeOf(context).height * 0.35,
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
                              children: _GallerySortOption.values
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
                      child: TextButton(
                        onPressed: () async {
                          setState(() {
                            _sortOption = tempOption;
                            _sortDescending = tempDescending;
                          });
                          _applyServerSort();
                          await ref
                              .read(gallerySortProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.tags_sort_saved),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
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
      builder: (context) => const GalleryFilterPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleriesAsync = ref.watch(galleryListProvider);
    final isGridView = ref.watch(galleryGridLayoutProvider);
    final gridColumns = ref.watch(galleryGridColumnsProvider);
    final filterActive = ref.watch(
      galleryFilterStateProvider.select((s) => s != GalleryFilter.empty()),
    );
    final organizedFilter = ref.watch(galleryOrganizedOnlyProvider);
    final hasActiveFilters = filterActive || organizedFilter != OrganizedFilter.all;
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    // ⚡ Bolt: Hoist server endpoint calculation out of the itemBuilder/imageUrlBuilder loop.
    // Why: Previously, _getThumbnailUrl was parsing the server URL and URI for every single item,
    // which is expensive O(N) work during scroll events.
    // Impact: Drastically reduces URI parsing overhead during list scrolling.
    final serverUrl = ref.watch(serverUrlProvider);
    final endpoint = Uri.parse(
      serverUrl.isEmpty ? 'http://localhost:9999/graphql' : serverUrl,
    );

    return ListPageScaffold<Gallery>(
      title: context.l10n.galleries_title,
      scrollController: ref.watch(galleryScrollControllerProvider),
      imageUrlBuilder: (gallery) => resolveGraphqlMediaUrl(
        rawUrl: gallery.coverPath ?? '/gallery/${gallery.id}/thumbnail',
        graphqlEndpoint: endpoint,
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.common_sort,
              onPressed: _showSortPanel,
            ),
            if (_sortOption != _GallerySortOption.path || _sortDescending)
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
        IconButton(
          icon: const Icon(Icons.image),
          tooltip: context.l10n.galleries_all_images,
          onPressed: () {
            ref.read(imageFilterStateProvider.notifier).clear();
            context.go('/galleries/images');
          },
        ),
      ],
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: galleriesAsync,
      onRefresh: () => ref.read(galleryListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(galleryListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(galleryListProvider.notifier).setPerPage(pageSize),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(crossAxisCount: gridColumns ?? 2)
          : null,
      useMasonry: isGridView,
      padding: isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      itemBuilder: (context, gallery, memCacheWidth, memCacheHeight) =>
          GalleryCard(
            gallery: gallery,
            isGrid: isGridView,
            useMasonry: isGridView,
            thumbnailUrl: resolveGraphqlMediaUrl(
              rawUrl: gallery.coverPath ?? '/gallery/${gallery.id}/thumbnail',
              graphqlEndpoint: endpoint,
            ),
            memCacheWidth: memCacheWidth,
            onTap: () {
              ref
                  .read(imageFilterStateProvider.notifier)
                  .setGalleryId(gallery.id);
              context.go('/galleries/images');
            },
          ),
      floatingActionButton: randomNavigationEnabled
          ? galleriesAsync.maybeWhen(
              data: (galleries) => FloatingActionButton.small(
                heroTag: 'galleries_random_fab',
                onPressed: _openRandomGallery,
                tooltip: context.l10n.random_gallery,
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
