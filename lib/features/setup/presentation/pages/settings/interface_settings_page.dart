import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/main_page_orientation_provider.dart';
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
  bool _mainPageGravityOrientation = true;
  bool _imageFullscreenVerticalSwipe = true;

  int? _sceneGridColumns;
  int? _galleryGridColumns;
  int? _performerGridColumns;
  int? _imageGridColumns;
  int? _studioGridColumns;
  int? _tagGridColumns;

  double? _cardTitleFontSize;

  int _maxPerformerAvatars = 3;
  bool _showPerformerAvatars = true;
  double _performerAvatarSize = 16.0;

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
    _mainPageGravityOrientation = ref.read(mainPageGravityOrientationProvider);
    _imageFullscreenVerticalSwipe =
        prefs.getBool(_imageFullscreenVerticalSwipeKey) ?? true;

    _sceneGridColumns = ref.read(sceneGridColumnsProvider);
    _galleryGridColumns = ref.read(galleryGridColumnsProvider);
    _performerGridColumns = ref.read(performerGridColumnsProvider);
    _imageGridColumns = ref.read(imageGridColumnsProvider);
    _studioGridColumns = ref.read(studioGridColumnsProvider);
    _tagGridColumns = ref.read(tagGridColumnsProvider);

    _cardTitleFontSize = ref.read(cardTitleFontSizeProvider);

    _maxPerformerAvatars = ref.read(maxPerformerAvatarsProvider);
    _showPerformerAvatars = ref.read(showPerformerAvatarsProvider);
    _performerAvatarSize = ref.read(performerAvatarSizeProvider);

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
    ref
        .read(mainPageGravityOrientationProvider.notifier)
        .set(_mainPageGravityOrientation);

    ref.read(sceneGridColumnsProvider.notifier).set(_sceneGridColumns);
    ref.read(galleryGridColumnsProvider.notifier).set(_galleryGridColumns);
    ref.read(performerGridColumnsProvider.notifier).set(_performerGridColumns);
    ref.read(imageGridColumnsProvider.notifier).set(_imageGridColumns);
    ref.read(studioGridColumnsProvider.notifier).set(_studioGridColumns);
    ref.read(tagGridColumnsProvider.notifier).set(_tagGridColumns);

    ref.read(cardTitleFontSizeProvider.notifier).set(_cardTitleFontSize);

    ref.read(maxPerformerAvatarsProvider.notifier).set(_maxPerformerAvatars);
    ref.read(showPerformerAvatarsProvider.notifier).set(_showPerformerAvatars);
    ref.read(performerAvatarSizeProvider.notifier).set(_performerAvatarSize);

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

    ref.watch(appLanguageProvider);
    final currentLanguageKey = ref
        .read(sharedPreferencesProvider)
        .getString(appLanguagePreferenceKey);

    return SettingsPageShell(
      title: context.l10n.settings_interface_title,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: context.l10n.settings_interface_language,
                    subtitle: context.l10n.settings_interface_language_subtitle,
                    child: SettingsActionCard(
                      icon: Icons.translate_rounded,
                      title: context.l10n.settings_interface_app_language,
                      subtitle:
                          supportedLanguages[currentLanguageKey] ??
                          'System Default',
                      onTap: () => _showLanguagePicker(context, ref),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_interface_navigation,
                    subtitle:
                        context.l10n.settings_interface_navigation_subtitle,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_interface_show_random,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_show_random_subtitle,
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
                          title: Text(
                            context
                                .l10n
                                .settings_interface_main_pages_gravity_orientation,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_main_pages_gravity_orientation_subtitle,
                          ),
                          value: _mainPageGravityOrientation,
                          onChanged: (value) async {
                            setState(() => _mainPageGravityOrientation = value);
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.settings_interface_show_edit,
                                ),
                              ),
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
                          subtitle: Text(
                            context.l10n.settings_interface_show_edit_subtitle,
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
                          title: Text(
                            context.l10n.settings_interface_customize_tabs,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_customize_tabs_subtitle,
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
                    title: context.l10n.settings_interface_scenes_layout,
                    subtitle:
                        context.l10n.settings_interface_scenes_layout_subtitle,
                    child: Column(
                      children: [
                        _buildSegmentedSetting(
                          context: context,
                          label:
                              context.l10n.settings_interface_layout_default,
                          description: context
                              .l10n
                              .settings_interface_layout_default_desc,
                          segments: [
                            ButtonSegment<String>(
                              value: 'list',
                              label: Text(
                                context.l10n.settings_interface_layout_list,
                              ),
                              icon: Icon(Icons.view_list),
                            ),
                            ButtonSegment<String>(
                              value: 'grid',
                              label: Text(
                                context.l10n.settings_interface_layout_grid,
                              ),
                              icon: Icon(Icons.grid_view),
                            ),
                            ButtonSegment<String>(
                              value: 'tiktok',
                              label: Text(
                                context.l10n.settings_interface_layout_tiktok,
                              ),
                              icon: Icon(Icons.swipe_up),
                            ),
                          ],
                          selected: {
                            _sceneTiktokLayout
                                ? 'tiktok'
                                : (_sceneGridLayout ? 'grid' : 'list'),
                          },
                          onSelectionChanged: (selection) async {
                            if (selection.isEmpty) return;
                            setState(() {
                              _sceneTiktokLayout = selection.first == 'tiktok';
                              _sceneGridLayout = selection.first == 'grid';
                            });
                            await _saveSettings();
                          },
                        ),
                        if (_sceneGridLayout) ...[
                          const Divider(height: AppTheme.spacingLarge),
                          _buildGridColumnSetting(
                            label: context.l10n.settings_interface_grid_columns,
                            value: _sceneGridColumns,
                            onChanged: (value) async {
                              setState(() => _sceneGridColumns = value);
                              await _saveSettings();
                            },
                          ),
                        ],
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context
                                .l10n
                                .settings_interface_show_performer_avatars,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_show_performer_avatars_subtitle,
                          ),
                          value: _showPerformerAvatars,
                          onChanged: (value) async {
                            setState(() => _showPerformerAvatars = value);
                            await _saveSettings();
                          },
                        ),
                        if (_showPerformerAvatars) ...[
                          const Divider(height: AppTheme.spacingLarge),
                          _buildGridColumnSetting(
                            label: context
                                .l10n
                                .settings_interface_max_performer_avatars,
                            value: _maxPerformerAvatars == 3
                                ? null
                                : _maxPerformerAvatars,
                            onChanged: (value) async {
                              setState(() => _maxPerformerAvatars = value ?? 3);
                              await _saveSettings();
                            },
                          ),
                          const Divider(height: AppTheme.spacingLarge),
                          _buildAvatarSizeSetting(
                            label: context
                                .l10n
                                .settings_interface_performer_avatar_size,
                            value: _performerAvatarSize,
                            onChanged: (value) async {
                              setState(
                                () => _performerAvatarSize = value ?? 16.0,
                              );
                              await _saveSettings();
                            },
                          ),
                        ],
                        const Divider(height: AppTheme.spacingLarge),
                        _buildFontSizeSetting(
                          label: 'Card Title Font Size',
                          value: _cardTitleFontSize,
                          onChanged: (value) async {
                            setState(() => _cardTitleFontSize = value ?? context.fontSizes.medium);
                            await _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_interface_galleries_layout,
                    subtitle: context
                        .l10n
                        .settings_interface_galleries_layout_subtitle,
                    child: Column(
                      children: [
                        _buildSegmentedSetting(
                          context: context,
                          label:
                              context.l10n.settings_interface_layout_default,
                          description: context
                              .l10n
                              .settings_interface_galleries_layout_subtitle_item,
                          segments: [
                            ButtonSegment<String>(
                              value: 'list',
                              label: Text(
                                context.l10n.settings_interface_layout_list,
                              ),
                              icon: Icon(Icons.view_list),
                            ),
                            ButtonSegment<String>(
                              value: 'grid',
                              label: Text(
                                context.l10n.settings_interface_layout_grid,
                              ),
                              icon: Icon(Icons.grid_view),
                            ),
                          ],
                          selected: {_galleryGridLayout ? 'grid' : 'list'},
                          onSelectionChanged: (selection) async {
                            if (selection.isEmpty) return;
                            setState(() {
                              _galleryGridLayout = selection.first == 'grid';
                            });
                            await _saveSettings();
                          },
                        ),
                        if (_galleryGridLayout) ...[
                          const Divider(height: AppTheme.spacingLarge),
                          _buildGridColumnSetting(
                            label: context.l10n.settings_interface_grid_columns,
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
                    title: context.l10n.settings_interface_image_viewer,
                    subtitle:
                        context.l10n.settings_interface_image_viewer_subtitle,
                    child: Column(
                      children: [
                        _buildSegmentedSetting(
                          context: context,
                          label:
                              context.l10n.settings_interface_swipe_direction,
                          description: context
                              .l10n
                              .settings_interface_swipe_direction_desc,
                          segments: [
                            ButtonSegment<String>(
                              value: 'vertical',
                              label: Text(
                                context.l10n.settings_interface_swipe_vertical,
                              ),
                              icon: Icon(Icons.swap_vert_rounded),
                            ),
                            ButtonSegment<String>(
                              value: 'horizontal',
                              label: Text(
                                context
                                    .l10n
                                    .settings_interface_swipe_horizontal,
                              ),
                              icon: Icon(Icons.swap_horiz_rounded),
                            ),
                          ],
                          selected: {
                            _imageFullscreenVerticalSwipe
                                ? 'vertical'
                                : 'horizontal',
                          },
                          onSelectionChanged: (selection) async {
                            if (selection.isEmpty) return;
                            setState(() {
                              _imageFullscreenVerticalSwipe =
                                  selection.first == 'vertical';
                            });
                            await _saveSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildGridColumnSetting(
                          label:
                              context.l10n.settings_interface_waterfall_columns,
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
                  _buildEntityLayoutsSection(
                    context: context,
                    title: context.l10n.settings_interface_performer_layouts,
                    subtitle: context
                        .l10n
                        .settings_interface_performer_layouts_subtitle,
                    mediaGridValue: _performerMediaGridLayout,
                    onMediaChanged: (isGrid) {
                      setState(() => _performerMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                    galleriesGridValue: _performerGalleriesGridLayout,
                    onGalleriesChanged: (isGrid) {
                      setState(() => _performerGalleriesGridLayout = isGrid);
                      _saveSettings();
                    },
                    gridColumnsValue: _performerGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _performerGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildEntityLayoutsSection(
                    context: context,
                    title: context.l10n.settings_interface_studio_layouts,
                    subtitle:
                        context.l10n.settings_interface_studio_layouts_subtitle,
                    mediaGridValue: _studioMediaGridLayout,
                    onMediaChanged: (isGrid) {
                      setState(() => _studioMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                    galleriesGridValue: _studioGalleriesGridLayout,
                    onGalleriesChanged: (isGrid) {
                      setState(() => _studioGalleriesGridLayout = isGrid);
                      _saveSettings();
                    },
                    gridColumnsValue: _studioGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _studioGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildEntityLayoutsSection(
                    context: context,
                    title: context.l10n.settings_interface_tag_layouts,
                    subtitle:
                        context.l10n.settings_interface_tag_layouts_subtitle,
                    mediaGridValue: _tagMediaGridLayout,
                    onMediaChanged: (isGrid) {
                      setState(() => _tagMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                    galleriesGridValue: _tagGalleriesGridLayout,
                    onGalleriesChanged: (isGrid) {
                      setState(() => _tagGalleriesGridLayout = isGrid);
                      _saveSettings();
                    },
                    gridColumnsValue: _tagGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _tagGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEntityLayoutsSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool mediaGridValue,
    required ValueChanged<bool> onMediaChanged,
    required bool galleriesGridValue,
    required ValueChanged<bool> onGalleriesChanged,
    required int? gridColumnsValue,
    required ValueChanged<int?> onGridColumnsChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final listGridSegments = [
      ButtonSegment<String>(
        value: 'list',
        label: Text(l10n.settings_interface_layout_list),
        icon: Icon(Icons.view_list),
      ),
      ButtonSegment<String>(
        value: 'grid',
        label: Text(l10n.settings_interface_layout_grid),
        icon: Icon(Icons.grid_view),
      ),
    ];

    return SettingsSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          _buildSegmentedSetting(
            context: context,
            label: l10n.settings_interface_media_layout,
            description: l10n.settings_interface_media_layout_subtitle,
            segments: listGridSegments,
            selected: {mediaGridValue ? 'grid' : 'list'},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              onMediaChanged(selection.first == 'grid');
            },
          ),
          const Divider(height: AppTheme.spacingLarge),
          _buildSegmentedSetting(
            context: context,
            label: l10n.settings_interface_galleries_layout_item,
            description: l10n.settings_interface_galleries_layout_subtitle_item,
            segments: listGridSegments,
            selected: {galleriesGridValue ? 'grid' : 'list'},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              onGalleriesChanged(selection.first == 'grid');
            },
          ),
          if (mediaGridValue || galleriesGridValue) ...[
            const Divider(height: AppTheme.spacingLarge),
            _buildGridColumnSetting(
              label: l10n.settings_interface_grid_columns,
              value: gridColumnsValue,
              onChanged: onGridColumnsChanged,
            ),
          ],
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLanguageKey = ref
        .read(sharedPreferencesProvider)
        .getString(appLanguagePreferenceKey);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusExtraLarge),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppTheme.spacingMedium),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: supportedLanguages.entries.map((entry) {
                    final isSelected = entry.key == currentLanguageKey;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                      title: Text(
                        entry.value,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),                      onTap: () async {
                        await ref
                            .read(appLanguageProvider.notifier)
                            .setLanguage(entry.key);
                        if (context.mounted) Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentedSetting({
    required BuildContext context,
    required String label,
    required String description,
    required List<ButtonSegment<String>> segments,
    required Set<String> selected,
    required ValueChanged<Set<String>> onSelectionChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.titleSmall;
    final descriptionStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final segmentedButton = SegmentedButton<String>(
          segments: segments,
          selected: selected,
          showSelectedIcon: false,
          onSelectionChanged: onSelectionChanged,
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
              Text(label, style: labelStyle),
              const SizedBox(height: 4),
              Text(description, style: descriptionStyle),
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
                  Text(label, style: labelStyle),
                  const SizedBox(height: 4),
                  Text(description, style: descriptionStyle),
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
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.titleSmall),
        MenuAnchor(
          builder: (context, controller, child) {
            return InkWell(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: ShapeDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                  shape: StadiumBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value == null ? l10n.common_default : value.toString(),
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            );
          },
          menuChildren: [
            MenuItemButton(
              onPressed: () => onChanged(null),
              child: Text(l10n.common_default),
            ),
            ...List.generate(10, (index) => index + 1).map(
              (i) => MenuItemButton(
                onPressed: () => onChanged(i),
                child: Text(i.toString()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontSizeSetting({
    required String label,
    required double? value,
    required ValueChanged<double?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.titleSmall),
            Text(
              value == null ? 'Default' : '${value.toInt()} pt',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value ?? 14.0,
          min: 10.0,
          max: 24.0,
          divisions: 7,
          label: value == null ? 'Default' : '${value.toInt()} pt',
          onChanged: (val) => onChanged(val),
        ),
      ],
    );
  }

  Widget _buildAvatarSizeSetting({
    required String label,
    required double value,
    required ValueChanged<double?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.titleSmall),
            Text(
              '${value.toInt()} px',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 12.0,
          max: 48.0,
          divisions: 9,
          label: '${value.toInt()} px',
          onChanged: (val) => onChanged(val),
        ),
      ],
    );
  }
}
