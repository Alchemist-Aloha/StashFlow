import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/navigation/presentation/router.dart';
import 'core/data/preferences/shared_preferences_provider.dart';
import 'core/utils/app_log_store.dart';
import 'core/utils/pip_mode.dart';
import 'core/utils/media_handler.dart';
import 'package:audio_service/audio_service.dart';

import 'core/presentation/theme/app_theme.dart';
import 'core/presentation/theme/theme_mode_provider.dart';

StashMediaHandler? mediaHandler;

StashMediaHandler _buildMediaHandler() => StashMediaHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PipMode.initialize();
  
  try {
    mediaHandler = await AudioService.init(
      builder: _buildMediaHandler,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.github.alchemistaloha.stash_app_flutter.channel.audio',
        androidNotificationChannelName: 'StashFlow Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
      ),    );
  } catch (e) {
    debugPrint('Failed to initialize AudioService: $e');
    // Fallback or handle gracefully
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  final oldDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      AppLogStore.instance.add(message, source: 'debugPrint');
    }
    oldDebugPrint(message, wrapWidth: wrapWidth);
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogStore.instance.add(
      details.exceptionAsString(),
      source: 'flutter_error',
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogStore.instance.add('$error\n$stack', source: 'unhandled_error');
    return false;
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'StashFlow',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
