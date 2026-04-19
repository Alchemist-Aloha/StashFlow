import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/models/scraper.dart';
import '../providers/scene_scrape_provider.dart';
import '../../../setup/presentation/providers/stashbox_provider.dart';
import 'enhanced_scrape_dialog.dart';

class ScrapeRequest {
  final String? scraperId;
  final String? stashBoxEndpoint;
  final String? query;
  final String? url;
  final bool useFingerprints;

  ScrapeRequest({
    this.scraperId,
    this.stashBoxEndpoint,
    this.query,
    this.url,
    this.useFingerprints = false,
  });
}

class ScrapeQueryDialog extends ConsumerStatefulWidget {
  final String initialQuery;
  final ScrapeEntityType entityType;

  const ScrapeQueryDialog({
    required this.initialQuery,
    this.entityType = ScrapeEntityType.scene,
    super.key,
  });

  @override
  ConsumerState<ScrapeQueryDialog> createState() => _ScrapeQueryDialogState();
}

class _ScrapeQueryDialogState extends ConsumerState<ScrapeQueryDialog> {
  late TextEditingController _queryController;
  late TextEditingController _urlController;
  String? _selectedScraperId;
  String? _selectedStashBoxEndpoint;
  bool _useFingerprints = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String _getEntityTypeString() {
    switch (widget.entityType) {
      case ScrapeEntityType.scene:
        return 'SCENE';
      case ScrapeEntityType.performer:
        return 'PERFORMER';
      case ScrapeEntityType.studio:
        return 'STUDIO';
    }
  }

  List<Scraper> _filterScrapers(List<Scraper> all) {
    return all.where((s) {
      ScraperSpec? spec;
      switch (widget.entityType) {
        case ScrapeEntityType.scene:
          spec = s.scene;
          break;
        case ScrapeEntityType.performer:
          spec = s.performer;
          break;
        case ScrapeEntityType.studio:
          // Studio scrapers are usually handled via SCENE in Stash
          // or have their own logic. Official webapp uses 'scene' scrapers for studio query.
          spec = s.scene;
          break;
      }
      return spec?.supportedScrapes.contains('NAME') ?? false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scrapersAsync = ref.watch(
      availableScrapersProvider(_getEntityTypeString()),
    );
    final stashBoxesAsync = ref.watch(stashBoxEndpointsProvider);

    return AlertDialog(
      title: Text(context.l10n.scenes_select_scraper),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: context.l10n.scrape_from_url,
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: 'Download',
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    if (_urlController.text.isNotEmpty) {
                      Navigator.of(
                        context,
                      ).pop(ScrapeRequest(url: _urlController.text));
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(context.l10n.common_or)),
            const SizedBox(height: 16),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: context.l10n.common_search_placeholder,
                border: const OutlineInputBorder(),
              ),
            ),
            if (widget.entityType == ScrapeEntityType.scene) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _useFingerprints,
                    onChanged: (val) {
                      setState(() {
                        _useFingerprints = val ?? false;
                      });
                    },
                  ),
                  Text(context.l10n.details_scene_fingerprint_query),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              context.l10n.scenes_available_scrapers,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Divider(),
            RadioGroup<String>(
              groupValue: _selectedStashBoxEndpoint ?? _selectedScraperId,
              onChanged: (val) {
                setState(() {
                  _selectedStashBoxEndpoint = val;
                  _selectedScraperId = null;
                });
              },
              child: stashBoxesAsync.when(
                data: (endpoints) => Column(
                  children: endpoints
                      .map(
                        (e) => RadioListTile<String>(
                          title: Text(e.name),
                          subtitle: Text(e.endpoint),
                          value: e.endpoint,
                        ),
                      )
                      .toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, _) => Text(context.l10n.common_error(err.toString())),
              ),
            ),
            RadioGroup<String>(
              groupValue: _selectedScraperId ?? _selectedStashBoxEndpoint,
              onChanged: (val) {
                setState(() {
                  _selectedScraperId = val;
                  _selectedStashBoxEndpoint = null;
                });
              },
              child: scrapersAsync.when(
                data: (scrapers) {
                  final filtered = _filterScrapers(scrapers);
                  return Column(
                    children: filtered
                        .map(
                          (s) => RadioListTile<String>(
                            title: Text(s.name),
                            value: s.id,
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, _) => Text(context.l10n.common_error(err.toString())),
              ),
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
          onPressed:
              (_selectedScraperId == null && _selectedStashBoxEndpoint == null)
              ? null
              : () {
                  Navigator.of(context).pop(
                    ScrapeRequest(
                      scraperId: _selectedScraperId,
                      stashBoxEndpoint: _selectedStashBoxEndpoint,
                      query: _queryController.text,
                      useFingerprints: _useFingerprints,
                    ),
                  );
                },
          child: Text(context.l10n.common_search),
        ),
      ],
    );
  }
}
