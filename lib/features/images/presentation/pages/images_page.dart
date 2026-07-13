import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/providers/list_scroll_controller_provider.dart';
import '../../../galleries/presentation/providers/gallery_random_navigation_provider.dart';
import '../providers/image_list_provider.dart';
import '../widgets/image_card.dart';
import '../../domain/entities/image.dart' as entity;

import '../widgets/image_filter_panel.dart';
import '../../domain/entities/image_filter.dart';
import '../../domain/entities/image_saved_filter_config.dart';
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
      if (!mounted) return;
      final sortConfig = ref.read(imageSortProvider);
      setState(() {
        _sortOption = _sortOptionForKey(sortConfig.sort);
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

  _ImageSortOption _sortOptionForKey(String? sort) {
    return switch (sort) {
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
  Future<void> _openRandomGallery() async {
    final gallery = await ref
        .read(galleryRandomNavigationControllerProvider)
        .getRandomGallery(excludeGalleryId: _lastRandomGalleryId);
    if (!mounted || gallery == null) return;

    _lastRandomGalleryId = gallery.id;

    // Set the filter and refresh.
    ref.read(imageFilterStateProvider.notifier).setGalleryId(gallery.id);
    context.go('/galleries/images');
  }

  void _showSortPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => ListSortBottomSheet<_ImageSortOption>(
        title: context.l10n.images_sort_title,
        options: _ImageSortOption.values,
        initialOption: _sortOption,
        initialDescending: _sortDescending,
        resetOption: _ImageSortOption.path,
        resetDescending: false,
        optionLabel: _sortOptionLabel,
        onApply: (option, descending) {
          setState(() {
            _sortOption = option;
            _sortDescending = descending;
          });
          _applyServerSort();
        },
        onSaveDefault: () =>
            ref.read(imageSortProvider.notifier).saveAsDefault(),
        saveDefaultSuccessMessage: context.l10n.images_sort_saved,
      ),
    );
  }

  void _showFilterPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => const ImageFilterPanel(),
    );
  }

  int _activeFilterCount(ImageFilter filter) {
    return activeFilterCount(filter.toJson());
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(imageSortProvider);
    final filterState = ref.read(imageFilterStateProvider);
    final organizedFilter = ref.read(imageOrganizedOnlyProvider);
    final effectiveFilter = filterState.filter.copyWith(
      organized: organizedFilter.toBool() ?? filterState.filter.organized,
    );

    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => SavedFilterDialog<ImageSavedFilterConfig>(
        searchQuery: ref.read(imageSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        activeFilterCount: _activeFilterCount(effectiveFilter),
        defaultSortLabel: 'path',
        saveSuccessMessage: context.l10n.saved_item('Image filter'),
        loadPresets: () => ref
            .read(savedFilterRepositoryProvider)
            .findAll(
              mode: 'IMAGES',
              fromRaw: (raw) => ImageSavedFilterConfig.fromServerPayload(
                id: raw['id'] as String,
                name: raw['name'] as String,
                findFilter: raw['find_filter'],
                objectFilter: raw['object_filter'],
              ),
            ),
        savePreset: ({required String name, String? existingId}) {
          return ref
              .read(savedFilterRepositoryProvider)
              .save(
                input: ImageSavedFilterConfig(
                  id: existingId,
                  name: name,
                  searchQuery: ref.read(imageSearchQueryProvider),
                  sort: sortConfig.sort,
                  descending: sortConfig.descending,
                  filter: effectiveFilter,
                ).toSaveInput(),
                fromRaw: (raw) => ImageSavedFilterConfig.fromServerPayload(
                  id: raw['id'] as String,
                  name: raw['name'] as String,
                  findFilter: raw['find_filter'],
                  objectFilter: raw['object_filter'],
                ),
              );
        },
        deletePreset: (id) =>
            ref.read(savedFilterRepositoryProvider).delete(id: id),
        onLoad: _applySavedFilterConfig,
      ),
    );
  }

  void _applySavedFilterConfig(ImageSavedFilterConfig config) {
    setState(() {
      _sortOption = _sortOptionForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(imageSearchQueryProvider.notifier).update(config.searchQuery);
    ref
        .read(imageFilterStateProvider.notifier)
        .updateFilter(config.filter.copyWith(organized: null));
    ref
        .read(imageOrganizedOnlyProvider.notifier)
        .set(OrganizedFilter.fromBool(config.filter.organized));
    ref
        .read(imageSortProvider.notifier)
        .setSort(sort: config.sort ?? 'path', descending: config.descending);
    ref.invalidate(imageListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imageListProvider);
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.image),
    );
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    final filterState = ref.watch(imageFilterStateProvider);
    final filterActive = ref.watch(
      imageFilterStateProvider.select((s) => s.filter != const ImageFilter()),
    );
    final organizedFilter = ref.watch(imageOrganizedOnlyProvider);
    final hasActiveFilters =
        filterActive || organizedFilter != OrganizedFilter.all;

    int crossAxisCount = gridColumns ?? (isTablet ? 3 : (isMobile ? 2 : 5));

    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return ListPageScaffold<entity.Image>(
      title: context.l10n.images_title,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      useResponsiveGrid: false,
      useMasonry: true,
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
        IconButton(
          tooltip: context.l10n.common_saved_filters,
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showSavedFilterDialog,
        ),
      ],
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: _onSearchChanged,
      provider: imagesAsync,
      itemBuilder: (context, image, memCacheWidth, memCacheHeight) =>
          ImageCard(image: image, memCacheWidth: memCacheWidth),
      loadingItemBuilder: (context, isGrid, index) =>
          ImageCard.skeleton(memCacheWidth: 300),
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
      scrollController: ref.watch(
        listScrollControllerProvider(ListScrollTarget.image),
      ),
      padding: EdgeInsets.all(context.dimensions.spacingSmall),
    );
  }
}
