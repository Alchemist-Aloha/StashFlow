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
                      context.l10n.images_filter_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = ImageFilter.empty();
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
                    bottom: bottomInset + safeBottom + context.dimensions.spacingLarge,
                  ),
                  child: Column(
                    children: [
                      _buildGeneralSection(),
                      _buildMetadataSection(),
                      _buildLibrarySection(),
                      _buildMediaInfoSection(),
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
                              .read(imageFilterStateProvider.notifier)
                              .updateFilter(_tempFilter);
                          ref
                              .read(imageOrganizedOnlyProvider.notifier)
                              .set(_tempOrganized);
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
                              .read(imageFilterStateProvider.notifier)
                              .updateFilter(_tempFilter);
                          ref
                              .read(imageOrganizedOnlyProvider.notifier)
                              .set(_tempOrganized);
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
                                content: Text(context.l10n.images_filter_saved),
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
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(title: val)),
        ),
        StringCriterionInput(
          label: 'Details',
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
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
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(studios: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Performer>(
          'Performers',
          'performer',
          _tempFilter.performers,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(performers: val as MultiCriterion?)),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(tags: val as HierarchicalMultiCriterion?)),
          true,
        ),
        _buildEntityFilter<Gallery>(
          'Galleries',
          'gallery',
          _tempFilter.galleries,
          (val) => setState(() =>
              _tempFilter = _tempFilter.copyWith(galleries: val as MultiCriterion?)),
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
        Text(context.l10n.galleries_min_rating,
            style: context.textTheme.labelLarge),
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
                            modifier: CriterionModifier.greaterThan),
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
      '4320p'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.images_resolution_title,
            style: context.textTheme.labelLarge),
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
                  final current =
                      List<String>.from(_tempFilter.resolution?.value ?? []);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.common_orientation,
            style: context.textTheme.labelLarge),
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
                  final current =
                      List<String>.from(_tempFilter.orientation?.value ?? []);
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
              spacing: context.dimensions.spacingSmall / 2,
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
