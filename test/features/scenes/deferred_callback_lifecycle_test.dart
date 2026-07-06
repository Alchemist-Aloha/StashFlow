import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scene deferred callbacks', () {
    test('guard post-frame provider and context work after dispose', () {
      final fullscreenOverlay = File(
        'lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart',
      ).readAsStringSync();
      final sceneVideoPlayer = File(
        'lib/features/scenes/presentation/widgets/scene_video_player.dart',
      ).readAsStringSync();
      final tiktokScenesView = File(
        'lib/features/scenes/presentation/widgets/tiktok_scenes_view.dart',
      ).readAsStringSync();
      final castSelectionSheet = File(
        'lib/features/scenes/presentation/widgets/video_controls/cast_selection_sheet.dart',
      ).readAsStringSync();

      expect(
        fullscreenOverlay,
        contains(
          'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
          '      if (!mounted) return;\n'
          '      final phase = ref.read(',
        ),
      );
      expect(
        fullscreenOverlay,
        contains(
          'void _onFullScreenChanged(bool isFullScreen) {\n'
          '    if (!mounted) return;',
        ),
      );
      expect(
        sceneVideoPlayer,
        contains(
          'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
          '      if (!mounted) return;\n'
          '      _startPlaybackIfNeeded',
        ),
      );
      expect(
        sceneVideoPlayer,
        contains(
          'Future<void> _startPlaybackIfNeeded({bool force = false}) async {\n'
          '    if (!mounted) return;',
        ),
      );
      expect(
        tiktokScenesView,
        contains(
          'Future<void> _manageControllers() async {\n'
          '    if (!mounted) return;\n'
          '\n'
          '    final scenesAsync = ref.read(sceneListProvider);',
        ),
      );
      expect(
        tiktokScenesView,
        contains(
          'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
          '            if (!mounted) return;\n'
          '            _manageControllers();',
        ),
      );
      expect(
        castSelectionSheet,
        contains(
          'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
          '      if (!mounted) return;\n'
          '      logCastProcess(',
        ),
      );
    });
  });
}
