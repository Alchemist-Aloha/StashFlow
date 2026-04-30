import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../../../../core/data/cache/app_cache_service.dart';
import '../../../../../core/data/cache/cache_state_provider.dart';
import '../../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../widgets/settings_page_shell.dart';
import '../../../../../core/utils/l10n_extensions.dart';

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
                    title: Text(context.l10n.settings_storage_images),
                    trailing: Text(context.l10n.settings_storage_mb(sizes.imageMb)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final l10n = context.l10n;
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(l10n.settings_storage_clearing_image)),
                              );
                              try {
                                await service.clearImageCache();
                                ref.invalidate(cacheSizesProvider);
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(l10n.settings_storage_cleared_image)),
                                );
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(l10n.common_error(e.toString()))),
                                );
                              }
                            },
                            child: Text(context.l10n.settings_storage_clear),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.settings_storage_videos),
                    trailing: Text(context.l10n.settings_storage_mb(sizes.videoMb)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final l10n = context.l10n;
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(l10n.settings_storage_clearing_video)),
                              );
                              try {
                                await service.clearVideoCache();
                                ref.invalidate(cacheSizesProvider);
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(l10n.settings_storage_cleared_video)),
                                );
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(l10n.common_error(e.toString()))),
                                );
                              }
                            },
                            child: Text(context.l10n.settings_storage_clear),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.settings_storage_database),
                    trailing: Text(context.l10n.settings_storage_mb(sizes.dbMb)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final l10n = context.l10n;
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(l10n.settings_storage_clearing_database)),
                              );
                              try {
                                await service.clearDatabaseCache();
                                ref.invalidate(cacheSizesProvider);
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(l10n.settings_storage_cleared_database)),
                                );
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(l10n.common_error(e.toString()))),
                                );
                              }
                            },
                            child: Text(context.l10n.settings_storage_clear),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text(context.l10n.settings_storage_error_loading),
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
