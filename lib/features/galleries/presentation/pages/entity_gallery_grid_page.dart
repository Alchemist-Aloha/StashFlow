import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../performers/presentation/providers/performer_details_provider.dart';
import '../../../studios/presentation/providers/studio_details_provider.dart';
import '../../../tags/presentation/providers/tag_details_provider.dart';
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
      title: _title(context, ref),
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

  String _title(BuildContext context, WidgetRef ref) {
    final name = switch (filterKind) {
      EntityGalleryFilterKind.performer =>
        ref.watch(performerDetailsProvider(entityId)).value?.name,
      EntityGalleryFilterKind.studio =>
        ref.watch(studioDetailsProvider(entityId)).value?.name,
      EntityGalleryFilterKind.tag =>
        ref.watch(tagDetailsProvider(entityId)).value?.name,
    };
    return name?.trim().isNotEmpty == true
        ? name!
        : context.l10n.details_galleries;
  }
}
