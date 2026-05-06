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
import '../../../../core/domain/entities/filter_options.dart';

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
                padding: EdgeInsets.all(context.dimensions.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.studios_filter_title,
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
                    bottom: bottomInset +
                        safeBottom +
                        context.dimensions.spacingLarge,
                  ),
                  child: Column(
                    children: [
                      _buildGeneralSection(),
                      _buildMetadataSection(),
                      _buildLibrarySection(),
                      _buildSystemSection(),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(context.dimensions.spacingMedium),
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
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_filters),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
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
                                content:
                                    Text(context.l10n.studios_filter_saved),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
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
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        _buildBooleanFilter(
          'Favorite',
          _tempFilter.favorite,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(favorite: val)),
        ),
        _buildRatingFilter(),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.studios_field_name,
          value: _tempFilter.name,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(name: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_details,
          value: _tempFilter.details,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_aliases,
          value: _tempFilter.aliases,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(aliases: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_url,
          value: _tempFilter.url,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        _buildOrganizedFilter(),
        _buildEntityFilter<Studio>(
          'Parent Studios',
          'studio',
          _tempFilter.parentStudios,
          (val) => setState(
            () => _tempFilter =
                _tempFilter.copyWith(parentStudios: val as HierarchicalMultiCriterion?),
          ),
          true,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?),
          ),
          true,
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        _buildBooleanFilter(
          'Is Missing',
          _tempFilter.isMissing,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(isMissing: val)),
        ),
        _buildBooleanFilter(
          'Ignore Auto Tag',
          _tempFilter.ignoreAutoTag,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: val)),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_scene_count,
          value: _tempFilter.sceneCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(sceneCount: val)),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_image_count,
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(imageCount: val)),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_gallery_count,
          value: _tempFilter.galleryCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(galleryCount: val)),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_sub_studio_count,
          value: _tempFilter.childCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(childCount: val)),
        ),
        DateCriterionInput(
          label: context.l10n.studios_field_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(createdAt: val)),
        ),
        DateCriterionInput(
          label: context.l10n.studios_field_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(updatedAt: val)),
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

  Widget _buildOrganizedFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.common_organized, style: context.textTheme.labelLarge),
        Wrap(
          spacing: context.dimensions.spacingSmall,
          children: OrganizedFilter.values.map((option) {
            return ChoiceChip(
              label: Text(option.name.toUpperCase()),
              selected:
                  OrganizedFilter.fromBool(_tempFilter.organized) == option,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _tempFilter =
                      _tempFilter.copyWith(organized: option.toBool()));
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBooleanFilter(
      String label, bool? value, ValueChanged<bool?> onChanged) {
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

  Widget _buildEntityFilter<T>(
    String label,
    String providerType,
    dynamic criterion,
    ValueChanged<dynamic> onChanged,
    bool isHierarchical,
  ) {
    final List<String> selectedIds = criterion?.value ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: context.textTheme.labelLarge),
              IconButton(
                tooltip: context.l10n.common_add,
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 24 * context.dimensions.fontSizeFactor,
                ),
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
                        modifier:
                            criterion?.modifier ?? CriterionModifier.includes,
                      ));
                    } else {
                      onChanged(MultiCriterion(
                        value: ids,
                        modifier:
                            criterion?.modifier ?? CriterionModifier.includes,
                      ));
                    }
                  }
                },
              ),
            ],
          ),
          if (selectedIds.isNotEmpty)
            Wrap(
              spacing: context.dimensions.spacingSmall / 2,
              children: selectedIds
                  .map((id) => Chip(
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
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
