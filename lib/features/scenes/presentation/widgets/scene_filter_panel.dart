import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/scene_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import 'entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../galleries/domain/entities/gallery.dart';

class SceneFilterPanel extends ConsumerStatefulWidget {
  const SceneFilterPanel({super.key});

  @override
  ConsumerState<SceneFilterPanel> createState() => _SceneFilterPanelState();
}

class _SceneFilterPanelState extends ConsumerState<SceneFilterPanel> {
  late SceneFilter _tempFilter;
  late bool _tempOrganizedOnly;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(sceneFilterStateProvider);
    _tempOrganizedOnly = ref.read(sceneOrganizedOnlyProvider);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusExtraLarge),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.scenes_filter_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = SceneFilter.empty();
                          _tempOrganizedOnly = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: bottomInset + safeBottom + AppTheme.spacingLarge,
                  ),
                  child: Column(
                    children: [
                      _buildGeneralSection(),
                      _buildMediaInfoSection(),
                      _buildPerformanceSection(),
                      _buildSystemSection(),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(sceneFilterStateProvider.notifier)
                              .update(_tempFilter);
                          ref
                              .read(sceneOrganizedOnlyProvider.notifier)
                              .set(_tempOrganizedOnly);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_filters),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          ref
                              .read(sceneFilterStateProvider.notifier)
                              .update(_tempFilter);
                          ref
                              .read(sceneOrganizedOnlyProvider.notifier)
                              .set(_tempOrganizedOnly);
                          await ref
                              .read(sceneFilterStateProvider.notifier)
                              .saveAsDefault();
                          await ref
                              .read(sceneOrganizedOnlyProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.galleries_filter_saved,
                                ),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_save_default),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: 'General',
      initiallyExpanded: true,
      children: [
        StringCriterionInput(
          label: 'Code',
          value: _tempFilter.code,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(code: val)),
        ),
        StringCriterionInput(
          label: 'Details',
          value: _tempFilter.details,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: 'Director',
          value: _tempFilter.director,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(director: val)),
        ),
        _buildRatingFilter(),
        _buildOrganizedFilter(),
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
        DateCriterionInput(
          label: 'Date',
          value: _tempFilter.date,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(date: val),
          ),
        ),
        IntCriterionInput(
          label: 'Performer Age',
          value: _tempFilter.performerAge,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerAge: val),
          ),
        ),
        IntCriterionInput(
          label: 'Tag Count',
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
        IntCriterionInput(
          label: 'Performer Count',
          value: _tempFilter.performerCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(performerCount: val)),
        ),
        StringCriterionInput(
          label: 'URL',
          value: _tempFilter.url,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(url: val),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaInfoSection() {
    return FilterSection(
      title: 'Media Info',
      children: [
        _buildResolutionFilter(),
        _buildOrientationFilter(),
        StringCriterionInput(
          label: 'Path',
          value: _tempFilter.path,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(path: val)),
        ),
        StringCriterionInput(
          label: 'Captions',
          value: _tempFilter.captions,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(captions: val)),
        ),
        IntCriterionInput(
          label: 'Duration (seconds)',
          value: _tempFilter.duration,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(duration: val)),
        ),
        IntCriterionInput(
          label: 'Bitrate',
          value: _tempFilter.bitrate,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(bitrate: val)),
        ),
        StringCriterionInput(
          label: 'Video Codec',
          value: _tempFilter.videoCodec,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(videoCodec: val)),
        ),
        StringCriterionInput(
          label: 'Audio Codec',
          value: _tempFilter.audioCodec,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(audioCodec: val)),
        ),
        IntCriterionInput(
          label: 'Framerate',
          value: _tempFilter.framerate,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(framerate: val)),
        ),
        IntCriterionInput(
          label: 'File Count',
          value: _tempFilter.fileCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(fileCount: val),
          ),
        ),
        IntCriterionInput(
          label: 'Resume Time',
          value: _tempFilter.resumeTime,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(resumeTime: val),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return FilterSection(
      title: 'Performance',
      children: [
        IntCriterionInput(
          label: 'Play Count',
          value: _tempFilter.playCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(playCount: val),
          ),
        ),
        IntCriterionInput(
          label: 'Play Duration',
          value: _tempFilter.playDuration,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(playDuration: val),
          ),
        ),
        IntCriterionInput(
          label: 'O-Counter',
          value: _tempFilter.oCounter,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(oCounter: val)),
        ),
        DateCriterionInput(
          label: 'Last Played At',
          value: _tempFilter.lastPlayedAt,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(lastPlayedAt: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: 'System',
      children: [
        IntCriterionInput(
          label: 'ID',
          value: _tempFilter.id,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(id: val)),
        ),
        IntCriterionInput(
          label: 'Stash ID Count',
          value: _tempFilter.stashIdCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(stashIdCount: val)),
        ),
        StringCriterionInput(
          label: 'Oshash',
          value: _tempFilter.oshash,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(oshash: val)),
        ),
        StringCriterionInput(
          label: 'Checksum',
          value: _tempFilter.checksum,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(checksum: val)),
        ),
        StringCriterionInput(
          label: 'Phash',
          value: _tempFilter.phash,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(phash: val)),
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
        _buildBooleanFilter(
          'Interactive',
          _tempFilter.interactive,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(interactive: val),
          ),
        ),
        IntCriterionInput(
          label: 'Interactive Speed',
          value: _tempFilter.interactiveSpeed,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(interactiveSpeed: val),
          ),
        ),
        DateCriterionInput(
          label: 'Created At',
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(createdAt: val)),
        ),
        DateCriterionInput(
          label: 'Updated At',
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(updatedAt: val)),
        ),
      ],
    );
  }

  Widget _buildDuplicatedFilter() {
    final options = ['phash', 'oshash'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duplicated'),
        Wrap(
          spacing: 4,
          children: options.map((opt) {
            final isSelected =
                _tempFilter.duplicated?.value.contains(opt) ?? false;
            return FilterChip(
              label: Text(opt.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current =
                      List<String>.from(_tempFilter.duplicated?.value ?? []);
                  if (selected) {
                    current.add(opt);
                  } else {
                    current.remove(opt);
                  }
                  
                  if (current.isEmpty) {
                    _tempFilter = _tempFilter.copyWith(duplicated: null);
                  } else {
                    _tempFilter = _tempFilter.copyWith(
                        duplicated: MultiCriterion(value: current));
                  }
                });
              }
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
          spacing: 4,
          children: [
            for (var stars = 0; stars <= 5; stars++)
              ChoiceChip(
                label: Text(stars == 0 ? 'Any' : '$stars'),
                selected:
                    (stars == 0 && _tempFilter.rating100 == null) ||
                    (_tempFilter.rating100?.value == stars * 20 &&
                        _tempFilter.rating100?.modifier ==
                            CriterionModifier.greaterThan),
                onSelected: (_) {
                  setState(() {
                    if (stars == 0) {
                      _tempFilter = _tempFilter.copyWith(rating100: null);
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        rating100: IntCriterion(
                          value: stars * 20,
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
    return _buildBooleanFilter(
      context.l10n.galleries_organized_only,
      _tempOrganizedOnly,
      (val) => setState(() => _tempOrganizedOnly = val ?? false),
    );
  }

  Widget _buildBooleanFilter(
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(value: value ?? false, onChanged: onChanged),
      ],
    );
  }

  Widget _buildResolutionFilter() {
    final resolutions = ['FOUR_K', 'FULL_HD', 'STANDARD_HD', 'STANDARD'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resolution'),
        Wrap(
          spacing: 4,
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
                  if (selected)
                    current.add(res);
                  else
                    current.remove(res);
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
        Text('Orientation'),
        Wrap(
          spacing: 4,
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
                  if (selected)
                    current.add(ori);
                  else
                    current.remove(ori);
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: context.textTheme.labelLarge),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  final result = await showDialog<List<T>>(
                    context: context,
                    builder: (context) => EntityPicker<T>(
                      title: 'Select $label',
                      providerType: providerType,
                      multiSelect: true,
                      initialSelection: selectedIds,
                    ),
                  );
                  if (result != null) {
                    final ids = result.map((e) {
                      if (e is Studio) return e.id;
                      if (e is Performer) return e.id;
                      if (e is Tag) return e.id;
                      return '';
                    }).toList();
                    if (isHierarchical) {
                      onChanged(
                        HierarchicalMultiCriterion(
                          value: ids,
                          modifier:
                              criterion?.modifier ?? CriterionModifier.includes,
                        ),
                      );
                    } else {
                      onChanged(
                        MultiCriterion(
                          value: ids,
                          modifier:
                              criterion?.modifier ?? CriterionModifier.includes,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          if (selectedIds.isNotEmpty)
            Wrap(
              spacing: 4,
              children: selectedIds
                  .map(
                    (id) => Chip(
                      label: Text(
                        id,
                      ), // Ideally show name, but we only have ID here
                      onDeleted: () {
                        final newList = List<String>.from(selectedIds);
                        newList.remove(id);
                        if (newList.isEmpty) {
                          onChanged(null);
                        } else {
                          if (isHierarchical) {
                            onChanged(
                              HierarchicalMultiCriterion(
                                value: newList,
                                modifier: criterion.modifier,
                              ),
                            );
                          } else {
                            onChanged(
                              MultiCriterion(
                                value: newList,
                                modifier: criterion.modifier,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
