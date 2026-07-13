import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../images/presentation/providers/image_list_provider.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../domain/entities/gallery_saved_filter_config.dart';
import '../providers/entity_gallery_filter_scope.dart';
import 'gallery_card.dart';
import 'gallery_filter_panel.dart';

enum EntityGallerySortOption {
  path,
  title,
  date,
  rating,
  imageCount,
  fileCount,
  createdAt,
  updatedAt,
  random,
}

class EntityGalleryGrid extends ConsumerStatefulWidget {
  const EntityGalleryGrid({
    required this.title,
    required this.entityId,
    required this.filterKind,
    required this.galleriesAsync,
    required this.isGridView,
    required this.gridColumns,
    required this.onRefresh,
    required this.onFetchNextPage,
    super.key,
  });

  final String title;
  final String entityId;
  final EntityGalleryFilterKind filterKind;
  final AsyncValue<List<Gallery>> galleriesAsync;
  final bool isGridView;
  final int? gridColumns;
  final Future<void> Function() onRefresh;
  final VoidCallback onFetchNextPage;

  @override
  ConsumerState<EntityGalleryGrid> createState() => _EntityGalleryGridState();
}

class _EntityGalleryGridState extends ConsumerState<EntityGalleryGrid> {
  EntityGallerySortOption _sortOption = EntityGallerySortOption.path;
  bool _sortDescending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(entityGallerySortProvider(widget.filterKind));
      setState(() {
        _sortOption = _sortOptionForKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
    });
  }

  GalleryFilter _scopedFilter(GalleryFilter filter) {
    return galleryFilterForEntityGalleries(
      filter: filter,
      kind: widget.filterKind,
      entityId: widget.entityId,
    );
  }

  String _sortKeyForOption(EntityGallerySortOption option) {
    return switch (option) {
      EntityGallerySortOption.path => 'path',
      EntityGallerySortOption.title => 'title',
      EntityGallerySortOption.date => 'date',
      EntityGallerySortOption.rating => 'rating',
      EntityGallerySortOption.imageCount => 'images_count',
      EntityGallerySortOption.fileCount => 'zip_file_count',
      EntityGallerySortOption.createdAt => 'created_at',
      EntityGallerySortOption.updatedAt => 'updated_at',
      EntityGallerySortOption.random => 'random',
    };
  }

  EntityGallerySortOption _sortOptionForKey(String? sort) {
    return switch (sort) {
      'title' => EntityGallerySortOption.title,
      'date' => EntityGallerySortOption.date,
      'rating100' || 'rating' => EntityGallerySortOption.rating,
      'images_count' || 'image_count' => EntityGallerySortOption.imageCount,
      'zip_file_count' || 'file_count' => EntityGallerySortOption.fileCount,
      'created_at' => EntityGallerySortOption.createdAt,
      'updated_at' => EntityGallerySortOption.updatedAt,
      'random' => EntityGallerySortOption.random,
      _ => EntityGallerySortOption.path,
    };
  }

  String _sortOptionLabel(EntityGallerySortOption option) {
    return switch (option) {
      EntityGallerySortOption.path => context.l10n.common_filepath,
      EntityGallerySortOption.title => context.l10n.common_title,
      EntityGallerySortOption.date => context.l10n.common_date,
      EntityGallerySortOption.rating => context.l10n.common_rating,
      EntityGallerySortOption.imageCount => context.l10n.common_image_count,
      EntityGallerySortOption.fileCount => context.l10n.sort_zip_file_count,
      EntityGallerySortOption.createdAt => context.l10n.sort_created_at,
      EntityGallerySortOption.updatedAt => context.l10n.sort_updated_at,
      EntityGallerySortOption.random => context.l10n.common_random,
    };
  }

  void _applyServerSort() {
    ref
        .read(entityGallerySortProvider(widget.filterKind).notifier)
        .setSort(
          sort: _sortKeyForOption(_sortOption),
          descending: _sortDescending,
        );
  }

  void _showSortPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => ListSortBottomSheet<EntityGallerySortOption>(
        title: context.l10n.galleries_sort_title,
        options: EntityGallerySortOption.values,
        initialOption: _sortOption,
        initialDescending: _sortDescending,
        resetOption: EntityGallerySortOption.path,
        resetDescending: false,
        optionLabel: _sortOptionLabel,
        onApply: (option, descending) {
          setState(() {
            _sortOption = option;
            _sortDescending = descending;
          });
          _applyServerSort();
        },
        onSaveDefault: () => ref
            .read(entityGallerySortProvider(widget.filterKind).notifier)
            .saveAsDefault(),
        saveDefaultSuccessMessage: context.l10n.tags_sort_saved,
      ),
    );
  }

  void _showFilterPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => GalleryFilterPanel(
        initialFilter: ref.read(
          entityGalleryFilterStateProvider(widget.filterKind),
        ),
        initialOrganized: ref.read(
          entityGalleryOrganizedOnlyProvider(widget.filterKind),
        ),
        onApply: (filter, organized) {
          ref
              .read(
                entityGalleryFilterStateProvider(widget.filterKind).notifier,
              )
              .update(filter);
          ref
              .read(
                entityGalleryOrganizedOnlyProvider(widget.filterKind).notifier,
              )
              .set(organized);
        },
        onSaveDefault: (filter, organized) async {
          ref
              .read(
                entityGalleryFilterStateProvider(widget.filterKind).notifier,
              )
              .update(filter);
          ref
              .read(
                entityGalleryOrganizedOnlyProvider(widget.filterKind).notifier,
              )
              .set(organized);
          await Future.wait([
            ref
                .read(
                  entityGalleryFilterStateProvider(widget.filterKind).notifier,
                )
                .saveAsDefault(),
            ref
                .read(
                  entityGalleryOrganizedOnlyProvider(
                    widget.filterKind,
                  ).notifier,
                )
                .saveAsDefault(),
          ]);
        },
        saveSuccessMessage: context.l10n.galleries_filter_saved,
      ),
    );
  }

  int _activeFilterCount(GalleryFilter filter) {
    return activeFilterCount(filter.toJson());
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(entityGallerySortProvider(widget.filterKind));
    final filter = ref.read(
      entityGalleryFilterStateProvider(widget.filterKind),
    );
    final organizedFilter = ref.read(
      entityGalleryOrganizedOnlyProvider(widget.filterKind),
    );
    final effectiveFilter = _scopedFilter(
      filter.copyWith(organized: organizedFilter.toBool() ?? filter.organized),
    );

    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => SavedFilterDialog<GallerySavedFilterConfig>(
        searchQuery: ref.read(
          entityGallerySearchQueryProvider(widget.filterKind),
        ),
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
                  searchQuery: ref.read(
                    entityGallerySearchQueryProvider(widget.filterKind),
                  ),
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
    );
  }

  void _applySavedFilterConfig(GallerySavedFilterConfig config) {
    final scopedFilter = _scopedFilter(config.filter);
    setState(() {
      _sortOption = _sortOptionForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref
        .read(entityGallerySearchQueryProvider(widget.filterKind).notifier)
        .update(config.searchQuery);
    ref
        .read(entityGalleryFilterStateProvider(widget.filterKind).notifier)
        .update(scopedFilter.copyWith(organized: null));
    ref
        .read(entityGalleryOrganizedOnlyProvider(widget.filterKind).notifier)
        .set(OrganizedFilter.fromBool(scopedFilter.organized));
    ref
        .read(entityGallerySortProvider(widget.filterKind).notifier)
        .setSort(sort: config.sort ?? 'path', descending: config.descending);
  }

  void _openAllEntityImages() {
    final method = ref.read(entityImageFilterMethodSettingProvider);
    ref.read(imageFilterStateProvider.notifier).clear();
    ref
        .read(imageFilterStateProvider.notifier)
        .updateFilter(
          imageFilterForEntityGalleries(
            kind: widget.filterKind,
            entityId: widget.entityId,
            method: method,
          ),
        );
    context.push('/galleries/images');
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(
      entityGalleryFilterStateProvider(widget.filterKind),
    );
    final scopedFilter = _scopedFilter(filter);
    final baseFilter = _scopedFilter(GalleryFilter.empty());
    final organizedFilter = ref.watch(
      entityGalleryOrganizedOnlyProvider(widget.filterKind),
    );
    final hasActiveFilters =
        scopedFilter != baseFilter || organizedFilter != OrganizedFilter.all;

    return ListPageScaffold<Gallery>(
      title: widget.title,
      searchHint: context.l10n.common_search_placeholder,
      onSearchChanged: (query) => ref
          .read(entityGallerySearchQueryProvider(widget.filterKind).notifier)
          .update(query),
      provider: widget.galleriesAsync,
      onRefresh: widget.onRefresh,
      onFetchNextPage: widget.onFetchNextPage,
      loadingItemBuilder: (context, isGrid, index) =>
          GalleryCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
      gridDelegate: widget.isGridView
          ? GridUtils.createDelegate(crossAxisCount: widget.gridColumns ?? 2)
          : null,
      useMasonry: widget.isGridView,
      padding: widget.isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.common_sort,
              onPressed: _showSortPanel,
            ),
            if (_sortOption != EntityGallerySortOption.path || _sortDescending)
              const Positioned(right: 8, top: 8, child: _ActionDot()),
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
              const Positioned(right: 8, top: 8, child: _ActionDot()),
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
          onPressed: _openAllEntityImages,
        ),
      ],
      itemBuilder: (context, item, memCacheWidth, memCacheHeight) {
        return GalleryCard(
          gallery: item,
          isGrid: widget.isGridView,
          useMasonry: widget.isGridView,
          memCacheWidth: memCacheWidth,
          onTap: () {
            ref.read(imageFilterStateProvider.notifier).setGalleryId(item.id);
            context.push('/galleries/images');
          },
        );
      },
    );
  }
}

class _ActionDot extends StatelessWidget {
  const _ActionDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
    );
  }
}
