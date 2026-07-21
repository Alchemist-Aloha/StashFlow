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
      appBar: AppBar(
        title: Text(context.l10n.scene_deduplication),
        actions: [
          IconButton(
            tooltip: context.l10n.common_refresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
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

          final controls = _Controls(
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
              setState(() => _safeSelect = value);
            },
            onSelectNone: () => setState(_selectedSceneIds.clear),
            onSelectMode: (mode) => _setSelection(groups, mode),
            onDeleteSelected: () => _confirmDelete(_selectedSceneIds),
          );

          final results = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResultsHeader(
                groupCount: groups.length,
                selectedCount: _selectedSceneIds.length,
              ),
              if (data.missingPhashCount > 0) ...[
                const SizedBox(height: 12),
                _WarningBanner(
                  message: context.l10n.missing_phashes_for_scenes(
                    data.missingPhashCount,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: _buildGroupList(
                  context,
                  groups: groups,
                  visibleGroups: visibleGroups,
                  totalPages: totalPages,
                ),
              ),
            ],
          );

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1000;
                final horizontalPadding = isWide ? 24.0 : 12.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        0,
                      ),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 340,
                                  child: SingleChildScrollView(child: controls),
                                ),
                                const SizedBox(width: 20),
                                Expanded(child: results),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _CompactConfiguration(
                                  expanded: _configExpanded,
                                  maxBodyHeight: constraints.maxHeight * 0.42,
                                  onToggle: () => setState(
                                    () => _configExpanded = !_configExpanded,
                                  ),
                                  child: controls,
                                ),
                                const SizedBox(height: 12),
                                Expanded(child: results),
                              ],
                            ),
                    ),
                  ),
                );
              },
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
      return _EmptyResults(message: context.l10n.no_duplicates_found);
    }

    return ListView.builder(
      key: ValueKey('scene_dedup_groups_$_page-$_pageSize'),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: visibleGroups.length + 2,
      itemBuilder: (context, index) {
        if (index == 0 || index == visibleGroups.length + 1) {
          return KeyedSubtree(
            key: ValueKey(
              index == 0
                  ? 'scene_dedup_pagination_top'
                  : 'scene_dedup_pagination_bottom',
            ),
            child: _PaginationBar(
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
            ),
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

class _CompactConfiguration extends StatelessWidget {
  const _CompactConfiguration({
    required this.expanded,
    required this.maxBodyHeight,
    required this.onToggle,
    required this.child,
  });

  final bool expanded;
  final double maxBodyHeight;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.configuration,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxBodyHeight),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: child,
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.groupCount, required this.selectedCount});

  final int groupCount;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.difference_rounded, color: colors.onPrimary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.l10n.duplicate_sets_count(groupCount),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selectedCount > 0)
              Badge.count(
                count: selectedCount,
                backgroundColor: colors.secondary,
                textColor: colors.onSecondary,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: colors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PanelHeading(
              icon: Icons.tune_rounded,
              title: context.l10n.configuration,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.search_accuracy,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: _SceneDeduplicationPageState._accuracyOptions.entries
                  .map(
                    (entry) => ButtonSegment<int>(
                      value: entry.key,
                      label: Text(entry.value),
                    ),
                  )
                  .toList(growable: false),
              selected: {distance},
              onSelectionChanged: (selection) {
                onDistanceChanged(selection.first);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _durationMenu(context)),
                const SizedBox(width: 10),
                Expanded(child: _pageSizeMenu(context)),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              child: SwitchListTile.adaptive(
                value: safeSelect,
                onChanged: onSafeSelectChanged,
                title: Text(
                  context.l10n.only_select_matching_codecs,
                  style: theme.textTheme.bodyMedium,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _PanelHeading(
              icon: Icons.checklist_rounded,
              title: context.l10n.select_scenes,
              badge: selectedCount > 0 ? '$selectedCount' : null,
            ),
            const SizedBox(height: 12),
            _SelectionMenu(onSelected: onSelectMode),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: selectedCount == 0 ? null : onSelectNone,
                    icon: const Icon(Icons.deselect_rounded),
                    label: Text(context.l10n.select_none),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Tooltip(
                    message: context.l10n.merge_editing_not_wired,
                    child: FilledButton.tonalIcon(
                      onPressed: null,
                      icon: const Icon(Icons.merge_rounded),
                      label: Text(context.l10n.merge),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: selectedCount == 0 || deleting
                  ? null
                  : onDeleteSelected,
              style: FilledButton.styleFrom(
                backgroundColor: colors.errorContainer,
                foregroundColor: colors.onErrorContainer,
                disabledBackgroundColor: colors.surfaceContainerHighest,
                disabledForegroundColor: colors.onSurfaceVariant,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: deleting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
              label: Text(context.l10n.delete_selected_count(selectedCount)),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenu<double> _durationMenu(BuildContext context) {
    return DropdownMenu<double>(
      expandedInsets: EdgeInsets.zero,
      initialSelection: durationDiff,
      label: Text(context.l10n.duration_difference),
      dropdownMenuEntries: _SceneDeduplicationPageState._durationOptions
          .map(
            (value) => DropdownMenuEntry<double>(
              value: value,
              label: value.toStringAsFixed(
                value.truncateToDouble() == value ? 0 : 1,
              ),
            ),
          )
          .toList(growable: false),
      onSelected: (value) {
        if (value != null) onDurationChanged(value);
      },
    );
  }

  DropdownMenu<int> _pageSizeMenu(BuildContext context) {
    return DropdownMenu<int>(
      expandedInsets: EdgeInsets.zero,
      initialSelection: pageSize,
      label: Text(context.l10n.page_size),
      dropdownMenuEntries: _SceneDeduplicationPageState._pageSizeOptions
          .map((value) => DropdownMenuEntry<int>(value: value, label: '$value'))
          .toList(growable: false),
      onSelected: (value) {
        if (value != null) onPageSizeChanged(value);
      },
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({required this.icon, required this.title, this.badge});

  final IconData icon;
  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: colors.onSecondaryContainer),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
        if (badge != null)
          Badge(
            label: Text(badge!),
            backgroundColor: colors.secondary,
            textColor: colors.onSecondary,
          ),
      ],
    );
  }
}

class _SelectionMenu extends StatelessWidget {
  const _SelectionMenu({required this.onSelected});

  final ValueChanged<DuplicateSelectionMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () =>
              onSelected(DuplicateSelectionMode.allButLargestResolution),
          leadingIcon: const Icon(Icons.aspect_ratio_rounded),
          child: Text(context.l10n.all_but_largest_resolution),
        ),
        MenuItemButton(
          onPressed: () => onSelected(DuplicateSelectionMode.allButLargestFile),
          leadingIcon: const Icon(Icons.data_usage_rounded),
          child: Text(context.l10n.all_but_largest_file),
        ),
        MenuItemButton(
          onPressed: () => onSelected(DuplicateSelectionMode.allButOldest),
          leadingIcon: const Icon(Icons.history_rounded),
          child: Text(context.l10n.all_but_oldest),
        ),
        MenuItemButton(
          onPressed: () => onSelected(DuplicateSelectionMode.allButYoungest),
          leadingIcon: const Icon(Icons.update_rounded),
          child: Text(context.l10n.all_but_youngest),
        ),
      ],
      builder: (context, controller, child) => FilledButton.tonalIcon(
        onPressed: controller.isOpen ? controller.close : controller.open,
        icon: const Icon(Icons.auto_awesome_motion_rounded),
        label: Text(context.l10n.select),
      ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer,
                      child: Text(
                        '$groupNumber',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.duplicate_set_number(groupNumber),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _MetadataPill(label: _formatBytes(group.totalFileSize)),
                  ],
                ),
              ),
              for (var index = 0; index < group.scenes.length; index++) ...[
                if (index > 0) const SizedBox(height: 8),
                _DuplicateSceneTile(
                  scene: group.scenes[index],
                  selected: selectedSceneIds.contains(group.scenes[index].id),
                  onSelectedChanged: (selected) {
                    onSceneSelectionChanged(group.scenes[index].id, selected);
                  },
                  onDelete: () => onDeleteScene(group.scenes[index].id),
                ),
              ],
            ],
          ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final file = scene.primaryFile;
    final title = scene.title.isNotEmpty ? scene.title : scene.path ?? scene.id;
    final metadata = <String>[
      if (file != null) _formatBytes(file.size),
      if (file != null)
        context.l10n.resolution_dimensions(file.width, file.height),
      if (file != null)
        context.l10n.duration_seconds_format(file.duration.toStringAsFixed(1)),
      if (file != null && file.bitRate > 0)
        context.l10n.bitrate_bps(file.bitRate),
      if (file?.videoCodec != null && file!.videoCodec!.isNotEmpty)
        file.videoCodec!,
      if (scene.oCounter > 0) context.l10n.o_count(scene.oCounter),
      if (scene.tagCount > 0) context.l10n.nTags(scene.tagCount),
      if (scene.performerCount > 0)
        context.l10n.nPerformers(scene.performerCount),
      if (scene.groupCount > 0) context.l10n.nGroups(scene.groupCount),
      if (scene.markerCount > 0) context.l10n.nMarkers(scene.markerCount),
      if (scene.galleryCount > 0) context.l10n.nGalleries(scene.galleryCount),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Material(
          color: selected
              ? colors.secondaryContainer.withValues(alpha: 0.75)
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onSelectedChanged(!selected),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox.adaptive(
                    value: selected,
                    onChanged: (value) => onSelectedChanged(value ?? false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (scene.path != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            scene.path!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (metadata.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final label in metadata)
                                _MetadataPill(label: label),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flex(
                    direction: compact ? Axis.vertical : Axis.horizontal,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        tooltip: context.l10n.open_scene,
                        icon: const Icon(Icons.open_in_new_rounded),
                        onPressed: () => context.push('/scene/${scene.id}'),
                      ),
                      SizedBox(width: compact ? 0 : 4, height: compact ? 4 : 0),
                      IconButton(
                        tooltip: context.l10n.common_delete,
                        style: IconButton.styleFrom(
                          foregroundColor: colors.error,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
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

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: colors.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onTertiaryContainer),
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Center(
        child: Material(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: context.l10n.previous_page,
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    context.l10n.scene_deduplication_page_count(
                      page,
                      totalPages,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.next_page,
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
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
