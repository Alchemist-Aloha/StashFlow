import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../gallery_sort.dart';
import '../providers/gallery_list_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';
import '../../domain/entities/gallery.dart';

import '../widgets/gallery_card.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';

import '../widgets/gallery_filter_panel.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../domain/entities/gallery_saved_filter_config.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/providers/list_scroll_controller_provider.dart';

class GalleriesPage extends ConsumerStatefulWidget {
  const GalleriesPage({super.key});

  @override
  ConsumerState<GalleriesPage> createState() => _GalleriesPageState();
}

class _GalleriesPageState extends ConsumerState<GalleriesPage> {
  GallerySortOption _sortOption = GallerySortOption.path;
  bool _sortDescending = false;

  /// Remembers the last random gallery ID to avoid consecutive duplicates.
  String? _lastRandomGalleryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(gallerySortProvider);
      setState(() {
        _sortOption = GallerySortOption.fromKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort();
    });
  }

  void _onSearchChanged(String query) {
    ref.read(gallerySearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort() {
    final sortKey = _sortOption.key;
    ref
        .read(galleryListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  /// Opens a random gallery image view.
  Future<void> _openRandomGallery() async {
    final gallery = await ref
        .read(galleryListProvider.notifier)
        .getRandomGallery(excludeGalleryId: _lastRandomGalleryId);
    if (!mounted || gallery == null) return;

    _lastRandomGalleryId = gallery.id;

    // Set the filter and navigate.
    ref.read(imageFilterStateProvider.notifier).setGalleryId(gallery.id);
    unawaited(context.push('/galleries/images'));
  }

  void _showSortPanel() {
    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => ListSortBottomSheet<GallerySortOption>(
          title: context.l10n.galleries_sort_title,
          options: GallerySortOption.values,
          commonOptions: GallerySortOption.commonOptions,
          initialOption: _sortOption,
          initialDescending: _sortDescending,
          resetOption: GallerySortOption.path,
          resetDescending: false,
          optionLabel: (option) => option.label(context),
          onApply: (option, descending) {
            setState(() {
              _sortOption = option;
              _sortDescending = descending;
            });
            _applyServerSort();
          },
          onSaveDefault: () =>
              ref.read(gallerySortProvider.notifier).saveAsDefault(),
          saveDefaultSuccessMessage: context.l10n.tags_sort_saved,
        ),
      ),
    );
  }

  void _showFilterPanel() {
    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => const GalleryFilterPanel(),
      ),
    );
  }

  int _activeFilterCount(GalleryFilter filter) {
    return activeFilterCount(filter.toJson());
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(gallerySortProvider);
    final filter = ref.read(galleryFilterStateProvider);
    final organizedFilter = ref.read(galleryOrganizedOnlyProvider);
    final effectiveFilter = filter.copyWith(
      organized: organizedFilter.toBool() ?? filter.organized,
    );

    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => SavedFilterDialog<GallerySavedFilterConfig>(
          searchQuery: ref.read(gallerySearchQueryProvider),
          sort: sortConfig.sort,
          descending: sortConfig.descending,
          activeFilterCount: _activeFilterCount(effectiveFilter),
          defaultSortLabel: 'path',
          saveSuccessMessage: context.l10n.saved_item('Gallery filter'),
          loadPresets: () => ref
              .read(savedFilterRepositoryProvider)
              .findAll(
                mode: 'GALLERIES',
                fromRaw: (raw) => GallerySavedFilterConfig.fromServerPayload(
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
                  input: GallerySavedFilterConfig(
                    id: existingId,
                    name: name,
                    searchQuery: ref.read(gallerySearchQueryProvider),
                    sort: sortConfig.sort,
                    descending: sortConfig.descending,
                    filter: effectiveFilter,
                  ).toSaveInput(),
                  fromRaw: (raw) => GallerySavedFilterConfig.fromServerPayload(
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
      ),
    );
  }

  void _applySavedFilterConfig(GallerySavedFilterConfig config) {
    setState(() {
      _sortOption = GallerySortOption.fromKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(gallerySearchQueryProvider.notifier).update(config.searchQuery);
    ref
        .read(galleryFilterStateProvider.notifier)
        .update(config.filter.copyWith(organized: null));
    ref
        .read(galleryOrganizedOnlyProvider.notifier)
        .set(OrganizedFilter.fromBool(config.filter.organized));
    ref
        .read(gallerySortProvider.notifier)
        .setSort(sort: config.sort ?? 'path', descending: config.descending);
    ref.invalidate(galleryListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final galleriesAsync = ref.watch(galleryListProvider);
    final isGridView = ref.watch(
      gridLayoutSettingProvider(GridLayoutSetting.gallery),
    );
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.gallery),
    );
    final filterActive = ref.watch(
      galleryFilterStateProvider.select((s) => s != GalleryFilter.empty()),
    );
    final organizedFilter = ref.watch(galleryOrganizedOnlyProvider);
    final hasActiveFilters =
        filterActive || organizedFilter != OrganizedFilter.all;
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    // Hoist server endpoint calculation out of the itemBuilder loop.
    // Why: Previously, _getThumbnailUrl was parsing the server URL and URI for every single item,
    // which is expensive O(N) work during scroll events.
    // Impact: Drastically reduces URI parsing overhead during list scrolling.
    final serverUrl = ref.watch(serverUrlProvider);
    final endpoint = Uri.parse(
      serverUrl.isEmpty ? 'http://localhost:9999/graphql' : serverUrl,
    );

    return ListPageScaffold<Gallery>(
      title: context.l10n.galleries_title,
      scrollController: ref.watch(
        listScrollControllerProvider(ListScrollTarget.gallery),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.common_sort,
              onPressed: _showSortPanel,
            ),
            if (_sortOption != GallerySortOption.path || _sortDescending)
              Positioned(
                right: context.dimensions.spacingSmall,
                top: context.dimensions.spacingSmall,
                child: Container(
                  padding: EdgeInsets.all(
                    context.dimensions.spacingSmall * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: context.dimensions.spacingSmall,
                    minHeight: context.dimensions.spacingSmall,
                  ),
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
                right: context.dimensions.spacingSmall,
                top: context.dimensions.spacingSmall,
                child: Container(
                  padding: EdgeInsets.all(
                    context.dimensions.spacingSmall * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: context.dimensions.spacingSmall,
                    minHeight: context.dimensions.spacingSmall,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          tooltip: context.l10n.common_saved_filters,
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showSavedFilterDialog,
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
      loadingItemBuilder: (context, isGrid, index) =>
          GalleryCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
      gridDelegate: isGridView
          ? GridUtils.createDelegate(context, crossAxisCount: gridColumns ?? 2)
          : null,
      useMasonry: isGridView,
      padding: isGridView ? GridUtils.defaultPadding(context) : EdgeInsets.zero,
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
