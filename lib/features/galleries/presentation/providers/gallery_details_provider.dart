import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../../images/domain/entities/image.dart' as entity;
import '../../../images/presentation/providers/image_list_provider.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/domain/entities/scene_filter.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';
import '../../../../core/domain/entities/criterion.dart';
import 'gallery_list_provider.dart';

part 'gallery_details_provider.g.dart';

@riverpod
FutureOr<Gallery> galleryDetails(Ref ref, String id) async {
  final repository = ref.watch(galleryRepositoryProvider);
  return repository.getGalleryById(id);
}

/// Loads the first gallery image page for the relationship tab.
@riverpod
FutureOr<List<entity.Image>> galleryImages(Ref ref, String id) async {
  ref.keepAlive();
  return ref
      .read(imageRepositoryProvider)
      .findImages(page: 1, perPage: 48, sort: 'path', galleryId: id);
}

/// Loads scenes linked to a gallery for the relationship tab.
@riverpod
FutureOr<List<Scene>> galleryScenes(Ref ref, String id) async {
  ref.keepAlive();
  return ref
      .read(sceneRepositoryProvider)
      .findScenes(
        page: 1,
        perPage: 24,
        sceneFilter: SceneFilter(galleries: MultiCriterion(value: [id])),
      );
}

/// Loads galleries linked to a scene for the scene details strip.
@riverpod
FutureOr<List<Gallery>> sceneGalleries(Ref ref, String sceneId) async {
  ref.keepAlive();
  return ref
      .read(galleryRepositoryProvider)
      .findGalleries(
        page: 1,
        perPage: 24,
        galleryFilter: GalleryFilter(scenes: MultiCriterion(value: [sceneId])),
      );
}
