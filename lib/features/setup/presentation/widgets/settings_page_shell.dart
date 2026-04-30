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
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final double maxContentWidth;
  final Widget? floatingActionButton;

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
      floatingActionButton: floatingActionButton,
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
    this.padding,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 32.0 * context.dimensions.fontSizeFactor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dimensions.spacingSmall,
              ),
              child: Text(
                title!,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
          if (subtitle != null) ...[
            SizedBox(height: 4 * context.dimensions.fontSizeFactor),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dimensions.spacingSmall,
              ),
              child: Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (title != null || subtitle != null)
            SizedBox(height: context.dimensions.spacingMedium),
          child,
        ],
      ),
    );
  }
}

class SettingsActionCard extends StatefulWidget {
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
  State<SettingsActionCard> createState() => _SettingsActionCardState();
}

class _SettingsActionCardState extends State<SettingsActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
        ),
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dimensions.spacingMedium,
              vertical: context.dimensions.spacingMedium,
            ),
            child: Row(
              children: [
                Container(
                  width: 48 * context.dimensions.fontSizeFactor,
                  height: 48 * context.dimensions.fontSizeFactor,
                  decoration: ShapeDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        32 * context.dimensions.fontSizeFactor,
                      ),
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: colorScheme.primary,
                    size: 24 * context.dimensions.fontSizeFactor,
                  ),
                ),
                SizedBox(width: context.dimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2 * context.dimensions.fontSizeFactor),
                      Text(
                        widget.subtitle,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.dimensions.spacingSmall),
                widget.trailing ??
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14 * context.dimensions.fontSizeFactor,
                      color: colorScheme.outline,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
