import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';

part 'image_browser_context.g.dart';

/// Immutable route restriction; editable image filters cannot escape this scope.
@immutable
class ImageBrowserContext {
  const ImageBrowserContext.gallery(this.galleryId, {required this.path})
    : entityKind = null,
      entityId = null;

  const ImageBrowserContext.entity(
    this.entityKind,
    this.entityId, {
    required this.path,
  }) : galleryId = null;

  final String path;
  final String? galleryId;
  final EntityGalleryFilterKind? entityKind;
  final String? entityId;

  // Router rebuilds must not reset a live browser's filters or sort.
  @override
  bool operator ==(Object other) =>
      other is ImageBrowserContext &&
      path == other.path &&
      galleryId == other.galleryId &&
      entityKind == other.entityKind &&
      entityId == other.entityId;

  @override
  int get hashCode => Object.hash(path, galleryId, entityKind, entityId);
}

/// Null denotes the persistent top-level Images library. Detail routes override
/// this once for both their grid and fullscreen child navigator.
@Riverpod(keepAlive: true, dependencies: [])
ImageBrowserContext? imageBrowserContext(Ref ref) => null;
