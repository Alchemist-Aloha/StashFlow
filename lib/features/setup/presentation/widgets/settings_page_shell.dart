import 'package:flutter/material.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class SettingsPageShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
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
      surfaceTintColor: colorScheme.surfaceTint,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
        onTap: onTap,
      ),
    );
  }
}
