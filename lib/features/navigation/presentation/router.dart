import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/graphql/graphql_client.dart';
import '../../../core/data/preferences/shared_preferences_provider.dart';
import '../../scenes/presentation/pages/scenes_page.dart';
import '../../scenes/presentation/pages/scene_details_page.dart';
import '../../performers/presentation/pages/performers_page.dart';
import '../../performers/presentation/pages/performer_details_page.dart';
import '../../performers/presentation/pages/performer_media_grid_page.dart';
import '../../studios/presentation/pages/studios_page.dart';
import '../../studios/presentation/pages/studio_details_page.dart';
import '../../studios/presentation/pages/studio_media_grid_page.dart';
import '../../tags/presentation/pages/tags_page.dart';
import '../../tags/presentation/pages/tag_details_page.dart';
import '../../tags/presentation/pages/tag_media_grid_page.dart';
import '../../setup/presentation/settings_page.dart';
import '../../setup/presentation/debug_log_viewer_page.dart';
import '../../scenes/presentation/widgets/scene_video_player.dart';
import 'shell_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/scenes',
    redirect: (context, state) {
      final prefs = ref.read(sharedPreferencesProvider);
      final serverUrl = normalizeGraphqlServerUrl(
        prefs.getString('server_base_url')?.trim() ?? '',
      );
      final apiKey = prefs.getString('server_api_key')?.trim() ?? '';

      final isConfigured = serverUrl.isNotEmpty && apiKey.isNotEmpty;
      final isSettingsPath =
          state.uri.path == '/settings' ||
          state.uri.path.startsWith('/settings/');

      if (!isConfigured && !isSettingsPath) {
        return '/settings';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scenes',
                builder: (context, state) => const ScenesPage(),
                routes: [
                  GoRoute(
                    path: 'scene/:id',
                    builder: (context, state) =>
                        SceneDetailsPage(sceneId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'fullscreen',
                        builder: (context, state) => FullscreenPlayerPage(
                          sceneId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'fullscreen/:id',
                    builder: (context, state) => FullscreenPlayerPage(
                      sceneId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/performers',
                builder: (context, state) => const PerformersPage(),
                routes: [
                  GoRoute(
                    path: 'performer/:id',
                    builder: (context, state) => PerformerDetailsPage(
                      performerId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'media',
                        builder: (context, state) => PerformerMediaGridPage(
                          performerId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/studios',
                builder: (context, state) => const StudiosPage(),
                routes: [
                  GoRoute(
                    path: 'studio/:id',
                    builder: (context, state) => StudioDetailsPage(
                      studioId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'media',
                        builder: (context, state) => StudioMediaGridPage(
                          studioId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tags',
                builder: (context, state) => const TagsPage(),
                routes: [
                  GoRoute(
                    path: 'tag/:id',
                    builder: (context, state) =>
                        TagDetailsPage(tagId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'media',
                        builder: (context, state) => TagMediaGridPage(
                          tagId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'logs',
                    builder: (context, state) => const DebugLogViewerPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Backward-compatible aliases for legacy absolute detail paths.
      GoRoute(
        path: '/scene/:id',
        builder: (context, state) =>
            SceneDetailsPage(sceneId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/performer/:id',
        builder: (context, state) =>
            PerformerDetailsPage(performerId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'media',
            builder: (context, state) => PerformerMediaGridPage(
              performerId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/studio/:id',
        builder: (context, state) =>
            StudioDetailsPage(studioId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'media',
            builder: (context, state) =>
                StudioMediaGridPage(studioId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/tag/:id',
        builder: (context, state) =>
            TagDetailsPage(tagId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'media',
            builder: (context, state) =>
                TagMediaGridPage(tagId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}
