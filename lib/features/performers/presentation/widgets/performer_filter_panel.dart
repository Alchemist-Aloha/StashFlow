import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/performer_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/performer_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../groups/domain/entities/group.dart';

class PerformerFilterPanel extends ConsumerStatefulWidget {
  const PerformerFilterPanel({super.key});

  @override
  ConsumerState<PerformerFilterPanel> createState() =>
      _PerformerFilterPanelState();
}

class _PerformerFilterPanelState extends ConsumerState<PerformerFilterPanel> {
  late PerformerFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(performerFilterStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.performer_filters,
      onReset: () {
        setState(() {
          _tempFilter = PerformerFilter.empty();
        });
      },
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildMetadataSection(),
          _buildLibrarySection(),
          _buildPhysicalSection(),
          _buildSystemSection(),
        ],
      ),
      onApply: () =>
          ref.read(performerFilterStateProvider.notifier).update(_tempFilter),
      onSaveDefault: () async {
        ref.read(performerFilterStateProvider.notifier).update(_tempFilter);
        await ref.read(performerFilterStateProvider.notifier).saveAsDefault();
      },
      saveDefaultSuccessMessage: context.l10n.performers_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        BooleanCriterionInput(
          label: 'Favorite',
          value: _tempFilter.favorite,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(favorite: val)),
        ),
        RatingCriterionInput(
          criterion: _tempFilter.rating100,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(rating100: value),
          ),
        ),
        _buildGenderFilter(),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.performers_field_name,
          value: _tempFilter.name,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(name: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_aliases,
          value: _tempFilter.aliases,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(aliases: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_disambiguation,
          value: _tempFilter.disambiguation,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(disambiguation: val),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_url,
          value: _tempFilter.url,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_details,
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_country,
          value: _tempFilter.country,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(country: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        EntityCriterionInput<Studio>(
          label: 'Studios',
          providerType: 'studio',
          criterion: _tempFilter.studios,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              studios: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Tag>(
          label: 'Tags',
          providerType: 'tag',
          criterion: _tempFilter.tags,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Group>(
          label: 'Groups',
          providerType: 'group',
          criterion: _tempFilter.groups,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              groups: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
      ],
    );
  }

  Widget _buildPhysicalSection() {
    return FilterSection(
      title: context.l10n.filter_group_physical,
      children: [
        DateCriterionInput(
          label: context.l10n.performers_field_birthdate,
          value: _tempFilter.birthdate,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(birthdate: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_birth_year,
          value: _tempFilter.birthYear,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(birthYear: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_age,
          value: _tempFilter.age,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(age: val)),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_height_cm,
          value: _tempFilter.heightCm,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(heightCm: val)),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_weight_kg,
          value: _tempFilter.weight,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(weight: val)),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_penis_length,
          value: _tempFilter.penisLength,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(penisLength: val),
          ),
        ),
        _buildCircumcisedFilter(),
        StringCriterionInput(
          label: context.l10n.performers_field_hair_color,
          value: _tempFilter.hairColor,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(hairColor: val),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_eye_color,
          value: _tempFilter.eyeColor,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(eyeColor: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_ethnicity,
          value: _tempFilter.ethnicity,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(ethnicity: val),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_measurements,
          value: _tempFilter.measurements,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(measurements: val),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_fake_tits,
          value: _tempFilter.fakeTits,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(fakeTits: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_tattoos,
          value: _tempFilter.tattoos,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tattoos: val)),
        ),
        StringCriterionInput(
          label: context.l10n.performers_field_piercings,
          value: _tempFilter.piercings,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(piercings: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.performers_field_career_start,
          value: _tempFilter.careerStart,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(careerStart: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.performers_field_career_end,
          value: _tempFilter.careerEnd,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(careerEnd: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.performers_field_deathdate,
          value: _tempFilter.deathDate,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(deathDate: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_death_year,
          value: _tempFilter.deathYear,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(deathYear: val),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        BooleanCriterionInput(
          label: 'Ignore Auto Tag',
          value: _tempFilter.ignoreAutoTag,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: val),
          ),
        ),
        MissingFieldCriterionInput(
          value: _tempFilter.isMissing,
          fields: const [
            'url',
            'ethnicity',
            'country',
            'hair_color',
            'eye_color',
            'height',
            'weight',
            'measurements',
            'fake_tits',
            'penis_length',
            'circumcised',
            'career_start',
            'career_end',
            'tattoos',
            'piercings',
            'aliases',
            'gender',
            'birthdate',
            'death_date',
            'disambiguation',
            'tags',
            'image',
            'details',
            'rating',
            'stash_id',
          ],
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: value),
          ),
        ),
        StashIdCriterionInput(
          value: _tempFilter.stashIdEndpoint,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(stashIdEndpoint: value),
          ),
        ),
        CustomFieldsCriterionInput(
          value: _tempFilter.customFields,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(customFields: value),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_scene_count,
          value: _tempFilter.sceneCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(sceneCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_image_count,
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(imageCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_gallery_count,
          value: _tempFilter.galleryCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(galleryCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_play_count,
          value: _tempFilter.playCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(playCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_o_counter,
          value: _tempFilter.oCounter,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(oCounter: val)),
        ),
        IntCriterionInput(
          label: context.l10n.performers_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
        DateCriterionInput(
          label: context.l10n.performers_field_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.performers_field_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(updatedAt: val),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    final genders = [
      'MALE',
      'FEMALE',
      'TRANSGENDER_MALE',
      'TRANSGENDER_FEMALE',
      'INTERSEX',
      'NON_BINARY',
    ];
    return FilterField(
      label: context.l10n.performers_gender,
      children: [
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: genders.map((g) {
            final isSelected = _tempFilter.gender?.value.contains(g) ?? false;
            return FilterChip(
              label: Text(g.replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(
                    _tempFilter.gender?.value ?? [],
                  );
                  if (selected) {
                    current.add(g);
                  } else {
                    current.remove(g);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    gender: current.isEmpty
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

  Widget _buildCircumcisedFilter() {
    final values = ['CUT', 'UNCUT'];
    return FilterField(
      label: context.l10n.performers_circumcised,
      children: [
        Wrap(
          spacing: context.dimensions.spacingSmall / 2,
          children: values
              .map(
                (v) => ChoiceChip(
                  label: Text(v),
                  selected: _tempFilter.circumcised == v,
                  onSelected: (selected) {
                    setState(
                      () => _tempFilter = _tempFilter.copyWith(
                        circumcised: selected ? v : null,
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
