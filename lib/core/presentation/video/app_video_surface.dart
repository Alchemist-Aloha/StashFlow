import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'app_video_controller.dart';

class AppVideoSurface extends StatelessWidget {
  final AppVideoController controller;

  const AppVideoSurface({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    if (controller is MediaKitVideoControllerAdapter) {
      final raw = (controller as MediaKitVideoControllerAdapter).videoController;
      return Video(controller: raw);
    }

    return const SizedBox.shrink();
  }
}
