import 'package:flutter/material.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'bottom_sheet_panel_chrome.dart';

class ListSortBottomSheet<T> extends StatefulWidget {
  const ListSortBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.commonOptions,
    required this.initialOption,
    required this.initialDescending,
    required this.resetOption,
    required this.resetDescending,
    required this.optionLabel,
    required this.onApply,
    required this.onSaveDefault,
    this.saveDefaultSuccessMessage,
  });

  final String title;
  final List<T> options;

  /// When set, other options are disclosed in an advanced section. The selected
  /// option stays in the first group even when it is not a common option.
  final List<T>? commonOptions;
  final T initialOption;
  final bool initialDescending;
  final T resetOption;
  final bool resetDescending;
  final String Function(T option) optionLabel;
  final void Function(T option, bool descending) onApply;
  final Future<void> Function() onSaveDefault;
  final String? saveDefaultSuccessMessage;

  @override
  State<ListSortBottomSheet<T>> createState() => _ListSortBottomSheetState<T>();
}

class _ListSortBottomSheetState<T> extends State<ListSortBottomSheet<T>> {
  late T _tempOption;
  late bool _tempDescending;
  late final ScrollController _optionsScrollController;

  @override
  void initState() {
    super.initState();
    _tempOption = widget.initialOption;
    _tempDescending = widget.initialDescending;
    _optionsScrollController = ScrollController();
  }

  @override
  void dispose() {
    _optionsScrollController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(_tempOption, _tempDescending);
    Navigator.pop(context);
  }

  Future<void> _saveDefault() async {
    widget.onApply(_tempOption, _tempDescending);
    await widget.onSaveDefault();
    if (!mounted) return;

    Navigator.pop(context);
    final message = widget.saveDefaultSuccessMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _optionChips(Iterable<T> options) => Wrap(
    spacing: context.dimensions.spacingSmall,
    runSpacing: context.dimensions.spacingSmall,
    children: options
        .map(
          (option) => ChoiceChip(
            label: Text(widget.optionLabel(option)),
            selected: _tempOption == option,
            onSelected: (selected) {
              if (!selected) return;
              setState(() => _tempOption = option);
            },
          ),
        )
        .toList(),
  );

  @override
  Widget build(BuildContext context) {
    final commonOptions = widget.commonOptions;
    final advancedOptions = commonOptions == null
        ? <T>[]
        : widget.options
              .where(
                (option) =>
                    !commonOptions.contains(option) && option != _tempOption,
              )
              .toList();
    return FractionallySizedBox(
      // Use the modal's available height and keep it stable while options expand.
      heightFactor: 0.88,
      child: SafeArea(
        top: false,
        child: FrostedPanel(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusExtraLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Scrollbar(
                  controller: _optionsScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _optionsScrollController,
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BottomSheetPanelHeader(
                          title: widget.title,
                          onReset: () {
                            setState(() {
                              _tempOption = widget.resetOption;
                              _tempDescending = widget.resetDescending;
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimensions.spacingLarge,
                          ),
                          child: Text(
                            context.l10n.common_sort_method,
                            style: context.textTheme.labelLarge,
                          ),
                        ),
                        SizedBox(height: context.dimensions.spacingSmall),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimensions.spacingLarge,
                            vertical: context.dimensions.spacingSmall,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _optionChips(
                                commonOptions == null
                                    ? widget.options
                                    : widget.options.where(
                                        (option) =>
                                            commonOptions.contains(option) ||
                                            option == _tempOption,
                                      ),
                              ),
                              if (advancedOptions.isNotEmpty)
                                ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text(
                                    context.l10n.common_advanced_sort_options,
                                  ),
                                  children: [_optionChips(advancedOptions)],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.dimensions.spacingMedium),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimensions.spacingLarge,
                          ),
                          child: Text(
                            context.l10n.common_direction,
                            style: context.textTheme.labelLarge,
                          ),
                        ),
                        SizedBox(height: context.dimensions.spacingSmall),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimensions.spacingLarge,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(
                                  value: true,
                                  label: Text(context.l10n.common_descending),
                                  icon: const Icon(Icons.arrow_downward),
                                ),
                                ButtonSegment(
                                  value: false,
                                  label: Text(context.l10n.common_ascending),
                                  icon: const Icon(Icons.arrow_upward),
                                ),
                              ],
                              selected: {_tempDescending},
                              onSelectionChanged: (value) =>
                                  setState(() => _tempDescending = value.first),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BottomSheetPanelActions(
                primaryLabel: context.l10n.common_apply_sort,
                secondaryLabel: context.l10n.common_save_default,
                onPrimary: _apply,
                onSecondary: _saveDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
