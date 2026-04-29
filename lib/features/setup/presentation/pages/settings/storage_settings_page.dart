import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../../../../core/data/cache/app_cache_service.dart';
import '../../../../../core/data/cache/cache_state_provider.dart';
import '../../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../widgets/settings_page_shell.dart';

class StorageSettingsPage extends ConsumerWidget {
  const StorageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizesAsync = ref.watch(cacheSizesProvider);
    final service = ref.watch(appCacheServiceProvider);
    final prefs = ref.watch(sharedPreferencesProvider);

    return SettingsPageShell(
      title: 'Storage & Cache',
      child: ListView(
        padding: EdgeInsets.all(context.dimensions.spacingLarge),
        children: [
          SettingsSectionCard(
            title: 'Storage Usage',
            subtitle: 'Current space used by caches',
            child: sizesAsync.when(
              data: (sizes) => Column(
                children: [
                  ListTile(
                    title: const Text('Images'),
                    trailing: Text('${sizes.imageMb} MB'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await service.clearImageCache();
                              ref.invalidate(cacheSizesProvider);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Videos'),
                    trailing: Text('${sizes.videoMb} MB'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await service.clearVideoCache();
                              ref.invalidate(cacheSizesProvider);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Database'),
                    trailing: Text('${sizes.dbMb} MB'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await service.clearDatabaseCache();
                              ref.invalidate(cacheSizesProvider);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Error loading sizes'),
            ),
          ),
          SizedBox(height: context.dimensions.spacingMedium),
          SettingsSectionCard(
            title: 'Limits',
            subtitle: 'Set maximum cache sizes',
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  initialValue: ref.watch(maxImageCacheSizeProvider),
                  decoration: const InputDecoration(labelText: 'Max Image Cache (MB)'),
                  items: const [
                    DropdownMenuItem(value: 100, child: Text('100 MB')),
                    DropdownMenuItem(value: 500, child: Text('500 MB')),
                    DropdownMenuItem(value: 1024, child: Text('1 GB')),
                    DropdownMenuItem(value: 999999, child: Text('Unlimited')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      prefs.setInt('max_image_cache_size_mb', v);
                      ref.invalidate(maxImageCacheSizeProvider);
                    }
                  },
                ),
                SizedBox(height: context.dimensions.spacingMedium),
                DropdownButtonFormField<int>(
                  initialValue: ref.watch(maxVideoCacheSizeProvider),
                  decoration: const InputDecoration(labelText: 'Max Video Cache (MB)'),
                  items: const [
                    DropdownMenuItem(value: 500, child: Text('500 MB')),
                    DropdownMenuItem(value: 1024, child: Text('1 GB')),
                    DropdownMenuItem(value: 2048, child: Text('2 GB')),
                    DropdownMenuItem(value: 999999, child: Text('Unlimited')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      prefs.setInt('max_video_cache_size_mb', v);
                      ref.invalidate(maxVideoCacheSizeProvider);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
