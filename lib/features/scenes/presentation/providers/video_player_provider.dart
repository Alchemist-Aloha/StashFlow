import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';

part 'video_player_provider.g.dart';

@riverpod
class PlayerState extends _$PlayerState {
  @override
  Scene? build() => null;

  void playScene(Scene scene) {
    state = scene;
  }

  void stop() {
    state = null;
  }
}
