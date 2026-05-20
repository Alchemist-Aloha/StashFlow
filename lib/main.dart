import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/navigation/presentation/router.dart';
import 'core/data/preferences/secure_storage_provider.dart';
import 'core/data/preferences/shared_preferences_provider.dart';
import 'core/utils/app_log_store.dart';
import 'core/utils/pip_mode.dart';
import 'core/utils/media_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/presentation/theme/app_theme.dart';
import 'core/presentation/theme/theme_mode_provider.dart';
import 'core/presentation/theme/theme_color_provider.dart';
import 'core/presentation/theme/true_black_provider.dart';
import 'core/presentation/providers/layout_settings_provider.dart';

import 'core/utils/environment.dart' as env;

final bool isTestMode = env.isTestMode;

StashMediaHandler? mediaHandler;

StashMediaHandler _buildMediaHandler() => StashMediaHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();
  }

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
          androidStopForegroundOnPause: false,
        ),
      );
    } catch (e) {
      debugPrint('Failed to initialize AudioService: $e');
      // Fallback or handle gracefully
    }
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  const secureStorage = FlutterSecureStorage();

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
    final useTrueBlack = ref.watch(trueBlackEnabledProvider);
    final appLocale = ref.watch(appLanguageProvider);

    final cardTitleFontSize = ref.watch(cardTitleFontSizeProvider);
    final performerAvatarSize = ref.watch(performerAvatarSizeProvider);
    final fontSizeFactor = ref.watch(appGlobalScaleProvider);

    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
