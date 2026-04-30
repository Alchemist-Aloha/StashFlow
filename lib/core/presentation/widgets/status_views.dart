import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A centered loading indicator for asynchronous operations.
class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// A centered error message with an optional retry button.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = theme.extension<AppDimensions>();
    final colors = theme.extension<AppColors>();
    
    // Fallback values if theme extensions are missing (e.g. in some tests)
    final spacingLarge = dims?.spacingLarge ?? 24.0;
    final spacingSmall = dims?.spacingSmall ?? 8.0;
    final fontSizeFactor = dims?.fontSizeFactor ?? 1.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48 * fontSizeFactor,
              color: colors?.error ?? Colors.redAccent,
            ),
            SizedBox(height: spacingSmall * 1.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: spacingLarge),
              FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
