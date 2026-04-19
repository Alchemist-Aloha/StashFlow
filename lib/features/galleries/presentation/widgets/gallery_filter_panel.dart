import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/gallery_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../../core/domain/entities/filter_options.dart';

class GalleryFilterPanel extends ConsumerStatefulWidget {
  const GalleryFilterPanel({super.key});

  @override
  ConsumerState<GalleryFilterPanel> createState() => _GalleryFilterPanelState();
}

class _GalleryFilterPanelState extends ConsumerState<GalleryFilterPanel> {
  late GalleryFilter _tempFilter;
  late OrganizedFilter _tempOrganized;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(galleryFilterStateProvider);
    _tempOrganized = ref.read(galleryOrganizedOnlyProvider);
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
                          _tempFilter = GalleryFilter.empty();
                          _tempOrganized = OrganizedFilter.all;
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
                              .read(galleryFilterStateProvider.notifier)
                              .update(_tempFilter);
                          ref
                              .read(galleryOrganizedOnlyProvider.notifier)
                              .set(_tempOrganized);
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
                              .read(galleryFilterStateProvider.notifier)
                              .update(_tempFilter);
                          ref
                              .read(galleryOrganizedOnlyProvider.notifier)
                              .set(_tempOrganized);
                          await ref
                              .read(galleryFilterStateProvider.notifier)
                              .saveAsDefault();
                          await ref
                              .read(galleryOrganizedOnlyProvider.notifier)
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
        _buildRatingFilter(),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: 'Metadata',
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
        DateCriterionInput(
          label: 'Date',
          value: _tempFilter.date,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(date: val)),
        ),
        IntCriterionInput(
          label: 'Performer Age',
          value: _tempFilter.performerAge,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(performerAge: val)),
        ),
        IntCriterionInput(
          label: 'Performer Count',
          value: _tempFilter.performerCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(performerCount: val)),
        ),
        IntCriterionInput(
          label: 'Tag Count',
          value: _tempFilter.tagCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
        StringCriterionInput(
          label: 'URL',
          value: _tempFilter.url,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: 'Library',
      children: [
        _buildOrganizedFilter(),
        _buildEntityFilter<Studio>(
          'Studios',
          'studio',
          _tempFilter.studios,
          (val) => setState(
              () => _tempFilter = _tempFilter.copyWith(studios: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Performer>(
          'Performers',
          'performer',
          _tempFilter.performers,
          (val) => setState(
              () => _tempFilter = _tempFilter.copyWith(performers: val as MultiCriterion?)),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(
              () => _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Tag>(
          'Performer Tags',
          'tag',
          _tempFilter.performerTags,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(performerTags: val as HierarchicalMultiCriterion?)),
          true,
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
        StringCriterionInput(
          label: 'Path',
          value: _tempFilter.path,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(path: val)),
        ),
        StringCriterionInput(
          label: 'Checksum',
          value: _tempFilter.checksum,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(checksum: val)),
        ),
        _buildBooleanFilter('Is Missing', _tempFilter.isMissing, (val) => setState(() => _tempFilter = _tempFilter.copyWith(isMissing: val))),
        _buildBooleanFilter('Is Zip', _tempFilter.isZip, (val) => setState(() => _tempFilter = _tempFilter.copyWith(isZip: val))),
        _buildBooleanFilter('Has Chapters', _tempFilter.hasChapters, (val) => setState(() => _tempFilter = _tempFilter.copyWith(hasChapters: val))),
        IntCriterionInput(
          label: 'Image Count',
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(imageCount: val)),
        ),
        IntCriterionInput(
          label: 'File Count',
          value: _tempFilter.fileCount,
          onChanged: (val) => setState(() => _tempFilter = _tempFilter.copyWith(fileCount: val)),
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
                          (stars > 0 && _tempFilter.rating100?.value == (stars - 1) * 20 && _tempFilter.rating100?.modifier == CriterionModifier.greaterThan),
                onSelected: (_) {
                  setState(() {
                    if (stars == 0) {
                      _tempFilter = _tempFilter.copyWith(rating100: null);
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        rating100: IntCriterion(value: (stars - 1) * 20, modifier: CriterionModifier.greaterThan),
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
          spacing: 8,
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
