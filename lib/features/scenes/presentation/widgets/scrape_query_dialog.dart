import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../providers/scene_scrape_provider.dart';
import '../../../setup/presentation/providers/stashbox_provider.dart';
import '../../domain/models/scraper.dart';
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

  @override
  Widget build(BuildContext context) {
    final scrapersAsync = ref.watch(
      availableScrapersProvider([_getEntityTypeString()]),
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
                labelText: 'Scrape from URL',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
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
            const Center(child: Text('OR')),
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
            stashBoxesAsync.when(
              data: (endpoints) => Column(
                children: endpoints
                    .map(
                      (e) => RadioListTile<String>(
                        title: Text(e.name),
                        subtitle: Text(e.endpoint),
                        value: e.endpoint,
                        groupValue:
                            _selectedStashBoxEndpoint ?? _selectedScraperId,
                        onChanged: (val) {
                          setState(() {
                            _selectedStashBoxEndpoint = val;
                            _selectedScraperId = null;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
            scrapersAsync.when(
              data: (scrapers) => Column(
                children: scrapers
                    .map(
                      (s) => RadioListTile<String>(
                        title: Text(s.name),
                        subtitle: s.description != null
                            ? Text(s.description!)
                            : null,
                        value: s.id,
                        groupValue:
                            _selectedScraperId ?? _selectedStashBoxEndpoint,
                        onChanged: (val) {
                          setState(() {
                            _selectedScraperId = val;
                            _selectedStashBoxEndpoint = null;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
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
