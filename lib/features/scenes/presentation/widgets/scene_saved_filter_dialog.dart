import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../providers/scene_list_provider.dart';

class SceneSavedFilterDialog extends ConsumerStatefulWidget {
  const SceneSavedFilterDialog({
    super.key,
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.filter,
    required this.onLoad,
  });

  final String searchQuery;
  final String? sort;
  final bool descending;
  final SceneFilter filter;
  final ValueChanged<SceneSavedFilterConfig> onLoad;

  @override
  ConsumerState<SceneSavedFilterDialog> createState() =>
      _SceneSavedFilterDialogState();
}

class _SceneSavedFilterDialogState
    extends ConsumerState<SceneSavedFilterDialog> {
  final _nameController = TextEditingController();
  late Future<List<SceneSavedFilterConfig>> _savedFiltersFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _savedFiltersFuture = _loadSavedFilters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<List<SceneSavedFilterConfig>> _loadSavedFilters() {
    return ref.read(sceneSavedFilterRepositoryProvider).findAll();
  }

  Future<void> _save(List<SceneSavedFilterConfig> existing) async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;

    final match = existing
        .where((filter) => filter.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;

    setState(() => _saving = true);
    try {
      await ref
          .read(sceneSavedFilterRepositoryProvider)
          .save(
            SceneSavedFilterConfig.current(
              id: match?.id,
              name: name,
              searchQuery: widget.searchQuery,
              sort: widget.sort,
              descending: widget.descending,
              filter: widget.filter,
            ),
          );
      _nameController.clear();
      setState(() {
        _savedFiltersFuture = _loadSavedFilters();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scene filter saved to server')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save filter: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _load(SceneSavedFilterConfig config) {
    widget.onLoad(config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: FutureBuilder<List<SceneSavedFilterConfig>>(
          future: _savedFiltersFuture,
          builder: (context, snapshot) {
            final savedFilters = snapshot.data ?? const [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bookmarks_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saved scene filters',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: 'Filter name',
                          helperText: 'Existing names are overwritten',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _save(savedFilters),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : () => _save(savedFilters),
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Load from server',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                  child: _SavedFilterList(
                    snapshot: snapshot,
                    onRetry: () {
                      setState(() {
                        _savedFiltersFuture = _loadSavedFilters();
                      });
                    },
                    onLoad: _load,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SavedFilterList extends StatelessWidget {
  const _SavedFilterList({
    required this.snapshot,
    required this.onRetry,
    required this.onLoad,
  });

  final AsyncSnapshot<List<SceneSavedFilterConfig>> snapshot;
  final VoidCallback onRetry;
  final ValueChanged<SceneSavedFilterConfig> onLoad;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load saved filters: ${snapshot.error}'),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final filters = snapshot.data ?? const [];
    if (filters.isEmpty) {
      return const Center(child: Text('No saved scene filters on server'));
    }

    final sorted = [...filters]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return ListView.separated(
      shrinkWrap: true,
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final filter = sorted[index];
        final sortLabel =
            '${filter.sort ?? 'default'} ${filter.descending ? 'DESC' : 'ASC'}';
        return ListTile(
          title: Text(filter.name),
          subtitle: Text(
            [
              if (filter.searchQuery.isNotEmpty)
                'Search: ${filter.searchQuery}',
              'Sort: $sortLabel',
            ].join(' • '),
          ),
          trailing: const Icon(Icons.download_outlined),
          onTap: () => onLoad(filter),
        );
      },
    );
  }
}
