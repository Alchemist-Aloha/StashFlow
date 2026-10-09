import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/image_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/image_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../../core/domain/entities/filter_options.dart';

import '../../../galleries/domain/entities/gallery.dart';

class ImageFilterPanel extends ConsumerStatefulWidget {
  const ImageFilterPanel({super.key});

  @override
  ConsumerState<ImageFilterPanel> createState() => _ImageFilterPanelState();
}

class _ImageFilterPanelState extends ConsumerState<ImageFilterPanel> {
  late ImageFilter _tempFilter;
  late OrganizedFilter _tempOrganized;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(imageFilterStateProvider).filter;
    _tempOrganized = ref.read(imageOrganizedOnlyProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.images_filter_title,
      onReset: () {
        setState(() {
          _tempFilter = ImageFilter.empty();
          _tempOrganized = OrganizedFilter.all;
        });
      },
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildMetadataSection(),
          _buildLibrarySection(),
          _buildPerformerSection(),
          _buildMediaInfoSection(),
          _buildSystemSection(),
        ],
      ),
      onApply: () {
        ref.read(imageFilterStateProvider.notifier).updateFilter(_tempFilter);
        ref.read(imageOrganizedOnlyProvider.notifier).set(_tempOrganized);
      },
      onSaveDefault: () async {
        ref.read(imageFilterStateProvider.notifier).updateFilter(_tempFilter);
        ref.read(imageOrganizedOnlyProvider.notifier).set(_tempOrganized);
        await Future.wait([
          ref.read(imageFilterStateProvider.notifier).saveAsDefault(),
          ref.read(imageOrganizedOnlyProvider.notifier).saveAsDefault(),
        ]);
      },
      saveDefaultSuccessMessage: context.l10n.images_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [_buildRatingFilter()],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.images_field_title,
          value: _tempFilter.title,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(title: val)),
        ),
        StringCriterionInput(
          label: context.l10n.images_field_details,
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_code,
          value: _tempFilter.code,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(code: value)),
        ),
        StringCriterionInput(
          label: context.l10n.filter_photographer,
          value: _tempFilter.photographer,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(photographer: value),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.common_date,
          value: _tempFilter.date,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(date: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        _buildOrganizedFilter(),
        HierarchicalIdCriterionInput(
          label: context.l10n.filter_folder,
          value: _tempFilter.folder,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(folder: value)),
        ),
        _buildEntityFilter<Studio>(
          context.l10n.studios_title,
          'studio',
          _tempFilter.studios,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              studios: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        _buildEntityFilter<Tag>(
          context.l10n.tags_title,
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
          label: context.l10n.galleries_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
        _buildEntityFilter<Gallery>(
          context.l10n.galleries_title,
          'gallery',
          _tempFilter.galleries,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              galleries: val as MultiCriterion?,
            ),
          ),
          false,
        ),
      ],
    );
  }

  Widget _buildPerformerSection() {
    return FilterSection(
      title: context.l10n.filter_group_performer,
      children: [
        _buildEntityFilter<Performer>(
          context.l10n.performers_title,
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
          context.l10n.tags_title,
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
          label: context.l10n.galleries_field_performer_count,
          value: _tempFilter.performerCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_performer_age,
          value: _tempFilter.performerAge,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerAge: val),
          ),
        ),
        _buildBooleanFilter(
          context.l10n.common_favorites_only,
          _tempFilter.performerFavorite,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerFavorite: val),
          ),
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
        PhashCriterionInput(
          label: context.l10n.scenes_field_phash,
          value: _tempFilter.phashDistance,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(phashDistance: value),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        StringCriterionInput(
          label: context.l10n.galleries_field_checksum,
          value: _tempFilter.checksum,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(checksum: val)),
        ),
        StringCriterionInput(
          label: context.l10n.images_field_path,
          value: _tempFilter.path,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(path: val)),
        ),
        StringCriterionInput(
          label: context.l10n.images_field_url,
          value: _tempFilter.url,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
        MissingFieldCriterionInput(
          value: _tempFilter.isMissing,
          fields: const [
            'title',
            'details',
            'photographer',
            'url',
            'date',
            'code',
            'rating',
            'galleries',
            'studio',
            'performers',
            'tags',
          ],
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: value),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.images_field_file_count,
          value: _tempFilter.fileCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(fileCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.images_field_o_counter,
          value: _tempFilter.oCounter,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(oCounter: val)),
        ),
        DateCriterionInput(
          label: context.l10n.sort_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.sort_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(updatedAt: val),
          ),
        ),
        CustomFieldsCriterionInput(
          value: _tempFilter.customFields,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(customFields: value),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return FilterField(
      label: context.l10n.galleries_min_rating,
      children: [
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
    return FilterField(
      label: context.l10n.common_organized,
      children: [
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
    return FilterField(
      label: label,
      children: [
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
    final resolutions = [
      '144p',
      '240p',
      '360p',
      '480p',
      '540p',
      '720p',
      '1080p',
      '1440p',
      '1920p',
      '2160p',
      '4320p',
    ];
    return FilterField(
      label: context.l10n.images_resolution_title,
      children: [
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: resolutions.map((res) {
            final isSelected =
                _tempFilter.resolution?.value.contains(res) ?? false;
            return FilterChip(
              label: Text(res),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(
                    _tempFilter.resolution?.value ?? [],
                  );
                  if (selected) {
                    current.add(res);
                  } else {
                    current.remove(res);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    resolution: current.isEmpty
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
    return FilterField(
      label: context.l10n.common_orientation,
      children: [
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: orientations.map((ori) {
            final isSelected =
                _tempFilter.orientation?.value.contains(ori) ?? false;
            return FilterChip(
              label: Text(ori),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(
                    _tempFilter.orientation?.value ?? [],
                  );
                  if (selected) {
                    current.add(ori);
                  } else {
                    current.remove(ori);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    orientation: current.isEmpty
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
    final selectedIds =
        (criterion?.value as List<dynamic>?)?.cast<String>() ?? <String>[];
    final modifier =
        criterion?.modifier as CriterionModifier? ?? CriterionModifier.includes;

    return SelectionCriterionInput(
      label: label,
      selectedIds: selectedIds,
      providerType: providerType,
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

        final ids = result.map(_extractEntityId).toList();
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
    if (entity is Gallery) return entity.id;
    throw StateError('Unsupported image filter entity: ${entity.runtimeType}');
  }
}
