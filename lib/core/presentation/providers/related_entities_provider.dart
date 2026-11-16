import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/criterion.dart';
import '../../../features/groups/domain/entities/group_filter.dart';
import '../../../features/groups/presentation/providers/group_list_provider.dart';
import '../../../features/performers/domain/entities/performer_filter.dart';
import '../../../features/performers/presentation/providers/performer_list_provider.dart';
import '../../../features/scenes/domain/entities/scene_marker.dart';
import '../../../features/scenes/presentation/providers/scene_marker_list_provider.dart';
import '../../../features/studios/domain/entities/studio_filter.dart';
import '../../../features/studios/presentation/providers/studio_list_provider.dart';

/// Entity types a details page can list as related.
enum RelatedEntityKind { performers, studios, groups, markers }

/// Entity types a related list can be filtered by.
enum RelatedEntityOwner { tag, studio, performer }

/// One row in a related-entity list, ready to render and navigate.
typedef RelatedEntity = ({
  String id,
  String title,
  String? subtitle,
  String? imagePath,
  String route,
});

/// Which related entities to load: [kind] linked to the [owner] entity [id].
typedef RelatedEntityQuery = ({
  RelatedEntityKind kind,
  RelatedEntityOwner owner,
  String id,
});

/// Maximum rows a details page shows for one related list.
const relatedEntityLimit = 24;

/// Loads up to [relatedEntityLimit] related entities, most scenes first.
///
/// Performers related to a performer are the ones who appear with them.
final relatedEntitiesProvider = FutureProvider.autoDispose
    .family<List<RelatedEntity>, RelatedEntityQuery>((ref, query) async {
      final id = query.id;
      final hierarchical = HierarchicalMultiCriterion(value: [id]);
      final multi = MultiCriterion(value: [id]);
      switch (query.kind) {
        case RelatedEntityKind.performers:
          final performers = await ref
              .watch(performerRepositoryProvider)
              .findPerformers(
                perPage: relatedEntityLimit,
                sort: 'scenes_count',
                performerFilter: switch (query.owner) {
                  RelatedEntityOwner.tag => PerformerFilter(
                    tags: hierarchical,
                  ),
                  RelatedEntityOwner.studio => PerformerFilter(
                    studios: hierarchical,
                  ),
                  RelatedEntityOwner.performer => PerformerFilter(
                    performers: multi,
                  ),
                },
              );
          return [
            for (final p in performers)
              if (p.id != id)
                (
                  id: p.id,
                  title: p.name,
                  subtitle: p.disambiguation,
                  imagePath: p.imagePath,
                  route: '/performers/performer/${p.id}',
                ),
          ];
        case RelatedEntityKind.studios:
          final studios = await ref
              .watch(studioRepositoryProvider)
              .findStudios(
                perPage: relatedEntityLimit,
                sort: 'scenes_count',
                descending: true,
                studioFilter: StudioFilter(tags: hierarchical),
              );
          return [
            for (final s in studios)
              (
                id: s.id,
                title: s.name,
                subtitle: null,
                imagePath: s.imagePath,
                route: '/studios/studio/${s.id}',
              ),
          ];
        case RelatedEntityKind.groups:
          final groups = await ref
              .watch(groupRepositoryProvider)
              .findGroups(
                perPage: relatedEntityLimit,
                sort: 'scenes_count',
                descending: true,
                groupFilter: switch (query.owner) {
                  RelatedEntityOwner.tag => GroupFilter(tags: hierarchical),
                  RelatedEntityOwner.studio => GroupFilter(
                    studios: hierarchical,
                  ),
                  RelatedEntityOwner.performer => GroupFilter(
                    performers: multi,
                  ),
                },
              );
          return [
            for (final g in groups)
              (
                id: g.id,
                title: g.name,
                subtitle: g.date,
                imagePath: g.frontImagePath,
                route: '/groups/group/${g.id}',
              ),
          ];
        case RelatedEntityKind.markers:
          final markers = await ref
              .watch(sceneMarkerRepositoryProvider)
              .findSceneMarkers(
                perPage: relatedEntityLimit,
                sort: 'created_at',
                filter: SceneMarkerFilter(tags: hierarchical),
              );
          return [
            for (final m in markers)
              (
                id: m.id,
                title: m.title.isEmpty ? (m.primaryTagName ?? '') : m.title,
                subtitle: m.sceneTitle,
                imagePath: m.screenshot,
                route: '/scenes/scene/${m.sceneId}',
              ),
          ];
      }
    });
