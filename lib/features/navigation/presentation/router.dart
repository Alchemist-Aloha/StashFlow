import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/graphql/graphql_client.dart';
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
import '../../images/presentation/pages/images_page.dart';
import '../../images/presentation/pages/image_fullscreen_page.dart';
import '../../galleries/presentation/pages/galleries_page.dart';
import '../../images/presentation/providers/image_list_provider.dart';
import '../../setup/presentation/pages/settings/settings_hub_page.dart';
import '../../setup/presentation/pages/settings/server_settings_page.dart';
import '../../setup/presentation/pages/settings/playback_settings_page.dart';
import '../../setup/presentation/pages/settings/appearance_settings_page.dart';
import '../../setup/presentation/pages/settings/interface_settings_page.dart';
import '../../setup/presentation/pages/settings/support_settings_page.dart';
import '../../setup/presentation/debug_log_viewer_page.dart';
import '../../scenes/presentation/widgets/scene_video_player.dart';
import 'shell_page.dart';

part 'router.g.dart';

/// Central application router defined using GoRouter and Riverpod.
///
/// This provider creates a [GoRouter] instance that handles:
/// 1. Tab-based navigation via [StatefulShellRoute].
/// 2. Deep linking to scenes, performers, studios, and tags.
/// 3. Redirection to the settings page if the Stash server is not configured.
/// 4. Immersive fullscreen transitions for the video player.
@riverpod
GoRouter router(Ref ref) {
  // Use listen to react to configuration changes without rebuilding the router itself.
  // This prevents the app from resetting to the initial location when settings change.
  ref.listen(serverUrlProvider, (previous, next) {
    if ((previous == null || previous.isEmpty) && next.isNotEmpty) {
      // If we just became configured, we might want to notify or refresh.
    }
  });

  return GoRouter(
    initialLocation: '/scenes',
    redirect: (context, state) {
      // Re-read inside redirect to get latest values during navigation
      final currentUrl = ref.read(serverUrlProvider);

      final isConfigured = currentUrl.isNotEmpty;
      final isSettingsPath =
          state.uri.path == '/settings' ||
          state.uri.path.startsWith('/settings/');

      // Force redirection to settings if the server URL is missing
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
                        pageBuilder: (context, state) => CustomTransitionPage(
                          key: state.pageKey,
                          child: FullscreenPlayerPage(
                            sceneId: state.pathParameters['id']!,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                          transitionDuration: const Duration(milliseconds: 200),
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
                path: '/media',
                redirect: (context, state) {
                  if (state.uri.path == '/media') {
                    final viewType = ref.read(mediaViewToggleProvider);
                    return viewType == MediaViewType.images
                        ? '/media/images'
                        : '/media/galleries';
                  }
                  return null;
                },
                routes: [
                  GoRoute(
                    path: 'images',
                    builder: (context, state) => const ImagesPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => ImageFullscreenPage(
                          imageId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'galleries',
                    builder: (context, state) => const GalleriesPage(),
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsHubPage(),
        routes: [
          GoRoute(
            path: 'server',
            builder: (context, state) => const ServerSettingsPage(),
          ),
          GoRoute(
            path: 'playback',
            builder: (context, state) => const PlaybackSettingsPage(),
          ),
          GoRoute(
            path: 'appearance',
            builder: (context, state) => const AppearanceSettingsPage(),
          ),
          GoRoute(
            path: 'interface',
            builder: (context, state) => const InterfaceSettingsPage(),
          ),
          GoRoute(
            path: 'support',
            builder: (context, state) => const SupportSettingsPage(),
          ),
          GoRoute(
            path: 'logs',
            builder: (context, state) => const DebugLogViewerPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/image/:id',
        builder: (context, state) => ImageFullscreenPage(
          imageId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
