import 'dart:async';
import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'video_controls/video_progress_bar.dart';
import 'video_controls/video_playback_controls.dart';
import 'video_controls/player_gesture_feedback.dart';
import '../../../../core/presentation/providers/desktop_capabilities_provider.dart';
import '../../../../core/presentation/providers/desktop_settings_provider.dart';
import '../../../../core/presentation/providers/keybinds_provider.dart';
import '../../../../core/utils/pip_mode.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/video_player_provider.dart';
import '../providers/playback_queue_provider.dart';
import 'scrubbing_preview.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/services/cast_service.dart';
import 'package:media_kit_video/media_kit_video.dart';

class NativeVideoControls extends ConsumerStatefulWidget {
  const NativeVideoControls({
    required this.controller,
    required this.useDoubleTapSeek,
    required this.enableNativePip,
    this.onFullScreenToggle,
    required this.scene,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onTransformationDelta,
    super.key,
  });

  final VideoController controller;
  final bool useDoubleTapSeek;
  final bool enableNativePip;
  final VoidCallback? onFullScreenToggle;
  final Scene scene;
  final GestureScaleStartCallback? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;
  final void Function(Matrix4 delta, Offset focalPoint)? onTransformationDelta;

  @override
  ConsumerState<NativeVideoControls> createState() =>
      _NativeVideoControlsState();
}

enum _DragMode { none, determining, horizontal, vertical }

class _NativeVideoControlsState extends ConsumerState<NativeVideoControls>
    with WidgetsBindingObserver {
  static const _controlsAutoHideDelay = Duration(milliseconds: 1000);
  static const _gestureSeekSeconds = 10;
  static const _dragSeekSensitivity = 0.30;
  static const _dragSeekCurveExponent = 1.6;

  final List<StreamSubscription> _subscriptions = [];

  bool _isScrubbing = false;
  double _scrubMs = 0;
  bool _controlsVisible = true;
  bool _wasPlaying = false;
  bool _wasPlayingBeforeScrub = false;
  bool _showVolumeSlider = false;
  bool _showSpeedSlider = false;
  Timer? _hideControlsTimer;
  Duration? _dragSeekStartPosition;
  Duration? _dragSeekTarget;
  double _dragSeekAccumulatedDx = 0;
  bool _dragSeekShouldResumePlayback = false;
  int? _seekFeedbackSeconds;
  Timer? _seekFeedbackTimer;
  ProviderSubscription<DesktopSettings>? _desktopSettingsSubscription;

  // Advanced gestures state
  double _originalSpeed = 1.0;
  double _currentSpeed = 1.0;
  IconData? _feedbackIcon;
  String _feedbackLabel = '';
  bool _feedbackVisible = false;
  Timer? _feedbackTimer;

  _DragMode _currentDragMode = _DragMode.none;
  double _dragStartValue = 0.0;
  bool _dragIsLeft = false;

  @override
  void initState() {
    super.initState();
    AppLogStore.instance.add(
      'NativeVideoControls init scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
    WidgetsBinding.instance.addObserver(this);

    _subscriptions.add(
      widget.controller.player.stream.playing.listen((_) => _onVideoTick()),
    );
    _subscriptions.add(
      widget.controller.player.stream.position.listen((_) => _onVideoTick()),
    );
    _subscriptions.add(
      widget.controller.player.stream.duration.listen((_) => _onVideoTick()),
    );

    _wasPlaying = widget.controller.player.state.playing;
    if (_wasPlaying) {
      _scheduleAutoHide();
    }

    if (ref.read(desktopCapabilitiesProvider)) {
      _desktopSettingsSubscription = ref.listenManual<DesktopSettings>(
        desktopSettingsProvider,
        (previous, next) {
          if (previous?.volume != next.volume ||
              previous?.isMuted != next.isMuted) {
            _showVolumeOverlay();
          }
        },
      );
    }
  }

  @override
  void didUpdateWidget(covariant NativeVideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      AppLogStore.instance.add(
        'NativeVideoControls didUpdateWidget controllerChange scene=${widget.scene.id}',
        source: 'NativeVideoControls',
      );
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
      _subscriptions.add(
        widget.controller.player.stream.playing.listen((_) => _onVideoTick()),
      );
      _subscriptions.add(
        widget.controller.player.stream.position.listen((_) => _onVideoTick()),
      );
      _subscriptions.add(
        widget.controller.player.stream.duration.listen((_) => _onVideoTick()),
      );
    }
  }

  @override
  void dispose() {
    AppLogStore.instance.add(
      'NativeVideoControls dispose scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
    WidgetsBinding.instance.removeObserver(this);
    _cancelAutoHide();
    _seekFeedbackTimer?.cancel();
    _desktopSettingsSubscription?.close();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableNativePip || kIsWeb || !Platform.isAndroid) return;
    if (state != AppLifecycleState.paused) return;

    final controller = widget.controller;
    if (!controller.player.state.playing) return;

    final isFullScreen = ref.read(playerStateProvider).isFullScreen;
    if (!isFullScreen) return;

    final width = controller.player.state.width;
    final height = controller.player.state.height;
    final aspect = (width != null && height != null && height > 0)
        ? width / height
        : 16 / 9;
    unawaited(PipMode.enterIfAvailable(aspectRatio: aspect));
  }

  void _onVideoTick() {
    if (!mounted) return;

    final isActive =
        ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    final isPlaying = widget.controller.player.state.playing;
    final playingChanged = isPlaying != _wasPlaying;

    if (playingChanged) {
      _wasPlaying = isPlaying;
      if (isPlaying) {
        _scheduleAutoHide();
      } else {
        _cancelAutoHide();
        setState(() => _controlsVisible = true);
        return;
      }
    }

    // Performance Optimization: If controls are hidden and we aren't scrubbing,
    // there's no need to trigger a rebuild for position updates.
    if (!_controlsVisible && !_isScrubbing && !playingChanged) return;

    // Further optimization: Even if visible, only rebuild if we are scrubbing
    // or if enough time has passed (throttling UI updates to ~10fps is plenty for labels).
    setState(() {});
  }

  void _cancelAutoHide() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  void _scheduleAutoHide() {
    _cancelAutoHide();
    final isPlaying = widget.controller.player.state.playing;
    if (!isPlaying || _isScrubbing) return;

    _hideControlsTimer = Timer(_controlsAutoHideDelay, () {
      if (!mounted) return;
      final stillPlaying = widget.controller.player.state.playing;
      if (!stillPlaying || _isScrubbing || !_controlsVisible) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _scheduleAutoHide();
    } else {
      _cancelAutoHide();
    }
  }

  void _showControlsTemporarily() {
    if (!mounted) return;
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleAutoHide();
  }

  void _seekRelativeSeconds(int seconds) {
    if (widget.controller.player.state.width == null) return;
    final current = widget.controller.player.state.position;
    final duration = widget.controller.player.state.duration;
    final wasPlaying = widget.controller.player.state.playing;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    unawaited(_seekToKeepingPlayback(target, keepPlayingAfterSeek: wasPlaying));
    _showSeekFeedback(seconds, transient: true);
  }

  Future<void> _seekToKeepingPlayback(
    Duration target, {
    required bool keepPlayingAfterSeek,
  }) async {
    final castState = ref.read(castServiceProvider);
    if (castState.isCasting) {
      await ref.read(castServiceProvider.notifier).seek(target);
    }

    await widget.controller.player.seek(target);
    if (!mounted || !keepPlayingAfterSeek) return;
    if (!widget.controller.player.state.playing) {
      await _play();
    }
  }

  Future<void> _stopCast() async {
    final castState = ref.read(castServiceProvider);
    if (!castState.isCasting) return;

    final messenger = ScaffoldMessenger.of(context);

    // TODO: Get real remote position if supported by protocol
    // For now we rely on the local player being in sync
    final currentPos = widget.controller.player.state.position;

    await ref.read(castServiceProvider.notifier).stopCasting();

    if (mounted) {
      final message = context.l10n.cast_stopped_resuming_locally;
      // Ensure local player is at the same position and playing
      await widget.controller.player.seek(currentPos);
      await widget.controller.player.play();

      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showSeekFeedback(int seconds, {bool transient = false}) {
    if (!mounted) return;
    _seekFeedbackTimer?.cancel();

    if (_seekFeedbackSeconds != seconds) {
      setState(() => _seekFeedbackSeconds = seconds);
    } else if (_seekFeedbackSeconds == null) {
      setState(() => _seekFeedbackSeconds = seconds);
    }

    if (transient) {
      _seekFeedbackTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _seekFeedbackSeconds = null);
      });
    }
  }

  void _beginDragSeek() {
    final isActive =
        ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    if (widget.controller.player.state.width == null) return;
    _dragSeekStartPosition = widget.controller.player.state.position;
    _dragSeekTarget = null;
    _dragSeekAccumulatedDx = 0;
    _dragSeekShouldResumePlayback = widget.controller.player.state.playing;
    _seekFeedbackTimer?.cancel();

    AppLogStore.instance.add(
      'NativeVideoControls beginDragSeek scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
  }

  void _updateDragSeek(ScaleUpdateDetails details, double dragAreaWidth) {
    final isActive =
        ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    final startPosition = _dragSeekStartPosition;
    if (widget.controller.player.state.width == null || startPosition == null) {
      return;
    }
    if (dragAreaWidth <= 0) return;

    final duration = widget.controller.player.state.duration;
    if (duration <= Duration.zero) return;

    _dragSeekAccumulatedDx += details.focalPointDelta.dx;
    final linearDragRatio = _dragSeekAccumulatedDx / dragAreaWidth;
    final curvedMagnitude = math
        .pow(linearDragRatio.abs(), _dragSeekCurveExponent)
        .toDouble();
    final curvedDragRatio = linearDragRatio.isNegative
        ? -curvedMagnitude
        : curvedMagnitude;

    final deltaMs =
        curvedDragRatio * duration.inMilliseconds * _dragSeekSensitivity;
    final unclampedTargetMs = startPosition.inMilliseconds + deltaMs;
    final targetMs = unclampedTargetMs.clamp(
      0,
      duration.inMilliseconds.toDouble(),
    );

    _dragSeekTarget = Duration(milliseconds: targetMs.round());

    final signedDeltaSeconds =
        ((_dragSeekTarget!.inMilliseconds - startPosition.inMilliseconds) /
                1000)
            .round();
    _showSeekFeedback(signedDeltaSeconds);
    setState(() {});
  }

  void _endDragSeek() {
    if (_dragSeekTarget != null) {
      unawaited(
        _seekToKeepingPlayback(
          _dragSeekTarget!,
          keepPlayingAfterSeek: _dragSeekShouldResumePlayback,
        ),
      );
    } else if (_dragSeekShouldResumePlayback &&
        !widget.controller.player.state.playing) {
      unawaited(_play());
    }

    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _seekFeedbackSeconds = null);
    });

    _dragSeekStartPosition = null;
    _dragSeekTarget = null;
    _dragSeekAccumulatedDx = 0;
    _dragSeekShouldResumePlayback = false;
  }

  Future<void> _play() async {
    final castState = ref.read(castServiceProvider);
    await widget.controller.player.play();
    if (castState.isCasting) {
      await ref.read(castServiceProvider.notifier).play();
    }
  }

  Future<void> _pause() async {
    final castState = ref.read(castServiceProvider);
    await widget.controller.player.pause();
    if (castState.isCasting) {
      await ref.read(castServiceProvider.notifier).pause();
    }
  }

  void _togglePlay() {
    if (widget.controller.player.state.playing) {
      _pause();
    } else {
      _play();
    }
    _showControlsTemporarily();
  }

  ButtonStyle _controlButtonStyle(ColorScheme colorScheme) {
    return IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      disabledBackgroundColor: Colors.transparent,
      disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(
        alpha: 0.55,
      ),
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(38, 38),
    );
  }

  Widget _buildSeekFeedbackOverlay(ColorScheme colorScheme) {
    final seconds = _seekFeedbackSeconds;
    final isVisible = seconds != null;
    final effectiveSeconds = seconds ?? 0;
    final isForward = effectiveSeconds > 0;
    final isBackward = effectiveSeconds < 0;

    final icon = isForward
        ? Icons.fast_forward_rounded
        : isBackward
        ? Icons.fast_rewind_rounded
        : Icons.drag_indicator_rounded;
    final label = isForward
        ? '+${effectiveSeconds}s'
        : isBackward
        ? '${effectiveSeconds}s'
        : '0s';

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: isVisible ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 250),
          curve: Curves.elasticOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(160),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: Colors.white.withAlpha(40), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                  shadows: const [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopVolumeControl(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final desktopSettings = ref.watch(desktopSettingsProvider);
    final isMuted = desktopSettings.isMuted;
    final volume = desktopSettings.volume;

    IconData iconData = Icons.volume_up_rounded;
    if (isMuted || volume == 0) {
      iconData = Icons.volume_off_rounded;
    } else if (volume < 0.5) {
      iconData = Icons.volume_down_rounded;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _showVolumeSlider = true),
      onExit: (_) => setState(() => _showVolumeSlider = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: isMuted ? 'Unmute' : 'Mute',
            style: _controlButtonStyle(colorScheme),
            iconSize: 20,
            icon: Icon(iconData),
            onPressed: () {
              ref.read(playerStateProvider.notifier).toggleMute();
              _showControlsTemporarily();
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _showVolumeSlider ? 100 : 0,
            curve: Curves.easeInOut,
            child: Visibility(
              visible: _showVolumeSlider,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.25,
                  ),
                  thumbColor: colorScheme.primary,
                ),
                child: Slider(
                  value: volume,
                  onChanged: (v) {
                    ref.read(playerStateProvider.notifier).setVolume(v);
                    _showControlsTemporarily();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVolumeOverlay() {
    if (!mounted) return;
    final desktopSettings = ref.read(desktopSettingsProvider);
    final volume = desktopSettings.volume;
    final isMuted = desktopSettings.isMuted;

    IconData iconData = Icons.volume_up_rounded;
    if (isMuted || volume == 0) {
      iconData = Icons.volume_off_rounded;
    } else if (volume < 0.5) {
      iconData = Icons.volume_down_rounded;
    }

    _showFeedback(
      iconData,
      isMuted ? context.l10n.common_mute : '${(volume * 100).round()}%',
    );
  }

  Widget _buildSpeedSliderPanel(ColorScheme colorScheme, double playbackSpeed) {
    if (!_showSpeedSlider) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.common_reset_to_1x,
            style: _controlButtonStyle(colorScheme),
            iconSize: 20,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              widget.controller.player.setRate(1.0);
              _showControlsTemporarily();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.25,
                ),
                thumbColor: colorScheme.primary,
              ),
              child: Slider(
                value: playbackSpeed.clamp(0.25, 3.0),
                min: 0.25,
                max: 3.0,
                divisions: 11,
                onChanged: (v) {
                  widget.controller.player.setRate(v);
                  _showControlsTemporarily();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: context.l10n.common_close,
            style: _controlButtonStyle(colorScheme),
            iconSize: 20,
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              setState(() => _showSpeedSlider = false);
              _showControlsTemporarily();
            },
          ),
        ],
      ),
    );
  }

  void _showFeedback(IconData icon, String label) {
    if (!mounted) return;
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackIcon = icon;
      _feedbackLabel = label;
      _feedbackVisible = true;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _feedbackVisible = false);
      }
    });
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final playerState = ref.watch(playerStateProvider);

    if (playerState.isInPipMode) {
      return const SizedBox.shrink();
    }

    final value = widget.controller.player.state;
    final duration = value.duration;
    final durationMs = math.max(1, duration.inMilliseconds);
    final playbackSpeed = value.rate;
    final isFullScreen = playerState.isFullScreen;
    final queueState = ref.watch(playbackQueueProvider);
    final nextScene =
        (queueState.currentIndex >= 0 &&
            queueState.currentIndex < queueState.sequence.length - 1)
        ? queueState.sequence[queueState.currentIndex + 1]
        : null;
    final previousScene =
        (queueState.currentIndex > 0 &&
            queueState.currentIndex < queueState.sequence.length)
        ? queueState.sequence[queueState.currentIndex - 1]
        : null;

    final isDesktop = ref.watch(desktopCapabilitiesProvider);
    final keybinds = ref.watch(keybindsProvider);

    Map<ShortcutActivator, VoidCallback> bindings = {};
    for (var entry in keybinds.binds.entries) {
      final action = entry.key;
      final bind = entry.value;

      VoidCallback? callback;
      switch (action) {
        case KeybindAction.playPause:
          callback = _togglePlay;
          break;
        case KeybindAction.seekForward:
          callback = () => _seekRelativeSeconds(5);
          break;
        case KeybindAction.seekBackward:
          callback = () => _seekRelativeSeconds(-5);
          break;
        case KeybindAction.seekForwardLarge:
          callback = () => _seekRelativeSeconds(10);
          break;
        case KeybindAction.seekBackwardLarge:
          callback = () => _seekRelativeSeconds(-10);
          break;
        case KeybindAction.volumeUp:
          callback = () {
            final currentVol = ref.read(desktopSettingsProvider).volume;
            ref.read(playerStateProvider.notifier).setVolume(currentVol + 0.05);
          };
          break;
        case KeybindAction.volumeDown:
          callback = () {
            final currentVol = ref.read(desktopSettingsProvider).volume;
            ref.read(playerStateProvider.notifier).setVolume(currentVol - 0.05);
          };
          break;
        case KeybindAction.toggleMute:
          callback = () => ref.read(playerStateProvider.notifier).toggleMute();
          break;
        case KeybindAction.toggleFullscreen:
          callback = () => widget.onFullScreenToggle?.call();
          break;
        case KeybindAction.togglePip:
          callback = () {
            if (widget.enableNativePip && !kIsWeb && Platform.isAndroid) {
              final w = widget.controller.player.state.width;
              final h = widget.controller.player.state.height;
              final r = (w != null && h != null && h > 0) ? w / h : 16 / 9;
              PipMode.enterIfAvailable(aspectRatio: r);
            }
          };
          break;
        case KeybindAction.nextScene:
          callback = () => ref.read(playerStateProvider.notifier).playNext();
          break;
        case KeybindAction.previousScene:
          callback = () => ref.read(playerStateProvider.notifier).playPrevious();
          break;
        case KeybindAction.speedUp:
          callback = () {
            final currentSpeed = widget.controller.player.state.rate;
            widget.controller.player.setRate(currentSpeed + 0.25);
          };
          break;
        case KeybindAction.speedDown:
          callback = () {
            final currentSpeed = widget.controller.player.state.rate;
            widget.controller.player.setRate(currentSpeed - 0.25);
          };
          break;
        case KeybindAction.resetSpeed:
          callback = () => widget.controller.player.setRate(1.0);
          break;
        case KeybindAction.closePlayer:
          callback = () => ref.read(playerStateProvider.notifier).stop();
          break;
        case KeybindAction.back:
          callback = () {
            ref.read(playerStateProvider.notifier).stop();
            if (context.canPop()) {
              context.pop();
            }
          };
          break;
        default:
          break;
      }

      if (callback != null) {
        bindings[bind.toActivator()] = callback;
      }
    }

    return PopScope(
      canPop: !_isScrubbing,
      child: CallbackShortcuts(
        bindings: bindings,
        child: Focus(
          autofocus: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Layer 0: Background Gesture Area (Handles toggle and seek)
                  Positioned.fill(
                    child: MouseRegion(
                      onHover: (_) => _showControlsTemporarily(),
                      onEnter: (_) => _showControlsTemporarily(),
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            final isCtrlPressed =
                                HardwareKeyboard.instance.isControlPressed;
                            final isAltPressed =
                                HardwareKeyboard.instance.isAltPressed;

                            if (isCtrlPressed) {
                              // Zoom logic: Scroll up (dy < 0) zooms in
                              final double scaleDelta =
                                  pointerSignal.scrollDelta.dy < 0 ? 1.1 : 0.9;
                              final matrix = Matrix4.identity()
                                ..translateByVector3(
                                  Vector3(
                                    pointerSignal.localPosition.dx,
                                    pointerSignal.localPosition.dy,
                                    0,
                                  ),
                                )
                                ..scaleByVector3(
                                  Vector3(scaleDelta, scaleDelta, 1.0),
                                )
                                ..translateByVector3(
                                  Vector3(
                                    -pointerSignal.localPosition.dx,
                                    -pointerSignal.localPosition.dy,
                                    0,
                                  ),
                                );
                              widget.onTransformationDelta?.call(
                                matrix,
                                pointerSignal.localPosition,
                              );
                              return;
                            }

                            if (isAltPressed) {
                              // Rotate logic: Scroll dy determines direction
                              final double rotationDelta =
                                  pointerSignal.scrollDelta.dy < 0 ? 0.1 : -0.1;
                              final matrix = Matrix4.identity()
                                ..translateByVector3(
                                  Vector3(
                                    pointerSignal.localPosition.dx,
                                    pointerSignal.localPosition.dy,
                                    0,
                                  ),
                                )
                                ..rotateZ(rotationDelta)
                                ..translateByVector3(
                                  Vector3(
                                    -pointerSignal.localPosition.dx,
                                    -pointerSignal.localPosition.dy,
                                    0,
                                  ),
                                );
                              widget.onTransformationDelta?.call(
                                matrix,
                                pointerSignal.localPosition,
                              );
                              return;
                            }

                            if (pointerSignal.scrollDelta.dy != 0) {
                              // Vertical scroll -> Volume
                              final currentVol = ref
                                  .read(desktopSettingsProvider)
                                  .volume;
                              if (pointerSignal.scrollDelta.dy < 0) {
                                ref
                                    .read(playerStateProvider.notifier)
                                    .setVolume(currentVol + 0.05);
                              } else {
                                ref
                                    .read(playerStateProvider.notifier)
                                    .setVolume(currentVol - 0.05);
                              }
                            } else if (pointerSignal.scrollDelta.dx != 0) {
                              // Horizontal scroll -> Seek
                              if (pointerSignal.scrollDelta.dx > 0) {
                                _seekRelativeSeconds(5);
                              } else {
                                _seekRelativeSeconds(-5);
                              }
                            }
                          }
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleControls,
                          onDoubleTapDown: widget.useDoubleTapSeek
                              ? (details) {
                                  if (details.localPosition.dx <
                                      constraints.maxWidth / 2) {
                                    _seekRelativeSeconds(-_gestureSeekSeconds);
                                  } else {
                                    _seekRelativeSeconds(_gestureSeekSeconds);
                                  }
                                }
                              : null,
                          onDoubleTap: isDesktop
                              ? () {
                                  widget.onFullScreenToggle?.call();
                                }
                              : null,
                          onLongPressStart: (_) {
                            _originalSpeed =
                                widget.controller.player.state.rate;
                            _currentSpeed = 2.0;
                            widget.controller.player.setRate(_currentSpeed);
                            _showFeedback(Icons.fast_forward, '2.0x');
                          },
                          onLongPressMoveUpdate: (details) {
                            final dy = details.localOffsetFromOrigin.dy;
                            if (dy < 0) {
                              // Increase speed from 2.0x up to 10.0x
                              final extraSpeed = (-dy / 20).clamp(0, 8);
                              final newSpeed = 2.0 + extraSpeed;
                              if (newSpeed != _currentSpeed) {
                                setState(() => _currentSpeed = newSpeed);
                                widget.controller.player.setRate(_currentSpeed);
                                _showFeedback(
                                  Icons.fast_forward,
                                  '${_currentSpeed.toStringAsFixed(1)}x',
                                );
                              }
                            }
                          },
                          onLongPressEnd: (_) {
                            widget.controller.player.setRate(_originalSpeed);
                            setState(() {
                              _feedbackVisible = false;
                            });
                          },
                          onScaleStart: (details) {
                            if (details.pointerCount == 1) {
                              _currentDragMode = _DragMode.determining;
                              _dragStartValue = 0.0;
                              _dragIsLeft = false;
                            } else if (details.pointerCount >= 2) {
                              widget.onScaleStart?.call(details);
                            }
                          },
                          onScaleUpdate: (details) {
                            if (details.pointerCount == 1) {
                              if (_currentDragMode == _DragMode.determining) {
                                // Determine primary drag axis
                                if (details.focalPointDelta.dy.abs() >
                                    details.focalPointDelta.dx.abs() * 1.5) {
                                  _currentDragMode = _DragMode.vertical;
                                  _dragIsLeft =
                                      details.focalPoint.dx <
                                      constraints.maxWidth / 2;
                                  if (_dragIsLeft) {
                                    ScreenBrightness().application.then((val) {
                                      if (mounted &&
                                          _currentDragMode ==
                                              _DragMode.vertical) {
                                        _dragStartValue = val;
                                      }
                                    });
                                  } else {
                                    _dragStartValue = ref
                                        .read(desktopSettingsProvider)
                                        .volume;
                                  }
                                } else if (details.focalPointDelta.dx.abs() >
                                    details.focalPointDelta.dy.abs() * 1.5) {
                                  _currentDragMode = _DragMode.horizontal;
                                  if (!widget.useDoubleTapSeek) {
                                    _beginDragSeek();
                                  }
                                }
                              }

                              if (_currentDragMode == _DragMode.vertical) {
                                final delta =
                                    -details.focalPointDelta.dy /
                                    constraints.maxHeight;
                                _dragStartValue = (_dragStartValue + delta)
                                    .clamp(0.0, 1.0);

                                if (_dragIsLeft) {
                                  // Brightness
                                  ScreenBrightness()
                                      .setApplicationScreenBrightness(
                                        _dragStartValue,
                                      );
                                  _showFeedback(
                                    Icons.brightness_6,
                                    '${(_dragStartValue * 100).round()}%',
                                  );
                                } else {
                                  // Volume
                                  ref
                                      .read(playerStateProvider.notifier)
                                      .setVolume(_dragStartValue);
                                  _showFeedback(
                                    Icons.volume_up,
                                    '${(_dragStartValue * 100).round()}%',
                                  );
                                }
                              } else if (_currentDragMode ==
                                  _DragMode.horizontal) {
                                if (!widget.useDoubleTapSeek) {
                                  _updateDragSeek(
                                    details,
                                    constraints.maxWidth,
                                  );
                                }
                              }
                            } else if (details.pointerCount >= 2) {
                              widget.onScaleUpdate?.call(details);
                            }
                          },
                          onScaleEnd: (details) {
                            if (_currentDragMode == _DragMode.horizontal &&
                                _dragSeekStartPosition != null) {
                              _endDragSeek();
                            }
                            _currentDragMode = _DragMode.none;
                            widget.onScaleEnd?.call(details);
                          },
                          child: const ColoredBox(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dragSeekTarget != null &&
                              (widget.scene.paths.vtt?.isNotEmpty ??
                                  false)) ...[
                            ScrubbingPreview(
                              vttUrl: widget.scene.paths.vtt!,
                              timeInSeconds:
                                  _dragSeekTarget!.inMilliseconds / 1000,
                              headers: ref.read(mediaPlaybackHeadersProvider),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildSeekFeedbackOverlay(colorScheme),
                        ],
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: PlayerGestureFeedback(
                      icon: _feedbackIcon ?? Icons.info,
                      label: _feedbackLabel,
                      visible: _feedbackVisible,
                    ),
                  ),

                  // Layer: Scrubbing Preview (Floating above the slider)
                  if (_isScrubbing &&
                      (widget.scene.paths.vtt?.isNotEmpty ?? false))
                    Positioned(
                      bottom: 84, // Positioned above the slider
                      left: 0,
                      right: 0,
                      height: 100, // Enough height for 160x90 preview
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double ratio = _scrubMs / durationMs;
                          const double previewWidth = 160;

                          // Track is inset slightly from edges
                          final double trackWidth = constraints.maxWidth - 32;
                          final double thumbX = 16 + (ratio * trackWidth);

                          double leftOffset = thumbX - (previewWidth / 2);

                          // Edge protection
                          if (leftOffset < 8) {
                            leftOffset = 8;
                          } else if (leftOffset + previewWidth >
                              constraints.maxWidth - 8) {
                            leftOffset =
                                constraints.maxWidth - previewWidth - 8;
                          }

                          return Stack(
                            children: [
                              Positioned(
                                left: leftOffset,
                                top: 0,
                                child: ScrubbingPreview(
                                  vttUrl: widget.scene.paths.vtt!,
                                  timeInSeconds: _scrubMs / 1000,
                                  headers: ref.read(
                                    mediaPlaybackHeadersProvider,
                                  ),
                                  width: 160,
                                  height: 90,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  // Layer 1: UI Overlays
                  // Debug Info (Follows controls visibility or always visible if you prefer)
                  if (playerState.showVideoDebugInfo)
                    Positioned(
                      top: isFullScreen ? 60 : 8,
                      left: 8,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(130),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                            ),
                            child: Text(
                              'mime: ${playerState.streamMimeType ?? 'unknown'}'
                              '${playerState.streamLabel == null || playerState.streamLabel!.isEmpty ? '' : '  label: ${playerState.streamLabel}'}'
                              '${playerState.streamSource == null || playerState.streamSource!.isEmpty ? '' : '  src: ${playerState.streamSource}'}'
                              '${playerState.prewarmAttempted != true ? '' : '  prewarm: ${playerState.prewarmSucceeded == true ? 'ok' : 'fail'}${playerState.prewarmLatencyMs == null ? '' : '/${playerState.prewarmLatencyMs}ms'}'}'
                              '${playerState.startupLatencyMs == null ? '' : '  start: ${playerState.startupLatencyMs}ms'}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: context.fontSizes.small,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (isFullScreen && widget.onFullScreenToggle != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: SafeArea(
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: context.l10n.common_exit_fullscreen,
                                style: _controlButtonStyle(colorScheme),
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () {
                                  widget.onFullScreenToggle?.call();
                                  _showControlsTemporarily();
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.scene.displayTitle,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: context.fontSizes.body,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      const Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Bottom Control Bar
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: AnimatedSlide(
                        offset: _controlsVisible
                            ? Offset.zero
                            : const Offset(0, 0.08),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: RepaintBoundary(
                            child: GestureDetector(
                              onTap: () {},
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(
                                    alpha: 0.62,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSpeedSliderPanel(
                                      colorScheme,
                                      playbackSpeed,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: StreamBuilder<Duration>(
                                          stream: widget
                                              .controller
                                              .player
                                              .stream
                                              .position,
                                          builder: (context, snapshot) {
                                            final position =
                                                snapshot.data ??
                                                widget
                                                    .controller
                                                    .player
                                                    .state
                                                    .position;
                                            final duration = widget
                                                .controller
                                                .player
                                                .state
                                                .duration;
                                            return Text(
                                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme.onSurface,
                                                    fontSize:
                                                        context.fontSizes.small,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    VideoProgressBar(
                                      durationMs: durationMs,
                                      positionStream: widget
                                          .controller
                                          .player
                                          .stream
                                          .position,
                                      initialPositionMs: value
                                          .position
                                          .inMilliseconds
                                          .toDouble(),
                                      isScrubbing: _isScrubbing,
                                      currentScrubValue: _scrubMs,
                                      onChangeStart: (v) {
                                        _wasPlayingBeforeScrub = value.playing;
                                        _cancelAutoHide();
                                        setState(() {
                                          _isScrubbing = true;
                                          _scrubMs = v;
                                          _controlsVisible = true;
                                        });
                                      },
                                      onChanged: (v) {
                                        setState(() => _scrubMs = v);
                                      },
                                      onChangeEnd: (v) {
                                        final target = Duration(
                                          milliseconds: v.round(),
                                        );
                                        unawaited(() async {
                                          await _seekToKeepingPlayback(
                                            target,
                                            keepPlayingAfterSeek:
                                                _wasPlayingBeforeScrub,
                                          );
                                        }());
                                        setState(() {
                                          _isScrubbing = false;
                                          _scrubMs = 0;
                                        });
                                        _wasPlayingBeforeScrub = false;
                                        _scheduleAutoHide();
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    VideoPlaybackControls(
                                      controller: widget.controller,
                                      scene: widget.scene,
                                      isPlaying: value.playing,
                                      playbackSpeed: playbackSpeed,
                                      nextScene: nextScene,
                                      previousScene: previousScene,
                                      isFullScreen: isFullScreen,
                                      onPlayPause: () {
                                        if (value.playing) {
                                          _pause();
                                        } else {
                                          _play();
                                        }
                                      },
                                      onStopCast: _stopCast,
                                      onSkipNext: () {
                                        ref
                                            .read(playerStateProvider.notifier)
                                            .playNext();
                                      },
                                      onSkipPrevious: () {
                                        ref
                                            .read(playerStateProvider.notifier)
                                            .playPrevious();
                                      },
                                      onSubtitleSelected: (val) async {
                                        if (val == null || val == 'none') {
                                          await ref
                                              .read(
                                                playerStateProvider.notifier,
                                              )
                                              .setSubtitle('none');
                                        } else {
                                          final parts = val.split(':');
                                          final lang = parts[0];
                                          final type = parts.length > 1
                                              ? parts[1]
                                              : '';
                                          await ref
                                              .read(
                                                playerStateProvider.notifier,
                                              )
                                              .setSubtitle(
                                                lang,
                                                captionType: type.isEmpty
                                                    ? null
                                                    : type,
                                              );
                                        }
                                      },
                                      onSpeedSelected: (speed) async {
                                        await widget.controller.player.setRate(
                                          speed,
                                        );
                                      },
                                      onFullScreenToggle:
                                          widget.onFullScreenToggle,
                                      enableNativePip: widget.enableNativePip,
                                      onInteract: _showControlsTemporarily,
                                      desktopVolumeControl:
                                          ref.watch(desktopCapabilitiesProvider)
                                          ? _buildDesktopVolumeControl(
                                              context,
                                              colorScheme,
                                            )
                                          : null,
                                      selectedSubtitleLanguage:
                                          playerState.selectedSubtitleLanguage,
                                      selectedSubtitleType:
                                          playerState.selectedSubtitleType,
                                      onSpeedTap: () {
                                        setState(
                                          () => _showSpeedSlider =
                                              !_showSpeedSlider,
                                        );
                                        _showControlsTemporarily();
                                      },
                                      isSpeedSliderVisible: _showSpeedSlider,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
