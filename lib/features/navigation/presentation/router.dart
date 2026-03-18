import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../scenes/presentation/pages/scenes_page.dart';
import '../../scenes/presentation/pages/scene_details_page.dart';
import '../../setup/presentation/settings_page.dart';
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
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/scene/:id',
            builder: (context, state) =>
                SceneDetailsPage(sceneId: state.pathParameters['id']!),
          ),
          // Explore, Subscriptions, Library routes will be added later
        ],
      ),
    ],
  );
}
