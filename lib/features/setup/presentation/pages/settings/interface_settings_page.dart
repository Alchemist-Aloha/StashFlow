import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/scrape_customization_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';

class InterfaceSettingsPage extends ConsumerStatefulWidget {
  const InterfaceSettingsPage({super.key});

  @override
  ConsumerState<InterfaceSettingsPage> createState() =>
      _InterfaceSettingsPageState();
}

class _InterfaceSettingsPageState extends ConsumerState<InterfaceSettingsPage> {
  bool _showRandomNavigation = true;
  bool _showScrapeButton = false;
  bool _sceneGridLayout = false;
  bool _sceneTiktokLayout = false;
  bool _galleryGridLayout = true;

  // New settings
  bool _performerMediaGridLayout = true;
  bool _performerGalleriesGridLayout = true;
  bool _studioMediaGridLayout = true;
  bool _studioGalleriesGridLayout = true;
  bool _tagMediaGridLayout = true;
  bool _tagGalleriesGridLayout = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _showRandomNavigation = ref.read(randomNavigationEnabledProvider);
    _showScrapeButton = ref.read(scrapeEnabledProvider);
    _sceneGridLayout = ref.read(sceneGridLayoutProvider);
    _sceneTiktokLayout = ref.read(sceneTiktokLayoutProvider);
    _galleryGridLayout = ref.read(galleryGridLayoutProvider);

    _performerMediaGridLayout = ref.read(performerMediaGridLayoutProvider);
    _performerGalleriesGridLayout =
        ref.read(performerGalleriesGridLayoutProvider);
    _studioMediaGridLayout = ref.read(studioMediaGridLayoutProvider);
    _studioGalleriesGridLayout = ref.read(studioGalleriesGridLayoutProvider);
    _tagMediaGridLayout = ref.read(tagMediaGridLayoutProvider);
    _tagGalleriesGridLayout = ref.read(tagGalleriesGridLayoutProvider);

    setState(() => _loading = false);
  }

  Future<void> _saveSettings() async {
    ref
        .read(randomNavigationEnabledProvider.notifier)
        .set(_showRandomNavigation);
    ref.read(scrapeEnabledProvider.notifier).set(_showScrapeButton);
    ref.read(sceneGridLayoutProvider.notifier).set(_sceneGridLayout);
    ref.read(sceneTiktokLayoutProvider.notifier).set(_sceneTiktokLayout);
    ref.read(galleryGridLayoutProvider.notifier).set(_galleryGridLayout);

    ref
        .read(performerMediaGridLayoutProvider.notifier)
        .set(_performerMediaGridLayout);
    ref
        .read(performerGalleriesGridLayoutProvider.notifier)
        .set(_performerGalleriesGridLayout);
    ref
        .read(studioMediaGridLayoutProvider.notifier)
        .set(_studioMediaGridLayout);
    ref
        .read(studioGalleriesGridLayoutProvider.notifier)
        .set(_studioGalleriesGridLayout);
    ref.read(tagMediaGridLayoutProvider.notifier).set(_tagMediaGridLayout);
    ref
        .read(tagGalleriesGridLayoutProvider.notifier)
        .set(_tagGalleriesGridLayout);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Interface Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Navigation'),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Random Navigation Buttons'),
                    subtitle: const Text(
                      'Enable/disable the floating casino buttons across list and details pages',
                    ),
                    value: _showRandomNavigation,
                    onChanged: (value) async {
                      setState(() => _showRandomNavigation = value);
                      await _saveSettings();
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        const Expanded(child: Text('Show Edit Button')),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'WIP',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Enable/disable the edit button on scene details page',
                    ),
                    value: _showScrapeButton,
                    onChanged: (value) async {
                      setState(() => _showScrapeButton = value);
                      await _saveSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Scenes Layout'),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingSmall,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Default Layout',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choose the default layout for the Scenes page',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        DropdownMenu<String>(
                          initialSelection: _sceneTiktokLayout
                              ? 'tiktok'
                              : (_sceneGridLayout ? 'grid' : 'list'),
                          onSelected: (String? value) async {
                            if (value == null) return;
                            setState(() {
                              _sceneTiktokLayout = value == 'tiktok';
                              _sceneGridLayout = value == 'grid';
                            });
                            await _saveSettings();
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry<String>(
                              value: 'list',
                              label: 'List',
                              leadingIcon: Icon(Icons.view_list),
                            ),
                            DropdownMenuEntry<String>(
                              value: 'grid',
                              label: 'Grid',
                              leadingIcon: Icon(Icons.grid_view),
                            ),
                            DropdownMenuEntry<String>(
                              value: 'tiktok',
                              label: 'Infinite Scroll',
                              leadingIcon: Icon(Icons.swipe_up),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Galleries Layout'),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingSmall,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Default Layout',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choose the default layout for the Galleries page',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        DropdownMenu<String>(
                          initialSelection: _galleryGridLayout ? 'grid' : 'list',
                          onSelected: (String? value) async {
                            if (value == null) return;
                            setState(() {
                              _galleryGridLayout = value == 'grid';
                            });
                            await _saveSettings();
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry<String>(
                              value: 'list',
                              label: 'List',
                              leadingIcon: Icon(Icons.view_list),
                            ),
                            DropdownMenuEntry<String>(
                              value: 'grid',
                              label: 'Grid',
                              leadingIcon: Icon(Icons.grid_view),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Performer Layouts'),
                  _buildLayoutSetting(
                    title: 'Media Layout',
                    subtitle: 'Layout for Performer Media page',
                    currentValue: _performerMediaGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _performerMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                  ),
                  _buildLayoutSetting(
                    title: 'Galleries Layout',
                    subtitle: 'Layout for Performer Galleries page',
                    currentValue: _performerGalleriesGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _performerGalleriesGridLayout = isGrid);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Studio Layouts'),
                  _buildLayoutSetting(
                    title: 'Media Layout',
                    subtitle: 'Layout for Studio Media page',
                    currentValue: _studioMediaGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _studioMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                  ),
                  _buildLayoutSetting(
                    title: 'Galleries Layout',
                    subtitle: 'Layout for Studio Galleries page',
                    currentValue: _studioGalleriesGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _studioGalleriesGridLayout = isGrid);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Tag Layouts'),
                  _buildLayoutSetting(
                    title: 'Media Layout',
                    subtitle: 'Layout for Tag Media page',
                    currentValue: _tagMediaGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _tagMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                  ),
                  _buildLayoutSetting(
                    title: 'Galleries Layout',
                    subtitle: 'Layout for Tag Galleries page',
                    currentValue: _tagGalleriesGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _tagGalleriesGridLayout = isGrid);
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLayoutSetting({
    required String title,
    required String subtitle,
    required bool currentValue,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          DropdownMenu<String>(
            initialSelection: currentValue ? 'grid' : 'list',
            onSelected: (String? value) {
              if (value == null) return;
              onChanged(value == 'grid');
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry<String>(
                value: 'list',
                label: 'List',
                leadingIcon: Icon(Icons.view_list),
              ),
              DropdownMenuEntry<String>(
                value: 'grid',
                label: 'Grid',
                leadingIcon: Icon(Icons.grid_view),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
