import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/scraped/scraped_scene.dart';
import '../../../../core/domain/entities/scraped/scraped_tag.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../setup/presentation/providers/stashbox_provider.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../providers/scene_list_provider.dart';
import '../widgets/scene_filter_panel.dart';

class SceneTaggerPage extends ConsumerStatefulWidget {
  const SceneTaggerPage({super.key});

  @override
  ConsumerState<SceneTaggerPage> createState() => _SceneTaggerPageState();
}

class _TaggerResult {
  const _TaggerResult._({this.matches, this.error, this.saved = false});

  const _TaggerResult.matches(List<ScrapedScene> matches)
    : this._(matches: matches);

  const _TaggerResult.error(String error) : this._(error: error);

  _TaggerResult copyWithSaved() =>
      _TaggerResult._(matches: matches, error: error, saved: true);

  final List<ScrapedScene>? matches;
  final String? error;
  final bool saved;
}

enum _TaggerMode {
  currentPage('current_page', 'Current page'),
  randomUnorganized('random_unorganized', 'Random unorganized');

  const _TaggerMode(this.value, this.label);

  final String value;
  final String label;
}

class _SceneTaggerPageState extends ConsumerState<SceneTaggerPage> {
  static const _pageSizeOptions = [10, 25, 50, 100];
  static const _sortOptions = <String, String>{
    'date': 'Date',
    'title': 'Title',
    'created_at': 'Created',
    'updated_at': 'Updated',
    'duration': 'Duration',
    'random': 'Random',
  };

  final _searchController = TextEditingController();
  late Future<List<SceneSavedFilterConfig>> _presetsFuture;
  List<Scene> _scenes = [];
  final Map<String, _TaggerResult> _results = {};
  _TaggerMode _mode = _TaggerMode.currentPage;
  int _pageSize = 25;
  String? _sort = 'date';
  bool _descending = true;
  SceneFilter _filter = SceneFilter.empty();
  OrganizedFilter _organized = OrganizedFilter.all;
  String? _selectedStashBoxEndpoint;
  bool _loadingScenes = true;
  bool _scraping = false;
  bool _stopRequested = false;
  bool _configExpanded = true;
  int _scrapedCount = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _presetsFuture = ref.read(sceneSavedFilterRepositoryProvider).findAll();
    Future.microtask(_loadScenes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScenes() async {
    setState(() {
      _loadingScenes = true;
      _loadError = null;
      _results.clear();
      _scrapedCount = 0;
    });

    try {
      final repository = ref.read(sceneRepositoryProvider);
      var effectiveSort = _sort;
      if (effectiveSort == 'random') {
        effectiveSort = 'random';
      }
      final scenes = await repository.findScenes(
        page: 1,
        perPage: _pageSize,
        filter: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        sort: effectiveSort,
        descending: _descending,
        organized: _organized.toBool() ?? _filter.organized,
        sceneFilter: _filter,
      );
      if (!mounted) return;
      setState(() {
        _scenes = scenes;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingScenes = false;
        });
      }
    }
  }

  void _clearRandomModeList() {
    setState(() {
      _scenes = [];
      _results.clear();
      _scrapedCount = 0;
      _loadError = null;
    });
  }

  void _reloadForMode() {
    if (_mode == _TaggerMode.currentPage) {
      _loadScenes();
    } else {
      _clearRandomModeList();
    }
  }

  Future<void> _startTagging(String stashBoxEndpoint) async {
    switch (_mode) {
      case _TaggerMode.currentPage:
        await _startCurrentPageTagging(stashBoxEndpoint);
        break;
      case _TaggerMode.randomUnorganized:
        await _startRandomUnorganizedTagging(stashBoxEndpoint);
        break;
    }
  }

  Future<void> _startCurrentPageTagging(String stashBoxEndpoint) async {
    if (_scraping || _scenes.isEmpty) return;
    setState(() {
      _scraping = true;
      _stopRequested = false;
      _scrapedCount = 0;
      _results.clear();
    });

    final repository = ref.read(sceneRepositoryProvider);
    for (final scene in _scenes) {
      if (_stopRequested) break;
      try {
        final matches = await repository.scrapeSingleScene(
          stashBoxEndpoint: stashBoxEndpoint,
          sceneId: scene.id,
        );
        if (!mounted) return;
        setState(() {
          _results[scene.id] = _TaggerResult.matches(matches);
          _scrapedCount += 1;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _results[scene.id] = _TaggerResult.error(error.toString());
          _scrapedCount += 1;
        });
      }
    }

    _finishScraping();
  }

  Future<void> _startRandomUnorganizedTagging(String stashBoxEndpoint) async {
    if (_scraping) return;
    setState(() {
      _scraping = true;
      _stopRequested = false;
      _scrapedCount = 0;
      _results.clear();
      _scenes = [];
    });

    final repository = ref.read(sceneRepositoryProvider);
    final randomSort = 'random_${DateTime.now().microsecondsSinceEpoch}';

    try {
      var page = 1;
      while (!_stopRequested) {
        final candidates = await repository.findScenes(
          page: page,
          perPage: _pageSize,
          sort: randomSort,
          descending: true,
          organized: false,
          sceneFilter: SceneFilter.empty(),
        );
        if (!mounted || _stopRequested || candidates.isEmpty) break;

        for (final scene in candidates) {
          if (_stopRequested) break;
          try {
            final matches = await repository.scrapeSingleScene(
              stashBoxEndpoint: stashBoxEndpoint,
              sceneId: scene.id,
            );
            if (!mounted) return;
            setState(() {
              _scrapedCount += 1;
              if (matches.isNotEmpty) {
                _scenes = [..._scenes, scene];
                _results[scene.id] = _TaggerResult.matches(matches);
              }
            });
          } catch (error) {
            if (!mounted) return;
            setState(() {
              _scrapedCount += 1;
            });
          }
        }

        page += 1;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
      });
    }

    _finishScraping();
  }

  void _finishScraping() {
    if (mounted) {
      setState(() {
        _scraping = false;
        _stopRequested = false;
      });
    }
  }

  Future<void> _applyScrapedScene(Scene scene, ScrapedScene scraped) async {
    try {
      await ref
          .read(sceneRepositoryProvider)
          .saveScrapedScene(
            sceneId: scene.id,
            scraped: scraped,
            tagIds: _storedTagIds(scraped.tags),
            performerIds: scraped.performers
                .map((performer) => performer.storedId)
                .whereType<String>()
                .toList(growable: false),
            studioId: scraped.studio?.storedId ?? scraped.studioId,
          );
      if (!mounted) return;
      setState(() {
        _results[scene.id] =
            _results[scene.id]?.copyWithSaved() ??
            const _TaggerResult.matches([]);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved ${scene.title}')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
    }
  }

  List<String> _storedTagIds(List<ScrapedTag> tags) {
    return tags
        .map((tag) => tag.storedId)
        .whereType<String>()
        .toList(growable: false);
  }

  void _applyPreset(SceneSavedFilterConfig preset) {
    setState(() {
      _searchController.text = preset.searchQuery;
      _sort = preset.sort ?? _sort;
      _descending = preset.descending;
      _filter = preset.filter;
      if (preset.perPage != null && _pageSizeOptions.contains(preset.perPage)) {
        _pageSize = preset.perPage!;
      }
    });
    _reloadForMode();
  }

  Future<void> _openFilterPanel() async {
    ref.read(sceneFilterStateProvider.notifier).update(_filter);
    ref.read(sceneOrganizedOnlyProvider.notifier).set(_organized);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SceneFilterPanel(),
    );
    if (!mounted) return;
    setState(() {
      _filter = ref.read(sceneFilterStateProvider);
      _organized = ref.read(sceneOrganizedOnlyProvider);
    });
    _reloadForMode();
  }

  @override
  Widget build(BuildContext context) {
    final stashBoxesAsync = ref.watch(stashBoxEndpointsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Scene Tagger')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(
                () => _configExpanded = !_configExpanded,
              ),
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
                      'Configuration',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildControls(stashBoxesAsync),
              crossFadeState: _configExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            if (_configExpanded) const SizedBox(height: 8),
            const SizedBox(height: 16),
            Expanded(child: _buildResultList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultList(BuildContext context) {
    if (_loadError != null) {
      return _ErrorBanner(message: _loadError!, onRetry: _loadScenes);
    }
    if (_loadingScenes) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _mode == _TaggerMode.randomUnorganized
        ? '$_scrapedCount checked • ${_scenes.length} matches'
        : '${_scenes.length} scenes on this page';
    if (_scenes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(summary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(
                _mode == _TaggerMode.randomUnorganized
                    ? 'No matched scenes yet.'
                    : 'No scenes match this configuration.',
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      key: ValueKey('scene_tagger_results_${_mode.name}'),
      itemCount: _scenes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        final scene = _scenes[index - 1];
        return _TaggerSceneCard(
          key: ValueKey('tagger_scene_${scene.id}'),
          scene: scene,
          result: _results[scene.id],
          onOpen: () => context.push('/scene/${scene.id}'),
          onApply: (scraped) => _applyScrapedScene(scene, scraped),
        );
      },
    );
  }

  Widget _buildControls(AsyncValue<List<StashBoxEndpoint>> stashBoxesAsync) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: compact ? double.infinity : 220,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadScenes(),
                  ),
                ),
                DropdownMenu<int>(
                  width: compact ? 150 : 170,
                  initialSelection: _pageSize,
                  label: const Text('Page size'),
                  dropdownMenuEntries: _pageSizeOptions
                      .map(
                        (size) =>
                            DropdownMenuEntry(value: size, label: '$size'),
                      )
                      .toList(growable: false),
                  onSelected: (value) {
                    if (value == null) return;
                    setState(() {
                      _pageSize = value;
                    });
                    _reloadForMode();
                  },
                ),
                DropdownMenu<String>(
                  width: compact ? 190 : 210,
                  initialSelection: _mode.value,
                  label: const Text('Mode'),
                  dropdownMenuEntries: _TaggerMode.values
                      .map(
                        (mode) => DropdownMenuEntry(
                          value: mode.value,
                          label: mode.label,
                        ),
                      )
                      .toList(growable: false),
                  onSelected: (value) {
                    final selected = _TaggerMode.values.firstWhere(
                      (mode) => mode.value == value,
                      orElse: () => _TaggerMode.currentPage,
                    );
                    setState(() {
                      _mode = selected;
                      _results.clear();
                      _scrapedCount = 0;
                      if (_mode == _TaggerMode.randomUnorganized) {
                        _scenes = [];
                      }
                    });
                    if (_mode == _TaggerMode.currentPage) {
                      _loadScenes();
                    }
                  },
                ),
                DropdownMenu<String>(
                  width: compact ? 150 : 170,
                  initialSelection: _sort,
                  label: const Text('Sort'),
                  dropdownMenuEntries: _sortOptions.entries
                      .map(
                        (entry) => DropdownMenuEntry(
                          value: entry.key,
                          label: entry.value,
                        ),
                      )
                      .toList(growable: false),
                  onSelected: (value) {
                    setState(() {
                      _sort = value;
                    });
                    _reloadForMode();
                  },
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Desc')),
                    ButtonSegment(value: false, label: Text('Asc')),
                  ],
                  selected: {_descending},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _descending = selection.first;
                    });
                    _reloadForMode();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _openFilterPanel,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
                FutureBuilder<List<SceneSavedFilterConfig>>(
                  future: _presetsFuture,
                  builder: (context, snapshot) {
                    final presets = snapshot.data ?? const [];
                    return PopupMenuButton<SceneSavedFilterConfig>(
                      tooltip: 'Load preset',
                      enabled: presets.isNotEmpty,
                      onSelected: _applyPreset,
                      itemBuilder: (context) => [
                        for (final preset in presets)
                          PopupMenuItem(
                            value: preset,
                            child: Text(preset.name),
                          ),
                      ],
                      child: IgnorePointer(
                        child: OutlinedButton.icon(
                          onPressed: presets.isEmpty ? null : () {},
                          icon: const Icon(Icons.bookmark_border),
                          label: const Text('Preset'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            stashBoxesAsync.when(
              data: (stashBoxes) {
                final endpoint =
                    _selectedStashBoxEndpoint ??
                    stashBoxes.firstOrNull?.endpoint;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownMenu<String>(
                      width: compact ? double.infinity : 280,
                      initialSelection: endpoint,
                      label: const Text('Stash-box scraper'),
                      dropdownMenuEntries: stashBoxes
                          .map(
                            (box) => DropdownMenuEntry(
                              value: box.endpoint,
                              label: box.name.isEmpty ? box.endpoint : box.name,
                            ),
                          )
                          .toList(growable: false),
                      onSelected: (value) {
                        setState(() {
                          _selectedStashBoxEndpoint = value;
                        });
                      },
                    ),
                    FilledButton.icon(
                      onPressed:
                          endpoint == null ||
                              _scraping ||
                              _loadingScenes ||
                              (_mode == _TaggerMode.currentPage &&
                                  _scenes.isEmpty)
                          ? null
                          : () => _startTagging(endpoint),
                      icon: const Icon(Icons.sell),
                      label: const Text('Start tagging'),
                    ),
                    if (_scraping)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _stopRequested = true;
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                      ),
                    Text(
                      _mode == _TaggerMode.randomUnorganized
                          ? '$_scrapedCount checked'
                          : '$_scrapedCount / ${_scenes.length}',
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Unable to load stash-boxes: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaggerSceneCard extends StatelessWidget {
  const _TaggerSceneCard({
    super.key,
    required this.scene,
    required this.result,
    required this.onOpen,
    required this.onApply,
  });

  final Scene scene;
  final _TaggerResult? result;
  final VoidCallback onOpen;
  final ValueChanged<ScrapedScene> onApply;

  @override
  Widget build(BuildContext context) {
    final scraped = result?.matches?.firstOrNull;
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final comparison = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LocalSceneSummary(scene: scene)),
              const SizedBox(width: 12),
              Expanded(
                child: _ScrapedSceneSummary(
                  scraped: scraped,
                  error: result?.error,
                  saved: result?.saved ?? false,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LocalSceneSummary(scene: scene),
              const SizedBox(height: 12),
              _ScrapedSceneSummary(
                scraped: scraped,
                error: result?.error,
                saved: result?.saved ?? false,
              ),
            ],
          );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    scene.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Open scene',
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
            const SizedBox(height: 8),
            comparison,
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(onPressed: () {}, child: const Text('Skip')),
                FilledButton(
                  onPressed: scraped == null || (result?.saved ?? false)
                      ? null
                      : () => onApply(scraped),
                  child: Text(result?.saved == true ? 'Applied' : 'Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalSceneSummary extends StatelessWidget {
  const _LocalSceneSummary({required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context) {
    return _MetadataPanel(
      title: 'Local scene',
      rows: [
        ('Title', scene.title),
        if (scene.details != null && scene.details!.isNotEmpty)
          ('Details', scene.details!),
        ('Studio', scene.studioName ?? 'None'),
        ('Performers', _joinOrNone(scene.performerNames)),
        ('Tags', _joinOrNone(scene.tagNames)),
        if (scene.files.isNotEmpty)
          (
            'File',
            '${scene.files.first.width ?? 0}x${scene.files.first.height ?? 0}'
                ' • ${_formatDuration(scene.files.first.duration)}',
          ),
      ],
    );
  }
}

class _ScrapedSceneSummary extends StatelessWidget {
  const _ScrapedSceneSummary({
    required this.scraped,
    required this.error,
    required this.saved,
  });

  final ScrapedScene? scraped;
  final String? error;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _MetadataPanel(
        title: 'Scraped metadata',
        rows: [('Error', error!)],
      );
    }
    if (scraped == null) {
      return const _MetadataPanel(
        title: 'Scraped metadata',
        rows: [('Status', 'No match found')],
      );
    }

    return _MetadataPanel(
      title: saved ? 'Scraped metadata - applied' : 'Scraped metadata',
      rows: [
        if (scraped!.title != null) ('Title', scraped!.title!),
        if (scraped!.details != null) ('Details', scraped!.details!),
        if (scraped!.date != null)
          ('Date', scraped!.date!.toIso8601String().split('T').first),
        ('Studio', scraped!.studio?.name ?? 'None'),
        ('Performers', _joinOrNone(scraped!.performers.map((p) => p.name))),
        ('Tags', _joinOrNone(scraped!.tags.map((t) => t.name))),
        if (scraped!.urls.isNotEmpty) ('URLs', scraped!.urls.join(', ')),
      ],
    );
  }
}

class _MetadataPanel extends StatelessWidget {
  const _MetadataPanel({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.$1,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(row.$2),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _joinOrNone(Iterable<String?> values) {
  final cleaned = values
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  return cleaned.isEmpty ? 'None' : cleaned.join(', ');
}

String _formatDuration(double? seconds) {
  if (seconds == null || seconds <= 0) return 'unknown duration';
  final total = seconds.round();
  final minutes = total ~/ 60;
  final remaining = total % 60;
  return '${minutes}m ${remaining}s';
}
