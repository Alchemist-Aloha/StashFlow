import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/models/scraped_scene.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class EnhancedScrapeDialog extends StatefulWidget {
  final ScrapedScene original;
  final ScrapedScene scraped;

  const EnhancedScrapeDialog({
    required this.original,
    required this.scraped,
    super.key,
  });

  @override
  State<EnhancedScrapeDialog> createState() => _EnhancedScrapeDialogState();
}

class _EnhancedScrapeDialogState extends State<EnhancedScrapeDialog> {
  late ScrapedScene _result;
  final Map<String, bool> _useScraped = {};

  @override
  void initState() {
    super.initState();
    _result = widget.scraped; // Default to use all scraped
    _useScraped['title'] = widget.scraped.title != null;
    _useScraped['details'] = widget.scraped.details != null;
    _useScraped['date'] = widget.scraped.date != null;
    _useScraped['studio'] = widget.scraped.studio != null || widget.scraped.studioId != null;
    _useScraped['image'] = widget.scraped.image != null;
  }

  void _updateResult() {
    setState(() {
      _result = ScrapedScene(
        remoteSiteId: widget.scraped.remoteSiteId,
        title: _useScraped['title'] == true ? widget.scraped.title : widget.original.title,
        details: _useScraped['details'] == true ? widget.scraped.details : widget.original.details,
        date: _useScraped['date'] == true ? widget.scraped.date : widget.original.date,
        urls: widget.scraped.urls, // URLs are usually merged or replaced
        image: _useScraped['image'] == true ? widget.scraped.image : widget.original.image,
        studio: _useScraped['studio'] == true ? widget.scraped.studio : widget.original.studio,
        studioId: _useScraped['studio'] == true ? widget.scraped.studioId : widget.original.studioId,
        performers: widget.scraped.performers, // Performers are merged in edit page
        tags: widget.scraped.tags, // Tags are merged in edit page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.scenes_select_result),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMergeRow(
              'title',
              context.l10n.common_title,
              widget.original.title,
              widget.scraped.title,
            ),
            _buildMergeRow(
              'details',
              context.l10n.common_details,
              widget.original.details,
              widget.scraped.details,
            ),
            _buildMergeRow(
              'date',
              context.l10n.common_release_date,
              widget.original.date?.toIso8601String().split('T').first,
              widget.scraped.date?.toIso8601String().split('T').first,
            ),
            _buildMergeRow(
              'studio',
              context.l10n.scenes_field_studio,
              widget.original.studio?.name ?? widget.original.studioId,
              widget.scraped.studio?.name ?? widget.scraped.studioId,
            ),
            _buildMergeRow(
              'image',
              context.l10n.common_image,
              widget.original.image != null ? '[Original Image]' : null,
              widget.scraped.image != null ? '[Scraped Image]' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_result),
          child: Text(context.l10n.common_apply),
        ),
      ],
    );
  }

  Widget _buildMergeRow(String field, String label, String? original, String? scraped) {
    if (scraped == null || scraped.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (original != null && original.isNotEmpty)
                      RadioListTile<bool>(
                        title: Text(original),
                        subtitle: Text(context.l10n.scrape_results_existing),
                        value: false,
                        groupValue: _useScraped[field],
                        onChanged: (val) {
                          setState(() {
                            _useScraped[field] = val!;
                            _updateResult();
                          });
                        },
                      ),
                    RadioListTile<bool>(
                      title: Text(scraped),
                      subtitle: Text(context.l10n.scrape_results_scraped),
                      value: true,
                      groupValue: _useScraped[field],
                      onChanged: (val) {
                        setState(() {
                          _useScraped[field] = val!;
                          _updateResult();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
