import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene.dart';
import '../../domain/models/scraped_scene.dart';
import '../../domain/models/scraper.dart';
import '../providers/scene_scrape_provider.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import '../../../studios/presentation/providers/studio_list_provider.dart';
import '../../../performers/presentation/providers/performer_list_provider.dart';
import '../../../tags/presentation/providers/tag_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';

/// A dialog for editing scene metadata.
///
/// Parameters:
/// - `scene` ([Scene]): the scene to edit.
class SceneEditDialog extends ConsumerStatefulWidget {
  final Scene scene;

  const SceneEditDialog({required this.scene, super.key});

  @override
  ConsumerState<SceneEditDialog> createState() => _SceneEditDialogState();
}

class _SceneEditDialogState extends ConsumerState<SceneEditDialog> {
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
        _scrapedTags = selected.tags;
        _scrapedPerformers = selected.performers;
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

      await ref.read(sceneScrapeProvider).saveScraped(
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

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Scene',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (scrapeEnabled)
                    if (_isScraping)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton.filledTonal(
                        onPressed: _scrape,
                        icon: const Icon(Icons.search),
                        tooltip: 'Scrape metadata',
                      ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_scrapedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingMedium,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _scrapedImage!.startsWith('data:')
                                ? Image.memory(
                                    base64Decode(
                                      _scrapedImage!.split(',').last,
                                    ),
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _scrapedImage!,
                                    height: 150,
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
                      const SizedBox(height: AppTheme.spacingMedium),
                      TextField(
                        controller: _detailsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Details',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
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
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Studio
                      Text('Studio',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: AppTheme.spacingSmall),
                      InkWell(
                        onTap: _pickStudio,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(_selectedStudioName ?? 'None'),
                              ),
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
                          Text('Performers',
                              style: Theme.of(context).textTheme.labelLarge),
                          const Spacer(),
                          IconButton(
                            onPressed: _pickPerformers,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add Performer',
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
                          Text('Tags',
                              style: Theme.of(context).textTheme.labelLarge),
                          const Spacer(),
                          IconButton(
                            onPressed: _pickTags,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add Tag',
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
                          Text(
                            'URLs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _addUrlField,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add URL',
                          ),
                        ],
                      ),
                      ..._urlControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingSmall,
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
                                tooltip: 'Remove URL',
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_scrapedTags != null && _scrapedTags!.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingMedium),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Scraped Tags',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _scrapedTags!
                                .map((t) => Chip(label: Text(t.name)))
                                .toList(),
                          ),
                        ),
                      ],
                      if (_scrapedPerformers != null &&
                          _scrapedPerformers!.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingMedium),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Scraped Performers',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Column(
                          children: _scrapedPerformers!
                              .map(
                                (p) => ListTile(
                                  dense: true,
                                  title: Text(p.name ?? 'Unknown'),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityPicker<T> extends ConsumerStatefulWidget {
  final String title;
  final String providerType; // 'studio', 'performer', 'tag'
  final bool multiSelect;
  final List<String>? initialSelection;

  const EntityPicker({
    required this.title,
    required this.providerType,
    this.multiSelect = false,
    this.initialSelection,
    super.key,
  });

  @override
  ConsumerState<EntityPicker<T>> createState() => _EntityPickerState<T>();
}

class _EntityPickerState<T> extends ConsumerState<EntityPicker<T>> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final List<T> _selectedEntities = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selectedIds.addAll(widget.initialSelection!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<dynamic>> listAsync;

    switch (widget.providerType) {
      case 'studio':
        listAsync = ref.watch(studioListProvider);
        break;
      case 'performer':
        listAsync = ref.watch(performerListProvider);
        break;
      case 'tag':
        listAsync = ref.watch(tagListProvider);
        break;
      default:
        listAsync = const AsyncValue.data([]);
    }

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _updateQuery('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _updateQuery,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: listAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No entities found'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final String id = _getId(item);
                      final String name = _getName(item);
                      final isSelected = _selectedIds.contains(id);

                      return ListTile(
                        title: Text(name),
                        selected: isSelected,
                        trailing: widget.multiSelect
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedIds.add(id);
                                      _selectedEntities.add(item as T);
                                    } else {
                                      _selectedIds.remove(id);
                                      _selectedEntities.removeWhere(
                                          (e) => _getId(e) == id);
                                    }
                                  });
                                },
                              )
                            : null,
                        onTap: () {
                          if (widget.multiSelect) {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(id);
                                _selectedEntities
                                    .removeWhere((e) => _getId(e) == id);
                              } else {
                                _selectedIds.add(id);
                                _selectedEntities.add(item as T);
                              }
                            });
                          } else {
                            Navigator.of(context).pop(item);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.multiSelect)
          ElevatedButton(
            onPressed: () {
              // We need to return the full entities, but we might only have the ones
              // that were visible/loaded during this picker session.
              // For now, let's just return what we have.
              Navigator.of(context).pop(_selectedEntities);
            },
            child: const Text('Done'),
          ),
      ],
    );
  }

  void _updateQuery(String query) {
    switch (widget.providerType) {
      case 'studio':
        ref.read(studioSearchQueryProvider.notifier).update(query);
        break;
      case 'performer':
        ref.read(performerSearchQueryProvider.notifier).update(query);
        break;
      case 'tag':
        ref.read(tagSearchQueryProvider.notifier).update(query);
        break;
    }
  }

  String _getId(dynamic item) {
    if (item is Studio) return item.id;
    if (item is Performer) return item.id;
    if (item is Tag) return item.id;
    return '';
  }

  String _getName(dynamic item) {
    if (item is Studio) return item.name;
    if (item is Performer) return item.name;
    if (item is Tag) return item.name;
    return '';
  }
}
