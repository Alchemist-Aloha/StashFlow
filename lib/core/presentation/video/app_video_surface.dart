import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;
import 'app_video_controller.dart';

class AppVideoSurface extends StatelessWidget {
  final AppVideoController controller;

  const AppVideoSurface({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    if (controller is VideoPlayerControllerAdapter) {
      final raw = (controller as VideoPlayerControllerAdapter).rawController;
      return vp.VideoPlayer(raw);
    }

    return const SizedBox.shrink();
  }
}
