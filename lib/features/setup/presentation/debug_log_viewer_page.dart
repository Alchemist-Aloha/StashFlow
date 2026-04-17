import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_log_store.dart';

class DebugLogViewerPage extends StatefulWidget {
  const DebugLogViewerPage({super.key});

  @override
  State<DebugLogViewerPage> createState() => _DebugLogViewerPageState();
}

class _DebugLogViewerPageState extends State<DebugLogViewerPage> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyAllLogs() async {
    final buffer = StringBuffer();
    for (final entry in AppLogStore.instance.entries) {
      buffer.writeln(
        '[${entry.formattedTimestamp}] [${entry.source}] ${entry.message}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settings_develop_logs_copied)),
    );
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _scheduleAutoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_autoScroll) return;
      _jumpToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings_develop_log_viewer),
        actions: [
          IconButton(
            tooltip: _autoScroll
                ? context.l10n.common_disable_autoscroll
                : context.l10n.common_enable_autoscroll,
            icon: Icon(_autoScroll ? Icons.lock_open : Icons.lock),
            onPressed: () {
              setState(() => _autoScroll = !_autoScroll);
              if (_autoScroll) {
                _scheduleAutoScroll();
              }
            },
          ),
          IconButton(
            tooltip: context.l10n.common_copy_logs,
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: _copyAllLogs,
          ),
          IconButton(
            tooltip: context.l10n.common_clear_logs,
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              AppLogStore.instance.clear();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: AppLogStore.instance.revision,
        builder: (context, revisionValue, child) {
          final entries = AppLogStore.instance.entries;
          _scheduleAutoScroll();

          if (entries.isEmpty) {
            return Center(
              child: Text(context.l10n.settings_develop_no_logs),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: SelectableText(
                  '[${entry.formattedTimestamp}] [${entry.source}] ${entry.message}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
