import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import '../../../galleries/presentation/widgets/entity_gallery_grid.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/tag_galleries_provider.dart';

/// A grid page showing all galleries for a specific tag.
class TagGalleriesGridPage extends ConsumerWidget {
  const TagGalleriesGridPage({required this.tagId, super.key});

  final String tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(tagGalleriesGridProvider(tagId));
    final isGridView = ref.watch(tagGalleriesGridLayoutProvider);
    final gridColumns = ref.watch(tagGridColumnsProvider);

    return EntityGalleryGrid(
      title: context.l10n.details_galleries,
      entityId: tagId,
      filterKind: EntityGalleryFilterKind.tag,
      galleriesAsync: galleriesAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      onRefresh: () => ref.refresh(tagGalleriesGridProvider(tagId).future),
      onFetchNextPage: () =>
          ref.read(tagGalleriesGridProvider(tagId).notifier).fetchNextPage(),
    );
  }
}
