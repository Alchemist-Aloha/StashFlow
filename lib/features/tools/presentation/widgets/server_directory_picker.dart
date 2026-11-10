import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../data/library_tasks_repository.dart';
import '../../domain/library_task.dart';
import '../providers/library_tasks_provider.dart';

/// Selects remote directories; typing a path never accesses local storage.
class ServerDirectoryPicker extends ConsumerStatefulWidget {
  const ServerDirectoryPicker({
    super.key,
    required this.repository,
    required this.libraryPaths,
  });
  final LibraryTasksRepository repository;
  final List<String> libraryPaths;

  @override
  ConsumerState<ServerDirectoryPicker> createState() =>
      _ServerDirectoryPickerState();
}

class _ServerDirectoryPickerState extends ConsumerState<ServerDirectoryPicker> {
  final _path = TextEditingController();
  final _selected = <String>{};
  Future<ServerDirectory>? _directory;

  @override
  void dispose() {
    _path.dispose();
    super.dispose();
  }

  void _browse(String path) {
    _path.text = path;
    setState(() {
      _directory = path.isEmpty ? null : widget.repository.directory(path);
      // FutureBuilder attaches next frame, after an immediate failure can fire.
      _directory?.ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    // A dialog is a separate route and must not retain a switched-out profile.
    ref.listen(libraryTasksRepositoryProvider, (previous, next) {
      if (next != widget.repository && mounted) Navigator.of(context).pop();
    });
    final l10n = context.l10n;
    final d = context.dimensions;
    return AlertDialog(
      title: Text(l10n.tools_select_folders),
      content: SizedBox(
        width: 560 * d.fontSizeFactor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.tools_server_folders),
              SizedBox(height: d.spacingMedium),
              for (final path in _selected)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(path),
                  trailing: IconButton(
                    tooltip: l10n.common_remove,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: () => setState(() => _selected.remove(path)),
                  ),
                ),
              TextField(
                controller: _path,
                decoration: InputDecoration(labelText: l10n.tools_server_path),
                autocorrect: false,
                onSubmitted: _browse,
                onChanged: (_) => setState(() {}),
              ),
              Wrap(
                spacing: d.spacingSmall,
                runSpacing: d.spacingSmall,
                children: [
                  TextButton.icon(
                    onPressed: () => _browse(_path.text),
                    icon: const Icon(Icons.folder_open_rounded),
                    label: Text(l10n.tools_browse),
                  ),
                  TextButton.icon(
                    onPressed: _path.text.trim().isEmpty
                        ? null
                        : () => setState(() => _selected.add(_path.text)),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.common_add),
                  ),
                ],
              ),
              if (_directory == null)
                for (final path in widget.libraryPaths) _folder(path)
              else
                FutureBuilder<ServerDirectory>(
                  future: _directory,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return ErrorStateView(
                        message: l10n.tools_directory_failed,
                        onRetry: () => _browse(_path.text),
                      );
                    }
                    final directory = snapshot.requireData;
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.drive_folder_upload_outlined,
                          ),
                          title: Text(l10n.tools_parent_folder),
                          onTap: () => _browse(
                            widget.libraryPaths.contains(directory.path)
                                ? ''
                                : directory.parent ?? '',
                          ),
                        ),
                        for (final path in directory.children) _folder(path),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.toList()),
          child: Text(l10n.tools_run_selected),
        ),
      ],
    );
  }

  Widget _folder(String path) => ListTile(
    leading: const Icon(Icons.folder_outlined),
    title: Text(path),
    onTap: () => _browse(path),
  );
}
