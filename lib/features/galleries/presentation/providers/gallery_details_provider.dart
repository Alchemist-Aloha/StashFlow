import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/gallery.dart';
import 'gallery_list_provider.dart';

part 'gallery_details_provider.g.dart';

@riverpod
FutureOr<Gallery> galleryDetails(Ref ref, String id) async {
  final repository = ref.watch(galleryRepositoryProvider);
  return repository.getGalleryById(id);
}
