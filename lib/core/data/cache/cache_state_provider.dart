import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_cache_service.dart';

typedef CacheSizes = ({int imageMb, int videoMb, int dbMb});

final cacheSizesProvider = FutureProvider<CacheSizes>((ref) async {
  final service = ref.watch(appCacheServiceProvider);
  final img = await service.getImageCacheSizeMb();
  final vid = await service.getVideoCacheSizeMb();
  final db = await service.getDatabaseCacheSizeMb();
  return (imageMb: img, videoMb: vid, dbMb: db);
});
