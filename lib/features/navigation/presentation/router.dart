import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../scenes/presentation/pages/scenes_page.dart';
import 'shell_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
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
          // Explore, Subscriptions, Library routes will be added later
        ],
      ),
    ],
  );
}
