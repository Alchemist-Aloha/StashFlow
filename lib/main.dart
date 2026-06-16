import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'core/data/cache/app_cache_service.dart';
import 'features/navigation/presentation/router.dart';
import 'core/data/preferences/secure_storage_provider.dart';
import 'core/data/preferences/shared_preferences_provider.dart';
import 'core/utils/app_log_store.dart';
import 'core/utils/pip_mode.dart';
import 'core/utils/media_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'core/presentation/theme/app_theme.dart';
import 'core/presentation/theme/theme_mode_provider.dart';
import 'core/presentation/theme/theme_color_provider.dart';
import 'core/presentation/theme/true_black_provider.dart';
import 'core/presentation/providers/layout_settings_provider.dart';
import 'core/presentation/widgets/app_lock_gate.dart';

import 'core/utils/environment.dart' as env;

final bool isTestMode = env.isTestMode;

StashMediaHandler? mediaHandler;

StashMediaHandler _buildMediaHandler() => StashMediaHandler();

Future<void> main() async {
  final startupStopwatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await windowManager.ensureInitialized();
      try {
        final primaryDisplay = await screenRetriever.getPrimaryDisplay();
        final visibleSize = primaryDisplay.visibleSize ?? primaryDisplay.size;
        final visiblePosition = primaryDisplay.visiblePosition ?? Offset.zero;

        await windowManager.setMinimumSize(const Size(800, 600));
        await windowManager.setSize(visibleSize);
        await windowManager.setPosition(visiblePosition);
      } catch (e) {
        debugPrint('Failed to set initial window size: $e');
      }
    }

    // Increase Flutter's in-memory image cache so more decoded thumbnails stay
    // resident during aggressive prefetching and fast scrolling.
    // Tune these values based on available memory and observed behavior.
    try {
      PaintingBinding.instance.imageCache.maximumSize = 500;
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          200 * 1024 * 1024; // 200 MB
    } catch (_) {
      // Ignore if PaintingBinding isn't available in some test environments.
    }
    // Initialize Hive for the GraphQL cache in a OS-managed cache directory
    // instead of the persistent app documents directory. This prevents the
    // GraphQL cache (which can contain large base64-encoded images from
    // scraping operations) from consuming GB-level persistent storage.
    // Android clears this directory automatically when storage is low.
    if (!kIsWeb) {
      final cacheDir = await getTemporaryDirectory();
      final hivePath = p.join(cacheDir.path, 'stash_graphql_cache');
      HiveStore.init(onPath: hivePath);
    }
    await HiveStore.open();
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
            androidStopForegroundOnPause: false,
          ),
        );
      } catch (e) {
        debugPrint('Failed to initialize AudioService: $e');
        // Fallback or handle gracefully
      }
    }

    final sharedPreferences = await SharedPreferences.getInstance();

    AppLogStore.instance.isEnabled =
        sharedPreferences.getBool('enable_debug_logging') ?? false;

    final secureStorage = AppSecureStorage(
      sharedPreferences: sharedPreferences,
    );

    // Migrate API key from SharedPreferences to Secure Storage if needed.
    if (sharedPreferences.containsKey('server_api_key')) {
      final oldApiKey = sharedPreferences.getString('server_api_key');
      if (oldApiKey != null && oldApiKey.isNotEmpty) {
        await secureStorage.write(key: 'server_api_key', value: oldApiKey);
      }
      await sharedPreferences.remove('server_api_key');
    }

    final oldDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (AppLogStore.instance.isEnabled) {
        if (message != null) {
          AppLogStore.instance.add(message, source: 'debugPrint');
        }
        oldDebugPrint(message, wrapWidth: wrapWidth);
      }
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

    unawaited(_enforceStartupCacheLimits(sharedPreferences));

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          secureStorageProvider.overrideWithValue(secureStorage),
        ],
        child: const MyApp(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startupStopwatch.stop();
      debugPrint(
        'Startup: first frame rendered in ${startupStopwatch.elapsedMilliseconds}ms',
      );
    });
  } catch (error, stackTrace) {
    AppLogStore.instance.add('$error\n$stackTrace', source: 'startup_error');
    runApp(StartupErrorApp(error: error, stackTrace: stackTrace));
  }
}

Future<void> _enforceStartupCacheLimits(SharedPreferences prefs) async {
  final imageLimitMb = prefs.getInt('max_image_cache_size_mb') ?? 500;
  final videoLimitMb = prefs.getInt('max_video_cache_size_mb') ?? 1024;

  debugPrint(
    'Startup: enforcing cache limits image=${imageLimitMb}MB '
    'video=${videoLimitMb}MB',
  );

  try {
    final service = AppCacheService();
    await service.enforceImageCacheLimit(imageLimitMb);
    await service.enforceVideoCacheLimit(videoLimitMb);
    debugPrint('Startup: cache limit enforcement completed');
  } catch (error, stackTrace) {
    debugPrint('Startup: cache limit enforcement failed: $error');
    AppLogStore.instance.add(
      '$error\n$stackTrace',
      source: 'cache_limit_enforcement',
    );
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.main_startup_failed,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(context.l10n.main_startup_failed_desc),
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText('$error\n\n$stackTrace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final seedColor = ref.watch(appThemeColorProvider);
    final useTrueBlack = ref.watch(trueBlackEnabledProvider);
    final appLocale = ref.watch(appLanguageProvider);

    final cardTitleFontSize = ref.watch(cardTitleFontSizeProvider);
    final performerAvatarSize = ref.watch(performerAvatarSizeProvider);
    final fontSizeFactor = ref.watch(appGlobalScaleProvider);

    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return AppLockGate(child: child);
      },
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      locale: appLocale,
      themeMode: themeMode,
      theme: AppTheme.buildTheme(
        Brightness.light,
        seedColor,
        cardTitleFontSize: cardTitleFontSize,
        performerAvatarSize: performerAvatarSize,
        fontSizeFactor: fontSizeFactor,
      ),
      darkTheme: AppTheme.buildTheme(
        Brightness.dark,
        seedColor,
        useTrueBlack: useTrueBlack,
        cardTitleFontSize: cardTitleFontSize,
        performerAvatarSize: performerAvatarSize,
        fontSizeFactor: fontSizeFactor,
      ),
    );
  }
}
