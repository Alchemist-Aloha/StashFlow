import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene.dart';
import '../../domain/models/scraped_scene.dart';
import '../../domain/models/scraper.dart';
import '../providers/scene_scrape_provider.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../widgets/entity_picker.dart';

/// A page for editing scene metadata.
class SceneEditPage extends ConsumerStatefulWidget {
  final Scene scene;

  const SceneEditPage({required this.scene, super.key});

  @override
  ConsumerState<SceneEditPage> createState() => _SceneEditPageState();
}

class _SceneEditPageState extends ConsumerState<SceneEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late TextEditingController _dateController;
  late List<TextEditingController> _urlControllers;
  DateTime? _selectedDate;
  String? _scrapedImage;

  String? _selectedStudioId;
  String? _selectedStudioName;
  late List<String> _selectedPerformerIds;
  late List<String> _selectedPerformerNames;
  late List<String> _selectedTagIds;
  late List<String> _selectedTagNames;

  List<ScrapedTag>? _scrapedTags;
  List<ScrapedPerformer>? _scrapedPerformers;
  bool _isSaving = false;
  bool _isScraping = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.scene.title);
    _detailsController = TextEditingController(
      text: widget.scene.details ?? '',
    );
    _selectedDate = widget.scene.date;
    _dateController = TextEditingController(
      text: _selectedDate?.toIso8601String().split('T').first ?? '',
    );
    _urlControllers = widget.scene.urls.isEmpty
        ? [TextEditingController()]
        : widget.scene.urls.map((u) => TextEditingController(text: u)).toList();

    _selectedStudioId = widget.scene.studioId;
    _selectedStudioName = widget.scene.studioName;
    _selectedPerformerIds = List.from(widget.scene.performerIds);
    _selectedPerformerNames = List.from(widget.scene.performerNames);
    _selectedTagIds = List.from(widget.scene.tagIds);
    _selectedTagNames = List.from(widget.scene.tagNames);

    _scrapedTags = null;
    _scrapedPerformers = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    for (final controller in _urlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  void _addUrlField() {
    setState(() {
      _urlControllers.add(TextEditingController());
    });
  }

  void _removeUrlField(int index) {
    setState(() {
      _urlControllers[index].dispose();
      _urlControllers.removeAt(index);
      if (_urlControllers.isEmpty) {
        _urlControllers.add(TextEditingController());
      }
    });
  }

  Future<void> _pickStudio() async {
    final result = await showDialog<Studio>(
      context: context,
      builder: (context) => const EntityPicker<Studio>(
        title: 'Select Studio',
        providerType: 'studio',
      ),
    );

    if (result != null) {
      setState(() {
        _selectedStudioId = result.id;
        _selectedStudioName = result.name;
      });
    }
  }

  Future<void> _pickPerformers() async {
    final results = await showDialog<List<Performer>>(
      context: context,
      builder: (context) => EntityPicker<Performer>(
        title: 'Select Performers',
        providerType: 'performer',
        multiSelect: true,
        initialSelection: _selectedPerformerIds,
      ),
    );

    if (results != null) {
      setState(() {
        _selectedPerformerIds = results.map((p) => p.id).toList();
        _selectedPerformerNames = results.map((p) => p.name).toList();
      });
    }
  }

  Future<void> _pickTags() async {
    final results = await showDialog<List<Tag>>(
      context: context,
      builder: (context) => EntityPicker<Tag>(
        title: 'Select Tags',
        providerType: 'tag',
        multiSelect: true,
        initialSelection: _selectedTagIds,
      ),
    );

    if (results != null) {
      setState(() {
        _selectedTagIds = results.map((t) => t.id).toList();
        _selectedTagNames = results.map((t) => t.name).toList();
      });
    }
  }

  Future<void> _scrape() async {
    final scrapers = await ref
        .read(sceneScrapeProvider)
        .listAvailableScrapers(types: ['SCENE']);

    if (!mounted) return;

    if (scrapers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No scrapers available')));
      return;
    }

    final scraper = await showDialog<Scraper>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Scraper'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: scrapers.length,
            itemBuilder: (context, index) {
              final s = scrapers[index];
              return ListTile(
                title: Text(s.name),
                subtitle: s.description != null ? Text(s.description!) : null,
                onTap: () => Navigator.of(context).pop(s),
              );
            },
          ),
        ),
      ),
    );

    if (scraper == null || !mounted) return;

    setState(() => _isScraping = true);
    try {
      final results = await ref
          .read(sceneScrapeProvider)
          .scrapeScene(scraperId: scraper.id, sceneId: widget.scene.id);

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No results found')));
        return;
      }

      ScrapedScene selected;
      if (results.length > 1) {
        final picked = await showDialog<ScrapedScene>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Result'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  return ListTile(
                    title: Text(r.title ?? 'No title'),
                    subtitle: Text(r.urls.isNotEmpty ? r.urls.first : 'No URL'),
                    onTap: () => Navigator.of(context).pop(r),
                  );
                },
              ),
            ),
          ),
        );
        if (picked == null) return;
        selected = picked;
      } else {
        selected = results.first;
      }

      setState(() {
        if (selected.title != null) _titleController.text = selected.title!;
        if (selected.details != null) {
          _detailsController.text = selected.details!;
        }
        if (selected.date != null) {
          _selectedDate = selected.date;
          _dateController.text = _selectedDate!
              .toIso8601String()
              .split('T')
              .first;
        }
        if (selected.urls.isNotEmpty) {
          for (final controller in _urlControllers) {
            controller.dispose();
          }
          _urlControllers = selected.urls
              .map((u) => TextEditingController(text: u))
              .toList();
        }
        _scrapedImage = selected.image;

        // Merge Performers that exist in library
        for (final p in selected.performers) {
          final id = p.storedId;
          if (id != null && !_selectedPerformerIds.contains(id)) {
            _selectedPerformerIds.add(id);
            _selectedPerformerNames.add(p.name ?? 'Unknown');
          }
        }

        // Merge Tags that exist in library
        for (final t in selected.tags) {
          final id = t.storedId;
          if (id != null && !_selectedTagIds.contains(id)) {
            _selectedTagIds.add(id);
            _selectedTagNames.add(t.name);
          }
        }

        _scrapedTags = selected.tags;
        _scrapedPerformers = selected.performers;

        if (selected.studioId != null && _selectedStudioId == null) {
          _selectedStudioId = selected.studioId;
          _selectedStudioName = 'Studio ID: ${selected.studioId}';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scrape failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isScraping = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final scraped = ScrapedScene(
        title: _titleController.text.trim(),
        details: _detailsController.text.trim(),
        date: _selectedDate,
        urls: _urlControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        image: _scrapedImage,
        tags: _scrapedTags,
        performers: _scrapedPerformers,
        studioId: _selectedStudioId,
      );

      await ref
          .read(sceneScrapeProvider)
          .saveScraped(
            sceneId: widget.scene.id,
            scraped: scraped,
            tagIds: _selectedTagIds,
            performerIds: _selectedPerformerIds,
          );

      if (mounted) {
        // Invalidate and wait for refresh to ensure UI is up to date before closing
        ref.invalidate(sceneDetailsProvider(widget.scene.id));
        ref.invalidate(sceneListProvider);
        await ref.read(sceneDetailsProvider(widget.scene.id).future);

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scene updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update scene: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrapeEnabled = ref.watch(scrapeEnabledProvider);

    final sTags = _scrapedTags;
    final sPerformers = _scrapedPerformers;

    // Filter out scraped items that are already in the main sections
    final unmatchedScrapedTags = (sTags ?? [])
        .where(
          (t) => t.storedId == null || !_selectedTagIds.contains(t.storedId),
        )
        .toList();
    final unmatchedScrapedPerformers = (sPerformers ?? [])
        .where(
          (p) =>
              p.storedId == null || !_selectedPerformerIds.contains(p.storedId),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Scene'),
        actions: [
          if (scrapeEnabled)
            if (_isScraping)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                onPressed: _scrape,
                icon: const Icon(Icons.search),
                tooltip: context.l10n.details_scene_scrape,
              ),
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            tooltip: context.l10n.common_save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_scrapedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _scrapedImage!.startsWith('data:')
                      ? Image.memory(
                          base64Decode(_scrapedImage!.split(',').last),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _scrapedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.common_title,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            TextField(
              controller: _detailsController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.common_details,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.common_release_date,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            // Studio
            Text('Studio', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppTheme.spacingSmall),
            InkWell(
              onTap: _pickStudio,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(_selectedStudioName ?? 'None')),
                    if (_selectedStudioId != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedStudioId = null;
                            _selectedStudioName = null;
                          });
                        },
                      )
                    else
                      const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            // Performers
            Row(
              children: [
                Text(
                  'Performers',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _pickPerformers,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: context.l10n.details_scene_add_performer,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < _selectedPerformerIds.length; i++)
                  InputChip(
                    label: Text(_selectedPerformerNames[i]),
                    onDeleted: () {
                      setState(() {
                        _selectedPerformerIds.removeAt(i);
                        _selectedPerformerNames.removeAt(i);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),

            // Tags
            Row(
              children: [
                Text('Tags', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                IconButton(
                  onPressed: _pickTags,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: context.l10n.details_scene_add_tag,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < _selectedTagIds.length; i++)
                  InputChip(
                    label: Text(_selectedTagNames[i]),
                    onDeleted: () {
                      setState(() {
                        _selectedTagIds.removeAt(i);
                        _selectedTagNames.removeAt(i);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            Row(
              children: [
                Text('URLs', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: _addUrlField,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: context.l10n.details_scene_add_url,
                ),
              ],
            ),
            ..._urlControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.common_url,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeUrlField(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: context.l10n.details_scene_remove_url,
                    ),
                  ],
                ),
              );
            }),
            if (unmatchedScrapedTags.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Unmatched Scraped Tags',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: unmatchedScrapedTags
                      .map(
                        (t) => Chip(
                          label: Text(t.name),
                          backgroundColor: context.colors.error.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if (unmatchedScrapedPerformers.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Unmatched Scraped Performers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Column(
                children: unmatchedScrapedPerformers
                    .map(
                      (p) => ListTile(
                        dense: true,
                        title: Text(p.name ?? 'Unknown'),
                        subtitle: const Text(
                          'No matching performer found in library',
                        ),
                        leading: const Icon(Icons.person_off_outlined),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
