import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import '../../../galleries/presentation/widgets/entity_gallery_grid.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../providers/studio_galleries_provider.dart';

/// A grid page showing all galleries for a specific studio.
class StudioGalleriesGridPage extends ConsumerWidget {
  const StudioGalleriesGridPage({required this.studioId, super.key});

  final String studioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(studioGalleriesGridProvider(studioId));
    final isGridView = ref.watch(
      gridLayoutSettingProvider(GridLayoutSetting.studioGalleries),
    );
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.studio),
    );

    return EntityGalleryGrid(
      title: context.l10n.studios_galleries_title,
      entityId: studioId,
      filterKind: EntityGalleryFilterKind.studio,
      galleriesAsync: galleriesAsync,
      isGridView: isGridView,
      gridColumns: gridColumns,
      onRefresh: () =>
          ref.refresh(studioGalleriesGridProvider(studioId).future),
      onFetchNextPage: () => ref
          .read(studioGalleriesGridProvider(studioId).notifier)
          .fetchNextPage(),
    );
  }
}
