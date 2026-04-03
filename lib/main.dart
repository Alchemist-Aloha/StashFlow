import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/navigation/presentation/router.dart';
import 'core/data/graphql/graphql_client.dart';
import 'core/data/preferences/secure_storage_provider.dart';
import 'core/data/preferences/shared_preferences_provider.dart';
import 'core/utils/app_log_store.dart';
import 'core/utils/pip_mode.dart';
import 'core/utils/media_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'core/presentation/theme/app_theme.dart';
import 'core/presentation/theme/theme_mode_provider.dart';
import 'core/presentation/theme/theme_color_provider.dart';

const bool isTestMode = bool.fromEnvironment(
  'FLUTTER_TEST',
  defaultValue: false,
);

StashMediaHandler? mediaHandler;

StashMediaHandler _buildMediaHandler() => StashMediaHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Increase Flutter's in-memory image cache so more decoded thumbnails stay
  // resident during aggressive prefetching and fast scrolling.
  // Tune these values based on available memory and observed behavior.
  try {
    PaintingBinding.instance.imageCache.maximumSize = 2000;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        100 * 1024 * 1024; // 100 MB
  } catch (_) {
    // Ignore if PaintingBinding isn't available in some test environments.
  }
  await initHiveForFlutter();
  PipMode.initialize();

  if (!isTestMode) {
    try {
      mediaHandler = await AudioService.init(
        builder: _buildMediaHandler,
        config: const AudioServiceConfig(
          androidNotificationChannelId:
              'com.github.alchemistaloha.stash_app_flutter.channel.audio',
          androidNotificationChannelName: 'StashFlow Playback',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: true,
        ),
      );
    } catch (e) {
      debugPrint('Failed to initialize AudioService: $e');
      // Fallback or handle gracefully
    }
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Migrate API key from SharedPreferences to Secure Storage if needed.
  if (sharedPreferences.containsKey('server_api_key')) {
    final oldApiKey = sharedPreferences.getString('server_api_key');
    if (oldApiKey != null && oldApiKey.isNotEmpty) {
      await secureStorage.write(key: 'server_api_key', value: oldApiKey);
    }
    await sharedPreferences.remove('server_api_key');
  }

  final initialApiKey = await secureStorage.read(key: 'server_api_key') ?? '';

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
        secureStorageProvider.overrideWithValue(secureStorage),
        serverApiKeyInternalProvider.overrideWith((ref) => initialApiKey),
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
    final seedColor = ref.watch(appThemeColorProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'StashFlow',
      themeMode: themeMode,
      theme: AppTheme.buildTheme(Brightness.light, seedColor),
      darkTheme: AppTheme.buildTheme(Brightness.dark, seedColor),
    );
  }
}
