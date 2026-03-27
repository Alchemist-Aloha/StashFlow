import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/scene_scrape_provider.dart';
import '../../domain/models/scraper.dart';
import '../../domain/models/scraped_scene.dart';

class SceneScrapeView extends ConsumerWidget {
  final String sceneId;
  const SceneScrapeView({required this.sceneId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Scraper',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Scraper>>(
                future: ref
                    .read(sceneScrapeProvider)
                    .listAvailableScrapers(types: ['SCENE']),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) return const Text('No scrapers available');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: list
                        .map(
                          (s) => ListTile(
                            title: Text(s.name),
                            subtitle: s.description != null
                                ? Text(s.description!)
                                : null,
                            onTap: () async {
                              Navigator.of(context).pop();
                              _runScrapeAndShowEditor(context, ref, s.id);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runScrapeAndShowEditor(
    BuildContext context,
    WidgetRef ref,
    String scraperId,
  ) async {
    try {
      final scraped = await ref
          .read(sceneScrapeProvider)
          .scrapeScene(scraperId: scraperId, sceneId: sceneId);
      if (scraped.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No results from scraper')),
          );
        }
        return;
      }

      if (!context.mounted) return;

      ScrapedScene selected;
      if (scraped.length > 1) {
        final picked = await showDialog<ScrapedScene>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Multiple matches found'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: scraped.length,
                itemBuilder: (context, index) {
                  final s = scraped[index];
                  return ListTile(
                    title: Text(s.title ?? 'No title'),
                    subtitle: Text(s.urls.isNotEmpty ? s.urls.first : 'No URL'),
                    onTap: () => Navigator.of(context).pop(s),
                  );
                },
              ),
            ),
          ),
        );
        if (picked == null) return;
        selected = picked;
      } else {
        selected = scraped.first;
      }

      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) => SceneScrapeEditView(
            sceneId: sceneId,
            scraped: selected,
            controller: controller,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scrape failed: $e')));
      }
    }
  }
}

class SceneScrapeEditView extends ConsumerStatefulWidget {
  final String sceneId;
  final ScrapedScene scraped;
  final ScrollController controller;
  const SceneScrapeEditView({
    required this.sceneId,
    required this.scraped,
    required this.controller,
    super.key,
  });

  @override
  ConsumerState<SceneScrapeEditView> createState() =>
      _SceneScrapeEditViewState();
}

class _SceneScrapeEditViewState extends ConsumerState<SceneScrapeEditView> {
  Map<String, List<Map<String, dynamic>>> performerCandidates = {};
  Map<String, List<Map<String, dynamic>>> tagCandidates = {};
  final Map<String, String> selectedPerformerIds = {};
  final Map<String, String> selectedTagIds = {};
  bool loadingCandidates = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => loadingCandidates = true);
    try {
      final queries = widget.scraped.performers
          .map((p) => p.name ?? (p.urls.isNotEmpty ? p.urls.first : ''))
          .where((s) => s.isNotEmpty)
          .toList();
      performerCandidates = await ref
          .read(sceneScrapeProvider)
          .findPerformerCandidates(queries);
      tagCandidates = await ref
          .read(sceneScrapeProvider)
          .findTagCandidates(widget.scraped.tags.map((t) => t.name).toList());
    } catch (e) {
      // ignore - UI will still allow save
    } finally {
      if (mounted) setState(() => loadingCandidates = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scraped = widget.scraped;
    Widget? imageWidget;
    if (scraped.image != null) {
      if (scraped.image!.startsWith('data:')) {
        final base64String = scraped.image!.split(',').last;
        imageWidget = Image.memory(base64Decode(base64String));
      } else {
        imageWidget = Image.network(scraped.image!);
      }
    }

    return Material(
      child: SingleChildScrollView(
        controller: widget.controller,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scrape Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (imageWidget != null) imageWidget,
            const SizedBox(height: 12),
            _fieldTile(context, 'Title', scraped.title),
            _fieldTile(context, 'Details', scraped.details),
            _fieldTile(
              context,
              'URL',
              scraped.urls.isNotEmpty ? scraped.urls.join(', ') : null,
            ),
            _fieldTile(context, 'Date', scraped.date?.toIso8601String()),
            const SizedBox(height: 8),
            Text('Tags', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 6,
              children: scraped.tags
                  .map((t) => Chip(label: Text(t.name)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            if (loadingCandidates)
              const Center(child: CircularProgressIndicator())
            else ...[
              for (final t in scraped.tags)
                _tagCandidateTile(t.name, tagCandidates[t.name] ?? []),
            ],
            const SizedBox(height: 12),
            Text('Performers', style: Theme.of(context).textTheme.titleMedium),
            if (loadingCandidates)
              const SizedBox.shrink()
            else
              Column(
                children: widget.scraped.performers
                    .map((p) => _performerCandidateTile(p))
                    .toList(),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        final performerIds = selectedPerformerIds.values
                            .where((v) => v.isNotEmpty)
                            .toList();
                        final tagIds = selectedTagIds.values
                            .where((v) => v.isNotEmpty)
                            .toList();
                        await ref.read(sceneScrapeProvider).saveScraped(
                              sceneId: widget.sceneId,
                              scraped: widget.scraped,
                              merge: false,
                              performerIds: performerIds.isEmpty ? null : performerIds,
                              tagIds: tagIds.isEmpty ? null : tagIds,
                            );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saved scrape to scene'),
                          ),
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Save failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldTile(BuildContext context, String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: value != null ? Text(value) : const Text('—'),
    );
  }

  Widget _performerCandidateTile(ScrapedPerformer p) {
    final key = p.name ?? (p.urls.isNotEmpty ? p.urls.first : '');
    final candidates = performerCandidates[key] ?? [];
    final selected = selectedPerformerIds[key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text(p.name ?? (p.urls.isNotEmpty ? p.urls.first : 'Unknown'))),
        if (candidates.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No matches — will be created'),
          )
        else
          Column(
            children: candidates.map((c) {
              final id = c['id'] as String? ?? '';
              final name = c['name'] as String? ?? id;
              return RadioListTile<String>(
                title: Text(name),
                value: id,
                groupValue: selected,
                onChanged: (v) {
                  setState(() {
                    selectedPerformerIds[key] = v ?? '';
                  });
                },
              );
            }).toList(),
          ),
        const Divider(),
      ],
    );
  }

  Widget _tagCandidateTile(String tag, List<Map<String, dynamic>> candidates) {
    final selected = selectedTagIds[tag];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text(tag)),
        if (candidates.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No tag matches — will be created'),
          )
        else
          Column(
            children: candidates.map((c) {
              final id = c['id'] as String? ?? '';
              final name = c['name'] as String? ?? id;
              return RadioListTile<String>(
                title: Text(name),
                value: id,
                groupValue: selected,
                onChanged: (v) {
                  setState(() {
                    selectedTagIds[tag] = v ?? '';
                  });
                },
              );
            }).toList(),
          ),
        const Divider(),
      ],
    );
  }
}
