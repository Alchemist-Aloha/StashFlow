import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';

class GroupFilterPanel extends ConsumerStatefulWidget {
  const GroupFilterPanel({super.key});

  @override
  ConsumerState<GroupFilterPanel> createState() => _GroupFilterPanelState();
}

class _GroupFilterPanelState extends ConsumerState<GroupFilterPanel> {
  late GroupFilter _tempFilter;

  static const _missingFieldOptions = <String, String>{
    'director': 'Director',
    'synopsis': 'Synopsis',
    'date': 'Date',
    'url': 'URL',
  };

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(groupListFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Material(
          color: context.colors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusExtraLarge),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(context.dimensions.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.common_filter,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = GroupFilter.empty();
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
                    bottom:
                        bottomInset +
                        safeBottom +
                        context.dimensions.spacingLarge,
                  ),
                  child: Column(
                    children: [
                      FilterSection(
                        title: context.l10n.filter_group_general,
                        initiallyExpanded: true,
                        children: [
                          DropdownButtonFormField<String?>(
                            value: _tempFilter.isMissingField,
                            decoration: const InputDecoration(
                              labelText: 'Missing Field',
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(context.l10n.common_none),
                              ),
                              ..._missingFieldOptions.entries.map(
                                (entry) => DropdownMenuItem<String?>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  isMissingField: value,
                                  clearIsMissingField: value == null,
                                );
                              });
                            },
                          ),
                          IntCriterionInput(
                            label: 'Sub-group Count',
                            value: _tempFilter.subGroupCount,
                            onChanged: (value) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  subGroupCount: value,
                                  clearSubGroupCount: value == null,
                                );
                              });
                            },
                          ),
                          IntCriterionInput(
                            label: context.l10n.sort_scene_count,
                            value: _tempFilter.sceneCount,
                            onChanged: (value) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  sceneCount: value,
                                  clearSceneCount: value == null,
                                );
                              });
                            },
                          ),
                        ],
                      ),
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
                              .read(groupListProvider.notifier)
                              .setFilter(_tempFilter);
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
                              .read(groupListProvider.notifier)
                              .setFilter(_tempFilter);
                          await ref
                              .read(groupListFilterProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
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
}
