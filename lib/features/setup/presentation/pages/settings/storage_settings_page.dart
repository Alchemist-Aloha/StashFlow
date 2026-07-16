import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../../../../core/data/cache/app_cache_service.dart';
import '../../../../../core/data/cache/cache_state_provider.dart';
import '../../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../../core/data/app_config/app_config_providers.dart';
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
      title: context.l10n.settings_storage,
      child: SettingsPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AppConfigBackupSection(),
            SettingsSectionCard(
              title: context.l10n.settings_storage_usage,
              subtitle: context.l10n.settings_storage_usage_subtitle,
              child: sizesAsync.when(
                data: (sizes) => Column(
                  children: [
                    ListTile(
                      title: Text(context.l10n.settings_storage_images),
                      trailing: Text(
                        context.l10n.settings_storage_mb(sizes.imageMb),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final l10n = context.l10n;
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.settings_storage_clearing_image,
                                    ),
                                  ),
                                );
                                try {
                                  await service.clearImageCache();
                                  ref.invalidate(cacheSizesProvider);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.settings_storage_cleared_image,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.common_error(e.toString()),
                                      ),
                                    ),
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
                      trailing: Text(
                        context.l10n.settings_storage_mb(sizes.videoMb),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final l10n = context.l10n;
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.settings_storage_clearing_video,
                                    ),
                                  ),
                                );
                                try {
                                  await service.clearVideoCache();
                                  ref.invalidate(cacheSizesProvider);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.settings_storage_cleared_video,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.common_error(e.toString()),
                                      ),
                                    ),
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
                      trailing: Text(
                        context.l10n.settings_storage_mb(sizes.dbMb),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final l10n = context.l10n;
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.settings_storage_clearing_database,
                                    ),
                                  ),
                                );
                                try {
                                  await service.clearDatabaseCache();
                                  ref.invalidate(cacheSizesProvider);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.settings_storage_cleared_database,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.common_error(e.toString()),
                                      ),
                                    ),
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
                error: (err, stack) =>
                    Text(context.l10n.settings_storage_error_loading),
              ),
            ),
            SettingsSectionCard(
              title: context.l10n.settings_storage_limits,
              subtitle: context.l10n.settings_storage_limits_subtitle,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: ref.watch(maxImageCacheSizeProvider),
                    decoration: InputDecoration(
                      labelText: context.l10n.settings_storage_max_image_cache,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 100,
                        child: Text(context.l10n.settings_storage_100_mb),
                      ),
                      DropdownMenuItem(
                        value: 500,
                        child: Text(context.l10n.settings_storage_500_mb),
                      ),
                      DropdownMenuItem(
                        value: 1024,
                        child: Text(context.l10n.settings_storage_1_gb),
                      ),
                      DropdownMenuItem(
                        value: 999999,
                        child: Text(context.l10n.settings_storage_unlimited),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        prefs.setInt('max_image_cache_size_mb', v);
                        ref.invalidate(maxImageCacheSizeProvider);
                        service.enforceImageCacheLimit(v).then((_) {
                          ref.invalidate(cacheSizesProvider);
                        });
                      }
                    },
                  ),
                  SizedBox(height: context.dimensions.spacingMedium),
                  DropdownButtonFormField<int>(
                    initialValue: ref.watch(maxVideoCacheSizeProvider),
                    decoration: InputDecoration(
                      labelText: context.l10n.settings_storage_max_video_cache,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 500,
                        child: Text(context.l10n.settings_storage_500_mb),
                      ),
                      DropdownMenuItem(
                        value: 1024,
                        child: Text(context.l10n.settings_storage_1_gb),
                      ),
                      DropdownMenuItem(
                        value: 2048,
                        child: Text(context.l10n.settings_storage_2_gb),
                      ),
                      DropdownMenuItem(
                        value: 999999,
                        child: Text(context.l10n.settings_storage_unlimited),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        prefs.setInt('max_video_cache_size_mb', v);
                        ref.invalidate(maxVideoCacheSizeProvider);
                        service.enforceVideoCacheLimit(v).then((_) {
                          ref.invalidate(cacheSizesProvider);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppConfigBackupSection extends ConsumerStatefulWidget {
  const _AppConfigBackupSection();

  @override
  ConsumerState<_AppConfigBackupSection> createState() =>
      _AppConfigBackupSectionState();
}

class _AppConfigBackupSectionState
    extends ConsumerState<_AppConfigBackupSection> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: context.l10n.settings_config_backup_title,
      subtitle: context.l10n.settings_config_backup_subtitle,
      child: Wrap(
        spacing: context.dimensions.spacingSmall,
        runSpacing: context.dimensions.spacingSmall,
        children: [
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.save_alt),
            label: Text(context.l10n.settings_config_export),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.file_open),
            label: Text(context.l10n.settings_config_import),
          ),
          if (_busy)
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    var includeCredentials = false;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.settings_config_export),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: includeCredentials,
                title: Text(context.l10n.settings_config_include_credentials),
                onChanged: (value) =>
                    setDialogState(() => includeCredentials = value ?? false),
              ),
              if (includeCredentials)
                Text(
                  context.l10n.settings_config_credentials_warning,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.settings_config_export),
            ),
          ],
        ),
      ),
    );
    if (proceed != true || !mounted) return;
    await _run(() async {
      final service = await ref.read(appConfigServiceProvider.future);
      final bytes = await service.export(
        includeCredentials: includeCredentials,
      );
      if (!mounted) return;
      final date = DateTime.now().toIso8601String().split('T').first;
      final box = context.findRenderObject() as RenderBox?;
      final exported = await ref
          .read(appConfigDocumentServiceProvider)
          .export(
            bytes,
            fileName: 'stashflow-config-$date.json',
            sharePositionOrigin: box == null
                ? null
                : box.localToGlobal(Offset.zero) & box.size,
          );
      if (exported && mounted) _message(context.l10n.settings_config_exported);
    });
  }

  Future<void> _import() async {
    await _run(() async {
      final bytes = await ref
          .read(appConfigDocumentServiceProvider)
          .pickForImport();
      if (bytes == null || !mounted) return;
      final service = await ref.read(appConfigServiceProvider.future);
      final backup = service.preview(bytes);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.settings_config_import_title),
          content: Text(
            context.l10n.settings_config_import_summary(
              backup.serverProfiles.length,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.settings_config_import_confirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await service.replace(backup);
      ref.invalidate(appConfigServiceProvider);
      if (mounted) _message(context.l10n.settings_config_imported);
    });
  }

  Future<void> _run(Future<void> Function() operation) async {
    setState(() => _busy = true);
    try {
      await operation();
    } catch (_) {
      if (mounted) _message(context.l10n.settings_config_invalid);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
