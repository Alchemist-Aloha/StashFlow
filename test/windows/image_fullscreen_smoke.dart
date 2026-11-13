// Run with scripts/test_windows_image_fullscreen.py after building this target.
// Widget tests mock the fullscreen channel, so they cannot detect native hangs.
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/desktop_fullscreen.dart';
import 'package:stash_app_flutter/core/utils/desktop_window.dart';
import 'package:stash_app_flutter/core/utils/root_app_runner.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class _Images extends ImageList {
  _Images(this.images);

  final List<entity.Image> images;

  @override
  FutureOr<List<entity.Image>> build() => images;

  @override
  Future<void> fetchNextPage() async {}
}

final _log = File('image_fullscreen_smoke.log');

void _record(String message) =>
    _log.writeAsStringSync('$message\n', mode: FileMode.append);

void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void _key(PhysicalKeyboardKey physical, LogicalKeyboardKey logical) {
  final handler = ui.PlatformDispatcher.instance.onKeyData;
  _check(handler != null, 'Keyboard dispatch is not installed');
  for (final type in [ui.KeyEventType.down, ui.KeyEventType.up]) {
    handler!(
      ui.KeyData(
        type: type,
        timeStamp: Duration.zero,
        physical: physical.usbHidUsage,
        logical: logical.keyId,
        character: null,
        // No legacy raw-key message follows these fixture events.
        synthesized: true,
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _log.writeAsStringSync('START\n');
  FlutterError.onError = (details) {
    _record('FAIL $details');
    exit(1);
  };
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    _record('FAIL $error\n$stack');
    exit(1);
  };

  try {
    await DesktopWindow.instance.initialize();
    const channel = MethodChannel('stash_app_flutter/fullscreen');
    final handle = await channel.invokeMethod<int>('getWindowHandle');
    final window = Window.createWithNativeWindow(
      Pointer<Void>.fromAddress(handle!),
    );
    if (window == null) throw StateError('Main window binding failed');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // Empty media URLs isolate window lifecycle and input from image services.
    // The native deadlock also occurs with the viewer's unavailable-image UI.
    final images = [
      for (var i = 1; i <= 3; i++)
        entity.Image(
          id: '$i',
          title: 'Fixture $i',
          files: const [],
          paths: const entity.ImagePaths(),
        ),
    ];
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mediaHeadersProvider.overrideWithValue(const {}),
        imageListProvider.overrideWith(() => _Images(images)),
      ],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: SizedBox.expand()),
        ),
        GoRoute(
          path: '/image',
          builder: (context, state) => const ImageFullscreenPage(imageId: '1'),
        ),
      ],
    );
    runRootApp(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    for (final maximized in [true, false, true]) {
      if (maximized) {
        window.maximize();
      } else {
        window.unmaximize();
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _check(window.isMaximized == maximized, 'Initial window state');
      _record('OPEN maximized=$maximized');
      unawaited(router.push('/image'));
      await Future<void>.delayed(const Duration(seconds: 1));
      _check(
        container.read(imageFullscreenCurrentIdProvider) == '1',
        'Initial image selection',
      );
      _key(PhysicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowRight);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _check(
        container.read(imageFullscreenCurrentIdProvider) == '2',
        'Keyboard navigation after entering fullscreen',
      );
      _record('NAVIGATED');
      _key(PhysicalKeyboardKey.escape, LogicalKeyboardKey.escape);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _check(!router.canPop(), 'Escape did not close the image viewer');
      await DesktopFullscreen.instance.exit();
      _check(window.isMaximized == maximized, 'Restored window state');
      _record('RESTORED maximized=$maximized');
    }
    _record('PASS');
    exit(0);
  } on Object catch (error, stack) {
    _record('FAIL $error\n$stack');
    exit(1);
  }
}
