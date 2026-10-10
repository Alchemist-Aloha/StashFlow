import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/performers/presentation/providers/performer_details_provider.dart';
import '../../../features/tags/presentation/providers/tag_details_provider.dart';
import '../../../features/studios/presentation/providers/studio_details_provider.dart';
import '../../../features/groups/presentation/providers/group_details_provider.dart';
import '../../../features/scenes/presentation/providers/scene_details_provider.dart';
import '../../../features/galleries/presentation/providers/gallery_details_provider.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/criterion.dart';

const _intCriterionModifiers = [
  CriterionModifier.equals,
  CriterionModifier.notEquals,
  CriterionModifier.greaterThan,
  CriterionModifier.lessThan,
  CriterionModifier.between,
  CriterionModifier.notBetween,
  CriterionModifier.isNull,
  CriterionModifier.notNull,
];

const _stringCriterionModifiers = [
  CriterionModifier.equals,
  CriterionModifier.notEquals,
  CriterionModifier.includes,
  CriterionModifier.excludes,
  CriterionModifier.matchesRegex,
  CriterionModifier.notMatchesRegex,
  CriterionModifier.isNull,
  CriterionModifier.notNull,
];

const _dateCriterionModifiers = [
  CriterionModifier.equals,
  CriterionModifier.notEquals,
  CriterionModifier.greaterThan,
  CriterionModifier.lessThan,
  CriterionModifier.between,
  CriterionModifier.notBetween,
  CriterionModifier.isNull,
  CriterionModifier.notNull,
];

const _selectionCriterionModifiers = [
  CriterionModifier.includes,
  CriterionModifier.excludes,
  CriterionModifier.includesAll,
  CriterionModifier.isNull,
  CriterionModifier.notNull,
];

bool _isNullaryModifier(CriterionModifier modifier) {
  return modifier == CriterionModifier.isNull ||
      modifier == CriterionModifier.notNull;
}

bool _usesSecondaryValue(CriterionModifier modifier) {
  return modifier == CriterionModifier.between ||
      modifier == CriterionModifier.notBetween;
}

Object _parseCustomFieldValue(String value) {
  if (value == 'true') return true;
  if (value == 'false') return false;
  return int.tryParse(value) ?? double.tryParse(value) ?? value;
}

String _criterionModifierLabel(
  BuildContext context,
  CriterionModifier modifier,
) {
  return switch (modifier) {
    CriterionModifier.equals => context.l10n.filter_equals,
    CriterionModifier.notEquals => context.l10n.filter_not_equals,
    CriterionModifier.greaterThan => context.l10n.filter_greater_than,
    CriterionModifier.lessThan => context.l10n.filter_less_than,
    CriterionModifier.isNull => context.l10n.filter_is_null,
    CriterionModifier.notNull => context.l10n.filter_not_null,
    CriterionModifier.includes => context.l10n.filter_includes,
    CriterionModifier.excludes => context.l10n.filter_excludes,
    CriterionModifier.includesAll => context.l10n.filter_includes_all,
    CriterionModifier.matchesRegex => context.l10n.filter_matches_regex,
    CriterionModifier.notMatchesRegex => context.l10n.filter_not_matches_regex,
    CriterionModifier.between => context.l10n.filter_between,
    CriterionModifier.notBetween => context.l10n.filter_not_between,
  };
}

List<DropdownMenuItem<CriterionModifier>> _buildModifierItems(
  BuildContext context,
  List<CriterionModifier> modifiers,
) {
  return modifiers
      .map(
        (modifier) => DropdownMenuItem(
          value: modifier,
          child: Text(_criterionModifierLabel(context, modifier)),
        ),
      )
      .toList(growable: false);
}

/// Shared label, spacing, and start alignment for every filter control.
class FilterField extends StatelessWidget {
  const FilterField({required this.label, required this.children, super.key});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.dimensions.spacingSmall,
      children: [
        Text(
          label,
          style: context.textTheme.labelLarge,
          textAlign: TextAlign.start,
        ),
        ...children,
      ],
    ),
  );
}

/// Full-width filter dropdown with scalable field and menu sizing.
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    itemHeight: null,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.dimensions.spacingMedium,
        vertical: context.dimensions.spacingSmall,
      ),
      constraints: BoxConstraints(
        minHeight: context.dimensions.buttonHeight.clamp(
          kMinInteractiveDimension,
          double.infinity,
        ),
      ),
    ),
    items: items,
    onChanged: onChanged,
  );
}

class FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const FilterSection({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title, style: context.textTheme.titleMedium),
      initiallyExpanded: initiallyExpanded,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      tilePadding: EdgeInsets.symmetric(
        horizontal: context.dimensions.spacingMedium,
      ),
      childrenPadding: EdgeInsets.symmetric(
        horizontal: context.dimensions.spacingMedium,
      ),
      children: children,
    );
  }
}

/// Selects the field whose value must be missing.
class MissingFieldCriterionInput extends StatelessWidget {
  const MissingFieldCriterionInput({
    required this.value,
    required this.fields,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final List<String> fields;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterField(
      label: context.l10n.auto_missing_field,
      children: [
        FilterDropdown<String?>(
          value: value,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(context.l10n.common_none),
            ),
            for (final field in fields)
              DropdownMenuItem<String?>(value: field, child: Text(field)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Displays entity names while retaining IDs as criterion and removal values.
class SelectionCriterionInput extends ConsumerWidget {
  const SelectionCriterionInput({
    required this.label,
    required this.selectedIds,
    required this.providerType,
    required this.modifier,
    required this.onModifierChanged,
    required this.onAddPressed,
    required this.onRemoveId,
    super.key,
  });

  final String label;
  final List<String> selectedIds;
  final String providerType;
  final CriterionModifier modifier;
  final ValueChanged<CriterionModifier> onModifierChanged;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onRemoveId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPickValues = !_isNullaryModifier(modifier);

    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          onChanged: (next) {
            if (next != null) onModifierChanged(next);
          },
          items: _buildModifierItems(context, _selectionCriterionModifiers),
        ),
        if (canPickValues)
          Wrap(
            spacing: context.dimensions.spacingSmall / 2,
            children: [
              IconButton(
                tooltip: context.l10n.common_add,
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 24 * context.dimensions.fontSizeFactor,
                ),
                onPressed: onAddPressed,
              ),
              for (final id in selectedIds)
                Chip(
                  label: Text(_entityLabel(ref, id)),
                  onDeleted: () => onRemoveId(id),
                ),
            ],
          ),
      ],
    );
  }

  String _entityLabel(WidgetRef ref, String id) {
    final name = switch (providerType) {
      'performer' => ref.watch(performerDetailsProvider(id)).value?.name,
      'tag' => ref.watch(tagDetailsProvider(id)).value?.name,
      'studio' => ref.watch(studioDetailsProvider(id)).value?.name,
      'group' => ref.watch(groupDetailsProvider(id)).value?.name,
      'scene' => ref.watch(sceneDetailsProvider(id)).value?.title,
      'gallery' => ref.watch(galleryDetailsProvider(id)).value?.displayName,
      _ => null,
    };
    return name == null || name.trim().isEmpty ? id : name;
  }
}

class IntCriterionInput extends StatelessWidget {
  final String label;
  final IntCriterion? value;
  final ValueChanged<IntCriterion?> onChanged;

  const IntCriterionInput({
    required this.label,
    this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final modifier = value?.modifier ?? CriterionModifier.equals;
    final showPrimaryValue = !_isNullaryModifier(modifier);
    final showSecondaryValue = _usesSecondaryValue(modifier);

    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          onChanged: (mod) {
            if (mod != null) {
              onChanged(
                IntCriterion(
                  value: value?.value ?? 0,
                  value2: _usesSecondaryValue(mod) ? value?.value2 : null,
                  modifier: mod,
                ),
              );
            }
          },
          items: _buildModifierItems(context, _intCriterionModifiers),
        ),
        if (showPrimaryValue) ...[
          TextFormField(
            key: ValueKey('int-primary-$label-$modifier'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            initialValue: value?.value.toString() ?? '',
            decoration: InputDecoration(hintText: context.l10n.filter_value),
            onChanged: (val) {
              final intVal = int.tryParse(val);
              if (intVal != null) {
                onChanged(
                  IntCriterion(
                    value: intVal,
                    value2: value?.value2,
                    modifier: modifier,
                  ),
                );
              }
            },
          ),
        ],
        if (showSecondaryValue) ...[
          TextFormField(
            key: ValueKey('int-secondary-$label-$modifier'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            initialValue: value?.value2?.toString() ?? '',
            decoration: InputDecoration(
              hintText: context.l10n.filter_value_secondary,
            ),
            onChanged: (val) {
              final intVal = int.tryParse(val);
              if (intVal != null) {
                onChanged(
                  IntCriterion(
                    value: value?.value ?? 0,
                    value2: intVal,
                    modifier: modifier,
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class MultiCriterionInput<T> extends StatelessWidget {
  final String label;
  final MultiCriterion? value;
  final ValueChanged<MultiCriterion?> onChanged;
  final Future<List<T>> Function() onSearch;
  final String Function(T) getLabel;
  final String Function(T) getId;

  const MultiCriterionInput({
    required this.label,
    this.value,
    required this.onChanged,
    required this.onSearch,
    required this.getLabel,
    required this.getId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final modifier = value?.modifier ?? CriterionModifier.includes;
    final showSelections = !_isNullaryModifier(modifier);

    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          onChanged: (mod) {
            if (mod != null) {
              onChanged(
                MultiCriterion(value: value?.value ?? [], modifier: mod),
              );
            }
          },
          items: _buildModifierItems(context, _selectionCriterionModifiers),
        ),
        if (showSelections) ...[
          Wrap(
            spacing: context.dimensions.spacingSmall / 2,
            children: [
              IconButton(
                tooltip: context.l10n.common_add,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  // Show picker and update.
                },
              ),
              ...?value?.value.map(
                (id) => Chip(
                  label: Text(id),
                  onDeleted: () {
                    final newValue = List<String>.from(value?.value ?? []);
                    newValue.remove(id);
                    onChanged(
                      MultiCriterion(value: newValue, modifier: modifier),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
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
    final modifier = value?.modifier ?? CriterionModifier.equals;

    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          onChanged: (mod) {
            if (mod != null) {
              if (_isNullaryModifier(mod)) {
                onChanged(StringCriterion(value: '', modifier: mod));
              } else {
                onChanged(
                  StringCriterion(value: value?.value ?? '', modifier: mod),
                );
              }
            }
          },
          items: _buildModifierItems(context, _stringCriterionModifiers),
        ),
        if (!_isNullaryModifier(modifier))
          TextFormField(
            textInputAction: TextInputAction.next,
            initialValue: value?.value ?? '',
            decoration: InputDecoration(hintText: context.l10n.filter_value),
            onChanged: (val) {
              onChanged(
                StringCriterion(
                  value: val,
                  modifier: value?.modifier ?? CriterionModifier.equals,
                ),
              );
            },
          ),
      ],
    );
  }
}

class DateCriterionInput extends StatelessWidget {
  final String label;
  final DateCriterion? value;
  final ValueChanged<DateCriterion?> onChanged;

  const DateCriterionInput({
    required this.label,
    this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final modifier = value?.modifier ?? CriterionModifier.equals;
    final showPrimaryValue = !_isNullaryModifier(modifier);
    final showSecondaryValue = _usesSecondaryValue(modifier);

    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          onChanged: (mod) {
            if (mod != null) {
              if (_isNullaryModifier(mod)) {
                onChanged(DateCriterion(value: '', modifier: mod));
              } else {
                onChanged(
                  DateCriterion(
                    value: value?.value ?? '',
                    value2: _usesSecondaryValue(mod) ? value?.value2 : null,
                    modifier: mod,
                  ),
                );
              }
            }
          },
          items: _buildModifierItems(context, _dateCriterionModifiers),
        ),
        if (showPrimaryValue) ...[
          TextFormField(
            key: ValueKey('date-primary-$label-$modifier'),
            textInputAction: TextInputAction.next,
            initialValue: value?.value ?? '',
            decoration: InputDecoration(
              hintText: context.l10n.common_hint_date,
            ),
            onChanged: (val) {
              onChanged(
                DateCriterion(
                  value: val,
                  value2: value?.value2,
                  modifier: value?.modifier ?? CriterionModifier.equals,
                ),
              );
            },
          ),
        ],
        if (showSecondaryValue) ...[
          TextFormField(
            key: ValueKey('date-secondary-$label-$modifier'),
            textInputAction: TextInputAction.next,
            initialValue: value?.value2 ?? '',
            decoration: InputDecoration(
              hintText: context.l10n.filter_value_secondary,
            ),
            onChanged: (val) {
              onChanged(
                DateCriterion(
                  value: value?.value ?? '',
                  value2: val,
                  modifier: modifier,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Edits a hierarchical criterion when the server exposes IDs without a picker.
class HierarchicalIdCriterionInput extends StatelessWidget {
  const HierarchicalIdCriterionInput({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final HierarchicalMultiCriterion? value;
  final ValueChanged<HierarchicalMultiCriterion?> onChanged;

  List<String> _ids(String text) => text
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final modifier = value?.modifier ?? CriterionModifier.includes;
    final enabled = !_isNullaryModifier(modifier);
    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          items: _buildModifierItems(context, _selectionCriterionModifiers),
          onChanged: (next) {
            if (next == null) return;
            onChanged(
              HierarchicalMultiCriterion(
                value: value?.value ?? const [],
                excludes: value?.excludes ?? const [],
                depth: value?.depth ?? 0,
                modifier: next,
              ),
            );
          },
        ),
        if (enabled) ...[
          TextFormField(
            initialValue: value?.value.join(', '),
            decoration: InputDecoration(labelText: context.l10n.filter_ids),
            onChanged: (text) => onChanged(
              HierarchicalMultiCriterion(
                value: _ids(text),
                excludes: value?.excludes ?? const [],
                depth: value?.depth ?? 0,
                modifier: modifier,
              ),
            ),
          ),
          TextFormField(
            initialValue: value?.excludes.join(', '),
            decoration: InputDecoration(
              labelText: context.l10n.filter_excluded_ids,
            ),
            onChanged: (text) => onChanged(
              HierarchicalMultiCriterion(
                value: value?.value ?? const [],
                excludes: _ids(text),
                depth: value?.depth ?? 0,
                modifier: modifier,
              ),
            ),
          ),
          TextFormField(
            initialValue: value?.depth.toString() ?? '0',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.l10n.filter_depth),
            onChanged: (text) => onChanged(
              HierarchicalMultiCriterion(
                value: value?.value ?? const [],
                excludes: value?.excludes ?? const [],
                depth: int.tryParse(text) ?? 0,
                modifier: modifier,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Edits an official Stash pHash-distance criterion.
class PhashCriterionInput extends StatelessWidget {
  const PhashCriterionInput({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final PhashCriterion? value;
  final ValueChanged<PhashCriterion?> onChanged;

  @override
  Widget build(BuildContext context) {
    final modifier = value?.modifier ?? CriterionModifier.equals;
    final enabled = !_isNullaryModifier(modifier);
    return FilterField(
      label: label,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          items: _buildModifierItems(context, const [
            CriterionModifier.equals,
            CriterionModifier.notEquals,
            CriterionModifier.isNull,
            CriterionModifier.notNull,
          ]),
          onChanged: (next) {
            if (next != null) {
              onChanged(
                PhashCriterion(
                  value: value?.value ?? '',
                  distance: value?.distance,
                  modifier: next,
                ),
              );
            }
          },
        ),
        if (enabled)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: value?.value,
                decoration: InputDecoration(
                  labelText: context.l10n.filter_value,
                ),
                onChanged: (text) => onChanged(
                  PhashCriterion(
                    value: text,
                    distance: value?.distance,
                    modifier: modifier,
                  ),
                ),
              ),
              SizedBox(height: context.dimensions.spacingSmall),
              TextFormField(
                initialValue: value?.distance?.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.filter_distance,
                ),
                onChanged: (text) => onChanged(
                  PhashCriterion(
                    value: value?.value ?? '',
                    distance: int.tryParse(text),
                    modifier: modifier,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Edits a Stash-box endpoint and Stash ID criterion.
class StashIdCriterionInput extends StatelessWidget {
  const StashIdCriterionInput({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final StashIdCriterion? value;
  final ValueChanged<StashIdCriterion?> onChanged;

  @override
  Widget build(BuildContext context) {
    final modifier = value?.modifier ?? CriterionModifier.equals;
    final enabled = !_isNullaryModifier(modifier);
    return FilterField(
      label: context.l10n.common_stash_id,
      children: [
        FilterDropdown<CriterionModifier>(
          value: modifier,
          items: _buildModifierItems(context, const [
            CriterionModifier.equals,
            CriterionModifier.notEquals,
            CriterionModifier.isNull,
            CriterionModifier.notNull,
          ]),
          onChanged: (next) {
            if (next != null) {
              onChanged(
                StashIdCriterion(
                  endpoint: value?.endpoint ?? '',
                  stashId: value?.stashId ?? '',
                  modifier: next,
                ),
              );
            }
          },
        ),
        if (enabled) ...[
          TextFormField(
            initialValue: value?.endpoint,
            decoration: InputDecoration(
              labelText: context.l10n.filter_endpoint,
            ),
            onChanged: (text) => onChanged(
              StashIdCriterion(
                endpoint: text,
                stashId: value?.stashId ?? '',
                modifier: modifier,
              ),
            ),
          ),
          TextFormField(
            initialValue: value?.stashId,
            decoration: InputDecoration(
              labelText: context.l10n.common_stash_id,
            ),
            onChanged: (text) => onChanged(
              StashIdCriterion(
                endpoint: value?.endpoint ?? '',
                stashId: text,
                modifier: modifier,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Edits the list of official Stash custom-field criteria.
class CustomFieldsCriterionInput extends StatelessWidget {
  const CustomFieldsCriterionInput({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<CustomFieldCriterion> value;
  final ValueChanged<List<CustomFieldCriterion>> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterField(
      label: context.l10n.filter_custom_fields,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            tooltip: context.l10n.common_add,
            onPressed: () =>
                onChanged([...value, const CustomFieldCriterion(field: '')]),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ),
        for (var index = 0; index < value.length; index++)
          _CustomFieldCriterionRow(
            key: ValueKey('custom-field-$index-${value[index].field}'),
            value: value[index],
            onChanged: (next) {
              final updated = [...value];
              updated[index] = next;
              onChanged(updated);
            },
            onRemove: () => onChanged([...value]..removeAt(index)),
          ),
      ],
    );
  }
}

class _CustomFieldCriterionRow extends StatelessWidget {
  const _CustomFieldCriterionRow({
    required this.value,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final CustomFieldCriterion value;
  final ValueChanged<CustomFieldCriterion> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.dimensions.spacingSmall),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: value.field,
                  decoration: InputDecoration(
                    labelText: context.l10n.filter_field,
                  ),
                  onChanged: (text) => onChanged(value.copyWith(field: text)),
                ),
              ),
              IconButton(
                tooltip: context.l10n.common_remove,
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
          TextFormField(
            initialValue: value.value.join(', '),
            decoration: InputDecoration(labelText: context.l10n.filter_values),
            onChanged: (text) => onChanged(
              value.copyWith(
                value: text
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .map<Object>(_parseCustomFieldValue)
                    .toList(growable: false),
              ),
            ),
          ),
          FilterDropdown<CriterionModifier>(
            value: value.modifier,
            items: _buildModifierItems(context, _stringCriterionModifiers),
            onChanged: (next) {
              if (next != null) onChanged(value.copyWith(modifier: next));
            },
          ),
        ],
      ),
    );
  }
}
