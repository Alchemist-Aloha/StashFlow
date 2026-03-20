import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
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
import 'shell_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/scenes',
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
