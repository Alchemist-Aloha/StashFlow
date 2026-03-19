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
import '../../galleries/presentation/pages/galleries_page.dart';
import '../../galleries/presentation/pages/gallery_details_page.dart';
import '../../groups/presentation/pages/groups_page.dart';
import '../../groups/presentation/pages/group_details_page.dart';
import '../../setup/presentation/settings_page.dart';
import '../../setup/presentation/debug_log_viewer_page.dart';
import 'shell_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/scenes',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/scenes',
            builder: (context, state) => const ScenesPage(),
          ),
          GoRoute(
            path: '/performers',
            builder: (context, state) => const PerformersPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/logs',
            builder: (context, state) => const DebugLogViewerPage(),
          ),
          GoRoute(
            path: '/studios',
            builder: (context, state) => const StudiosPage(),
          ),
          GoRoute(path: '/tags', builder: (context, state) => const TagsPage()),
          GoRoute(
            path: '/galleries',
            builder: (context, state) => const GalleriesPage(),
          ),
          GoRoute(
            path: '/groups',
            builder: (context, state) => const GroupsPage(),
          ),
          GoRoute(
            path: '/scene/:id',
            builder: (context, state) =>
                SceneDetailsPage(sceneId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/performer/:id',
            builder: (context, state) =>
                PerformerDetailsPage(performerId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/performer/:id/media',
            builder: (context, state) => PerformerMediaGridPage(
              performerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/studio/:id',
            builder: (context, state) =>
                StudioDetailsPage(studioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/studio/:id/media',
            builder: (context, state) =>
                StudioMediaGridPage(studioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/tag/:id',
            builder: (context, state) =>
                TagDetailsPage(tagId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/tag/:id/media',
            builder: (context, state) =>
                TagMediaGridPage(tagId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/gallery/:id',
            builder: (context, state) =>
                GalleryDetailsPage(galleryId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/group/:id',
            builder: (context, state) =>
                GroupDetailsPage(groupId: state.pathParameters['id']!),
          ),
          // Explore, Subscriptions, Library routes will be added later
        ],
      ),
    ],
  );
}
