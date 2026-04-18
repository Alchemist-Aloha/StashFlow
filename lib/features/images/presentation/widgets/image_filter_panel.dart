import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/image_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/image_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';

import '../../../galleries/domain/entities/gallery.dart';

class ImageFilterPanel extends ConsumerStatefulWidget {
  const ImageFilterPanel({super.key});

  @override
  ConsumerState<ImageFilterPanel> createState() => _ImageFilterPanelState();
}

class _ImageFilterPanelState extends ConsumerState<ImageFilterPanel> {
  late ImageFilter _tempFilter;
  late bool _tempOrganizedOnly;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(imageFilterStateProvider).filter;
    _tempOrganizedOnly = ref.read(imageOrganizedOnlyProvider);
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
                      context.l10n.galleries_filter_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = ImageFilter.empty();
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
                              .read(imageFilterStateProvider.notifier)
                              .updateFilter(_tempFilter);
                          ref
                              .read(imageOrganizedOnlyProvider.notifier)
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
                              .read(imageFilterStateProvider.notifier)
                              .updateFilter(_tempFilter);
                          ref
                              .read(imageOrganizedOnlyProvider.notifier)
                              .set(_tempOrganizedOnly);
                          await ref
                              .read(imageFilterStateProvider.notifier)
                              .saveAsDefault();
                          await ref
                              .read(imageOrganizedOnlyProvider.notifier)
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
          label: 'Title',
          value: _tempFilter.title,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(title: val)),
        ),
        StringCriterionInput(
          label: 'Details',
          value: _tempFilter.details,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        _buildRatingFilter(),
        _buildOrganizedFilter(),
        _buildEntityFilter<Studio>(
          'Studios',
          'studio',
          _tempFilter.studios,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(studios: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Performer>(
          'Performers',
          'performer',
          _tempFilter.performers,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(performers: val as MultiCriterion?)),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Gallery>(
          'Galleries',
          'gallery',
          _tempFilter.galleries,
          (val) => setState(() => _tempFilter = _tempFilter.copyWith(galleries: val as MultiCriterion?)),
          false,
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
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: 'System',
      children: [
        StringCriterionInput(
            label: 'Path',
            value: _tempFilter.path,
            onChanged: (val) =>
                setState(() => _tempFilter = _tempFilter.copyWith(path: val))),
        StringCriterionInput(
            label: 'URL',
            value: _tempFilter.url,
            onChanged: (val) =>
                setState(() => _tempFilter = _tempFilter.copyWith(url: val))),
        _buildBooleanFilter('Is Missing', _tempFilter.isMissing,
            (val) => setState(() => _tempFilter = _tempFilter.copyWith(isMissing: val))),
        IntCriterionInput(
          label: 'File Count',
          value: _tempFilter.fileCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(fileCount: val)),
        ),
        IntCriterionInput(
          label: 'O-Counter',
          value: _tempFilter.oCounter,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(oCounter: val)),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.galleries_min_rating, style: context.textTheme.labelLarge),
        Wrap(
          spacing: 4,
          children: [
            for (var stars = 0; stars <= 5; stars++)
              ChoiceChip(
                label: Text(stars == 0 ? 'Any' : '$stars'),
                selected: (stars == 0 && _tempFilter.rating100 == null) || 
                          (_tempFilter.rating100?.value == stars * 20 && _tempFilter.rating100?.modifier == CriterionModifier.greaterThan),
                onSelected: (_) {
                  setState(() {
                    if (stars == 0) {
                      _tempFilter = _tempFilter.copyWith(rating100: null);
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        rating100: IntCriterion(value: stars * 20, modifier: CriterionModifier.greaterThan),
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
    return _buildBooleanFilter(context.l10n.galleries_organized_only, _tempOrganizedOnly, (val) => setState(() => _tempOrganizedOnly = val ?? false));
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

  Widget _buildResolutionFilter() {
    return FilterSection(
      title: 'Resolution',
      children: [
        DropdownButtonFormField<CriterionModifier>(
          value: _tempFilter.resolution?.modifier ?? CriterionModifier.equals,
          decoration: const InputDecoration(labelText: 'Modifier'),
          items: const [
            DropdownMenuItem(value: CriterionModifier.equals, child: Text('Equals')),
            DropdownMenuItem(value: CriterionModifier.notEquals, child: Text('Not Equals')),
            DropdownMenuItem(value: CriterionModifier.greaterThan, child: Text('Greater Than')),
            DropdownMenuItem(value: CriterionModifier.lessThan, child: Text('Less Than')),
            DropdownMenuItem(value: CriterionModifier.isNull, child: Text('Is Null')),
            DropdownMenuItem(value: CriterionModifier.notNull, child: Text('Not Null')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                if (_tempFilter.resolution != null) {
                  _tempFilter = _tempFilter.copyWith(
                    resolution: MultiCriterion(value: _tempFilter.resolution!.value, modifier: val),
                  );
                } else {
                  _tempFilter = _tempFilter.copyWith(
                    resolution: MultiCriterion(value: [], modifier: val),
                  );
                }
              });
            }
          },
        ),
        if (_tempFilter.resolution?.modifier != CriterionModifier.isNull &&
            _tempFilter.resolution?.modifier != CriterionModifier.notNull)
          DropdownButtonFormField<String>(
            value: _tempFilter.resolution?.value.isNotEmpty == true ? _tempFilter.resolution!.value.first : null,
            decoration: const InputDecoration(labelText: 'Value'),
            items: const [
              DropdownMenuItem(value: '144p', child: Text('144p')),
              DropdownMenuItem(value: '240p', child: Text('240p')),
              DropdownMenuItem(value: '360p', child: Text('360p')),
              DropdownMenuItem(value: '480p', child: Text('480p')),
              DropdownMenuItem(value: '540p', child: Text('540p')),
              DropdownMenuItem(value: '720p', child: Text('720p')),
              DropdownMenuItem(value: '1080p', child: Text('1080p')),
              DropdownMenuItem(value: '1440p', child: Text('1440p')),
              DropdownMenuItem(value: '1920p', child: Text('1920p')),
              DropdownMenuItem(value: '2160p', child: Text('4K (2160p)')),
              DropdownMenuItem(value: '4320p', child: Text('8K (4320p)')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(
                    resolution: MultiCriterion(
                      value: [val],
                      modifier: _tempFilter.resolution?.modifier ?? CriterionModifier.equals,
                    ),
                  );
                });
              }
            },
          ),
      ],
    );
  }

  Widget _buildOrientationFilter() {
    return FilterSection(
      title: 'Orientation',
      children: [
        DropdownButtonFormField<String>(
          value: _tempFilter.orientation?.value.isNotEmpty == true ? _tempFilter.orientation!.value.first : null,
          decoration: const InputDecoration(labelText: 'Value'),
          items: const [
            DropdownMenuItem(value: 'PORTRAIT', child: Text('Portrait')),
            DropdownMenuItem(value: 'LANDSCAPE', child: Text('Landscape')),
            DropdownMenuItem(value: 'SQUARE', child: Text('Square')),
          ],
          onChanged: (val) {
            setState(() {
              if (val != null) {
                _tempFilter = _tempFilter.copyWith(
                  orientation: MultiCriterion(
                    value: [val],
                    modifier: _tempFilter.orientation?.modifier ?? CriterionModifier.equals,
                  ),
                );
              } else {
                _tempFilter = _tempFilter.copyWith(orientation: null);
              }
            });
          },
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
