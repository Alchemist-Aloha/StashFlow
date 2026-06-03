import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
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
      childrenPadding: EdgeInsets.symmetric(
        horizontal: context.dimensions.spacingMedium,
      ),
      children: children,
    );
  }
}

class SelectionCriterionInput extends StatelessWidget {
  const SelectionCriterionInput({
    required this.label,
    required this.selectedIds,
    required this.modifier,
    required this.onModifierChanged,
    required this.onAddPressed,
    required this.onRemoveId,
    super.key,
  });

  final String label;
  final List<String> selectedIds;
  final CriterionModifier modifier;
  final ValueChanged<CriterionModifier> onModifierChanged;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onRemoveId;

  @override
  Widget build(BuildContext context) {
    final canPickValues = !_isNullaryModifier(modifier);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              Expanded(
                child: DropdownButton<CriterionModifier>(
                  isExpanded: true,
                  value: modifier,
                  onChanged: (next) {
                    if (next != null) {
                      onModifierChanged(next);
                    }
                  },
                  items: _buildModifierItems(
                    context,
                    _selectionCriterionModifiers,
                  ),
                ),
              ),
              if (canPickValues) ...[
                SizedBox(width: context.dimensions.spacingSmall),
                IconButton(
                  tooltip: context.l10n.common_add,
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 24 * context.dimensions.fontSizeFactor,
                  ),
                  onPressed: onAddPressed,
                ),
              ],
            ],
          ),
          if (canPickValues && selectedIds.isNotEmpty)
            Wrap(
              spacing: context.dimensions.spacingSmall / 2,
              children: selectedIds
                  .map(
                    (id) =>
                        Chip(label: Text(id), onDeleted: () => onRemoveId(id)),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              DropdownButton<CriterionModifier>(
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
                SizedBox(width: context.dimensions.spacingSmall),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('int-primary-$label-$modifier'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    initialValue: value?.value.toString() ?? '',
                    decoration: InputDecoration(
                      hintText: context.l10n.filter_value,
                    ),
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
                ),
              ],
              if (showSecondaryValue) ...[
                SizedBox(width: context.dimensions.spacingSmall),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
            ],
          ),
        ],
      ),
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              DropdownButton<CriterionModifier>(
                value: modifier,
                onChanged: (mod) {
                  if (mod != null) {
                    onChanged(
                      MultiCriterion(value: value?.value ?? [], modifier: mod),
                    );
                  }
                },
                items: _buildModifierItems(
                  context,
                  _selectionCriterionModifiers,
                ),
              ),
              if (showSelections) ...[
                SizedBox(width: context.dimensions.spacingSmall),
                Expanded(
                  child: Wrap(
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
                            final newValue = List<String>.from(
                              value?.value ?? [],
                            );
                            newValue.remove(id);
                            onChanged(
                              MultiCriterion(
                                value: newValue,
                                modifier: modifier,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
    final modifier = value?.modifier ?? CriterionModifier.equals;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              DropdownButton<CriterionModifier>(
                value: modifier,
                onChanged: (mod) {
                  if (mod != null) {
                    if (_isNullaryModifier(mod)) {
                      onChanged(StringCriterion(value: "", modifier: mod));
                    } else {
                      onChanged(
                        StringCriterion(
                          value: value?.value ?? "",
                          modifier: mod,
                        ),
                      );
                    }
                  }
                },
                items: _buildModifierItems(context, _stringCriterionModifiers),
              ),
              SizedBox(width: context.dimensions.spacingSmall),
              if (!_isNullaryModifier(modifier))
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    initialValue: value?.value ?? '',
                    decoration: InputDecoration(
                      hintText: context.l10n.filter_value,
                    ),
                    onChanged: (val) {
                      onChanged(
                        StringCriterion(
                          value: val,
                          modifier: value?.modifier ?? CriterionModifier.equals,
                        ),
                      );
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              DropdownButton<CriterionModifier>(
                value: modifier,
                onChanged: (mod) {
                  if (mod != null) {
                    if (_isNullaryModifier(mod)) {
                      onChanged(DateCriterion(value: "", modifier: mod));
                    } else {
                      onChanged(
                        DateCriterion(
                          value: value?.value ?? "",
                          value2: _usesSecondaryValue(mod)
                              ? value?.value2
                              : null,
                          modifier: mod,
                        ),
                      );
                    }
                  }
                },
                items: _buildModifierItems(context, _dateCriterionModifiers),
              ),
              if (showPrimaryValue) ...[
                SizedBox(width: context.dimensions.spacingSmall),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
              if (showSecondaryValue) ...[
                SizedBox(width: context.dimensions.spacingSmall),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
