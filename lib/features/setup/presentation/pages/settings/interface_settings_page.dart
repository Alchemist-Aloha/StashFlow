import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/gesture_settings_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/scrape_customization_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import '../../widgets/settings_page_shell.dart';

class InterfaceSettingsPage extends ConsumerStatefulWidget {
  const InterfaceSettingsPage({super.key});

  @override
  ConsumerState<InterfaceSettingsPage> createState() =>
      _InterfaceSettingsPageState();
}

class _InterfaceSettingsPageState extends ConsumerState<InterfaceSettingsPage> {
  static const _imageFullscreenVerticalSwipeKey =
      'image_fullscreen_vertical_swipe';

  bool _showRandomNavigation = true;
  bool _showScrapeButton = false;
  bool _sceneGridLayout = false;
  bool _sceneTiktokLayout = false;
  bool _galleryGridLayout = true;
  bool _imageFullscreenVerticalSwipe = true;

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
    final prefs = ref.read(sharedPreferencesProvider);

    _showRandomNavigation = ref.read(randomNavigationEnabledProvider);
    _showScrapeButton = ref.read(scrapeEnabledProvider);
    _sceneGridLayout = ref.read(sceneGridLayoutProvider);
    _sceneTiktokLayout = ref.read(sceneTiktokLayoutProvider);
    _galleryGridLayout = ref.read(galleryGridLayoutProvider);
    _imageFullscreenVerticalSwipe =
        prefs.getBool(_imageFullscreenVerticalSwipeKey) ?? true;

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
    final prefs = ref.read(sharedPreferencesProvider);

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

    await prefs.setBool(
      _imageFullscreenVerticalSwipeKey,
      _imageFullscreenVerticalSwipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsPageShell(
      title: 'Interface Settings',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: 'Navigation',
                    subtitle: 'Visibility of global navigation shortcuts',
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Show Random Navigation Buttons'),
                          subtitle: const Text(
                            'Enable or disable the floating casino buttons across list and details pages',
                          ),
                          value: _showRandomNavigation,
                          onChanged: (value) async {
                            setState(() => _showRandomNavigation = value);
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Shake to Discover'),
                          subtitle: const Text(
                            'Shake your device to jump to a random item in the current tab',
                          ),
                          value: ref.watch(shakeToRandomEnabledProvider),
                          onChanged: (value) {
                            ref
                                .read(shakeToRandomEnabledProvider.notifier)
                                .setShakeToRandom(value);
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              const Expanded(child: Text('Show Edit Button')),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'WIP',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Text(
                            'Enable or disable the edit button on the scene details page',
                          ),
                          value: _showScrapeButton,
                          onChanged: (value) async {
                            setState(() => _showScrapeButton = value);
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Customize Tabs'),
                          subtitle: const Text(
                            'Reorder or hide navigation menu items',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/settings/interface/navigation');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Scenes Layout',
                    subtitle: 'Default browsing mode for scenes',
                    child: _buildLayoutRow(
                      context,
                      label: 'Default Layout',
                      description:
                          'Choose the default layout for the Scenes page',
                      value: _sceneTiktokLayout
                          ? 'tiktok'
                          : (_sceneGridLayout ? 'grid' : 'list'),
                      options: const [
                        ButtonSegment<String>(
                          value: 'list',
                          label: Text('List'),
                          icon: Icon(Icons.view_list),
                        ),
                        ButtonSegment<String>(
                          value: 'grid',
                          label: Text('Grid'),
                          icon: Icon(Icons.grid_view),
                        ),
                        ButtonSegment<String>(
                          value: 'tiktok',
                          label: Text('Infinite Scroll'),
                          icon: Icon(Icons.swipe_up),
                        ),
                      ],
                      onSelected: (value) async {
                        setState(() {
                          _sceneTiktokLayout = value == 'tiktok';
                          _sceneGridLayout = value == 'grid';
                        });
                        await _saveSettings();
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Galleries Layout',
                    subtitle: 'Default browsing mode for galleries',
                    child: _buildLayoutRow(
                      context,
                      label: 'Default Layout',
                      description:
                          'Choose the default layout for the Galleries page',
                      value: _galleryGridLayout ? 'grid' : 'list',
                      options: const [
                        ButtonSegment<String>(
                          value: 'list',
                          label: Text('List'),
                          icon: Icon(Icons.view_list),
                        ),
                        ButtonSegment<String>(
                          value: 'grid',
                          label: Text('Grid'),
                          icon: Icon(Icons.grid_view),
                        ),
                      ],
                      onSelected: (value) async {
                        setState(() {
                          _galleryGridLayout = value == 'grid';
                        });
                        await _saveSettings();
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Image Viewer',
                    subtitle: 'Configure fullscreen image browsing behavior',
                    child: _buildLayoutRow(
                      context,
                      label: 'Fullscreen Swipe Direction',
                      description:
                          'Choose how images advance in fullscreen mode',
                      value: _imageFullscreenVerticalSwipe
                          ? 'vertical'
                          : 'horizontal',
                      options: const [
                        ButtonSegment<String>(
                          value: 'vertical',
                          label: Text('Vertical'),
                          icon: Icon(Icons.swap_vert_rounded),
                        ),
                        ButtonSegment<String>(
                          value: 'horizontal',
                          label: Text('Horizontal'),
                          icon: Icon(Icons.swap_horiz_rounded),
                        ),
                      ],
                      onSelected: (value) async {
                        setState(() {
                          _imageFullscreenVerticalSwipe = value == 'vertical';
                        });
                        await _saveSettings();
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Performer Layouts',
                    subtitle: 'Media and gallery defaults for performers',
                    child: Column(
                      children: [
                        _buildLayoutSetting(
                          title: 'Media Layout',
                          subtitle: 'Layout for Performer Media page',
                          currentValue: _performerMediaGridLayout,
                          onChanged: (isGrid) {
                            setState(() => _performerMediaGridLayout = isGrid);
                            _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildLayoutSetting(
                          title: 'Galleries Layout',
                          subtitle: 'Layout for Performer Galleries page',
                          currentValue: _performerGalleriesGridLayout,
                          onChanged: (isGrid) {
                            setState(() => _performerGalleriesGridLayout = isGrid);
                            _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Studio Layouts',
                    subtitle: 'Media and gallery defaults for studios',
                    child: Column(
                      children: [
                        _buildLayoutSetting(
                          title: 'Media Layout',
                          subtitle: 'Layout for Studio Media page',
                          currentValue: _studioMediaGridLayout,
                          onChanged: (isGrid) {
                            setState(() => _studioMediaGridLayout = isGrid);
                            _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildLayoutSetting(
                          title: 'Galleries Layout',
                          subtitle: 'Layout for Studio Galleries page',
                          currentValue: _studioGalleriesGridLayout,
                          onChanged: (isGrid) {
                            setState(() => _studioGalleriesGridLayout = isGrid);
                            _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Tag Layouts',
                    subtitle: 'Media and gallery defaults for tags',
                    child: Column(
                      children: [
                        _buildLayoutSetting(
                          title: 'Media Layout',
                          subtitle: 'Layout for Tag Media page',
                          currentValue: _tagMediaGridLayout,
                          onChanged: (isGrid) {
                            setState(() => _tagMediaGridLayout = isGrid);
                            _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final segments = const [
          ButtonSegment<String>(
            value: 'list',
            label: Text('List'),
            icon: Icon(Icons.view_list),
          ),
          ButtonSegment<String>(
            value: 'grid',
            label: Text('Grid'),
            icon: Icon(Icons.grid_view),
          ),
        ];

        final segmentedButton = SegmentedButton<String>(
          segments: segments,
          selected: {currentValue ? 'grid' : 'list'},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            onChanged(selection.first == 'grid');
          },
        );

        Widget control = segmentedButton;
        if (isCompact) {
          control = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: segmentedButton,
          );
        }

        if (isCompact) {
          return Column(
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
              const SizedBox(height: AppTheme.spacingMedium),
              SizedBox(width: double.infinity, child: control),
            ],
          );
        }

        return Row(
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
            Flexible(child: control),
          ],
        );
      },
    );
  }

  Widget _buildLayoutRow(
    BuildContext context, {
    required String label,
    required String description,
    required String value,
    required List<ButtonSegment<String>> options,
    required ValueChanged<String> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final segmentedButton = SegmentedButton<String>(
          segments: options,
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            onSelected(selection.first);
          },
        );

        Widget control = segmentedButton;
        if (isCompact) {
          control = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: segmentedButton,
          );
        }

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              SizedBox(width: double.infinity, child: control),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Flexible(child: control),
          ],
        );
      },
    );
  }
}
