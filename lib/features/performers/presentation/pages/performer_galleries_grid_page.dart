import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import '../../../galleries/presentation/widgets/entity_gallery_grid.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/performer_galleries_provider.dart';

/// A grid page showing all galleries for a specific performer.
///
/// Uses [ListPageScaffold] for consistent layout and [GalleryCard] for
/// unified item representation.
class PerformerGalleriesGridPage extends ConsumerWidget {
  const PerformerGalleriesGridPage({required this.performerId, super.key});

  /// The ID of the performer whose galleries to display.
  final String performerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(
      performerGalleriesGridProvider(performerId),
    );
    final isGridView = ref.watch(performerGalleriesGridLayoutProvider);
    final gridColumns = ref.watch(performerGridColumnsProvider);

    return EntityGalleryGrid(
      title: context.l10n.performers_galleries_title,
      entityId: performerId,
      filterKind: EntityGalleryFilterKind.performer,
      galleriesAsync: galleriesAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      onRefresh: () =>
          ref.refresh(performerGalleriesGridProvider(performerId).future),
      onFetchNextPage: () => ref
          .read(performerGalleriesGridProvider(performerId).notifier)
          .fetchNextPage(),
    );
  }
}
