import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'stash_image.dart';

/// A tappable row that opens a related entity's details page, such as a parent
/// studio, a sub-group, or a group a scene belongs to.
///
/// Placeholder server images (`default=true`) fall back to [fallbackIcon].
class RelatedEntityTile extends StatelessWidget {
  const RelatedEntityTile({
    required this.title,
    required this.route,
    required this.fallbackIcon,
    this.imagePath,
    this.subtitle,
    super.key,
  });

  final String title;

  /// Location pushed on tap, for example `/groups/group/1`.
  final String route;
  final IconData fallbackIcon;
  final String? imagePath;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage =
        path != null && path.isNotEmpty && !path.contains('default=true');
    final size = 40 * context.dimensions.fontSizeFactor;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: hasImage
            ? ClipOval(
                child: StashImage(
                  imageUrl: path,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  memCacheWidth: 120,
                ),
              )
            : Icon(fallbackIcon),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(route),
    );
  }
}

/// Compact chips that each open a related entity, such as parent tags.
class EntityLinkChips extends StatelessWidget {
  const EntityLinkChips({required this.links, super.key});

  /// Chip labels with the location each one pushes.
  final List<({String label, String route})> links;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.dimensions.spacingSmall,
      runSpacing: context.dimensions.spacingSmall,
      children: [
        for (final link in links)
          ActionChip(
            label: Text(link.label, style: context.textTheme.bodySmall),
            visualDensity: VisualDensity.compact,
            onPressed: () => context.push(link.route),
          ),
      ],
    );
  }
}
