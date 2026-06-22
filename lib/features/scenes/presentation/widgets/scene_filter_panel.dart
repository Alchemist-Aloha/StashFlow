import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/scene_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import 'entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../galleries/domain/entities/gallery.dart';
import '../../../../core/domain/entities/filter_options.dart';

class SceneFilterPanel extends ConsumerStatefulWidget {
  const SceneFilterPanel({
    super.key,
    this.initialFilter,
    this.initialOrganized,
    this.onApply,
    this.onSaveDefault,
    this.saveSuccessMessage,
  });

  final SceneFilter? initialFilter;
  final OrganizedFilter? initialOrganized;
  final void Function(SceneFilter filter, OrganizedFilter organized)? onApply;
  final Future<void> Function(SceneFilter filter, OrganizedFilter organized)?
  onSaveDefault;
  final String? saveSuccessMessage;

  @override
  ConsumerState<SceneFilterPanel> createState() => _SceneFilterPanelState();
}

class _SceneFilterPanelState extends ConsumerState<SceneFilterPanel> {
  late SceneFilter _tempFilter;
  late OrganizedFilter _tempOrganized;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.initialFilter ?? ref.read(sceneFilterStateProvider);
    _tempOrganized =
        widget.initialOrganized ?? ref.read(sceneOrganizedOnlyProvider);
  }

  void _applyFilter() {
    final onApply = widget.onApply;
    if (onApply != null) {
      onApply(_tempFilter, _tempOrganized);
      return;
    }

    ref.read(sceneFilterStateProvider.notifier).update(_tempFilter);
    ref.read(sceneOrganizedOnlyProvider.notifier).set(_tempOrganized);
  }

  Future<void> _saveDefaultFilter() async {
    final onSaveDefault = widget.onSaveDefault;
    if (onSaveDefault != null) {
      await onSaveDefault(_tempFilter, _tempOrganized);
      return;
    }

    _applyFilter();
    await Future.wait([
      ref.read(sceneFilterStateProvider.notifier).saveAsDefault(),
      ref.read(sceneOrganizedOnlyProvider.notifier).saveAsDefault(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.scenes_filter_title,
      onReset: () {
        setState(() {
          _tempFilter = SceneFilter.empty();
          _tempOrganized = OrganizedFilter.all;
        });
      },
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildPerformerSection(),
          _buildLibrarySection(),
          _buildMetadataSection(),
          _buildMediaInfoSection(),
          _buildUsageSection(),
          _buildSystemSection(),
        ],
      ),
      onApply: _applyFilter,
      onSaveDefault: _saveDefaultFilter,
      saveDefaultSuccessMessage:
          widget.saveSuccessMessage ?? context.l10n.scenes_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [_buildRatingFilter(), _buildOrganizedFilter()],
    );
  }

  Widget _buildPerformerSection() {
    return FilterSection(
      title: context.l10n.filter_group_performer,
      children: [
        _buildEntityFilter<Performer>(
          'Performers',
          'performer',
          _tempFilter.performers,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performers: val as MultiCriterion?,
            ),
          ),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Performer Tags',
          'tag',
          _tempFilter.performerTags,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performerTags: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_performer_age,
          value: _tempFilter.performerAge,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerAge: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_performer_count,
          value: _tempFilter.performerCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerCount: val),
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        _buildEntityFilter<Studio>(
          'Studios',
          'studio',
          _tempFilter.studios,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              studios: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        _buildEntityFilter<Group>(
          'Groups',
          'group',
          _tempFilter.groups,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              groups: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        _buildEntityFilter<Gallery>(
          'Galleries',
          'gallery',
          _tempFilter.galleries,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              galleries: val as MultiCriterion?,
            ),
          ),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.scenes_field_code,
          value: _tempFilter.code,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(code: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_details,
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_director,
          value: _tempFilter.director,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(director: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_url,
          value: _tempFilter.url,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
        DateCriterionInput(
          label: context.l10n.scenes_field_date,
          value: _tempFilter.date,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(date: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_path,
          value: _tempFilter.path,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(path: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_captions,
          value: _tempFilter.captions,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(captions: val)),
        ),
      ],
    );
  }

  Widget _buildMediaInfoSection() {
    return FilterSection(
      title: context.l10n.filter_group_media_info,
      children: [
        _buildResolutionFilter(),
        _buildOrientationFilter(),
        IntCriterionInput(
          label: context.l10n.scenes_field_duration,
          value: _tempFilter.duration,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(duration: val)),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_bitrate,
          value: _tempFilter.bitrate,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(bitrate: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_video_codec,
          value: _tempFilter.videoCodec,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(videoCodec: val),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_audio_codec,
          value: _tempFilter.audioCodec,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(audioCodec: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_framerate,
          value: _tempFilter.framerate,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(framerate: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_file_count,
          value: _tempFilter.fileCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(fileCount: val),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageSection() {
    return FilterSection(
      title: context.l10n.filter_group_usage,
      children: [
        IntCriterionInput(
          label: context.l10n.scenes_field_play_count,
          value: _tempFilter.playCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(playCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_play_duration,
          value: _tempFilter.playDuration,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(playDuration: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_o_counter,
          value: _tempFilter.oCounter,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(oCounter: val)),
        ),
        DateCriterionInput(
          label: context.l10n.scenes_field_last_played_at,
          value: _tempFilter.lastPlayedAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(lastPlayedAt: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_resume_time,
          value: _tempFilter.resumeTime,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(resumeTime: val),
          ),
        ),
        _buildBooleanFilter(
          'Interactive',
          _tempFilter.interactive,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(interactive: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_interactive_speed,
          value: _tempFilter.interactiveSpeed,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(interactiveSpeed: val),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        IntCriterionInput(
          label: context.l10n.scenes_field_id,
          value: _tempFilter.id,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(id: val)),
        ),
        IntCriterionInput(
          label: context.l10n.scenes_field_stash_id_count,
          value: _tempFilter.stashIdCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(stashIdCount: val),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_oshash,
          value: _tempFilter.oshash,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(oshash: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_checksum,
          value: _tempFilter.checksum,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(checksum: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_phash,
          value: _tempFilter.phash,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(phash: val)),
        ),
        _buildDuplicatedFilter(),
        _buildBooleanFilter(
          'Has Markers',
          _tempFilter.hasMarkers,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(hasMarkers: val),
          ),
        ),
        _buildBooleanFilter(
          'Is Missing',
          _tempFilter.isMissing,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.scenes_field_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.scenes_field_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(updatedAt: val),
          ),
        ),
      ],
    );
  }

  Widget _buildDuplicatedFilter() {
    final options = ['phash', 'oshash'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.scenes_duplicated,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: options.map((opt) {
            final isSelected =
                _tempFilter.duplicated?.value.contains(opt) ?? false;
            return FilterChip(
              label: Text(opt.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(
                    _tempFilter.duplicated?.value ?? [],
                  );
                  if (selected) {
                    current.add(opt);
                  } else {
                    current.remove(opt);
                  }

                  if (current.isEmpty) {
                    _tempFilter = _tempFilter.copyWith(duplicated: null);
                  } else {
                    _tempFilter = _tempFilter.copyWith(
                      duplicated: MultiCriterion(value: current),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.galleries_min_rating,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: [
            for (var stars = 0; stars <= 5; stars++)
              ChoiceChip(
                label: stars == 0
                    ? Text(context.l10n.common_any)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$stars'),
                          SizedBox(width: context.dimensions.spacingSmall / 2),
                          Icon(
                            Icons.star,
                            size: 16 * context.dimensions.fontSizeFactor,
                          ),
                        ],
                      ),
                selected:
                    (stars == 0 && _tempFilter.rating100 == null) ||
                    (stars > 0 &&
                        _tempFilter.rating100?.value == (stars - 1) * 20 &&
                        _tempFilter.rating100?.modifier ==
                            CriterionModifier.greaterThan),
                onSelected: (_) {
                  setState(() {
                    if (stars == 0) {
                      _tempFilter = _tempFilter.copyWith(rating100: null);
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        rating100: IntCriterion(
                          value: (stars - 1) * 20,
                          modifier: CriterionModifier.greaterThan,
                        ),
                      );
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizedFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.common_organized,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: context.dimensions.spacingSmall,
          children: OrganizedFilter.values.map((option) {
            return ChoiceChip(
              label: Text(option.name.toUpperCase()),
              selected: _tempOrganized == option,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _tempOrganized = option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBooleanFilter(
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        Wrap(
          spacing: context.dimensions.spacingSmall,
          children: [
            ChoiceChip(
              label: Text(context.l10n.common_any),
              selected: value == null,
              onSelected: (selected) {
                if (selected) onChanged(null);
              },
            ),
            ChoiceChip(
              label: Text(context.l10n.common_yes),
              selected: value == true,
              onSelected: (selected) {
                if (selected) onChanged(true);
              },
            ),
            ChoiceChip(
              label: Text(context.l10n.common_no),
              selected: value == false,
              onSelected: (selected) {
                if (selected) onChanged(false);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResolutionFilter() {
    final resolutions = ['FOUR_K', 'FULL_HD', 'STANDARD_HD', 'STANDARD'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.images_resolution_title,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: resolutions.map((res) {
            final isSelected =
                _tempFilter.resolutions?.value.contains(res) ?? false;
            return FilterChip(
              label: Text(res.replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(
                    _tempFilter.resolutions?.value ?? [],
                  );
                  if (selected) {
                    current.add(res);
                  } else {
                    current.remove(res);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    resolutions: current.isEmpty
                        ? null
                        : MultiCriterion(value: current),
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrientationFilter() {
    final orientations = ['LANDSCAPE', 'PORTRAIT', 'SQUARE'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.common_orientation,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: orientations.map((ori) {
            final isSelected =
                _tempFilter.orientations?.value.contains(ori) ?? false;
            return FilterChip(
              label: Text(ori),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(
                    _tempFilter.orientations?.value ?? [],
                  );
                  if (selected) {
                    current.add(ori);
                  } else {
                    current.remove(ori);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    orientations: current.isEmpty
                        ? null
                        : MultiCriterion(value: current),
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEntityFilter<T>(
    String label,
    String providerType,
    dynamic criterion,
    ValueChanged<dynamic> onChanged,
    bool isHierarchical,
  ) {
    final List<String> selectedIds = criterion?.value ?? [];
    final modifier = criterion?.modifier ?? CriterionModifier.includes;

    return SelectionCriterionInput(
      label: label,
      selectedIds: selectedIds,
      modifier: modifier,
      onModifierChanged: (next) {
        onChanged(
          _buildEntityCriterion(
            ids: selectedIds,
            modifier: next,
            isHierarchical: isHierarchical,
          ),
        );
      },
      onAddPressed: () async {
        final result = await showDialog<List<T>>(
          context: context,
          builder: (context) => EntityPicker<T>(
            title: context.l10n.common_select(label),
            providerType: providerType,
            multiSelect: true,
            initialSelection: selectedIds,
          ),
        );
        if (result == null) return;

        final ids = result.map((entity) => _extractEntityId(entity)).toList();
        if (ids.isEmpty) {
          onChanged(null);
          return;
        }

        onChanged(
          _buildEntityCriterion(
            ids: ids,
            modifier: modifier,
            isHierarchical: isHierarchical,
          ),
        );
      },
      onRemoveId: (id) {
        final newList = List<String>.from(selectedIds)..remove(id);
        if (newList.isEmpty) {
          onChanged(null);
          return;
        }

        onChanged(
          _buildEntityCriterion(
            ids: newList,
            modifier: modifier,
            isHierarchical: isHierarchical,
          ),
        );
      },
    );
  }

  dynamic _buildEntityCriterion({
    required List<String> ids,
    required CriterionModifier modifier,
    required bool isHierarchical,
  }) {
    if (isHierarchical) {
      return HierarchicalMultiCriterion(value: ids, modifier: modifier);
    }
    return MultiCriterion(value: ids, modifier: modifier);
  }

  String _extractEntityId(Object? entity) {
    if (entity is Studio) return entity.id;
    if (entity is Performer) return entity.id;
    if (entity is Tag) return entity.id;
    if (entity is Group) return entity.id;
    if (entity is Gallery) return entity.id;
    throw StateError('Unsupported scene filter entity: ${entity.runtimeType}');
  }
}
