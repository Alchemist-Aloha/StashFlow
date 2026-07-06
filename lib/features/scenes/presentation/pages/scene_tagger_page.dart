import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/domain/entities/scraped/scraped_scene.dart';
import '../../../../core/domain/entities/scraped/scraped_tag.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../setup/presentation/providers/stashbox_provider.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../../data/utils/scrape_normalizer.dart';
import '../providers/scene_list_provider.dart';
import '../widgets/scene_filter_panel.dart';

class SceneTaggerPage extends ConsumerStatefulWidget {
  const SceneTaggerPage({super.key});

  @override
  ConsumerState<SceneTaggerPage> createState() => _SceneTaggerPageState();
}

class _TaggerResult {
  const _TaggerResult._({this.matches, this.error});

  const _TaggerResult.matches(List<ScrapedScene> matches)
    : this._(matches: matches);

  const _TaggerResult.error(String error) : this._(error: error);

  final List<ScrapedScene>? matches;
  final String? error;
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
  final Map<String, int> _selectedMatchIndexes = {};
  final Set<String> _expandedSceneIds = <String>{};
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
  String? _activePreviewSceneId;

  @override
  void initState() {
    super.initState();
    _presetsFuture = ref
        .read(savedFilterRepositoryProvider)
        .findAll(mode: 'SCENES', fromRaw: SceneSavedFilterConfig.fromRaw);
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
      _selectedMatchIndexes.clear();
      _expandedSceneIds.clear();
      _activePreviewSceneId = null;
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
      _selectedMatchIndexes.clear();
      _expandedSceneIds.clear();
      _activePreviewSceneId = null;
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
      _selectedMatchIndexes.clear();
      _expandedSceneIds.clear();
      _activePreviewSceneId = null;
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
          _selectedMatchIndexes[scene.id] = 0;
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
      _selectedMatchIndexes.clear();
      _expandedSceneIds.clear();
      _activePreviewSceneId = null;
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
                _selectedMatchIndexes[scene.id] = 0;
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

  void _removeSceneFromResults(String sceneId) {
    setState(() {
      _scenes = _scenes
          .where((scene) => scene.id != sceneId)
          .toList(growable: false);
      _results.remove(sceneId);
      _selectedMatchIndexes.remove(sceneId);
      _expandedSceneIds.remove(sceneId);
      if (_activePreviewSceneId == sceneId) {
        _activePreviewSceneId = null;
      }
    });
  }

  int _selectedMatchIndex(String sceneId, List<ScrapedScene>? matches) {
    final available = matches?.length ?? 0;
    if (available <= 1) {
      return 0;
    }
    final current = _selectedMatchIndexes[sceneId] ?? 0;
    if (current < 0) return 0;
    if (current >= available) return available - 1;
    return current;
  }

  Future<void> _applySelectedScrapedScene(Scene scene) async {
    final result = _results[scene.id];
    final matches = result?.matches;
    if (matches == null || matches.isEmpty) return;
    final selectedIndex = _selectedMatchIndex(scene.id, matches);
    final scraped = matches[selectedIndex];

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
      _removeSceneFromResults(scene.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saved_item(scene.title))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failed_to_save(error.toString()))),
      );
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
      appBar: AppBar(title: Text(context.l10n.scene_tagger)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _configExpanded = !_configExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      _configExpanded ? Icons.expand_less : Icons.expand_more,
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
        ? context.l10n.scene_tagger_checked_matches_summary(
            _scrapedCount,
            _scenes.length,
          )
        : context.l10n.scene_tagger_page_summary(_scenes.length);
    if (_scenes.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(summary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                _mode == _TaggerMode.randomUnorganized
                    ? context.l10n.no_matched_scenes_yet
                    : context.l10n.no_scenes_match_configuration,
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
        final result = _results[scene.id];
        final selectedMatchIndex = _selectedMatchIndex(
          scene.id,
          result?.matches,
        );
        return _TaggerSceneCard(
          key: ValueKey('tagger_scene_${scene.id}'),
          scene: scene,
          result: result,
          selectedMatchIndex: selectedMatchIndex,
          expanded: _expandedSceneIds.contains(scene.id),
          isPreviewActive: _activePreviewSceneId == scene.id,
          onOpen: () => context.go('/scene/${scene.id}'),
          onApply: () => _applySelectedScrapedScene(scene),
          onSkip: () => _removeSceneFromResults(scene.id),
          onSelectMatch: (selectedIndex) {
            setState(() {
              _selectedMatchIndexes[scene.id] = selectedIndex;
            });
          },
          onToggleExpanded: () {
            setState(() {
              if (_expandedSceneIds.contains(scene.id)) {
                _expandedSceneIds.remove(scene.id);
              } else {
                _expandedSceneIds.add(scene.id);
              }
            });
          },
          onPreviewActivate: () {
            setState(() {
              _activePreviewSceneId = scene.id;
            });
          },
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
                      labelText: '',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ).copyWith(labelText: context.l10n.common_search),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadScenes(),
                  ),
                ),
                DropdownMenu<int>(
                  width: compact ? 150 : 170,
                  initialSelection: _pageSize,
                  label: Text(context.l10n.page_size),
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
                  label: Text(context.l10n.mode),
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
                  label: Text(context.l10n.sort),
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
                  segments: [
                    ButtonSegment(value: true, label: Text(context.l10n.desc)),
                    ButtonSegment(value: false, label: Text(context.l10n.asc)),
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
                  label: Text(context.l10n.filter),
                ),
                FutureBuilder<List<SceneSavedFilterConfig>>(
                  future: _presetsFuture,
                  builder: (context, snapshot) {
                    final presets = snapshot.data ?? const [];
                    return PopupMenuButton<SceneSavedFilterConfig>(
                      tooltip: context.l10n.load_preset,
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
                          label: Text(context.l10n.preset),
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
                      label: Text(context.l10n.stash_box_scraper),
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
                      label: Text(context.l10n.start_tagging),
                    ),
                    if (_scraping)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _stopRequested = true;
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: Text(context.l10n.stop),
                      ),
                    Text(
                      _mode == _TaggerMode.randomUnorganized
                          ? context.l10n.scene_tagger_checked_count(
                              _scrapedCount,
                            )
                          : context.l10n.scene_tagger_progress(
                              _scrapedCount,
                              _scenes.length,
                            ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(
                context.l10n.unable_to_load_stash_boxes(error.toString()),
              ),
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
    required this.selectedMatchIndex,
    required this.expanded,
    required this.isPreviewActive,
    required this.onOpen,
    required this.onApply,
    required this.onSkip,
    required this.onSelectMatch,
    required this.onToggleExpanded,
    required this.onPreviewActivate,
  });

  final Scene scene;
  final _TaggerResult? result;
  final int selectedMatchIndex;
  final bool expanded;
  final bool isPreviewActive;
  final VoidCallback onOpen;
  final VoidCallback onApply;
  final VoidCallback onSkip;
  final ValueChanged<int> onSelectMatch;
  final VoidCallback onToggleExpanded;
  final VoidCallback onPreviewActivate;

  @override
  Widget build(BuildContext context) {
    final matches = result?.matches ?? const <ScrapedScene>[];
    final hasMatches = matches.isNotEmpty;
    final safeSelectedIndex = hasMatches
        ? selectedMatchIndex.clamp(0, matches.length - 1)
        : 0;
    final scraped = hasMatches ? matches[safeSelectedIndex] : null;
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final comparison = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LocalSceneSummary(
                  scene: scene,
                  isPreviewActive: isPreviewActive,
                  onPreviewActivate: onPreviewActivate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScrapedSceneSummary(
                  sceneId: scene.id,
                  scraped: scraped,
                  error: result?.error,
                  title: context.l10n.scraped_metadata_title,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LocalSceneSummary(
                scene: scene,
                isPreviewActive: isPreviewActive,
                onPreviewActivate: onPreviewActivate,
              ),
              const SizedBox(height: 12),
              _ScrapedSceneSummary(
                sceneId: scene.id,
                scraped: scraped,
                error: result?.error,
                title: context.l10n.scraped_metadata_title,
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
                  tooltip: context.l10n.open_scene,
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
            const SizedBox(height: 8),
            comparison,
            if (matches.length > 1) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onToggleExpanded,
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(
                    expanded
                        ? 'Collapse results'
                        : 'Show ${matches.length - 1} more result${matches.length == 2 ? '' : 's'}',
                  ),
                ),
              ),
            ],
            if (expanded && matches.length > 1) ...[
              const SizedBox(height: 8),
              for (var index = 0; index < matches.length; index++) ...[
                _ExpandedScrapedMatchCard(
                  sceneId: scene.id,
                  index: index,
                  total: matches.length,
                  scraped: matches[index],
                  selected: index == safeSelectedIndex,
                  onSelect: () => onSelectMatch(index),
                ),
                if (index < matches.length - 1) const SizedBox(height: 8),
              ],
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(onPressed: onSkip, child: Text(context.l10n.skip)),
                FilledButton(
                  onPressed: scraped == null ? null : onApply,
                  child: Text(context.l10n.apply),
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
  const _LocalSceneSummary({
    required this.scene,
    required this.isPreviewActive,
    required this.onPreviewActivate,
  });

  final Scene scene;
  final bool isPreviewActive;
  final VoidCallback onPreviewActivate;

  @override
  Widget build(BuildContext context) {
    return _MetadataPanel(
      title: context.l10n.local_scene_title,
      media: _ScenePreviewPlayer(
        key: ValueKey('scene_preview_player_${scene.id}'),
        scene: scene,
        isActive: isPreviewActive,
        onActivate: onPreviewActivate,
      ),
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
        if (scene.path != null && scene.path!.trim().isNotEmpty)
          ('Path', scene.path!.trim()),
      ],
    );
  }
}

class _ScrapedSceneSummary extends StatelessWidget {
  const _ScrapedSceneSummary({
    required this.sceneId,
    required this.scraped,
    required this.error,
    required this.title,
  });

  final String sceneId;
  final ScrapedScene? scraped;
  final String? error;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _MetadataPanel(title: title, rows: [('Error', error!)]);
    }
    if (scraped == null) {
      return _MetadataPanel(title: title, rows: [('Status', 'No match found')]);
    }

    return _MetadataPanel(
      title: title,
      media: scraped!.image == null || scraped!.image!.trim().isEmpty
          ? null
          : _ScrapedImagePreview(
              key: ValueKey('selected_scraped_image_$sceneId'),
              image: scraped!.image!,
              height: 180,
            ),
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

class _ExpandedScrapedMatchCard extends StatelessWidget {
  const _ExpandedScrapedMatchCard({
    required this.sceneId,
    required this.index,
    required this.total,
    required this.scraped,
    required this.selected,
    required this.onSelect,
  });

  final String sceneId;
  final int index;
  final int total;
  final ScrapedScene scraped;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return _MetadataPanel(
      title: context.l10n.scene_tagger_result_count(index + 1, total),
      headerTrailing: selected
          ? Chip(label: Text(context.l10n.selected))
          : OutlinedButton(
              key: ValueKey('select_scraped_${sceneId}_$index'),
              onPressed: onSelect,
              child: Text(context.l10n.select),
            ),
      media: scraped.image == null || scraped.image!.trim().isEmpty
          ? null
          : _ScrapedImagePreview(
              key: ValueKey('expanded_scraped_image_${sceneId}_$index'),
              image: scraped.image!,
              height: 140,
            ),
      rows: [
        if (scraped.title != null) ('Title', scraped.title!),
        if (scraped.details != null) ('Details', scraped.details!),
        if (scraped.date != null)
          ('Date', scraped.date!.toIso8601String().split('T').first),
        ('Studio', scraped.studio?.name ?? 'None'),
        ('Performers', _joinOrNone(scraped.performers.map((p) => p.name))),
        ('Tags', _joinOrNone(scraped.tags.map((t) => t.name))),
        if (scraped.urls.isNotEmpty) ('URLs', scraped.urls.join(', ')),
      ],
    );
  }
}

class _MetadataPanel extends StatelessWidget {
  const _MetadataPanel({
    required this.title,
    required this.rows,
    this.media,
    this.headerTrailing,
  });

  final String title;
  final List<(String, String)> rows;
  final Widget? media;
  final Widget? headerTrailing;

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
            if (headerTrailing != null) ...[
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: headerTrailing!),
            ],
            if (media != null) ...[const SizedBox(height: 8), media!],
            if (rows.isNotEmpty) const SizedBox(height: 8),
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
              label: Text(context.l10n.common_retry),
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

class _ScenePreviewPlayer extends ConsumerStatefulWidget {
  const _ScenePreviewPlayer({
    required this.scene,
    required this.isActive,
    required this.onActivate,
    super.key,
  });

  final Scene scene;
  final bool isActive;
  final VoidCallback onActivate;

  @override
  ConsumerState<_ScenePreviewPlayer> createState() =>
      _ScenePreviewPlayerState();
}

class _ScenePreviewPlayerState extends ConsumerState<_ScenePreviewPlayer> {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<Object>? _errorSubscription;
  bool _initializing = false;
  String? _error;

  String? get _thumbnailUrl {
    final screenshot = widget.scene.paths.screenshot?.trim();
    if (screenshot != null && screenshot.isNotEmpty) {
      return screenshot;
    }
    final preview = widget.scene.paths.preview?.trim();
    if (preview != null && preview.isNotEmpty) {
      return preview;
    }
    return null;
  }

  String? get _streamUrl {
    final raw = widget.scene.paths.stream?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final graphqlEndpoint = Uri.tryParse(ref.read(serverUrlProvider));
    if (graphqlEndpoint == null) {
      return raw;
    }
    return resolveGraphqlMediaUrl(
      rawUrl: raw,
      graphqlEndpoint: graphqlEndpoint,
    );
  }

  @override
  void didUpdateWidget(covariant _ScenePreviewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id) {
      unawaited(_disposePlayer());
      return;
    }
    if (oldWidget.isActive && !widget.isActive) {
      unawaited(_disposePlayer());
      return;
    }
    if (!oldWidget.isActive && widget.isActive) {
      unawaited(_ensurePlayerAndPlay());
    }
  }

  @override
  void dispose() {
    unawaited(_disposePlayer());
    super.dispose();
  }

  Future<void> _ensurePlayerAndPlay() async {
    if (_initializing) return;
    final streamUrl = _streamUrl;
    if (streamUrl == null || streamUrl.isEmpty) {
      setState(() {
        _error = 'Preview unavailable';
      });
      return;
    }

    if (_player != null && _controller != null) {
      setState(() {
        _error = null;
      });
      await _player!.play();
      return;
    }

    setState(() {
      _initializing = true;
      _error = null;
    });

    final player = Player();
    final controller = VideoController(player);
    _player = player;
    _controller = controller;

    _errorSubscription = player.stream.error.listen((error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    });

    try {
      final headers = ref.read(mediaPlaybackHeadersProvider);
      var effectiveStreamUrl = streamUrl;
      var effectiveHeaders = headers;
      if (kIsWeb) {
        final authState = ref.read(authProvider);
        final apiKey = ref.read(serverApiKeyProvider);
        final serverUrl = ref.read(serverUrlProvider);
        effectiveStreamUrl = applyWebMediaAuthFallback(
          url: streamUrl,
          authMode: authState.mode,
          apiKey: apiKey,
          username: authState.username,
          password: authState.password,
          graphqlEndpoint: Uri.tryParse(serverUrl),
        );
        effectiveHeaders = const <String, String>{};
      }

      await player.open(
        Media(effectiveStreamUrl, httpHeaders: effectiveHeaders),
        play: true,
      );
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  Future<void> _disposePlayer() async {
    await _errorSubscription?.cancel();
    _errorSubscription = null;

    final player = _player;
    _player = null;
    _controller = null;
    if (player != null) {
      await player.dispose();
    }

    if (!mounted) return;
    setState(() {
      _initializing = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasActiveVideo = widget.isActive && controller != null;
    final thumbnailUrl = _thumbnailUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: hasActiveVideo
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _PreviewNativeControls(
                      child: Video(controller: controller),
                    ),
                    if (_initializing)
                      const Center(child: CircularProgressIndicator()),
                    if (_error != null && _error!.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                )
              : GestureDetector(
                  onTap: _streamUrl == null ? null : widget.onActivate,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumbnailUrl != null)
                        StashImage(
                          key: ValueKey(
                            'scene_preview_thumbnail_${widget.scene.id}',
                          ),
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                        )
                      else
                        const Center(
                          child: Icon(
                            Icons.movie_outlined,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                        ),
                      ),
                      Center(
                        child: Container(
                          key: ValueKey(
                            'scene_preview_activate_${widget.scene.id}',
                          ),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      if (_error != null && _error!.isNotEmpty)
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _PreviewNativeControls extends StatelessWidget {
  const _PreviewNativeControls({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const mobileControls = MaterialVideoControlsThemeData(
      bottomButtonBarMargin: EdgeInsets.fromLTRB(12, 0, 4, 8),
      seekBarMargin: EdgeInsets.fromLTRB(12, 0, 12, 8),
    );
    const desktopControls = MaterialDesktopVideoControlsThemeData(
      bottomButtonBarMargin: EdgeInsets.fromLTRB(12, 0, 12, 8),
      seekBarMargin: EdgeInsets.fromLTRB(12, 0, 12, 8),
    );

    return MaterialVideoControlsTheme(
      normal: mobileControls,
      fullscreen: mobileControls,
      child: MaterialDesktopVideoControlsTheme(
        normal: desktopControls,
        fullscreen: desktopControls,
        child: child,
      ),
    );
  }
}

class _ScrapedImagePreview extends StatefulWidget {
  const _ScrapedImagePreview({
    super.key,
    required this.image,
    required this.height,
  });

  final String image;
  final double height;

  @override
  State<_ScrapedImagePreview> createState() => _ScrapedImagePreviewState();
}

class _ScrapedImagePreviewState extends State<_ScrapedImagePreview> {
  late String _trimmedImage;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _updateCachedImage();
  }

  @override
  void didUpdateWidget(covariant _ScrapedImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _updateCachedImage();
    }
  }

  void _updateCachedImage() {
    _trimmedImage = widget.image.trim();
    _imageBytes = _scrapedImageBytes(_trimmedImage);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: _imageBytes != null
              ? Image.memory(
                  excludeFromSemantics: true,
                  _imageBytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) =>
                      const _ScrapedImageFallback(),
                )
              : StashImage(imageUrl: _trimmedImage, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

Uint8List? _scrapedImageBytes(String image) {
  final coverImage = normalizedSceneCoverImage(image);
  if (coverImage == null) return null;
  try {
    return base64Decode(coverImage.split(',').last);
  } on FormatException {
    return null;
  }
}

class _ScrapedImageFallback extends StatelessWidget {
  const _ScrapedImageFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant),
    );
  }
}
