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

import '../widgets/image_filter_panel.dart';
import '../../domain/entities/image_filter.dart';

enum _ImageSortOption { date, rating, title, path, random }

class ImagesPage extends ConsumerStatefulWidget {
  const ImagesPage({super.key});

  @override
  ConsumerState<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends ConsumerState<ImagesPage> {
  _ImageSortOption _sortOption = _ImageSortOption.path;
  bool _sortDescending = false;

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
          'path' => _ImageSortOption.path,
          'random' => _ImageSortOption.random,
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
    };
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
                          'Sort Images',
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
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text('Sort Method', style: context.textTheme.labelLarge),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Wrap(
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
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text('Direction', style: context.textTheme.labelLarge),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Descending'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Ascending'),
                            icon: Icon(Icons.arrow_upward),
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
                        child: const Text('Apply Sort'),
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
                              const SnackBar(
                                content: Text(
                                  'Sort preferences saved as default',
                                ),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: const Text('Save as Default'),
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    final filterState = ref.watch(imageFilterStateProvider);
    final filterActive = ref.watch(
      imageFilterStateProvider.select(
        (s) => s.filter != const ImageFilter(),
      ),
    );
    final organizedOnly = ref.watch(imageOrganizedOnlyProvider);
    final hasActiveFilters = filterActive || organizedOnly;

    int crossAxisCount = 2;
    if (isTablet) {
      crossAxisCount = 3;
    } else if (!isMobile) {
      crossAxisCount = 5;
    }

    return ListPageScaffold<entity.Image>(
      title: 'Images',
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort options',
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
      searchHint: 'Search images...',
      onSearchChanged: _onSearchChanged,
      provider: imagesAsync,
      onRefresh: () => ref.refresh(imageListProvider.future),
      onFetchNextPage: () =>
          ref.read(imageListProvider.notifier).fetchNextPage(),
      sortBar: filterState.galleryId != null
          ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            child: Row(
              children: [
                InputChip(
                  label: const Text('Filtered by Gallery'),
                  onDeleted: () {
                    ref.read(imageFilterStateProvider.notifier).clearGalleryId();
                  },
                ),
              ],
            ),
          )
          : null,
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
