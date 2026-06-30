import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

import '../../domain/entities/scene_deduplication.dart';
import '../providers/scene_list_provider.dart';

class SceneDeduplicationPage extends ConsumerStatefulWidget {
  const SceneDeduplicationPage({super.key});

  @override
  ConsumerState<SceneDeduplicationPage> createState() =>
      _SceneDeduplicationPageState();
}

class _SceneDeduplicationData {
  const _SceneDeduplicationData({
    required this.groups,
    required this.missingPhashCount,
  });

  final List<SceneDuplicateGroup> groups;
  final int missingPhashCount;
}

class _SceneDeduplicationPageState
    extends ConsumerState<SceneDeduplicationPage> {
  static const _accuracyOptions = <int, String>{
    0: 'Exact',
    4: 'High',
    8: 'Medium',
    10: 'Low',
  };
  static const _durationOptions = <double>[-1, 0, 1, 5, 10];
  static const _pageSizeOptions = <int>[
    10,
    20,
    30,
    40,
    50,
    100,
    150,
    200,
    250,
    500,
    750,
    1000,
    1250,
    1500,
  ];

  int _distance = 0;
  double _durationDiff = 1;
  int _page = 1;
  int _pageSize = 20;
  bool _safeSelect = true;
  bool _deleting = false;
  bool _configExpanded = true;
  final Set<String> _selectedSceneIds = {};

  late Future<_SceneDeduplicationData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SceneDeduplicationData> _load() async {
    final repository = ref.read(sceneRepositoryProvider);
    final results = await Future.wait([
      repository.findDuplicateScenes(
        distance: _distance,
        durationDiff: _durationDiff,
      ),
      repository.countScenesMissingPhash(),
    ]);
    return _SceneDeduplicationData(
      groups: results[0] as List<SceneDuplicateGroup>,
      missingPhashCount: results[1] as int,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  List<SceneDuplicateGroup> _visibleGroups(List<SceneDuplicateGroup> groups) {
    final start = (_page - 1) * _pageSize;
    if (start >= groups.length) return const [];
    final end = (start + _pageSize).clamp(0, groups.length);
    return groups.sublist(start, end);
  }

  void _setSelection(
    List<SceneDuplicateGroup> groups,
    DuplicateSelectionMode mode,
  ) {
    setState(() {
      _selectedSceneIds
        ..clear()
        ..addAll(
          selectDuplicateScenes(
            groups: _visibleGroups(groups),
            mode: mode,
            safeSelect: _safeSelect,
          ),
        );
    });
  }

  Future<void> _confirmDelete(Set<String> ids) async {
    if (ids.isEmpty || _deleting) return;

    final deleteFile = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.delete_n_scenes_question(ids.length)),
        content: Text(context.l10n.delete_scenes_help),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.delete_metadata),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete_files),
          ),
        ],
      ),
    );

    if (deleteFile == null || !mounted) return;

    setState(() {
      _deleting = true;
    });
    try {
      final repository = ref.read(sceneRepositoryProvider);
      for (final id in ids) {
        await repository.deleteScene(
          id,
          deleteFile: deleteFile,
          deleteGenerated: true,
        );
      }
      ref.invalidate(sceneListProvider);
      if (!mounted) return;
      setState(() {
        _selectedSceneIds.clear();
        _future = _load();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.deleted_n_scenes(ids.length))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.delete_failed_error(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.scene_deduplication)),
      body: FutureBuilder<_SceneDeduplicationData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.requireData;
          final groups = data.groups;
          final visibleGroups = _visibleGroups(groups);
          final totalPages = groups.isEmpty
              ? 1
              : ((groups.length + _pageSize - 1) ~/ _pageSize);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _configExpanded = !_configExpanded),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _configExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.configuration,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _Controls(
                    distance: _distance,
                    durationDiff: _durationDiff,
                    pageSize: _pageSize,
                    safeSelect: _safeSelect,
                    selectedCount: _selectedSceneIds.length,
                    deleting: _deleting,
                    onDistanceChanged: (value) {
                      setState(() {
                        _distance = value;
                        _page = 1;
                        _selectedSceneIds.clear();
                        _future = _load();
                      });
                    },
                    onDurationChanged: (value) {
                      setState(() {
                        _durationDiff = value;
                        _page = 1;
                        _selectedSceneIds.clear();
                        _future = _load();
                      });
                    },
                    onPageSizeChanged: (value) {
                      setState(() {
                        _pageSize = value;
                        _page = 1;
                        _selectedSceneIds.clear();
                      });
                    },
                    onSafeSelectChanged: (value) {
                      setState(() {
                        _safeSelect = value;
                      });
                    },
                    onSelectNone: () {
                      setState(_selectedSceneIds.clear);
                    },
                    onSelectMode: (mode) => _setSelection(groups, mode),
                    onDeleteSelected: () => _confirmDelete(_selectedSceneIds),
                  ),
                  crossFadeState: _configExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                if (data.missingPhashCount > 0) ...[
                  const SizedBox(height: 12),
                  _WarningBanner(
                    message: context.l10n.missing_phashes_for_scenes(
                      data.missingPhashCount,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: _buildGroupList(
                    context,
                    groups: groups,
                    visibleGroups: visibleGroups,
                    totalPages: totalPages,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupList(
    BuildContext context, {
    required List<SceneDuplicateGroup> groups,
    required List<SceneDuplicateGroup> visibleGroups,
    required int totalPages,
  }) {
    if (groups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.duplicate_sets_count(groups.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(child: Text(context.l10n.no_duplicates_found)),
          ),
        ],
      );
    }

    return ListView.builder(
      key: ValueKey('scene_dedup_groups_$_page-$_pageSize'),
      itemCount: visibleGroups.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              context.l10n.duplicate_sets_count(groups.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        if (index == visibleGroups.length + 1) {
          return _PaginationBar(
            page: _page,
            totalPages: totalPages,
            onPrevious: _page > 1
                ? () => setState(() {
                    _page -= 1;
                    _selectedSceneIds.clear();
                  })
                : null,
            onNext: _page < totalPages
                ? () => setState(() {
                    _page += 1;
                    _selectedSceneIds.clear();
                  })
                : null,
          );
        }

        final groupIndex = index - 1;
        final group = visibleGroups[groupIndex];
        return _DuplicateGroupCard(
          key: ValueKey(
            'duplicate_group_${((_page - 1) * _pageSize) + groupIndex + 1}',
          ),
          groupNumber: ((_page - 1) * _pageSize) + groupIndex + 1,
          group: group,
          selectedSceneIds: _selectedSceneIds,
          onSceneSelectionChanged: (sceneId, selected) {
            setState(() {
              if (selected) {
                _selectedSceneIds.add(sceneId);
              } else {
                _selectedSceneIds.remove(sceneId);
              }
            });
          },
          onDeleteScene: (sceneId) => _confirmDelete({sceneId}),
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.distance,
    required this.durationDiff,
    required this.pageSize,
    required this.safeSelect,
    required this.selectedCount,
    required this.deleting,
    required this.onDistanceChanged,
    required this.onDurationChanged,
    required this.onPageSizeChanged,
    required this.onSafeSelectChanged,
    required this.onSelectNone,
    required this.onSelectMode,
    required this.onDeleteSelected,
  });

  final int distance;
  final double durationDiff;
  final int pageSize;
  final bool safeSelect;
  final int selectedCount;
  final bool deleting;
  final ValueChanged<int> onDistanceChanged;
  final ValueChanged<double> onDurationChanged;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<bool> onSafeSelectChanged;
  final VoidCallback onSelectNone;
  final ValueChanged<DuplicateSelectionMode> onSelectMode;
  final VoidCallback onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final theme = Theme.of(context);
    final buttonStyle = _controlButtonStyle(theme, isCompact);
    final dropdownWidth = isCompact ? 154.0 : null;
    final dropdownInputDecoration = isCompact
        ? const InputDecorationTheme(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          )
        : null;
    final menuItemStyle = isCompact
        ? ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(36)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            textStyle: WidgetStatePropertyAll(theme.textTheme.labelMedium),
          )
        : null;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: SizedBox(
          height: isCompact ? 44 : 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children:
                [
                  DropdownMenu<int>(
                    width: dropdownWidth,
                    textStyle: isCompact ? theme.textTheme.bodySmall : null,
                    inputDecorationTheme: dropdownInputDecoration,
                    initialSelection: distance,
                    label: Text(context.l10n.search_accuracy),
                    dropdownMenuEntries: _SceneDeduplicationPageState
                        ._accuracyOptions
                        .entries
                        .map(
                          (entry) => DropdownMenuEntry<int>(
                            value: entry.key,
                            label: entry.value,
                            style: menuItemStyle,
                          ),
                        )
                        .toList(growable: false),
                    onSelected: (value) {
                      if (value != null) onDistanceChanged(value);
                    },
                  ),
                  DropdownMenu<double>(
                    width: dropdownWidth,
                    textStyle: isCompact ? theme.textTheme.bodySmall : null,
                    inputDecorationTheme: dropdownInputDecoration,
                    initialSelection: durationDiff,
                    label: Text(context.l10n.duration_difference),
                    dropdownMenuEntries: _SceneDeduplicationPageState
                        ._durationOptions
                        .map(
                          (value) => DropdownMenuEntry<double>(
                            value: value,
                            label: value.toStringAsFixed(
                              value.truncateToDouble() == value ? 0 : 1,
                            ),
                            style: menuItemStyle,
                          ),
                        )
                        .toList(growable: false),
                    onSelected: (value) {
                      if (value != null) onDurationChanged(value);
                    },
                  ),
                  DropdownMenu<int>(
                    width: dropdownWidth,
                    textStyle: isCompact ? theme.textTheme.bodySmall : null,
                    inputDecorationTheme: dropdownInputDecoration,
                    initialSelection: pageSize,
                    label: Text(context.l10n.page_size),
                    dropdownMenuEntries: _SceneDeduplicationPageState
                        ._pageSizeOptions
                        .map(
                          (value) => DropdownMenuEntry<int>(
                            value: value,
                            label: '$value',
                            style: menuItemStyle,
                          ),
                        )
                        .toList(growable: false),
                    onSelected: (value) {
                      if (value != null) onPageSizeChanged(value);
                    },
                  ),
                  FilterChip(
                    visualDensity: isCompact ? VisualDensity.compact : null,
                    materialTapTargetSize: isCompact
                        ? MaterialTapTargetSize.shrinkWrap
                        : null,
                    selected: safeSelect,
                    label: Text(context.l10n.only_select_matching_codecs),
                    onSelected: onSafeSelectChanged,
                  ),
                  PopupMenuButton<DuplicateSelectionMode>(
                    tooltip: context.l10n.select_scenes,
                    onSelected: onSelectMode,
                    constraints: isCompact
                        ? const BoxConstraints(minWidth: 196, maxWidth: 240)
                        : null,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: DuplicateSelectionMode.allButLargestResolution,
                        height: isCompact ? 36 : kMinInteractiveDimension,
                        child: Text(context.l10n.all_but_largest_resolution),
                      ),
                      PopupMenuItem(
                        value: DuplicateSelectionMode.allButLargestFile,
                        height: isCompact ? 36 : kMinInteractiveDimension,
                        child: Text(context.l10n.all_but_largest_file),
                      ),
                      PopupMenuItem(
                        value: DuplicateSelectionMode.allButOldest,
                        height: isCompact ? 36 : kMinInteractiveDimension,
                        child: Text(context.l10n.all_but_oldest),
                      ),
                      PopupMenuItem(
                        value: DuplicateSelectionMode.allButYoungest,
                        height: isCompact ? 36 : kMinInteractiveDimension,
                        child: Text(context.l10n.all_but_youngest),
                      ),
                    ],
                    child: IntrinsicWidth(
                      child: FilledButton.tonalIcon(
                        onPressed: null,
                        style: buttonStyle,
                        icon: const Icon(Icons.select_all),
                        label: Text(context.l10n.select),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSelectNone,
                    style: buttonStyle,
                    icon: const Icon(Icons.clear),
                    label: Text(context.l10n.select_none),
                  ),
                  FilledButton.icon(
                    onPressed: selectedCount == 0 || deleting
                        ? null
                        : onDeleteSelected,
                    style: buttonStyle,
                    icon: deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete),
                    label: Text(
                      context.l10n.delete_selected_count(selectedCount),
                    ),
                  ),
                  Tooltip(
                    message: context.l10n.merge_editing_not_wired,
                    child: FilledButton.tonalIcon(
                      onPressed: null,
                      style: buttonStyle,
                      icon: const Icon(Icons.merge),
                      label: Text(context.l10n.merge),
                    ),
                  ),
                ].expand((widget) sync* {
                  yield Padding(
                    padding: EdgeInsets.only(right: isCompact ? 8 : 12),
                    child: widget,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  ButtonStyle _controlButtonStyle(ThemeData theme, bool isCompact) {
    return FilledButton.styleFrom(
      visualDensity: isCompact ? VisualDensity.compact : null,
      tapTargetSize: isCompact
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      minimumSize: Size(0, isCompact ? 36 : 40),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 14,
        vertical: isCompact ? 8 : 10,
      ),
      iconSize: isCompact ? 18 : 20,
      textStyle: isCompact ? theme.textTheme.labelMedium : null,
    );
  }
}

class _DuplicateGroupCard extends StatelessWidget {
  const _DuplicateGroupCard({
    super.key,
    required this.groupNumber,
    required this.group,
    required this.selectedSceneIds,
    required this.onSceneSelectionChanged,
    required this.onDeleteScene,
  });

  final int groupNumber;
  final SceneDuplicateGroup group;
  final Set<String> selectedSceneIds;
  final void Function(String sceneId, bool selected) onSceneSelectionChanged;
  final ValueChanged<String> onDeleteScene;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.duplicate_set_number(groupNumber),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final scene in group.scenes)
              _DuplicateSceneTile(
                scene: scene,
                selected: selectedSceneIds.contains(scene.id),
                onSelectedChanged: (selected) {
                  onSceneSelectionChanged(scene.id, selected);
                },
                onDelete: () => onDeleteScene(scene.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _DuplicateSceneTile extends StatelessWidget {
  const _DuplicateSceneTile({
    required this.scene,
    required this.selected,
    required this.onSelectedChanged,
    required this.onDelete,
  });

  final SceneDuplicateScene scene;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final file = scene.primaryFile;
    final title = scene.title.isNotEmpty ? scene.title : scene.path ?? scene.id;

    return CheckboxListTile(
      value: selected,
      onChanged: (value) => onSelectedChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(title),
      subtitle: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (scene.path != null) Text(scene.path!),
          if (file != null) Text(_formatBytes(file.size)),
          if (file != null)
            Text(context.l10n.resolution_dimensions(file.width, file.height)),
          if (file != null)
            Text(
              context.l10n.duration_seconds_format(
                file.duration.toStringAsFixed(1),
              ),
            ),
          if (file != null && file.bitRate > 0)
            Text(context.l10n.bitrate_bps(file.bitRate)),
          if (file?.videoCodec != null && file!.videoCodec!.isNotEmpty)
            Text(file.videoCodec!),
          if (scene.oCounter > 0) Text(context.l10n.o_count(scene.oCounter)),
          if (scene.tagCount > 0) Text(context.l10n.nTags(scene.tagCount)),
          if (scene.performerCount > 0)
            Text(context.l10n.nPerformers(scene.performerCount)),
          if (scene.groupCount > 0)
            Text(context.l10n.nGroups(scene.groupCount)),
          if (scene.markerCount > 0)
            Text(context.l10n.nMarkers(scene.markerCount)),
          if (scene.galleryCount > 0)
            Text(context.l10n.nGalleries(scene.galleryCount)),
        ],
      ),
      secondary: SizedBox(
        width: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.open_scene,
              iconSize: 18,
              style: IconButton.styleFrom(
                fixedSize: const Size(28, 28),
                minimumSize: const Size(28, 28),
                maximumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/scenes/scene/${scene.id}'),
            ),
            IconButton(
              tooltip: context.l10n.common_delete,
              iconSize: 18,
              style: IconButton.styleFrom(
                fixedSize: const Size(28, 28),
                minimumSize: const Size(28, 28),
                maximumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[unitIndex]}';
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: colors.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: context.l10n.previous_page,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(context.l10n.scene_deduplication_page_count(page, totalPages)),
          IconButton(
            tooltip: context.l10n.next_page,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}
