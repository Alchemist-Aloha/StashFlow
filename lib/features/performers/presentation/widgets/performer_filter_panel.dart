import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/performer_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/performer_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../groups/domain/entities/group.dart';

class PerformerFilterPanel extends ConsumerStatefulWidget {
  const PerformerFilterPanel({super.key});

  @override
  ConsumerState<PerformerFilterPanel> createState() => _PerformerFilterPanelState();
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
                      'Performer Filters',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = PerformerFilter.empty();
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
                      _buildMetadataSection(),
                      _buildLibrarySection(),
                      _buildPhysicalSection(),
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
                              .read(performerFilterStateProvider.notifier)
                              .update(_tempFilter);
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
                              .read(performerFilterStateProvider.notifier)
                              .update(_tempFilter);
                          await ref
                              .read(performerFilterStateProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.performers_filter_saved),
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
        _buildBooleanFilter(
          'Favorite',
          _tempFilter.favorite,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(favorite: val)),
        ),
        _buildRatingFilter(),
        _buildGenderFilter(),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: 'Metadata',
      children: [
        StringCriterionInput(
          label: 'Name',
          value: _tempFilter.name,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(name: val)),
        ),
        StringCriterionInput(
          label: 'Aliases',
          value: _tempFilter.aliases,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(aliases: val)),
        ),
        StringCriterionInput(
          label: 'Disambiguation',
          value: _tempFilter.disambiguation,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(disambiguation: val)),
        ),
        StringCriterionInput(
          label: 'URL',
          value: _tempFilter.url,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
        StringCriterionInput(
          label: 'Details',
          value: _tempFilter.details,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: 'Country',
          value: _tempFilter.country,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(country: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: 'Library',
      children: [
        _buildEntityFilter<Studio>(
          'Studios',
          'studio',
          _tempFilter.studios,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(studios: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Group>(
          'Groups',
          'group',
          _tempFilter.groups,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(groups: val as HierarchicalMultiCriterion?)),
          true,
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
                label: stars == 0
                    ? const Text('Any')
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$stars'),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 16),
                        ],
                      ),
                selected: (stars == 0 && _tempFilter.rating100 == null) ||
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

  Widget _buildPhysicalSection() {
    return FilterSection(
      title: 'Physical',
      children: [
        DateCriterionInput(
          label: 'Birth Date',
          value: _tempFilter.birthdate,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(birthdate: val)),
        ),
        IntCriterionInput(
          label: 'Birth Year',
          value: _tempFilter.birthYear,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(birthYear: val)),
        ),
        IntCriterionInput(
          label: 'Age',
          value: _tempFilter.age,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(age: val)),
        ),
        IntCriterionInput(
          label: 'Height (cm)',
          value: _tempFilter.heightCm,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(heightCm: val)),
        ),
        IntCriterionInput(
          label: 'Weight (kg)',
          value: _tempFilter.weight,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(weight: val)),
        ),
        IntCriterionInput(
          label: 'Penis Length',
          value: _tempFilter.penisLength,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(penisLength: val)),
        ),
        _buildCircumcisedFilter(),
        StringCriterionInput(
          label: 'Hair Color',
          value: _tempFilter.hairColor,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(hairColor: val)),
        ),
        StringCriterionInput(
          label: 'Eye Color',
          value: _tempFilter.eyeColor,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(eyeColor: val)),
        ),
        StringCriterionInput(
          label: 'Ethnicity',
          value: _tempFilter.ethnicity,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(ethnicity: val)),
        ),
        StringCriterionInput(
          label: 'Measurements',
          value: _tempFilter.measurements,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(measurements: val)),
        ),
        StringCriterionInput(
          label: 'Fake Tits',
          value: _tempFilter.fakeTits,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(fakeTits: val)),
        ),
        StringCriterionInput(
          label: 'Tattoos',
          value: _tempFilter.tattoos,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(tattoos: val)),
        ),
        StringCriterionInput(
          label: 'Piercings',
          value: _tempFilter.piercings,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(piercings: val)),
        ),
        DateCriterionInput(
          label: 'Career Start',
          value: _tempFilter.careerStart,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(careerStart: val)),
        ),
        DateCriterionInput(
          label: 'Career End',
          value: _tempFilter.careerEnd,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(careerEnd: val)),
        ),
        DateCriterionInput(
          label: 'Death Date',
          value: _tempFilter.deathDate,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(deathDate: val)),
        ),
        IntCriterionInput(
          label: 'Death Year',
          value: _tempFilter.deathYear,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(deathYear: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: 'System',
      children: [
        _buildBooleanFilter('Ignore Auto Tag', _tempFilter.ignoreAutoTag, (val) => setState(() => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: val))),
        _buildBooleanFilter('Is Missing', _tempFilter.isMissing, (val) => setState(() => _tempFilter = _tempFilter.copyWith(isMissing: val))),
        IntCriterionInput(
          label: 'Scene Count',
          value: _tempFilter.sceneCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(sceneCount: val)),
        ),
        IntCriterionInput(
          label: 'Image Count',
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(imageCount: val)),
        ),
        IntCriterionInput(
          label: 'Gallery Count',
          value: _tempFilter.galleryCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(galleryCount: val)),
        ),
        IntCriterionInput(
          label: 'Play Count',
          value: _tempFilter.playCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(playCount: val)),
        ),
        IntCriterionInput(
          label: 'O-Counter',
          value: _tempFilter.oCounter,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(oCounter: val)),
        ),
        IntCriterionInput(
          label: 'Tag Count',
          value: _tempFilter.tagCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
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

  Widget _buildBooleanFilter(String label, bool? value, ValueChanged<bool?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Any'),
              selected: value == null,
              onSelected: (selected) {
                if (selected) onChanged(null);
              },
            ),
            ChoiceChip(
              label: const Text('Yes'),
              selected: value == true,
              onSelected: (selected) {
                if (selected) onChanged(true);
              },
            ),
            ChoiceChip(
              label: const Text('No'),
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

  Widget _buildGenderFilter() {
    final genders = ['MALE', 'FEMALE', 'TRANSGENDER_MALE', 'TRANSGENDER_FEMALE', 'INTERSEX', 'NON_BINARY'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.performers_gender, style: context.textTheme.labelLarge),
        Wrap(
          spacing: 4,
          children: genders.map((g) {
            final isSelected = _tempFilter.gender?.value.contains(g) ?? false;
            return FilterChip(
              label: Text(g.replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final current = List<String>.from(_tempFilter.gender?.value ?? []);
                  if (selected) {
                    current.add(g);
                  } else {
                    current.remove(g);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    gender: current.isEmpty ? null : MultiCriterion(value: current),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.performers_circumcised, style: context.textTheme.labelLarge),
        Wrap(
          spacing: 4,
          children: values.map((v) => ChoiceChip(
            label: Text(v),
            selected: _tempFilter.circumcised == v,
            onSelected: (selected) {
              setState(() => _tempFilter = _tempFilter.copyWith(circumcised: selected ? v : null));
            },
          )).toList(),
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
                tooltip: 'Add',
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
                      if (e is Tag) return e.id;
                      return '';
                    }).toList();
                    if (isHierarchical) {
                      onChanged(HierarchicalMultiCriterion(
                        value: ids,
                        modifier: criterion?.modifier ?? CriterionModifier.includes,
                      ));
                    } else {
                      onChanged(MultiCriterion(
                        value: ids,
                        modifier: criterion?.modifier ?? CriterionModifier.includes,
                      ));
                    }
                  }
                },
              ),
            ],
          ),
          if (selectedIds.isNotEmpty)
            Wrap(
              spacing: 4,
              children: selectedIds.map((id) => Chip(
                label: Text(id),
                onDeleted: () {
                  final newList = List<String>.from(selectedIds);
                  newList.remove(id);
                  if (newList.isEmpty) {
                    onChanged(null);
                  } else {
                    if (isHierarchical) {
                      onChanged(HierarchicalMultiCriterion(
                        value: newList,
                        modifier: criterion.modifier,
                      ));
                    } else {
                      onChanged(MultiCriterion(
                        value: newList,
                        modifier: criterion.modifier,
                      ));
                    }
                  }
                },
              )).toList(),
            ),
        ],
      ),
    );
  }
}
