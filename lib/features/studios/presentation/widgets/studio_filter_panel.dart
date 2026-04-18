import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/studio_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/studio_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../domain/entities/studio.dart';
import '../../../tags/domain/entities/tag.dart';

class StudioFilterPanel extends ConsumerStatefulWidget {
  const StudioFilterPanel({super.key});

  @override
  ConsumerState<StudioFilterPanel> createState() => _StudioFilterPanelState();
}

class _StudioFilterPanelState extends ConsumerState<StudioFilterPanel> {
  late StudioFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(studioFilterStateProvider);
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
                      'Studio Filters',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = StudioFilter.empty();
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
                              .read(studioFilterStateProvider.notifier)
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
                              .read(studioFilterStateProvider.notifier)
                              .update(_tempFilter);
                          await ref
                              .read(studioFilterStateProvider.notifier)
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
        StringCriterionInput(
          label: 'Name',
          value: _tempFilter.name,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(name: val)),
        ),
        StringCriterionInput(
          label: 'Details',
          value: _tempFilter.details,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: 'Aliases',
          value: _tempFilter.aliases,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(aliases: val)),
        ),
        _buildBooleanFilter('Favorite', _tempFilter.favorite, (val) => setState(() => _tempFilter = _tempFilter.copyWith(favorite: val))),
        _buildBooleanFilter('Organized', _tempFilter.organized, (val) => setState(() => _tempFilter = _tempFilter.copyWith(organized: val))),
        _buildEntityFilter<Studio>(
          'Parent Studios',
          'studio',
          _tempFilter.parentStudios,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(parentStudios: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?)),
          true,
        ),
        StringCriterionInput(
          label: 'URL',
          value: _tempFilter.url,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
        IntCriterionInput(
          label: 'Tag Count',
          value: _tempFilter.tagCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
        IntCriterionInput(
          label: 'Rating',
          value: _tempFilter.rating100,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(rating100: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: 'System',
      children: [
        _buildBooleanFilter('Is Missing', _tempFilter.isMissing, (val) => setState(() => _tempFilter = _tempFilter.copyWith(isMissing: val))),
        _buildBooleanFilter('Ignore Auto Tag', _tempFilter.ignoreAutoTag, (val) => setState(() => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: val))),
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
          label: 'Sub-studio Count',
          value: _tempFilter.childCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(childCount: val)),
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
