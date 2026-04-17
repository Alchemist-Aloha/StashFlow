import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/gesture_settings_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/scrape_customization_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
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

  int? _sceneGridColumns;
  int? _galleryGridColumns;
  int? _performerGridColumns;
  int? _imageGridColumns;
  int? _studioGridColumns;
  int? _tagGridColumns;

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

    _sceneGridColumns = ref.read(sceneGridColumnsProvider);
    _galleryGridColumns = ref.read(galleryGridColumnsProvider);
    _performerGridColumns = ref.read(performerGridColumnsProvider);
    _imageGridColumns = ref.read(imageGridColumnsProvider);
    _studioGridColumns = ref.read(studioGridColumnsProvider);
    _tagGridColumns = ref.read(tagGridColumnsProvider);

    _performerMediaGridLayout = ref.read(performerMediaGridLayoutProvider);
    _performerGalleriesGridLayout = ref.read(
      performerGalleriesGridLayoutProvider,
    );
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

    ref.read(sceneGridColumnsProvider.notifier).set(_sceneGridColumns);
    ref.read(galleryGridColumnsProvider.notifier).set(_galleryGridColumns);
    ref.read(performerGridColumnsProvider.notifier).set(_performerGridColumns);
    ref.read(imageGridColumnsProvider.notifier).set(_imageGridColumns);
    ref.read(studioGridColumnsProvider.notifier).set(_studioGridColumns);
    ref.read(tagGridColumnsProvider.notifier).set(_tagGridColumns);

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
      title: context.l10n.settings_interface_title,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: 'Language',
                    subtitle: 'Overwrite the default system language',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'App Language',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String?>(
                              value:
                                  ref.watch(appLanguageProvider)?.toString() ??
                                  (ref
                                      .watch(sharedPreferencesProvider)
                                      .getString(appLanguagePreferenceKey)),
                              dropdownColor: colorScheme.surface,
                              items: supportedLanguages.entries.map((entry) {
                                return DropdownMenuItem<String?>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                await ref
                                    .read(appLanguageProvider.notifier)
                                    .setLanguage(value);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_interface_navigation,
                    subtitle: context.l10n.settings_interface_navigation_subtitle,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.settings_interface_show_random),
                          subtitle: Text(context.l10n.settings_interface_show_random_subtitle),
                          value: _showRandomNavigation,
                          onChanged: (value) async {
                            setState(() => _showRandomNavigation = value);
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.settings_interface_shake_random),
                          subtitle: Text(context.l10n.settings_interface_shake_random_subtitle),
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
                              Expanded(child: Text(context.l10n.settings_interface_show_edit)),
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
                          subtitle: Text(context.l10n.settings_interface_show_edit_subtitle),
                          value: _showScrapeButton,
                          onChanged: (value) async {
                            setState(() => _showScrapeButton = value);
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.settings_interface_customize_tabs),
                          subtitle: Text(context.l10n.settings_interface_customize_tabs_subtitle),
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
                    child: Column(
                      children: [
                        _buildLayoutRow(
                          context,
                          label: context.l10n.settings_interface_layout_default,
                          description:
                              context.l10n.settings_interface_layout_default_desc,
                          value: _sceneTiktokLayout
                              ? 'tiktok'
                              : (_sceneGridLayout ? 'grid' : 'list'),
                          options: [
                            ButtonSegment<String>(
                              value: 'list',
                              label: Text(context.l10n.settings_interface_layout_list),
                              icon: Icon(Icons.view_list),
                            ),
                            ButtonSegment<String>(
                              value: 'grid',
                              label: Text(context.l10n.settings_interface_layout_grid),
                              icon: Icon(Icons.grid_view),
                            ),
                            ButtonSegment<String>(
                              value: 'tiktok',
                              label: Text(context.l10n.settings_interface_layout_tiktok),
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
                        if (_sceneGridLayout) ...[
                          const Divider(height: AppTheme.spacingLarge),
                          _buildGridColumnSetting(
                            label: 'Grid Columns',
                            value: _sceneGridColumns,
                            onChanged: (value) async {
                              setState(() => _sceneGridColumns = value);
                              await _saveSettings();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Galleries Layout',
                    subtitle: 'Default browsing mode for galleries',
                    child: Column(
                      children: [
                        _buildLayoutRow(
                          context,
                          label: 'Default Layout',
                          description:
                              'Choose the default layout for the Galleries page',
                          value: _galleryGridLayout ? 'grid' : 'list',
                          options: [
                            ButtonSegment<String>(
                              value: 'list',
                              label: Text(context.l10n.settings_interface_layout_list),
                              icon: Icon(Icons.view_list),
                            ),
                            ButtonSegment<String>(
                              value: 'grid',
                              label: Text(context.l10n.settings_interface_layout_grid),
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
                        if (_galleryGridLayout) ...[
                          const Divider(height: AppTheme.spacingLarge),
                          _buildGridColumnSetting(
                            label: 'Grid Columns',
                            value: _galleryGridColumns,
                            onChanged: (value) async {
                              setState(() => _galleryGridColumns = value);
                              await _saveSettings();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Image Viewer',
                    subtitle: 'Configure fullscreen image browsing behavior',
                    child: Column(
                      children: [
                        _buildLayoutRow(
                          context,
                          label: 'Fullscreen Swipe Direction',
                          description:
                              'Choose how images advance in fullscreen mode',
                          value: _imageFullscreenVerticalSwipe
                              ? 'vertical'
                              : 'horizontal',
                          options: [
                            ButtonSegment<String>(
                              value: 'vertical',
                              label: Text(context.l10n.settings_interface_swipe_vertical),
                              icon: Icon(Icons.swap_vert_rounded),
                            ),
                            ButtonSegment<String>(
                              value: 'horizontal',
                              label: Text(context.l10n.settings_interface_swipe_horizontal),
                              icon: Icon(Icons.swap_horiz_rounded),
                            ),
                          ],
                          onSelected: (value) async {
                            setState(() {
                              _imageFullscreenVerticalSwipe =
                                  value == 'vertical';
                            });
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildGridColumnSetting(
                          label: 'Waterfall Grid Columns',
                          value: _imageGridColumns,
                          onChanged: (value) async {
                            setState(() => _imageGridColumns = value);
                            await _saveSettings();
                          },
                        ),
                      ],
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
                            setState(
                              () => _performerGalleriesGridLayout = isGrid,
                            );
                            _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildGridColumnSetting(
                          label: 'Grid Columns',
                          value: _performerGridColumns,
                          onChanged: (value) async {
                            setState(() => _performerGridColumns = value);
                            await _saveSettings();
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
                        const Divider(height: AppTheme.spacingLarge),
                        _buildGridColumnSetting(
                          label: 'Grid Columns',
                          value: _studioGridColumns,
                          onChanged: (value) async {
                            setState(() => _studioGridColumns = value);
                            await _saveSettings();
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
                        const Divider(height: AppTheme.spacingLarge),
                        _buildGridColumnSetting(
                          label: 'Grid Columns',
                          value: _tagGridColumns,
                          onChanged: (value) async {
                            setState(() => _tagGridColumns = value);
                            await _saveSettings();
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

  Widget _buildGridColumnSetting({
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        DropdownButton<int?>(
          value: value,
          dropdownColor: colorScheme.surface,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(l10n.common_default),
            ),
            ...List.generate(10, (index) => index + 1).map(
              (i) =>
                  DropdownMenuItem<int?>(value: i, child: Text(i.toString())),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
