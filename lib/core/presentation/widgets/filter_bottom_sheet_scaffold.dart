import 'package:flutter/material.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'bottom_sheet_panel_chrome.dart';

class FilterBottomSheetScaffold extends StatelessWidget {
  const FilterBottomSheetScaffold({
    super.key,
    required this.title,
    required this.onReset,
    required this.body,
    required this.onApply,
    required this.onSaveDefault,
    this.saveDefaultSuccessMessage,
  });

  final String title;
  final VoidCallback onReset;
  final Widget body;
  final VoidCallback onApply;
  final Future<void> Function() onSaveDefault;
  final String? saveDefaultSuccessMessage;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: FrostedPanel(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusExtraLarge),
          ),
          child: Column(
            children: [
              BottomSheetPanelHeader(title: title, onReset: onReset),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom:
                        bottomInset +
                        safeBottom +
                        context.dimensions.spacingLarge,
                  ),
                  child: body,
                ),
              ),
              const Divider(height: 1),
              BottomSheetPanelActions(
                primaryLabel: context.l10n.common_apply_filters,
                secondaryLabel: context.l10n.common_save_default,
                onPrimary: () {
                  onApply();
                  Navigator.pop(context);
                },
                onSecondary: () async {
                  await onSaveDefault();
                  if (!context.mounted) return;

                  Navigator.pop(context);
                  final message = saveDefaultSuccessMessage;
                  if (message != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
