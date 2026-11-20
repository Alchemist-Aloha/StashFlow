import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/data/android_update_installer.dart';
import 'package:stash_app_flutter/features/setup/domain/entities/update_info.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/app_update_dialog.dart';

import '../../../../helpers/test_helpers.dart';

class _FakeInstaller implements AndroidUpdateInstaller {
  Completer<File>? pendingDownload;
  ProgressCallback? lastProgress;
  String? lastSha256;
  int downloadCalls = 0;
  final installResults = <ApkInstallResult>[];
  int installCalls = 0;
  bool canInstall = false;

  @override
  Future<File> download({
    required String url,
    required String version,
    String? sha256,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) {
    downloadCalls++;
    lastProgress = onProgress;
    lastSha256 = sha256;
    pendingDownload = Completer<File>();
    return pendingDownload!.future;
  }

  @override
  Future<ApkInstallResult> install(File apk) async {
    installCalls++;
    return installResults.isEmpty
        ? ApkInstallResult.started
        : installResults.removeAt(0);
  }

  @override
  Future<bool> canRequestPackageInstalls() async => canInstall;

  @override
  Future<void> deleteDownloads() async {}
}

const _info = UpdateInfo(
  isUpdateAvailable: true,
  latestVersion: 'v9.0.0',
  currentVersion: '1.10.0',
  releaseUrl: 'https://example.test/release',
  androidApkUrl: 'https://example.test/StashFlow-arm64-v8a.apk',
  androidApkSha256: 'abc',
);

Future<_FakeInstaller> _pump(
  WidgetTester tester, {
  UpdateInfo info = _info,
}) async {
  // A recent check keeps the startup provider from querying GitHub.
  SharedPreferences.setMockInitialValues({
    'last_app_update_check_timestamp': DateTime.now().millisecondsSinceEpoch,
  });
  final installer = _FakeInstaller();
  await pumpTestWidget(
    tester,
    prefs: await SharedPreferences.getInstance(),
    overrides: [androidUpdateInstallerProvider.overrideWithValue(installer)],
    child: AppUpdateDialog(updateInfo: info),
  );
  await tester.pumpAndSettle();
  return installer;
}

void main() {
  final android = TargetPlatformVariant.only(TargetPlatform.android);

  testWidgets('downloads with progress and opens the installer', (
    tester,
  ) async {
    final installer = await _pump(tester);

    await tester.tap(find.text('Download & Install'));
    await tester.pump();
    expect(find.text('Downloading update…'), findsOneWidget);
    expect(installer.lastSha256, 'abc');

    installer.lastProgress!(42, 100);
    await tester.pump();
    expect(find.text('Downloading update… 42%'), findsOneWidget);
    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, closeTo(0.42, 0.001));

    installer.pendingDownload!.complete(File('update.apk'));
    await tester.pumpAndSettle();

    expect(installer.installCalls, 1);
    expect(find.text('The update is ready to install.'), findsOneWidget);
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();
    expect(installer.installCalls, 2);
  }, variant: android);

  testWidgets('resumes the install after the permission is granted', (
    tester,
  ) async {
    final installer = await _pump(tester);
    installer.installResults.add(ApkInstallResult.permissionRequired);

    await tester.tap(find.text('Download & Install'));
    await tester.pump();
    installer.pendingDownload!.complete(File('update.apk'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Allow StashFlow to install unknown apps'),
      findsOneWidget,
    );

    // Returning without the permission keeps waiting.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(installer.installCalls, 1);

    installer.canInstall = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(installer.installCalls, 2);
    expect(find.text('The update is ready to install.'), findsOneWidget);
  }, variant: android);

  testWidgets('reports download failures and retries', (tester) async {
    final installer = await _pump(tester);

    await tester.tap(find.text('Download & Install'));
    await tester.pump();
    installer.pendingDownload!.completeError(const ApkVerificationException());
    await tester.pumpAndSettle();
    expect(
      find.textContaining('The update could not be downloaded'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(installer.downloadCalls, 2);
    expect(find.text('Downloading update…'), findsOneWidget);
  }, variant: android);

  testWidgets('cancelling a download returns to the prompt', (tester) async {
    final installer = await _pump(tester);

    await tester.tap(find.text('Download & Install'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    installer.pendingDownload!.completeError(
      DioException.requestCancelled(
        requestOptions: RequestOptions(),
        reason: 'cancelled',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Download & Install'), findsOneWidget);
    expect(installer.installCalls, 0);
  }, variant: android);

  testWidgets('only links to the release page without an APK', (tester) async {
    await _pump(tester, info: _info.copyWith(androidApkUrl: null));

    expect(find.text('Download & Install'), findsNothing);
    expect(
      find.widgetWithText(FilledButton, 'Release Details'),
      findsOneWidget,
    );
  }, variant: android);

  testWidgets('does not offer in-app install off Android', (tester) async {
    await _pump(tester);

    expect(find.text('Download & Install'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
