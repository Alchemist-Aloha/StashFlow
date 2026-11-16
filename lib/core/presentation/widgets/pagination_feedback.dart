import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../utils/app_log_store.dart';
import '../../utils/l10n_extensions.dart';

/// Loads another page without letting a failed background request escape.
/// The list retains its loaded items; Retry requests the same failed page.
Future<void> loadNextPageWithFeedback(
  BuildContext context,
  Future<void> Function() fetch,
) async {
  if (!context.mounted) return;
  try {
    await fetch();
  } on Object catch (error, stackTrace) {
    AppLogStore.instance.addError(
      'fetchNextPage',
      error,
      stackTrace,
      source: 'list_pagination',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.common_error(error.toString())),
          action: SnackBarAction(
            label: context.l10n.common_retry,
            onPressed: () =>
                unawaited(loadNextPageWithFeedback(context, fetch)),
          ),
        ),
      );
  }
}
