import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_log_store.dart';
import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'section_header.dart';

/// A Links section listing an entity's URLs, each opening externally.
///
/// Shows the first [collapsedCount] links with a header Show more/Show less
/// toggle for the rest.
class EntityLinksSection extends StatefulWidget {
  const EntityLinksSection({required this.urls, super.key});

  static const collapsedCount = 5;

  final List<String> urls;

  @override
  State<EntityLinksSection> createState() => _EntityLinksSectionState();
}

class _EntityLinksSectionState extends State<EntityLinksSection> {
  bool _showAll = false;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.common_error(url))));
      }
    } on Exception catch (e, stackTrace) {
      AppLogStore.instance.addError(
        'open',
        e,
        stackTrace,
        source: 'entity_links_section',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.common_error(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    final collapsible = urls.length > EntityLinksSection.collapsedCount;
    final visible = _showAll || !collapsible
        ? urls
        : urls.take(EntityLinksSection.collapsedCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          key: const Key('entity_links_header'),
          title: context.l10n.details_links,
          padding: EdgeInsets.zero,
          onViewAll: collapsible
              ? () => setState(() => _showAll = !_showAll)
              : null,
          actionLabel: _showAll
              ? context.l10n.details_show_less
              : context.l10n.details_show_more,
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        for (final url in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
            child: InkWell(
              onTap: () => _open(url),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16, color: context.colors.primary),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      url,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
