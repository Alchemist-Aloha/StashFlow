import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

class SettingsPageShell extends ConsumerWidget {
  const SettingsPageShell({
    super.key,
    required this.title,
    required this.child,
    this.maxContentWidth = 920,
  });

  final String title;
  final Widget child;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final canGoToLibrary = serverUrl.isNotEmpty;

    // Use maybeOf to avoid throwing in tests that don't provide a GoRouter
    final router = GoRouter.maybeOf(context);
    final canPop = router?.canPop() ?? false;

    Widget? leading;
    if (!canPop && canGoToLibrary) {
      leading = IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: context.l10n.common_close,
        onPressed: () => context.go('/scenes'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), leading: leading),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (title != null || subtitle != null)
              const SizedBox(height: AppTheme.spacingMedium),
            child,
          ],
        ),
      ),
    );
  }
}

class SettingsActionCard extends StatelessWidget {
  const SettingsActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colorScheme.outline,
            ),
        onTap: onTap,
      ),
    );
  }
}
