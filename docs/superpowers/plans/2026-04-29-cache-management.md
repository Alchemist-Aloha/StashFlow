# Cache Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a centralized `AppCacheService` to manage image, video, and database caches, and expose these controls via a new `StorageSettingsPage`.

**Architecture:** A Riverpod-backed `AppCacheService` will calculate sizes for `flutter_cache_manager`, `extended_image`, `media_kit`, and `Hive`. It will prune files according to user-configurable limits stored in SharedPreferences. A new settings page will allow users to manually clear these caches and set limits.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, flutter_cache_manager, extended_image, media_kit, Hive

---

### Task 1: Add Cache Size Preferences

**Files:**
- Modify: `lib/core/data/preferences/shared_preferences_provider.dart`

- [ ] **Step 1: Define preference providers**

Append the following providers to `lib/core/data/preferences/shared_preferences_provider.dart`:

```dart
final maxImageCacheSizeProvider = Provider<int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt('max_image_cache_size_mb') ?? 500; // Default 500 MB
});

final maxVideoCacheSizeProvider = Provider<int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt('max_video_cache_size_mb') ?? 1024; // Default 1 GB
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/data/preferences/shared_preferences_provider.dart
git commit -m "feat(settings): add cache size preferences"
```

### Task 2: Create AppCacheService

**Files:**
- Create: `lib/core/data/cache/app_cache_service.dart`

- [ ] **Step 1: Write `AppCacheService`**

Create `lib/core/data/cache/app_cache_service.dart`:

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:extended_image/extended_image.dart' as extended_image;
import '../graphql/graphql_client.dart';
import '../../presentation/widgets/stash_image.dart';

final appCacheServiceProvider = Provider<AppCacheService>((ref) {
  return AppCacheService();
});

class AppCacheService {
  AppCacheService();

  Future<int> _calculateDirSize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (_) {}
    return size;
  }

  Future<int> getImageCacheSizeMb() async {
    int bytes = 0;
    // extended_image cache size
    final extCacheDir = Directory(p.join((await getTemporaryDirectory()).path, 'cache'));
    bytes += await _calculateDirSize(extCacheDir);
    
    // flutter_cache_manager (StashImage) size (approximate by looking at its default folder)
    final stashImageDir = Directory(p.join((await getTemporaryDirectory()).path, 'stashImageCache'));
    bytes += await _calculateDirSize(stashImageDir);

    return bytes ~/ (1024 * 1024);
  }

  Future<int> getVideoCacheSizeMb() async {
    final tempDir = await getTemporaryDirectory();
    // media_kit usually creates temp files in system temp dir
    int bytes = 0;
    try {
      await for (final entity in tempDir.list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.mkv')) { // Common media_kit extension or logic
          bytes += await entity.length();
        }
      }
    } catch (_) {}
    return bytes ~/ (1024 * 1024);
  }

  Future<int> getDatabaseCacheSizeMb() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    return (await _calculateDirSize(hiveDir)) ~/ (1024 * 1024);
  }

  Future<void> clearImageCache() async {
    await StashImage.cacheManager.emptyCache();
    extended_image.clearMemoryImageCache();
    await extended_image.clearDiskCachedImages();
  }

  Future<void> clearVideoCache() async {
    final tempDir = await getTemporaryDirectory();
    try {
      await for (final entity in tempDir.list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.mkv')) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> clearDatabaseCache() async {
    // Requires restarting GraphQL client or manual hive clear
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(p.join(appDir.path, 'stash_hive'));
    if (await hiveDir.exists()) {
      try {
        await hiveDir.delete(recursive: true);
      } catch (_) {}
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/data/cache/app_cache_service.dart
git commit -m "feat(cache): implement AppCacheService"
```

### Task 3: Expose Cache State Providers

**Files:**
- Create: `lib/core/data/cache/cache_state_provider.dart`

- [ ] **Step 1: Write `CacheStateProvider`**

Create `lib/core/data/cache/cache_state_provider.dart`:

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/data/cache/cache_state_provider.dart
git commit -m "feat(cache): add cacheSizesProvider"
```

### Task 4: Create StorageSettingsPage

**Files:**
- Create: `lib/features/setup/presentation/pages/settings/storage_settings_page.dart`

- [ ] **Step 1: Write `StorageSettingsPage`**

Create `lib/features/setup/presentation/pages/settings/storage_settings_page.dart`:

```dart
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
                    subtitle: ElevatedButton(
                      onPressed: () async {
                        await service.clearImageCache();
                        ref.invalidate(cacheSizesProvider);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  ListTile(
                    title: const Text('Videos'),
                    trailing: Text('${sizes.videoMb} MB'),
                    subtitle: ElevatedButton(
                      onPressed: () async {
                        await service.clearVideoCache();
                        ref.invalidate(cacheSizesProvider);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  ListTile(
                    title: const Text('Database'),
                    trailing: Text('${sizes.dbMb} MB'),
                    subtitle: ElevatedButton(
                      onPressed: () async {
                        await service.clearDatabaseCache();
                        ref.invalidate(cacheSizesProvider);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading sizes'),
            ),
          ),
          SizedBox(height: context.dimensions.spacingMedium),
          SettingsSectionCard(
            title: 'Limits',
            subtitle: 'Set maximum cache sizes',
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: ref.watch(maxImageCacheSizeProvider),
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
                DropdownButtonFormField<int>(
                  value: ref.watch(maxVideoCacheSizeProvider),
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/setup/presentation/pages/settings/storage_settings_page.dart
git commit -m "feat(settings): add StorageSettingsPage"
```

### Task 5: Add StorageSettingsPage to Router & Hub

**Files:**
- Modify: `lib/features/navigation/presentation/router.dart`
- Modify: `lib/features/setup/presentation/pages/settings/settings_hub_page.dart`

- [ ] **Step 1: Add to Router**

Update `lib/features/navigation/presentation/router.dart`. Find the `GoRoute` entries under `/settings` and add:

```dart
          GoRoute(
            path: 'storage',
            builder: (context, state) => const StorageSettingsPage(),
          ),
```
*(Ensure you import `../../setup/presentation/pages/settings/storage_settings_page.dart` at the top of the file.)*

- [ ] **Step 2: Add to Settings Hub**

Modify `lib/features/setup/presentation/pages/settings/settings_hub_page.dart` inside the `SettingsSectionCard` children list:

```dart
                SettingsActionCard(
                  icon: Icons.storage_rounded,
                  title: 'Storage & Cache',
                  subtitle: 'Manage local caches and storage limits',
                  onTap: () => context.push('/settings/storage'),
                ),
                SizedBox(height: context.dimensions.spacingMedium),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/navigation/presentation/router.dart lib/features/setup/presentation/pages/settings/settings_hub_page.dart
git commit -m "feat(settings): link storage settings in router and hub"
```
