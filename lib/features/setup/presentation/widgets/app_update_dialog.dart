import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../data/android_update_installer.dart';
import '../../domain/entities/update_info.dart';
import '../providers/update_provider.dart';

enum _UpdatePhase { idle, downloading, ready, permissionRequired, failed }

/// Startup prompt for a newer release.
///
/// On Android, when the release ships an APK for this device's ABI, the dialog
/// downloads it in-app and opens the system installer. Every other platform
/// links to the release page. Any user decision marks the daily startup check
/// as done.
class AppUpdateDialog extends ConsumerStatefulWidget {
  const AppUpdateDialog({required this.updateInfo, super.key});

  final UpdateInfo updateInfo;

  @override
  ConsumerState<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends ConsumerState<AppUpdateDialog> {
  _UpdatePhase _phase = _UpdatePhase.idle;
  int? _percent;
  String? _failure;
  File? _apk;
  CancelToken? _cancelToken;
  bool _installing = false;
  late final AppLifecycleListener _lifecycleListener;

  bool get _canInstallInApp =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      (widget.updateInfo.androidApkUrl?.isNotEmpty ?? false);

  AndroidUpdateInstaller get _installer =>
      ref.read(androidUpdateInstallerProvider);

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  void _markChecked() =>
      ref.read(startupUpdateCheckProvider.notifier).markChecked();

  void _close() {
    _markChecked();
    Navigator.pop(context);
  }

  Future<void> _openReleasePage() async {
    final url = Uri.parse(widget.updateInfo.releaseUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } on Exception catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'openReleasePage',
        error,
        stackTrace,
        source: 'app_update_dialog',
      );
    }
    if (mounted) _close();
  }

  Future<void> _download() async {
    _markChecked();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    setState(() {
      _phase = _UpdatePhase.downloading;
      _percent = null;
      _apk = null;
    });

    try {
      final apk = await _installer.download(
        url: widget.updateInfo.androidApkUrl!,
        version: widget.updateInfo.latestVersion,
        sha256: widget.updateInfo.androidApkSha256,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (!mounted || total <= 0) return;
          final percent = (received * 100 ~/ total).clamp(0, 100);
          if (percent != _percent) setState(() => _percent = percent);
        },
      );
      if (!mounted || cancelToken.isCancelled) return;
      _apk = apk;
      await _install();
    } on Object catch (error, stackTrace) {
      if (!mounted || (error is DioException && CancelToken.isCancel(error))) {
        return;
      }
      AppLogStore.instance.addError(
        'download',
        error,
        stackTrace,
        source: 'app_update_dialog',
      );
      setState(() {
        _phase = _UpdatePhase.failed;
        _failure = context.l10n.update_download_failed;
      });
    } finally {
      if (identical(_cancelToken, cancelToken)) _cancelToken = null;
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
    setState(() => _phase = _UpdatePhase.idle);
  }

  Future<void> _install() async {
    final apk = _apk;
    if (apk == null || _installing) return;
    _installing = true;
    ApkInstallResult result;
    try {
      result = await _installer.install(apk);
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'install',
        error,
        stackTrace,
        source: 'app_update_dialog',
      );
      result = ApkInstallResult.failed;
    } finally {
      _installing = false;
    }
    if (!mounted) return;
    setState(() {
      switch (result) {
        case ApkInstallResult.started:
          // Stay open so the installer can be reopened if the user backs out.
          _phase = _UpdatePhase.ready;
        case ApkInstallResult.permissionRequired:
          _phase = _UpdatePhase.permissionRequired;
        case ApkInstallResult.failed:
          _phase = _UpdatePhase.failed;
          _failure = context.l10n.update_install_failed;
      }
    });
  }

  /// Continues automatically once the user grants the install permission in
  /// the settings screen opened by [_install].
  Future<void> _onResume() async {
    if (_phase != _UpdatePhase.permissionRequired) return;
    try {
      if (!await _installer.canRequestPackageInstalls()) return;
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'onResume',
        error,
        stackTrace,
        source: 'app_update_dialog',
      );
      return;
    }
    if (mounted && _phase == _UpdatePhase.permissionRequired) {
      await _install();
    }
  }

  void _retry() =>
      _apk == null ? unawaited(_download()) : unawaited(_install());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.dimensions.spacingMedium;

    final Widget status = switch (_phase) {
      _UpdatePhase.idle => Text(
        _canInstallInApp
            ? l10n.update_download_install_prompt
            : l10n.would_you_like_to_visit_the_release_page_to_download_it,
      ),
      _UpdatePhase.downloading => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _percent == null
                ? l10n.update_downloading
                : l10n.update_downloading_progress(_percent!),
          ),
          SizedBox(height: context.dimensions.spacingSmall),
          LinearProgressIndicator(
            value: _percent == null ? null : _percent! / 100,
            semanticsLabel: l10n.update_downloading,
            semanticsValue: _percent == null ? null : '$_percent%',
          ),
        ],
      ),
      _UpdatePhase.ready => Text(l10n.update_ready_to_install),
      _UpdatePhase.permissionRequired => Text(
        l10n.update_install_permission_required,
      ),
      _UpdatePhase.failed => Text(
        _failure ?? l10n.update_download_failed,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    };

    final later = TextButton(onPressed: _close, child: Text(l10n.common_later));
    final releaseDetails = TextButton(
      onPressed: _openReleasePage,
      child: Text(l10n.common_release_details),
    );

    final List<Widget> actions = switch (_phase) {
      _UpdatePhase.idle when _canInstallInApp => [
        later,
        releaseDetails,
        FilledButton(
          onPressed: _download,
          child: Text(l10n.update_download_and_install),
        ),
      ],
      _UpdatePhase.idle => [
        later,
        FilledButton(
          onPressed: _openReleasePage,
          child: Text(l10n.common_release_details),
        ),
      ],
      _UpdatePhase.downloading => [
        TextButton(onPressed: _cancelDownload, child: Text(l10n.common_cancel)),
      ],
      _UpdatePhase.ready || _UpdatePhase.permissionRequired => [
        later,
        FilledButton(onPressed: _install, child: Text(l10n.update_install)),
      ],
      _UpdatePhase.failed => [
        later,
        releaseDetails,
        FilledButton(onPressed: _retry, child: Text(l10n.common_retry)),
      ],
    };

    return PopScope(
      // Back cancels an active download instead of silently dropping it.
      canPop: _phase != _UpdatePhase.downloading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelDownload();
      },
      child: AlertDialog(
        scrollable: true,
        title: Text(l10n.common_update_available),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.update_available(widget.updateInfo.latestVersion)),
            SizedBox(height: spacing),
            status,
          ],
        ),
        actions: actions,
      ),
    );
  }
}
