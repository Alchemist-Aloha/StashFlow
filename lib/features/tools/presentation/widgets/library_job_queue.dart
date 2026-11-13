import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../setup/presentation/widgets/settings_page_shell.dart';
import '../../data/library_tasks_repository.dart';
import '../../domain/library_task.dart';

/// Polls only while mounted; requests never overlap or cross server profiles.
class LibraryJobQueue extends StatefulWidget {
  const LibraryJobQueue({
    super.key,
    required this.repository,
    this.queuedJobId,
  });
  final LibraryTasksRepository repository;
  final String? queuedJobId;

  @override
  State<LibraryJobQueue> createState() => _LibraryJobQueueState();
}

class _LibraryJobQueueState extends State<LibraryJobQueue> {
  Timer? _timer;
  List<LibraryJob>? _jobs;
  bool _loading = false;
  bool _failed = false;
  bool _stopping = false;
  final _tracked = <String>{};
  final _completedAt = <String, DateTime>{};

  @override
  void initState() {
    super.initState();
    if (widget.queuedJobId case final String id) _tracked.add(id);
    unawaited(_refresh());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void didUpdateWidget(covariant LibraryJobQueue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.queuedJobId != oldWidget.queuedJobId) {
      if (widget.queuedJobId case final String id) _tracked.add(id);
      unawaited(_refresh());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final jobs = await widget.repository.jobs();
      if (!mounted) return;
      final now = DateTime.now();
      final expired = _completedAt.entries
          .where(
            (entry) =>
                now.difference(entry.value) >= const Duration(seconds: 10),
          )
          .map((entry) => entry.key)
          .toList();
      for (final id in expired) {
        _completedAt.remove(id);
        _tracked.remove(id);
      }
      final currentIds = jobs.map((job) => job.id).toSet();
      // Completed jobs leave jobQueue immediately; findJob retains recent results.
      final missing = _tracked.difference(currentIds);
      for (final id in missing) {
        if (_completedAt.containsKey(id)) {
          jobs.add(_jobs!.firstWhere((job) => job.id == id));
        } else {
          final job = await widget.repository.findJob(id);
          if (!mounted) return;
          if (job == null) {
            _tracked.remove(id);
          } else {
            jobs.add(job);
          }
        }
      }
      for (final job in jobs) {
        _tracked.add(job.id);
        if (!job.canStop && job.status != 'STOPPING') {
          _completedAt.putIfAbsent(job.id, () => now);
        }
      }
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _failed = false;
        });
      }
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      _loading = false;
    }
  }

  Future<void> _stop([String? id]) async {
    setState(() => _stopping = true);
    try {
      if (id == null) {
        await widget.repository.stopAllJobs();
      } else {
        await widget.repository.stopJob(id);
      }
      await _refresh();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.tools_stop_failed)));
      }
    } finally {
      if (mounted) setState(() => _stopping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final jobs = _jobs ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(title: l10n.tools_job_queue),
        if (_failed)
          ErrorStateView(message: l10n.tools_jobs_failed, onRetry: _refresh)
        else if (_jobs == null)
          const LinearProgressIndicator()
        else if (jobs.isEmpty)
          Padding(
            padding: EdgeInsets.all(context.dimensions.spacingMedium),
            child: Text(l10n.tools_jobs_empty),
          )
        else ...[
          SettingsPanelCard(
            child: Column(
              children: [
                for (final job in jobs)
                  ListTile(
                    title: Text(job.description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(switch (job.status) {
                          'READY' => l10n.tools_job_ready,
                          'RUNNING' => l10n.tools_job_running,
                          'STOPPING' => l10n.tools_job_stopping,
                          'FINISHED' => l10n.tools_job_finished,
                          'CANCELLED' => l10n.tools_job_cancelled,
                          _ => l10n.tools_job_failed,
                        }),
                        if (job.status == 'RUNNING') ...[
                          LinearProgressIndicator(
                            value: job.progress?.clamp(0.0, 1.0),
                            semanticsLabel: l10n.tools_job_running,
                          ),
                          if (job.progress case final double progress)
                            Text(
                              '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                            ),
                          if (job.startTime != null && (job.progress ?? 0) > 0)
                            Text(
                              l10n.tools_job_eta(
                                (DateTime.now()
                                            .difference(job.startTime!)
                                            .inSeconds *
                                        (1 - job.progress!) /
                                        job.progress!)
                                    .round()
                                    .clamp(0, 2147483647),
                              ),
                            ),
                        ],
                        if (job.status == 'RUNNING' || job.status == 'STOPPING')
                          for (final task in job.subTasks) Text(task),
                        if (job.status == 'FAILED' && job.error != null)
                          Text(
                            job.error!,
                            style: TextStyle(color: context.colors.error),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: l10n.tools_stop_job,
                      onPressed: !_stopping && job.canStop
                          ? () => _stop(job.id)
                          : null,
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: !_stopping && jobs.any((j) => j.canStop)
                  ? _stop
                  : null,
              child: Text(l10n.tools_stop_all_jobs),
            ),
          ),
        ],
      ],
    );
  }
}
