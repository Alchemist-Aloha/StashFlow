import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
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
  late Future<List<SceneSavedFilterConfig>> _savedFiltersFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _savedFiltersFuture = _loadSavedFilters();
  }

  Future<List<SceneSavedFilterConfig>> _loadSavedFilters() {
    return ref.read(sceneSavedFilterRepositoryProvider).findAll();
  }

  Future<void> _save({
    required List<SceneSavedFilterConfig> existing,
    required String name,
  }) async {
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

  Future<void> _promptSave(List<SceneSavedFilterConfig> existing) async {
    if (_saving) return;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _SavePresetNameDialog(),
    );

    if (!mounted || name == null) return;
    await _save(existing: existing, name: name);
  }

  void _load(SceneSavedFilterConfig config) {
    widget.onLoad(config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaSize.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight * 0.9
            : mediaSize.height * 0.9;

        return SafeArea(
          top: false,
          child: SizedBox(
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusExtraLarge),
                ),
              ),
              child: FutureBuilder<List<SceneSavedFilterConfig>>(
                future: _savedFiltersFuture,
                builder: (context, snapshot) {
                  final savedFilters = snapshot.data ?? const [];
                  return Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(
                          context.dimensions.spacingMedium,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Saved Presets',
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _saving
                                  ? null
                                  : () => _promptSave(savedFilters),
                              icon: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              tooltip: context.l10n.common_save,
                            ),
                            SizedBox(width: context.dimensions.spacingSmall),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              tooltip: context.l10n.common_close,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom:
                                bottomInset +
                                safeBottom +
                                context.dimensions.spacingLarge,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              context.dimensions.spacingMedium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ActiveSettingsSummary(
                                  searchQuery: widget.searchQuery,
                                  sort: widget.sort,
                                  descending: widget.descending,
                                  filter: widget.filter,
                                ),
                                SizedBox(
                                  height: context.dimensions.spacingLarge,
                                ),
                                Text(
                                  'Load Preset',
                                  style: context.textTheme.titleMedium,
                                ),
                                SizedBox(
                                  height: context.dimensions.spacingSmall,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.sizeOf(context).height *
                                        0.45,
                                  ),
                                  child: _SavedFilterList(
                                    snapshot: snapshot,
                                    onRetry: () {
                                      setState(() {
                                        _savedFiltersFuture =
                                            _loadSavedFilters();
                                      });
                                    },
                                    onLoad: _load,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SavePresetNameDialog extends StatefulWidget {
  const _SavePresetNameDialog();

  @override
  State<_SavePresetNameDialog> createState() => _SavePresetNameDialogState();
}

class _SavePresetNameDialogState extends State<_SavePresetNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Preset'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Preset name',
          helperText: 'Existing names are overwritten',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.common_save)),
      ],
    );
  }
}

class _ActiveSettingsSummary extends StatelessWidget {
  const _ActiveSettingsSummary({
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.filter,
  });

  final String searchQuery;
  final String? sort;
  final bool descending;
  final SceneFilter filter;

  @override
  Widget build(BuildContext context) {
    final activeFilterCount = filter
        .toJson()
        .values
        .where((value) => value != null)
        .length;
    final sortLabel = '${sort ?? 'date'} ${descending ? 'DESC' : 'ASC'}';

    return Material(
      color: context.colors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current active settings will be saved.',
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: context.dimensions.spacingSmall),
            Wrap(
              spacing: context.dimensions.spacingSmall,
              runSpacing: context.dimensions.spacingSmall,
              children: [
                Chip(label: Text('Sort: $sortLabel')),
                Chip(label: Text('Filters: $activeFilterCount')),
                if (searchQuery.isNotEmpty)
                  Chip(label: Text('Search: $searchQuery')),
              ],
            ),
          ],
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
            Text('Failed to load presets: ${snapshot.error}'),
            SizedBox(height: context.dimensions.spacingSmall),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.common_retry),
            ),
          ],
        ),
      );
    }

    final filters = snapshot.data ?? const [];
    if (filters.isEmpty) {
      return const Center(child: Text('No saved presets'));
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
