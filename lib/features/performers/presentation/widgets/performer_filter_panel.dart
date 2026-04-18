import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/performer_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/performer_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../domain/entities/performer.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../tags/domain/entities/tag.dart';

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
                                content: Text(context.l10n.galleries_filter_saved),
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
        _buildBooleanFilter('Favorite', _tempFilter.favorite, (val) => setState(() => _tempFilter = _tempFilter.copyWith(favorite: val))),
        _buildGenderFilter(),
        _buildEntityFilter<Studio>(
          'Studios',
          'studio',
          _tempFilter.studios,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(studios: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?)),
          true,
        ),
        IntCriterionInput(
          label: 'Rating',
          value: _tempFilter.rating100,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(rating100: val)),
        ),
      ],
    );
  }

  Widget _buildPhysicalSection() {
    return FilterSection(
      title: 'Physical',
      children: [
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
        _buildCircumcisedFilter(),
        StringCriterionInput(
          label: 'Ethnicity',
          value: _tempFilter.ethnicity,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(ethnicity: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: 'System',
      children: [
        _buildBooleanFilter('Is Missing', _tempFilter.isMissing, (val) => setState(() => _tempFilter = _tempFilter.copyWith(isMissing: val))),
        IntCriterionInput(
          label: 'Scene Count',
          value: _tempFilter.sceneCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(sceneCount: val)),
        ),
      ],
    );
  }

  Widget _buildBooleanFilter(String label, bool? value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value ?? false,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    final genders = ['MALE', 'FEMALE', 'TRANSGENDER_MALE', 'TRANSGENDER_FEMALE', 'INTERSEX', 'NON_BINARY'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: context.textTheme.labelLarge),
        Wrap(
          spacing: 4,
          children: genders.map((g) => ChoiceChip(
            label: Text(g.replaceAll('_', ' ')),
            selected: _tempFilter.gender == g,
            onSelected: (selected) {
              setState(() => _tempFilter = _tempFilter.copyWith(gender: selected ? g : null));
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCircumcisedFilter() {
    final values = ['CUT', 'UNCUT'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Circumcised', style: context.textTheme.labelLarge),
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

class StringCriterionInput extends StatelessWidget {
  final String label;
  final StringCriterion? value;
  final ValueChanged<StringCriterion?> onChanged;

  const StringCriterionInput({
    required this.label,
    this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(hintText: label),
                  onChanged: (val) {
                    onChanged(StringCriterion(
                      value: val,
                      modifier: value?.modifier ?? CriterionModifier.equals,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
