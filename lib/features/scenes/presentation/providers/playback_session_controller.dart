import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlaybackSession {
  final Player player;
  final VideoController controller;

  const PlaybackSession({required this.player, required this.controller});
}

class PlaybackSessionController {
  PlaybackSessionController({
    Player Function()? createPlayer,
    VideoController Function(Player)? createVideoController,
  }) : _createPlayer = createPlayer ?? Player.new,
       _createVideoController = createVideoController ?? VideoController.new;

  final Player Function() _createPlayer;
  final VideoController Function(Player) _createVideoController;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Player? _playerRef;
  VideoController? _videoControllerRef;
  bool _isUsingBorrowedController = false;

  Player? get player => _playerRef;
  VideoController? get controller => _videoControllerRef;

  PlaybackSession createOwnedSession() {
    final player = _createPlayer();
    final controller = _createVideoController(player);
    _playerRef = player;
    _videoControllerRef = controller;
    _isUsingBorrowedController = false;
    return PlaybackSession(player: player, controller: controller);
  }

  void adoptBorrowedSession(Player player, VideoController controller) {
    _playerRef = player;
    _videoControllerRef = controller;
    _isUsingBorrowedController = true;
  }

  Future<void> bindPlayerStreams(
    Player player, {
    required void Function() onTick,
    required void Function() onCompleted,
    required void Function(Object error) onError,
  }) async {
    await _cancelSubscriptions();

    _subscriptions.add(player.stream.playing.listen((_) => onTick()));
    _subscriptions.add(player.stream.position.listen((_) => onTick()));
    _subscriptions.add(player.stream.duration.listen((_) => onTick()));
    _subscriptions.add(
      player.stream.completed.listen((completed) {
        if (completed) {
          onCompleted();
        }
      }),
    );
    _subscriptions.add(player.stream.buffering.listen((_) => onTick()));
    _subscriptions.add(player.stream.width.listen((_) => onTick()));
    _subscriptions.add(player.stream.height.listen((_) => onTick()));
    _subscriptions.add(
      player.stream.error.listen((error) {
        onError(error);
      }),
    );
  }

  Future<void> disposeSession({
    required bool isTestMode,
    Player? fallbackPlayer,
    required void Function(String message) log,
  }) async {
    await _cancelSubscriptions();

    final prevPlayer = _playerRef ?? fallbackPlayer;
    _playerRef = null;
    _videoControllerRef = null;

    if (isTestMode) {
      _isUsingBorrowedController = false;
      return;
    }

    if (prevPlayer != null) {
      if (_isUsingBorrowedController) {
        log('provider skipping dispose of borrowed controller');
        _isUsingBorrowedController = false;
      } else {
        await prevPlayer.dispose();
      }
    }
  }

  Future<void> _cancelSubscriptions() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }
}
