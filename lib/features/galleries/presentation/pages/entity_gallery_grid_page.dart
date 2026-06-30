import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../providers/entity_gallery_filter_scope.dart'
    show EntityGalleryFilterKind, entityGalleryGridProvider;
import '../widgets/entity_gallery_grid.dart';

class EntityGalleryGridPage extends ConsumerWidget {
  const EntityGalleryGridPage({
    required this.entityId,
    required this.filterKind,
    super.key,
  });

  final String entityId;
  final EntityGalleryFilterKind filterKind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(
      entityGalleryGridProvider(filterKind, entityId),
    );

    return EntityGalleryGrid(
      title: _title(context),
      entityId: entityId,
      filterKind: filterKind,
      galleriesAsync: galleriesAsync,
      isGridView: ref.watch(gridLayoutSettingProvider(_layoutSetting)),
      gridColumns: ref.watch(gridColumnSettingProvider(_columnSetting)),
      onRefresh: () =>
          ref.refresh(entityGalleryGridProvider(filterKind, entityId).future),
      onFetchNextPage: () => ref
          .read(entityGalleryGridProvider(filterKind, entityId).notifier)
          .fetchNextPage(),
    );
  }

  GridLayoutSetting get _layoutSetting => switch (filterKind) {
    EntityGalleryFilterKind.performer => GridLayoutSetting.performerGalleries,
    EntityGalleryFilterKind.studio => GridLayoutSetting.studioGalleries,
    EntityGalleryFilterKind.tag => GridLayoutSetting.tagGalleries,
  };

  GridColumnSetting get _columnSetting => switch (filterKind) {
    EntityGalleryFilterKind.performer => GridColumnSetting.performer,
    EntityGalleryFilterKind.studio => GridColumnSetting.studio,
    EntityGalleryFilterKind.tag => GridColumnSetting.tag,
  };

  String _title(BuildContext context) => switch (filterKind) {
    EntityGalleryFilterKind.performer =>
      context.l10n.performers_galleries_title,
    EntityGalleryFilterKind.studio => context.l10n.studios_galleries_title,
    EntityGalleryFilterKind.tag => context.l10n.details_galleries,
  };
}
