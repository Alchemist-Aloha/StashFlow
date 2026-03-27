import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene.dart';
import '../../domain/models/scraped_scene.dart';
import '../providers/scene_scrape_provider.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';

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
  bool _isSaving = false;

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
      );

      await ref
          .read(sceneScrapeProvider)
          .saveScraped(sceneId: widget.scene.id, scraped: scraped);

      if (mounted) {
        ref.invalidate(sceneDetailsProvider(widget.scene.id));
        ref.invalidate(sceneListProvider);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scene updated successfully')),
        );
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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Scene',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
