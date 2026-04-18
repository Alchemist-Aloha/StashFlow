import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/criterion.dart';

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
      childrenPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      children: children,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              DropdownButton<CriterionModifier>(
                value: value?.modifier ?? CriterionModifier.equals,
                onChanged: (mod) {
                  if (mod != null) {
                    onChanged(IntCriterion(
                      value: value?.value ?? 0,
                      value2: value?.value2,
                      modifier: mod,
                    ));
                  }
                },
                items: CriterionModifier.values.map((mod) {
                  return DropdownMenuItem(
                    value: mod,
                    child: Text(mod.name),
                  );
                }).toList(),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Value'),
                  onChanged: (val) {
                    final intVal = int.tryParse(val);
                    if (intVal != null) {
                      onChanged(IntCriterion(
                        value: intVal,
                        value2: value?.value2,
                        modifier: value?.modifier ?? CriterionModifier.equals,
                      ));
                    }
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelLarge),
          Row(
            children: [
              DropdownButton<CriterionModifier>(
                value: value?.modifier ?? CriterionModifier.includes,
                onChanged: (mod) {
                  if (mod != null) {
                    onChanged(MultiCriterion(
                      value: value?.value ?? [],
                      modifier: mod,
                    ));
                  }
                },
                items: [
                  CriterionModifier.includes,
                  CriterionModifier.excludes,
                  CriterionModifier.includesAll,
                  CriterionModifier.isNull,
                  CriterionModifier.notNull,
                ].map((mod) {
                  return DropdownMenuItem(
                    value: mod,
                    child: Text(mod.name),
                  );
                }).toList(),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () async {
                        // Show picker and update
                      },
                    ),
                    ...?value?.value.map((id) => Chip(
                      label: Text(id),
                      onDeleted: () {
                        final newValue = List<String>.from(value?.value ?? []);
                        newValue.remove(id);
                        onChanged(MultiCriterion(
                          value: newValue,
                          modifier: value?.modifier ?? CriterionModifier.includes,
                        ));
                      },
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
