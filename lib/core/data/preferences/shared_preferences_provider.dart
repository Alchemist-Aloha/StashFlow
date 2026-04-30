import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final maxImageCacheSizeProvider = Provider<int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt('max_image_cache_size_mb') ?? 500; // Default 500 MB
});

final maxVideoCacheSizeProvider = Provider<int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt('max_video_cache_size_mb') ?? 1024; // Default 1 GB
});
