import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/graphql/media_headers_provider.dart';
import '../../utils/l10n_extensions.dart';
import '../providers/related_entities_provider.dart';
import '../theme/app_theme.dart';
import 'section_header.dart';
import 'section_panel.dart';
import 'stash_image.dart';

void _openRelated(
  BuildContext context,
  String route, {
  required bool closesSheet,
}) {
  final router = GoRouter.of(context);
  if (closesSheet) Navigator.of(context).pop();
  unawaited(router.push(route));
}

/// A tappable row that opens a related entity's details page, such as a parent
/// studio, a sub-group, or a group a scene belongs to.
///
/// Placeholder server images (`default=true`) fall back to [fallbackIcon].
class RelatedEntityTile extends ConsumerWidget {
  const RelatedEntityTile({
    required this.title,
    required this.route,
    required this.fallbackIcon,
    this.imagePath,
    this.subtitle,
    this.closesSheet = false,
    super.key,
  });

  final String title;

  /// Pops the enclosing bottom sheet before navigating, so the new page is
  /// not opened underneath it.
  final bool closesSheet;

  /// Location pushed on tap, for example `/groups/group/1`.
  final String route;
  final IconData fallbackIcon;
  final String? imagePath;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = imagePath?.trim();
    final hasImage =
        path != null && path.isNotEmpty && !path.contains('default=true');
    final description = subtitle?.trim();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: hasImage
          ? CircleAvatar(
              backgroundColor: context.colors.surfaceVariant,
              foregroundImage: StashImage.provider(
                ref,
                path,
                headers: ref.watch(mediaHeadersProvider),
              ),
              child: Icon(fallbackIcon),
            )
          : CircleAvatar(child: Icon(fallbackIcon)),
      title: Text(title, style: context.textTheme.bodyLarge),
      subtitle: description == null || description.isEmpty
          ? null
          : Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openRelated(context, route, closesSheet: closesSheet),
    );
  }
}

/// Compact chips that each open a related entity, such as parent tags.
class EntityLinkChips extends StatelessWidget {
  const EntityLinkChips({
    required this.links,
    this.closesSheet = false,
    super.key,
  });

  /// Chip labels with the location each one pushes.
  final List<({String label, String route})> links;

  /// See [RelatedEntityTile.closesSheet].
  final bool closesSheet;

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
            onPressed: () =>
                _openRelated(context, link.route, closesSheet: closesSheet),
          ),
      ],
    );
  }
}

/// A details-page section listing entities related through [query], such as
/// a tag's performers. Renders nothing while loading or when the list is
/// empty, so pages only show sections that have content.
class RelatedEntitiesSection extends ConsumerStatefulWidget {
  const RelatedEntitiesSection({
    required this.title,
    required this.query,
    required this.fallbackIcon,
    this.collapsedCount,
    super.key,
  });

  final String title;
  final RelatedEntityQuery query;
  final IconData fallbackIcon;

  /// Optional initial row limit, with a header Show more/Show less toggle.
  /// Omitting it keeps the entire related list visible.
  final int? collapsedCount;

  @override
  ConsumerState<RelatedEntitiesSection> createState() =>
      _RelatedEntitiesSectionState();
}

class _RelatedEntitiesSectionState
    extends ConsumerState<RelatedEntitiesSection> {
  bool _showAll = false;

  @override
  void didUpdateWidget(RelatedEntitiesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) _showAll = false;
  }

  @override
  Widget build(BuildContext context) {
    final related = ref.watch(relatedEntitiesProvider(widget.query));
    final limit = widget.collapsedCount;
    final collapsible = limit != null && (related.value?.length ?? 0) > limit;
    final content = related.when(
      data: (entities) => entities.isEmpty
          ? null
          : [
              for (final entity
                  in _showAll || limit == null
                      ? entities
                      : entities.take(limit))
                Padding(
                  padding: EdgeInsets.only(
                    top: context.dimensions.spacingSmall,
                  ),
                  child: RelatedEntityTile(
                    title: entity.title,
                    subtitle: entity.subtitle,
                    route: entity.route,
                    imagePath: entity.imagePath,
                    fallbackIcon: widget.fallbackIcon,
                  ),
                ),
            ],
      loading: () => null,
      error: (error, _) => [
        Text(
          context.l10n.common_error(error.toString()),
          style: context.textTheme.bodySmall,
        ),
      ],
    );
    if (content == null) return const SizedBox.shrink();
    return SectionPanel(
      margin: EdgeInsets.only(bottom: context.dimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: widget.title,
            padding: EdgeInsets.zero,
            onViewAll: collapsible
                ? () => setState(() => _showAll = !_showAll)
                : null,
            actionLabel: _showAll
                ? context.l10n.details_show_less
                : context.l10n.details_show_more,
          ),
          ...content,
        ],
      ),
    );
  }
}
