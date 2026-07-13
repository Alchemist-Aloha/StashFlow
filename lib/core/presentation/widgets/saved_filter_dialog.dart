import 'package:flutter/material.dart';

import '../../domain/entities/saved_filter_config.dart';
import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'bottom_sheet_panel_chrome.dart';

class SavedFilterDialog<T extends SavedFilterConfig<dynamic>>
    extends StatefulWidget {
  const SavedFilterDialog({
    super.key,
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.activeFilterCount,
    required this.defaultSortLabel,
    required this.saveSuccessMessage,
    required this.loadPresets,
    required this.savePreset,
    required this.deletePreset,
    required this.onLoad,
  });

  final String searchQuery;
  final String? sort;
  final bool descending;
  final int activeFilterCount;
  final String defaultSortLabel;
  final String saveSuccessMessage;
  final Future<List<T>> Function() loadPresets;
  final Future<T> Function({required String name, String? existingId})
  savePreset;
  final Future<bool> Function(String id) deletePreset;
  final ValueChanged<T> onLoad;

  @override
  State<SavedFilterDialog<T>> createState() => _SavedFilterDialogState<T>();
}

class _SavedFilterDialogState<T extends SavedFilterConfig<dynamic>>
    extends State<SavedFilterDialog<T>> {
  late Future<List<T>> _savedFiltersFuture;
  bool _saving = false;
  bool _deleting = false;
  String? _deletingId;

  @override
  void initState() {
    super.initState();
    _savedFiltersFuture = widget.loadPresets();
  }

  Future<void> _save({required List<T> existing, required String name}) async {
    if (name.isEmpty || _saving || _deleting) return;

    final match = existing
        .where((filter) => filter.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;

    setState(() => _saving = true);
    try {
      await widget.savePreset(name: name, existingId: match?.id);
      if (!mounted) return;
      setState(() {
        _savedFiltersFuture = widget.loadPresets();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.saveSuccessMessage)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failed_to_save_filter(error.toString())),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _promptSave(List<T> existing) async {
    if (_saving || _deleting) return;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _SavePresetNameDialog(),
    );

    if (!mounted || name == null) return;
    await _save(existing: existing, name: name);
  }

  void _load(T config) {
    widget.onLoad(config);
    Navigator.of(context).pop();
  }

  Future<void> _promptDelete(T config) async {
    final id = config.id;
    if (id == null || _saving || _deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DeletePresetConfirmDialog(name: config.name),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _deleting = true;
      _deletingId = id;
    });
    try {
      final deleted = await widget.deletePreset(id);
      if (!deleted) {
        throw StateError('Preset could not be deleted');
      }

      if (!mounted) return;
      setState(() {
        _savedFiltersFuture = widget.loadPresets();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.preset_deleted)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.failed_to_delete_preset(error.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
          _deletingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: FrostedPanel(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusExtraLarge),
          ),
          child: FutureBuilder<List<T>>(
            future: _savedFiltersFuture,
            builder: (context, snapshot) {
              final savedFilters = snapshot.data ?? const [];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BottomSheetPanelHeader(title: context.l10n.saved_presets),
                  const Divider(height: 1),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(context.dimensions.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.current_settings,
                            style: context.textTheme.labelLarge,
                          ),
                          SizedBox(height: context.dimensions.spacingSmall),
                          _ActiveSettingsSummary(
                            searchQuery: widget.searchQuery,
                            sort: widget.sort,
                            descending: widget.descending,
                            activeFilterCount: widget.activeFilterCount,
                            defaultSortLabel: widget.defaultSortLabel,
                          ),
                          SizedBox(height: context.dimensions.spacingSmall),
                          Text(
                            context.l10n.available_presets,
                            style: context.textTheme.labelLarge,
                          ),
                          SizedBox(height: context.dimensions.spacingSmall),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.sizeOf(context).height * 0.22,
                            ),
                            child: _SavedFilterList<T>(
                              snapshot: snapshot,
                              defaultSortLabel: widget.defaultSortLabel,
                              busy: _saving || _deleting,
                              deletingId: _deletingId,
                              onRetry: () {
                                setState(() {
                                  _savedFiltersFuture = widget.loadPresets();
                                });
                              },
                              onDelete: _promptDelete,
                              onLoad: _load,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  BottomSheetPanelActions(
                    primaryLabel: context.l10n.save_preset,
                    secondaryLabel: context.l10n.common_close,
                    onPrimary: _saving || _deleting
                        ? null
                        : () => _promptSave(savedFilters),
                    onSecondary: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeletePresetConfirmDialog extends StatelessWidget {
  const _DeletePresetConfirmDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.delete_preset),
      content: Text(context.l10n.delete_preset_confirm(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.common_delete),
        ),
      ],
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
      title: Text(context.l10n.save_preset),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: context.l10n.enter_preset_name,
          helperText: context.l10n.existing_names_are_overwritten,
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
    required this.activeFilterCount,
    required this.defaultSortLabel,
  });

  final String searchQuery;
  final String? sort;
  final bool descending;
  final int activeFilterCount;
  final String defaultSortLabel;

  @override
  Widget build(BuildContext context) {
    final sortLabel =
        '${sort ?? defaultSortLabel} ${descending ? 'DESC' : 'ASC'}';

    return Material(
      color: context.colors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.active_settings_saved_server,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: context.dimensions.spacingSmall),
            Wrap(
              spacing: context.dimensions.spacingSmall,
              runSpacing: context.dimensions.spacingSmall,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(context.l10n.sort_label(sortLabel)),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(context.l10n.filters_count(activeFilterCount)),
                ),
                if (searchQuery.isNotEmpty)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(context.l10n.search_label(searchQuery)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedFilterList<T extends SavedFilterConfig<dynamic>>
    extends StatelessWidget {
  const _SavedFilterList({
    required this.snapshot,
    required this.defaultSortLabel,
    required this.busy,
    required this.deletingId,
    required this.onRetry,
    required this.onDelete,
    required this.onLoad,
  });

  final AsyncSnapshot<List<T>> snapshot;
  final String defaultSortLabel;
  final bool busy;
  final String? deletingId;
  final VoidCallback onRetry;
  final ValueChanged<T> onDelete;
  final ValueChanged<T> onLoad;

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
            Text(
              context.l10n.failed_to_load_presets(snapshot.error.toString()),
            ),
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
      return Center(child: Text(context.l10n.no_saved_presets));
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
            '${filter.sort ?? defaultSortLabel} ${filter.descending ? 'DESC' : 'ASC'}';
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.dimensions.spacingSmall,
          ),
          enabled: !busy,
          title: Text(filter.name),
          subtitle: Text(
            [
              if (filter.searchQuery.isNotEmpty)
                context.l10n.search_label(filter.searchQuery),
              context.l10n.sort_label(sortLabel),
            ].join(' • '),
          ),
          trailing: filter.id == null
              ? null
              : IconButton(
                  onPressed: busy ? null : () => onDelete(filter),
                  tooltip: context.l10n.delete_preset,
                  icon: deletingId == filter.id
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                ),
          onTap: busy ? null : () => onLoad(filter),
        );
      },
    );
  }
}
