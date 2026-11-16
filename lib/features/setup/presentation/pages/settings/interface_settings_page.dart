import 'dart:async';

import 'package:material_ui/material_ui.dart';
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
  bool _autoHideTopAppBar = false;
  bool _sceneRandomRespectActiveFilter = true;
  bool _sceneTiktokLayout = false;
  bool _mainPageGravityOrientation = true;
  bool _useActualSceneVideoInMiniPlayer = true;
  EntityImageFilterMethod _entityImageFilterMethod =
      EntityImageFilterMethod.directEntity;
  bool _imageFullscreenVerticalSwipe = true;

  int? _sceneGridColumns;
  int? _galleryGridColumns;
  int? _performerGridColumns;
  int? _imageGridColumns;
  int? _markerGridColumns;

  double? _cardTitleFontSize;

  int _maxPerformerAvatars = 3;
  bool _showPerformerAvatars = true;
  bool _hideSceneTechnicalMetadata = true;
  bool _showScenePlaybackProgress = true;
  double _performerAvatarSize = 16.0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final prefs = ref.read(sharedPreferencesProvider);

    _showRandomNavigation = ref.read(randomNavigationEnabledProvider);
    _autoHideTopAppBar = ref.read(autoHideTopAppBarProvider);
    _sceneRandomRespectActiveFilter = ref.read(
      sceneRandomRespectActiveFilterProvider,
    );
    _sceneTiktokLayout = ref.read(sceneTiktokLayoutProvider);
    _mainPageGravityOrientation = ref.read(mainPageGravityOrientationProvider);
    _useActualSceneVideoInMiniPlayer = PlayerSettingsStore(prefs)
        .load()
        .useActualSceneVideoInMiniPlayer;
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
    _markerGridColumns = ref.read(
      gridColumnSettingProvider(GridColumnSetting.sceneMarker),
    );

    _cardTitleFontSize = ref.read(cardTitleFontSizeProvider);

    _maxPerformerAvatars = ref.read(maxPerformerAvatarsProvider);
    _showPerformerAvatars = ref.read(showPerformerAvatarsProvider);
    _hideSceneTechnicalMetadata = ref.read(hideSceneTechnicalMetadataProvider);
    _showScenePlaybackProgress = ref.read(showScenePlaybackProgressProvider);
    _performerAvatarSize = ref.read(performerAvatarSizeProvider);

    setState(() => _loading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    ref
        .read(playerStateProvider.notifier)
        .setUseActualSceneVideoInMiniPlayer(_useActualSceneVideoInMiniPlayer);

    await Future.wait([
      ref
          .read(randomNavigationEnabledProvider.notifier)
          .set(_showRandomNavigation),
      ref.read(autoHideTopAppBarProvider.notifier).set(_autoHideTopAppBar),
      ref
          .read(sceneRandomRespectActiveFilterProvider.notifier)
          .set(_sceneRandomRespectActiveFilter),
      ref.read(sceneTiktokLayoutProvider.notifier).set(_sceneTiktokLayout),
      ref
          .read(mainPageGravityOrientationProvider.notifier)
          .set(_mainPageGravityOrientation),
      ref
          .read(entityImageFilterMethodSettingProvider.notifier)
          .set(_entityImageFilterMethod),
      ref
          .read(gridColumnSettingProvider(GridColumnSetting.scene).notifier)
          .set(_sceneGridColumns),
      ref
          .read(gridColumnSettingProvider(GridColumnSetting.gallery).notifier)
          .set(_galleryGridColumns),
      ref
          .read(gridColumnSettingProvider(GridColumnSetting.performer).notifier)
          .set(_performerGridColumns),
      ref
          .read(gridColumnSettingProvider(GridColumnSetting.image).notifier)
          .set(_imageGridColumns),
      ref
          .read(
            gridColumnSettingProvider(GridColumnSetting.sceneMarker).notifier,
          )
          .set(_markerGridColumns),
      ref.read(cardTitleFontSizeProvider.notifier).set(_cardTitleFontSize),
      ref.read(maxPerformerAvatarsProvider.notifier).set(_maxPerformerAvatars),
      ref
          .read(showPerformerAvatarsProvider.notifier)
          .set(_showPerformerAvatars),
      ref
          .read(hideSceneTechnicalMetadataProvider.notifier)
          .set(_hideSceneTechnicalMetadata),
      ref
          .read(showScenePlaybackProgressProvider.notifier)
          .set(_showScenePlaybackProgress),
      ref.read(performerAvatarSizeProvider.notifier).set(_performerAvatarSize),
      prefs.setBool(
        _imageFullscreenVerticalSwipeKey,
        _imageFullscreenVerticalSwipe,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpacerEnabled = ref.watch(
      miniPlayerBottomSpacerEnabledProvider,
    );
    final bottomOffset = ref.watch(miniPlayerBottomOffsetProvider);
    return SettingsPageShell(
      title: context.l10n.settings_interface_title,
      child: _loading
          ? const SettingsLoadingState()
          : SettingsPageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            context.l10n.settings_interface_auto_hide_app_bar,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_auto_hide_app_bar_subtitle,
                          ),
                          value: _autoHideTopAppBar,
                          onChanged: (value) async {
                            setState(() => _autoHideTopAppBar = value);
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
                            context.l10n.settings_interface_show_scene_progress,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_show_scene_progress_subtitle,
                          ),
                          value: _showScenePlaybackProgress,
                          onChanged: (value) async {
                            setState(() => _showScenePlaybackProgress = value);
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
                        SwitchListTile.adaptive(
                          key: const Key('mini-player-bottom-spacer-toggle'),
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context
                                .l10n
                                .settings_interface_miniplayer_bottom_spacer,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_interface_miniplayer_bottom_spacer_subtitle,
                          ),
                          value: bottomSpacerEnabled,
                          onChanged: (value) => ref
                              .read(
                                miniPlayerBottomSpacerEnabledProvider.notifier,
                              )
                              .set(value),
                        ),
                        if (bottomSpacerEnabled)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: context.dimensions.spacingSmall),
                              Text(
                                context
                                    .l10n
                                    .settings_interface_miniplayer_bottom_offset,
                                style: context.textTheme.titleSmall,
                              ),
                              Text(
                                context.l10n.common_px(bottomOffset.round()),
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              Semantics(
                                label: context
                                    .l10n
                                    .settings_interface_miniplayer_bottom_offset,
                                child: Slider(
                                  key: const Key(
                                    'mini-player-bottom-offset-slider',
                                  ),
                                  value: bottomOffset,
                                  min: 0,
                                  max: MiniPlayerBottomOffset.maxValue,
                                  divisions: 50,
                                  label: context.l10n.common_px(
                                    bottomOffset.round(),
                                  ),
                                  semanticFormatterCallback: (value) =>
                                      context.l10n.common_px(value.round()),
                                  onChanged: (value) => ref
                                      .read(
                                        miniPlayerBottomOffsetProvider.notifier,
                                      )
                                      .set(value),
                                ),
                              ),
                            ],
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
                            unawaited(
                              context.push('/settings/interface/navigation'),
                            );
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
                          selected: {_sceneTiktokLayout ? 'tiktok' : 'grid'},
                          onSelectionChanged: (selection) async {
                            if (selection.isEmpty) return;
                            setState(() {
                              _sceneTiktokLayout = selection.first == 'tiktok';
                            });
                            await _saveSettings();
                          },
                        ),
                        if (!_sceneTiktokLayout) ...[
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
                        _buildGridColumnSetting(
                          label: context.l10n.settings_interface_grid_columns,
                          value: _galleryGridColumns,
                          onChanged: (value) async {
                            setState(() => _galleryGridColumns = value);
                            await _saveSettings();
                          },
                        ),
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
                    title: context.l10n.markers_title,
                    subtitle: context.l10n.markers_browsing_mode_subtitle,
                    gridColumnsValue: _markerGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _markerGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  _buildSingleLayoutSection(
                    context: context,
                    title: context.l10n.performers_title,
                    sliderKey: const Key('performer-list-grid-columns-slider'),
                    gridColumnsValue: _performerGridColumns,
                    onGridColumnsChanged: (value) async {
                      setState(() => _performerGridColumns = value);
                      await _saveSettings();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSingleLayoutSection({
    required BuildContext context,
    required String title,
    String? subtitle,
    Key? sliderKey,
    required int? gridColumnsValue,
    required ValueChanged<int?> onGridColumnsChanged,
  }) {
    return SettingsSectionCard(
      title: title,
      subtitle: subtitle,
      child: _buildGridColumnSetting(
        label: context.l10n.settings_interface_grid_columns,
        sliderKey: sliderKey,
        value: gridColumnsValue,
        onChanged: onGridColumnsChanged,
      ),
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
