import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/gallery_list_provider.dart';
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
        ref.read(galleryListProvider.notifier).setSort(sort: 'title', descending: false);
        break;
    }
  }

  Widget _buildSortBar() {
    const options = [
      (_GallerySortOption.title, 'Title'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
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

    return ListPageScaffold<Gallery>(
      title: 'Galleries',
      searchHint: 'Search galleries...',
      onSearchChanged: _onSearchChanged,
      provider: galleriesAsync,
      onRefresh: () => ref.refresh(galleryListProvider.future),
      onFetchNextPage: () => ref.read(galleryListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      itemBuilder: (context, gallery) => Card(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.photo_library),
          title: Text(
            gallery.title.isEmpty ? 'Untitled gallery' : gallery.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('ID: ${gallery.id}'),
          onTap: () => context.push('/gallery/${gallery.id}'),
        ),
      ),
    );
  }
}
