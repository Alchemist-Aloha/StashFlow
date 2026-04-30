import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/scene_scrape_provider.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../widgets/entity_picker.dart';
import '../widgets/scrape_query_dialog.dart';
import '../widgets/enhanced_scrape_dialog.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_performer.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_tag.dart';

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
      builder: (context) => EntityPicker<Studio>(
        title: context.l10n.scenes_select_studio,
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
        title: context.l10n.scenes_select_performers,
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
        title: context.l10n.scenes_select_tags,
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
    String query = _titleController.text;
    if (query.isEmpty) {
      query = getFilestem(widget.scene.path) ?? '';
    }

    final scrapeRequest = await showDialog<ScrapeRequest>(
      context: context,
      builder: (context) => ScrapeQueryDialog(initialQuery: query),
    );

    if (scrapeRequest == null || !mounted) return;

    setState(() => _isScraping = true);
    try {
      List<ScrapedScene> results = [];
      if (scrapeRequest.url != null) {
        final res = await ref
            .read(sceneScrapeProvider)
            .scrapeSceneURL(scrapeRequest.url!);
        if (res != null) results = [res];
      } else {
        results = await ref
            .read(sceneScrapeProvider)
            .scrapeScene(
              scraperId: scrapeRequest.scraperId,
              stashBoxEndpoint: scrapeRequest.stashBoxEndpoint,
              sceneId: scrapeRequest.useFingerprints ? widget.scene.id : null,
              query: scrapeRequest.query,
            );
      }

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.scenes_no_results_found)),
        );
        return;
      }

      ScrapedScene selected;
      if (results.length > 1) {
        final picked = await showDialog<ScrapedScene>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.scenes_select_result),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  return ListTile(
                    title: Text(r.title ?? context.l10n.common_no_title),
                    subtitle: Text(
                      r.urls.isNotEmpty
                          ? r.urls.first
                          : context.l10n.common_no_url,
                    ),
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

      // Enhanced merge dialog
      final original = ScrapedScene(
        title: _titleController.text,
        details: _detailsController.text,
        date: _selectedDate,
        studioId: _selectedStudioId,
        image: _scrapedImage,
      );

      if (!mounted) return;

      final merged = await showDialog<ScrapedScene>(
        context: context,
        builder: (context) => EnhancedScrapeDialog(
          original: original,
          scraped: selected,
          type: ScrapeEntityType.scene,
        ),
      );

      if (merged == null || !mounted) return;

      setState(() {
        if (merged.title != null) _titleController.text = merged.title!;
        if (merged.details != null) {
          _detailsController.text = merged.details!;
        }
        if (merged.date != null) {
          _selectedDate = merged.date;
          _dateController.text = _selectedDate!
              .toIso8601String()
              .split('T')
              .first;
        }
        if (merged.urls.isNotEmpty) {
          for (final controller in _urlControllers) {
            controller.dispose();
          }
          _urlControllers = merged.urls
              .map((u) => TextEditingController(text: u))
              .toList();
        }
        _scrapedImage = merged.image;

        // Merge Performers that exist in library
        for (final p in merged.performers) {
          final id = p.storedId;
          if (id != null && !_selectedPerformerIds.contains(id)) {
            _selectedPerformerIds.add(id);
            _selectedPerformerNames.add(p.name ?? context.l10n.common_unknown);
          }
        }

        // Merge Tags that exist in library
        for (final t in merged.tags) {
          final id = t.storedId;
          if (id != null && !_selectedTagIds.contains(id)) {
            _selectedTagIds.add(id);
            _selectedTagNames.add(t.name);
          }
        }

        _scrapedTags = merged.tags;
        _scrapedPerformers = merged.performers;

        if (merged.studioId != null) {
          _selectedStudioId = merged.studioId;
          _selectedStudioName =
              merged.studio?.name ??
              context.l10n.scenes_studio_id_prefix(merged.studioId!);
        } else if (merged.studio != null) {
          _selectedStudioId = merged.studio!.storedId;
          _selectedStudioName = merged.studio!.name;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.scenes_scrape_failed(e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScraping = false);
    }
  }

  Future<void> _generatePhash() async {
    setState(() => _isScraping = true);
    try {
      await ref.read(sceneScrapeProvider).generatePhash(widget.scene.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.scenes_phash_started)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.scenes_phash_failed(e.toString()))));
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
        tags: _scrapedTags ?? [],
        performers: _scrapedPerformers ?? [],
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
            SnackBar(content: Text(context.l10n.scenes_updated_successfully)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.scenes_update_failed(e.toString())),
          ),
        );
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
        title: Text(context.l10n.scenes_edit_title),
        actions: [
          if (scrapeEnabled)
            if (_isScraping)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dimensions.spacingMedium,
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else ...[
              IconButton(
                onPressed: _generatePhash,
                icon: const Icon(Icons.fingerprint),
                tooltip: context.l10n.details_scene_fingerprint_query,
              ),
              IconButton(
                onPressed: _scrape,
                icon: const Icon(Icons.search),
                tooltip: context.l10n.details_scene_scrape,
              ),
            ],
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
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_scrapedImage != null)
              Padding(
                padding: EdgeInsets.only(
                  bottom: context.dimensions.spacingMedium,
                ),
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
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: context.dimensions.spacingMedium),
            TextField(
              controller: _detailsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: context.dimensions.spacingMedium),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Release Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: context.dimensions.spacingMedium),

            // Studio
            Text(
              context.l10n.scenes_field_studio,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            SizedBox(height: context.dimensions.spacingSmall),
            InkWell(
              onTap: _pickStudio,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.dimensions.spacingMedium,
                    vertical: context.dimensions.spacingSmall,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedStudioName ?? context.l10n.common_none,
                      ),
                    ),
                    if (_selectedStudioId != null)
                      IconButton(
                        tooltip: 'Clear',
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
            SizedBox(height: context.dimensions.spacingMedium),

            // Performers
            Row(
              children: [
                Text(
                  context.l10n.performers_title,
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
              spacing: context.dimensions.spacingSmall,
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
            SizedBox(height: context.dimensions.spacingSmall),

            // Tags
            Row(
              children: [
                Text(
                  context.l10n.scenes_field_tags,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _pickTags,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: context.l10n.details_scene_add_tag,
                ),
              ],
            ),
            Wrap(
              spacing: context.dimensions.spacingSmall,
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
            SizedBox(height: context.dimensions.spacingMedium),

            Row(
              children: [
                Text(
                  context.l10n.scenes_field_urls,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
                padding: EdgeInsets.only(
                  bottom: context.dimensions.spacingSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'URL',
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
              SizedBox(height: context.dimensions.spacingMedium),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.scenes_unmatched_scraped_tags,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(height: context.dimensions.spacingSmall),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: context.dimensions.spacingSmall * 0.75,
                  runSpacing: context.dimensions.spacingSmall * 0.75,
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
              SizedBox(height: context.dimensions.spacingMedium),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.scenes_unmatched_scraped_performers,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(height: context.dimensions.spacingSmall),
              Column(
                children: unmatchedScrapedPerformers
                    .map(
                      (p) => ListTile(
                        dense: true,
                        title: Text(p.name ?? context.l10n.common_unknown),
                        subtitle: Text(
                          context.l10n.scenes_no_matching_performer_found,
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
