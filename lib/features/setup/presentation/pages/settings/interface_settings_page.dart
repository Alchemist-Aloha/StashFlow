import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_customization_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/main_page_orientation_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';
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
  bool _sceneRandomRespectActiveFilter = true;
  bool _sceneGridLayout = false;
  bool _sceneTiktokLayout = false;
  bool _galleryGridLayout = true;
  bool _mainPageGravityOrientation = true;
  bool _useActualSceneVideoInMiniPlayer = true;
  EntityImageFilterMethod _entityImageFilterMethod =
      EntityImageFilterMethod.directEntity;
  bool _imageFullscreenVerticalSwipe = true;

  int? _sceneGridColumns;
  int? _galleryGridColumns;
  int? _performerGridColumns;
  int? _imageGridColumns;
  int? _studioGridColumns;
  int? _tagGridColumns;
  int? _groupGridColumns;
  int? _markerGridColumns;

  double? _cardTitleFontSize;

  int _maxPerformerAvatars = 3;
  bool _showPerformerAvatars = true;
  bool _hideSceneTechnicalMetadata = true;
  double _performerAvatarSize = 16.0;

  // New settings
  bool _performerMediaGridLayout = true;
  bool _performerGalleriesGridLayout = true;
  bool _studioMediaGridLayout = true;
  bool _studioGalleriesGridLayout = true;
  bool _tagMediaGridLayout = true;
  bool _tagGalleriesGridLayout = true;
  bool _groupMediaGridLayout = true;
  bool _markerGridLayout = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);

    _showRandomNavigation = ref.read(randomNavigationEnabledProvider);
    _sceneRandomRespectActiveFilter = ref.read(
      sceneRandomRespectActiveFilterProvider,
    );
    _sceneGridLayout = ref.read(sceneGridLayoutProvider);
    _sceneTiktokLayout = ref.read(sceneTiktokLayoutProvider);
    _galleryGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.gallery),
    );
    _mainPageGravityOrientation = ref.read(mainPageGravityOrientationProvider);
    _useActualSceneVideoInMiniPlayer = PlayerSettingsStore(
      prefs,
    ).load().useActualSceneVideoInMiniPlayer;
    _entityImageFilterMethod = ref.read(entityImageFilterMethodSettingProvider);
    _imageFullscreenVerticalSwipe =
        prefs.getBool(_imageFullscreenVerticalSwipeKey) ?? true;

    _sceneGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.scene),
    );
    _galleryGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.gallery),
    );
    _performerGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.performer),
    );
    _imageGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.image),
    );
    _studioGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.studio),
    );
    _tagGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.tag),
    );
    _groupGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.group),
    );
    _markerGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.sceneMarker),
    );

    _cardTitleFontSize = ref.read(cardTitleFontSizeProvider);

    _maxPerformerAvatars = ref.read(maxPerformerAvatarsProvider);
    _showPerformerAvatars = ref.read(showPerformerAvatarsProvider);
    _hideSceneTechnicalMetadata = ref.read(hideSceneTechnicalMetadataProvider);
    _performerAvatarSize = ref.read(performerAvatarSizeProvider);

    _performerMediaGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.performerMedia),
    );
    _performerGalleriesGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.performerGalleries),
    );
    _studioMediaGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.studioMedia),
    );
    _studioGalleriesGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.studioGalleries),
    );
    _tagMediaGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.tagMedia),
    );
    _tagGalleriesGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.tagGalleries),
    );
    _groupMediaGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.groupMedia),
    );
    _markerGridLayout = ref.read(
      gridLayoutSettingProvider(GridLayoutSetting.sceneMarker),
    );

    setState(() => _loading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);

    ref
        .read(randomNavigationEnabledProvider.notifier)
        .set(_showRandomNavigation);
    ref
        .read(sceneRandomRespectActiveFilterProvider.notifier)
        .set(_sceneRandomRespectActiveFilter);
    ref.read(sceneGridLayoutProvider.notifier).set(_sceneGridLayout);
    ref.read(sceneTiktokLayoutProvider.notifier).set(_sceneTiktokLayout);
    ref
        .read(gridLayoutSettingProvider(GridLayoutSetting.gallery).notifier)
        .set(_galleryGridLayout);
    ref
        .read(mainPageGravityOrientationProvider.notifier)
        .set(_mainPageGravityOrientation);
    ref
        .read(playerStateProvider.notifier)
        .setUseActualSceneVideoInMiniPlayer(_useActualSceneVideoInMiniPlayer);
    await ref
        .read(entityImageFilterMethodSettingProvider.notifier)
        .set(_entityImageFilterMethod);

    ref
        .read(gridColumnSettingProvider(GridColumnSetting.scene).notifier)
        .set(_sceneGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.gallery).notifier)
        .set(_galleryGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.performer).notifier)
        .set(_performerGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.image).notifier)
        .set(_imageGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.studio).notifier)
        .set(_studioGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.tag).notifier)
        .set(_tagGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.group).notifier)
        .set(_groupGridColumns);
    ref
        .read(gridColumnSettingProvider(GridColumnSetting.sceneMarker).notifier)
        .set(_markerGridColumns);

    ref.read(cardTitleFontSizeProvider.notifier).set(_cardTitleFontSize);

    ref.read(maxPerformerAvatarsProvider.notifier).set(_maxPerformerAvatars);
    ref.read(showPerformerAvatarsProvider.notifier).set(_showPerformerAvatars);
    ref
        .read(hideSceneTechnicalMetadataProvider.notifier)
        .set(_hideSceneTechnicalMetadata);
    ref.read(performerAvatarSizeProvider.notifier).set(_performerAvatarSize);

    ref
        .read(
          gridLayoutSettingProvider(GridLayoutSetting.performerMedia).notifier,
        )
        .set(_performerMediaGridLayout);
    ref
        .read(
          gridLayoutSettingProvider(
            GridLayoutSetting.performerGalleries,
          ).notifier,
        )
        .set(_performerGalleriesGridLayout);
    ref
        .read(gridLayoutSettingProvider(GridLayoutSetting.studioMedia).notifier)
        .set(_studioMediaGridLayout);
    ref
        .read(
          gridLayoutSettingProvider(GridLayoutSetting.studioGalleries).notifier,
        )
        .set(_studioGalleriesGridLayout);
    ref
        .read(gridLayoutSettingProvider(GridLayoutSetting.tagMedia).notifier)
        .set(_tagMediaGridLayout);
    ref
        .read(
          gridLayoutSettingProvider(GridLayoutSetting.tagGalleries).notifier,
        )
        .set(_tagGalleriesGridLayout);
    ref
        .read(gridLayoutSettingProvider(GridLayoutSetting.groupMedia).notifier)
        .set(_groupMediaGridLayout);
    ref
        .read(gridLayoutSettingProvider(GridLayoutSetting.sceneMarker).notifier)
        .set(_markerGridLayout);

    await prefs.setBool(
      _imageFullscreenVerticalSwipeKey,
      _imageFullscreenVerticalSwipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final currentLanguageKey = ref
        .read(sharedPreferencesProvider)
        .getString(appLanguagePreferenceKey);

    return SettingsPageShell(
      title: context.l10n.settings_interface_title,
      child: _loading
          ? const SettingsLoadingState()
          : SettingsPageBody(
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
                  SizedBox(height: context.dimensions.spacingLarge),
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
                        Divider(height: context.dimensions.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_interface_hide_scene_metadata,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_hide_scene_metadata_subtitle,
                          ),
                          value: _hideSceneTechnicalMetadata,
                          onChanged: (value) async {
                            setState(() => _hideSceneTechnicalMetadata = value);
                            await _saveSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_interface_random_scene_filter,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_random_scene_filter_subtitle,
                          ),
                          value: _sceneRandomRespectActiveFilter,
                          onChanged: (value) async {
                            setState(
                              () => _sceneRandomRespectActiveFilter = value,
                            );
                            await _saveSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildSegmentedSetting(
                          context: context,
                          label: context
                              .l10n
                              .settings_interface_entity_image_filtering,
                          description: context
                              .l10n
                              .settings_interface_entity_image_filtering_subtitle,
                          segments: [
                            ButtonSegment<String>(
                              value: EntityImageFilterMethod.directEntity.name,
                              label: Text(
                                context
                                    .l10n
                                    .settings_interface_entity_image_filtering_direct,
                              ),
                            ),
                            ButtonSegment<String>(
                              value:
                                  EntityImageFilterMethod.relatedGalleries.name,
                              label: Text(
                                context
                                    .l10n
                                    .settings_interface_entity_image_filtering_galleries,
                              ),
                            ),
                          ],
                          selected: {_entityImageFilterMethod.name},
                          onSelectionChanged: (selection) async {
                            if (selection.isEmpty) return;
                            setState(() {
                              _entityImageFilterMethod = EntityImageFilterMethod
                                  .values
                                  .firstWhere(
                                    (method) => method.name == selection.first,
                                  );
                            });
                            await _saveSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
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
                        Divider(height: context.dimensions.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context
                                .l10n
                                .settings_interface_use_actual_scene_video_miniplayer,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_use_actual_scene_video_miniplayer_subtitle,
                          ),
                          value: _useActualSceneVideoInMiniPlayer,
                          onChanged: (value) async {
                            setState(
                              () => _useActualSceneVideoInMiniPlayer = value,
                            );
                            await _saveSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
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
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 24 * context.dimensions.fontSizeFactor,
                          ),
                          onTap: () {
                            context.push('/settings/interface/navigation');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_interface_scenes_layout,
                    subtitle:
                        context.l10n.settings_interface_scenes_layout_subtitle,
                    child: Column(
                      children: [
                        _buildSegmentedSetting(
                          context: context,
                          label: context.l10n.settings_interface_layout_default,
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
                          Divider(height: context.dimensions.spacingLarge),
                          _buildGridColumnSetting(
                            label: context.l10n.settings_interface_grid_columns,
                            value: _sceneGridColumns,
                            onChanged: (value) async {
                              setState(() => _sceneGridColumns = value);
                              await _saveSettings();
                            },
                          ),
                        ],
                        Divider(height: context.dimensions.spacingLarge),
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
                          Divider(height: context.dimensions.spacingLarge),
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
                          Divider(height: context.dimensions.spacingLarge),
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
                        Divider(height: context.dimensions.spacingLarge),
                        _buildFontSizeSetting(
                          label: context
                              .l10n
                              .settings_interface_card_title_font_size,
                          value: _cardTitleFontSize,
                          onChanged: (value) async {
                            setState(
                              () => _cardTitleFontSize =
                                  value ?? context.fontSizes.medium,
                            );
                            await _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_interface_galleries_layout,
                    subtitle: context
                        .l10n
                        .settings_interface_galleries_layout_subtitle,
                    child: Column(
                      children: [
                        _buildSegmentedSetting(
                          context: context,
                          label: context.l10n.settings_interface_layout_default,
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
                          Divider(height: context.dimensions.spacingLarge),
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
                  SizedBox(height: context.dimensions.spacingLarge),
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
                        Divider(height: context.dimensions.spacingLarge),
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
                  SizedBox(height: context.dimensions.spacingLarge),
                  _buildSingleLayoutSection(
                    context: context,
                    title: context.l10n.groups_title,
                    subtitle: context.l10n.groups_browsing_mode_subtitle,
                    segmentedKey: const Key('group-layout-segmented'),
                    label: context.l10n.settings_interface_media_layout,
                    description:
                        context.l10n.settings_interface_media_layout_subtitle,
                    gridValue: _groupMediaGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _groupMediaGridLayout = isGrid);
                      _saveSettings();
                    },
                    gridColumnsValue: _groupGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _groupGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  _buildSingleLayoutSection(
                    context: context,
                    title: context.l10n.markers_title,
                    subtitle: context.l10n.markers_browsing_mode_subtitle,
                    segmentedKey: const Key('marker-layout-segmented'),
                    label: context.l10n.settings_interface_layout_default,
                    description:
                        context.l10n.settings_interface_layout_default_desc,
                    gridValue: _markerGridLayout,
                    onChanged: (isGrid) {
                      setState(() => _markerGridLayout = isGrid);
                      _saveSettings();
                    },
                    gridColumnsValue: _markerGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _markerGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  // Consolidated Entity Layouts
                  SettingsSectionCard(
                    title: context.l10n.entity_layouts_title,
                    subtitle: context.l10n.entity_layouts_subtitle,
                    child: Column(
                      children: [
                        _buildEntityTypeLayoutRow(
                          context: context,
                          label:
                              context.l10n.settings_interface_performer_layouts,
                          mediaGridValue: _performerMediaGridLayout,
                          onMediaChanged: (isGrid) {
                            setState(() => _performerMediaGridLayout = isGrid);
                            _saveSettings();
                          },
                          galleriesGridValue: _performerGalleriesGridLayout,
                          onGalleriesChanged: (isGrid) {
                            setState(
                              () => _performerGalleriesGridLayout = isGrid,
                            );
                            _saveSettings();
                          },
                          alwaysShowGridColumns: true,
                          gridColumnsLabel:
                              '${context.l10n.performers_title} ${context.l10n.settings_interface_grid_columns}',
                          gridColumnsSliderKey: const Key(
                            'performer-list-grid-columns-slider',
                          ),
                          gridColumnsValue: _performerGridColumns,
                          onGridColumnsChanged: (value) async {
                            setState(() => _performerGridColumns = value);
                            await _saveSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildEntityTypeLayoutRow(
                          context: context,
                          label: context.l10n.settings_interface_studio_layouts,
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
                        Divider(height: context.dimensions.spacingLarge),
                        _buildEntityTypeLayoutRow(
                          context: context,
                          label: context.l10n.settings_interface_tag_layouts,
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
                ],
              ),
            ),
    );
  }

  Widget _buildSingleLayoutSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    Key? segmentedKey,
    required String label,
    required String description,
    required bool gridValue,
    required ValueChanged<bool> onChanged,
    required int? gridColumnsValue,
    required ValueChanged<int?> onGridColumnsChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          _buildSegmentedSetting(
            context: context,
            segmentedKey: segmentedKey,
            label: label,
            description: description,
            segments: [
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
            ],
            selected: {gridValue ? 'grid' : 'list'},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              onChanged(selection.first == 'grid');
            },
          ),
          if (gridValue) ...[
            Divider(height: context.dimensions.spacingLarge),
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

  Widget _buildEntityTypeLayoutRow({
    required BuildContext context,
    required String label,
    required bool mediaGridValue,
    required ValueChanged<bool> onMediaChanged,
    bool? galleriesGridValue,
    ValueChanged<bool>? onGalleriesChanged,
    bool alwaysShowGridColumns = false,
    String? gridColumnsLabel,
    Key? gridColumnsSliderKey,
    required int? gridColumnsValue,
    required ValueChanged<int?> onGridColumnsChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    final bool showGridColumns =
        alwaysShowGridColumns ||
        mediaGridValue ||
        (galleriesGridValue != null && galleriesGridValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_outlined, size: 20, color: colorScheme.primary),
            SizedBox(width: 8 * context.dimensions.fontSizeFactor),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: context.dimensions.spacingSmall),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.settings_interface_media_layout,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SegmentedButton<String>(
              segments: listGridSegments,
              selected: {mediaGridValue ? 'grid' : 'list'},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                onMediaChanged(selection.first == 'grid');
              },
            ),
          ],
        ),
        if (galleriesGridValue != null && onGalleriesChanged != null) ...[
          SizedBox(height: context.dimensions.spacingSmall),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.settings_interface_galleries_layout_item,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SegmentedButton<String>(
                segments: listGridSegments,
                selected: {galleriesGridValue ? 'grid' : 'list'},
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  onGalleriesChanged(selection.first == 'grid');
                },
              ),
            ],
          ),
        ],
        if (showGridColumns) ...[
          SizedBox(height: context.dimensions.spacingSmall),
          _buildGridColumnSetting(
            label: gridColumnsLabel ?? l10n.settings_interface_grid_columns,
            sliderKey: gridColumnsSliderKey,
            value: gridColumnsValue,
            onChanged: onGridColumnsChanged,
          ),
        ],
      ],
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLanguageKey = ref
        .read(sharedPreferencesProvider)
        .getString(appLanguagePreferenceKey);
    final languageEntries = supportedLanguages.entries.toList(growable: false);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32 * context.dimensions.fontSizeFactor),
        ),
      ),
      builder: (context) {
        final textTheme = context.textTheme;
        final fontSizeFactor = context.dimensions.fontSizeFactor;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: context.dimensions.spacingMedium),
              Container(
                width: 32 * context.dimensions.fontSizeFactor,
                height: 4 * context.dimensions.fontSizeFactor,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(
                    2 * context.dimensions.fontSizeFactor,
                  ),
                ),
              ),
              SizedBox(height: context.dimensions.spacingMedium),
              Flexible(
                child: ListView.builder(
                  itemCount: languageEntries.length,
                  itemBuilder: (context, index) {
                    final entry = languageEntries[index];
                    final isSelected = entry.key == currentLanguageKey;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected ? colorScheme.primary : null,
                        size: 24 * fontSizeFactor,
                      ),
                      title: Text(
                        entry.value,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                      onTap: () async {
                        await ref
                            .read(appLanguageProvider.notifier)
                            .setLanguage(entry.key);
                        if (context.mounted) Navigator.pop(context);
                      },
                    );
                  },
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
    Key? segmentedKey,
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
          key: segmentedKey,
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
              SizedBox(height: 4 * context.dimensions.fontSizeFactor),
              Text(description, style: descriptionStyle),
              SizedBox(height: context.dimensions.spacingMedium),
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
                  SizedBox(height: 4 * context.dimensions.fontSizeFactor),
                  Text(description, style: descriptionStyle),
                ],
              ),
            ),
            SizedBox(width: context.dimensions.spacingMedium),
            Flexible(child: control),
          ],
        );
      },
    );
  }

  Widget _buildGridColumnSetting({
    required String label,
    Key? sliderKey,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final displayValue = (value ?? 3).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.titleSmall),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value == null ? l10n.common_default : value.toString(),
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (value != null)
                  IconButton(
                    icon: Icon(
                      Icons.restart_alt_rounded,
                      size: 20 * context.dimensions.fontSizeFactor,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: l10n.common_default,
                    onPressed: () => onChanged(null),
                  ),
              ],
            ),
          ],
        ),
        Slider(
          key: sliderKey,
          value: displayValue,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: value == null ? l10n.common_default : value.toString(),
          onChanged: (val) => onChanged(val.toInt()),
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
          label: value == null
              ? context.l10n.common_default
              : context.l10n.common_pt(value.toInt()),
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
          label: context.l10n.common_px(value.toInt()),
          onChanged: (val) => onChanged(val),
        ),
      ],
    );
  }
}
