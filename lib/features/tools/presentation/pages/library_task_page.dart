import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../setup/presentation/widgets/settings_page_shell.dart';
import '../../data/library_tasks_repository.dart';
import '../../domain/library_task.dart';
import '../providers/library_tasks_provider.dart';
import '../widgets/library_job_queue.dart';
import '../widgets/server_directory_picker.dart';

/// Scan and generation share server-backed defaults and the same task workflow.
class LibraryTaskPage extends ConsumerWidget {
  const LibraryTaskPage({super.key, required this.task});
  final LibraryTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(libraryTasksRepositoryProvider);
    final settings = ref.watch(libraryTaskSettingsProvider);
    return SettingsPageShell(
      title: task == LibraryTask.scan
          ? context.l10n.tools_library_scan
          : context.l10n.tools_generate_content,
      child: settings.when(
        skipLoadingOnRefresh: false,
        loading: () => const SettingsLoadingState(),
        error: (_, _) => ErrorStateView(
          message: context.l10n.tools_load_failed,
          onRetry: () => ref.invalidate(libraryTaskSettingsProvider),
        ),
        data: (settings) => _TaskForm(
          key: ValueKey((repository, task)),
          repository: repository,
          task: task,
          settings: settings,
          onRefresh: () => ref.invalidate(libraryTaskSettingsProvider),
        ),
      ),
    );
  }
}

class _TaskForm extends StatefulWidget {
  const _TaskForm({
    super.key,
    required this.repository,
    required this.task,
    required this.settings,
    required this.onRefresh,
  });
  final LibraryTasksRepository repository;
  final LibraryTask task;
  final LibraryTaskSettings settings;
  final VoidCallback onRefresh;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late Map<String, bool> _options = {...widget.settings.options(widget.task)};
  bool _busy = false;
  String? _queuedJobId;

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save(String key, bool value) async {
    final previous = _options;
    final updated = {..._options, key: value};
    setState(() {
      _busy = true;
      _options = updated;
    });
    try {
      await widget.repository.saveOptions(widget.task, updated);
    } on Object {
      if (!mounted) return;
      setState(() => _options = previous);
      _message(context.l10n.tools_save_failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start({bool selective = false}) async {
    try {
      List<String>? paths;
      if (selective) {
        paths = await showDialog<List<String>>(
          context: context,
          builder: (_) => ServerDirectoryPicker(
            repository: widget.repository,
            libraryPaths: widget.settings.libraryPaths,
          ),
        );
        if (!mounted || paths == null) return;
      }
      setState(() => _busy = true);
      final id = await widget.repository.start(
        widget.task,
        _options,
        paths: paths,
      );
      if (!mounted) return;
      _message(context.l10n.tools_job_queued(id));
      setState(() => _queuedJobId = id);
    } on Object {
      if (mounted) _message(context.l10n.tools_start_failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = context.dimensions;
    final scan = widget.task == LibraryTask.scan;
    final labels = <String, String>{
      if (scan) ...{
        'scanGenerateCovers': l10n.tools_option_covers,
        'scanGeneratePreviews': l10n.tools_option_previews,
        'scanGenerateImagePreviews': l10n.tools_option_image_previews,
        'scanGenerateSprites': l10n.tools_option_sprites,
        'scanGeneratePhashes': l10n.tools_option_phashes,
        'scanGenerateThumbnails': l10n.tools_option_image_thumbnails,
        'scanGenerateImagePhashes': l10n.tools_option_image_phashes,
        'scanGenerateClipPreviews': l10n.tools_option_clip_previews,
        'rescan': l10n.tools_option_rescan,
      } else ...{
        'covers': l10n.tools_option_covers,
        'previews': l10n.tools_option_previews,
        'imagePreviews': l10n.tools_option_image_previews,
        'sprites': l10n.tools_option_sprites,
        'markers': l10n.tools_option_markers,
        'markerImagePreviews': l10n.tools_option_marker_previews,
        'markerScreenshots': l10n.tools_option_marker_screenshots,
        'transcodes': l10n.tools_option_transcodes,
        'phashes': l10n.tools_option_phashes,
        'interactiveHeatmapsSpeeds': l10n.tools_option_heatmaps,
        'clipPreviews': l10n.tools_option_clip_previews,
        'imageThumbnails': l10n.tools_option_image_thumbnails,
        'imagePhashes': l10n.tools_option_image_phashes,
        'overwrite': l10n.tools_option_overwrite,
      },
    };
    return SettingsPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionHeader(
            subtitle: scan
                ? l10n.tools_scan_description
                : l10n.tools_generate_description,
          ),
          Wrap(
            spacing: d.spacingSmall,
            runSpacing: d.spacingSmall,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _start,
                icon: Icon(
                  scan ? Icons.search_rounded : Icons.auto_awesome_rounded,
                ),
                label: Text(l10n.tools_run_all),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _start(selective: true),
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(l10n.tools_run_selected),
              ),
            ],
          ),
          SizedBox(height: d.spacingLarge),
          SettingsSectionHeader(
            title: l10n.tools_task_options,
            subtitle: l10n.tools_options_sync,
          ),
          if (_busy) ...[
            const LinearProgressIndicator(),
            SizedBox(height: d.spacingSmall),
          ],
          SettingsPanelCard(
            child: Column(
              children: [
                for (final entry in labels.entries)
                  SwitchListTile.adaptive(
                    key: ValueKey(entry.key),
                    title: Text(entry.value),
                    subtitle: entry.key == 'overwrite'
                        ? Text(l10n.tools_overwrite_warning)
                        : null,
                    value: _options[entry.key] == true,
                    onChanged:
                        _busy ||
                            (entry.key ==
                                    (scan
                                        ? 'scanGenerateImagePreviews'
                                        : 'imagePreviews') &&
                                _options[scan
                                        ? 'scanGeneratePreviews'
                                        : 'previews'] !=
                                    true)
                        ? null
                        : (value) => _save(entry.key, value),
                  ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: _busy ? null : widget.onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.common_refresh),
            ),
          ),
          SizedBox(height: d.spacingLarge),
          LibraryJobQueue(
            repository: widget.repository,
            queuedJobId: _queuedJobId,
          ),
        ],
      ),
    );
  }
}
