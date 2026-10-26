import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../setup/presentation/providers/server_profiles_provider.dart';

part 'scene_playback_position_provider.g.dart';

/// Last observed playback position in seconds, scoped to the current server.
///
/// Only played scenes are retained across routes. Cards can observe this without
/// starting a player or fetching scene details; server resume data is the fallback.
@riverpod
class ScenePlaybackPosition extends _$ScenePlaybackPosition {
  @override
  double? build(String sceneId) {
    ref.watch(activeProfileProvider);
    return null;
  }

  /// Publishes local or cast ticks, including backward seeks and restart at zero.
  void update(Duration position) {
    if (position < Duration.zero) return;
    if (state == null) ref.keepAlive();
    state = position.inMilliseconds / 1000.0;
  }
}
