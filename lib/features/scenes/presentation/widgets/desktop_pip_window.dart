import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart' show VideoParams;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/pip_mode.dart';
import 'video_controls/video_progress_bar.dart';

/// Shorter side of the smallest desktop PiP window the user can resize to.
const double kDesktopPipMinimumShortSide = 120;
const double _defaultAspectRatio = 16 / 9;
const String kDesktopPipWindowTitle = 'Picture-in-Picture — StashFlow';

double sanitizeDesktopPipAspectRatio(double? aspectRatio) {
  if (aspectRatio == null || !aspectRatio.isFinite || aspectRatio <= 0) {
    return _defaultAspectRatio;
  }
  return aspectRatio.clamp(0.25, 4.0).toDouble();
}

Size desktopPipWindowSize(double? aspectRatio) {
  final ratio = sanitizeDesktopPipAspectRatio(aspectRatio);
  const height = 300.0;
  return Size(height * ratio, height);
}

/// Integer client dimensions that preserve the user's height when video changes.
Size desktopPipResizeSize(Size current, double aspectRatio) {
  final ratio = sanitizeDesktopPipAspectRatio(aspectRatio);
  final minimum = desktopPipMinimumSize(ratio);
  final height = current.height.clamp(minimum.height, 50000).ceilToDouble();
  return Size((height * ratio).roundToDouble(), height);
}

/// Applies a video ratio to the native client area, not GTK's decorated frame.
/// Wayland ignores ordinary GTK resize requests; briefly equal min/max hints
/// request the new dimensions, then restore free resizing after confirmation.
Future<void> applyDesktopPipWindowAspectRatio(
  MultiViewDesktop window,
  double ratio, {
  required bool isWayland,
  Size? initialSize,
}) async {
  if (!await window.setAspectRatio(0)) {
    throw StateError('Could not unlock PiP aspect ratio');
  }
  final minimum = desktopPipMinimumSize(ratio);
  if (!window.setMinimumSize(minimum)) {
    throw StateError('Could not set PiP minimum size');
  }
  if (isWayland) {
    final target = desktopPipResizeSize(initialSize ?? window.getSize(), ratio);
    final maximum = window.getMaximumSize();
    final observer = _PipResizeObserver(window, target);
    WidgetsBinding.instance.addObserver(observer);
    var locked = false;
    try {
      if (!window.setMaximumSize(target) ||
          !window.setMinimumSize(target) ||
          !await window.setSize(target)) {
        throw StateError('Could not resize Wayland PiP window');
      }
      observer.didChangeMetrics();
      await observer.resized.future.timeout(const Duration(seconds: 2));
    } finally {
      WidgetsBinding.instance.removeObserver(observer);
      window.setMinimumSize(minimum);
      window.setMaximumSize(maximum);
      locked = await window.setAspectRatio(ratio);
    }
    if (!locked) throw StateError('Could not lock PiP aspect ratio');
    return;
  }
  if (!await window.setAspectRatio(ratio)) {
    throw StateError('Could not lock PiP aspect ratio');
  }
}

class _PipResizeObserver extends WidgetsBindingObserver {
  _PipResizeObserver(this.window, this.target);

  final MultiViewDesktop window;
  final Size target;
  final resized = Completer<void>();

  @override
  void didChangeMetrics() {
    final size = window.getSize();
    if (!resized.isCompleted &&
        (size.width - target.width).abs() < 1 &&
        (size.height - target.height).abs() < 1) {
      resized.complete();
    }
  }
}

/// Smallest window size the PiP window can be resized to.
///
/// The minimum follows [aspectRatio] so it never conflicts with the window's
/// locked ratio: a fixed 16:9 minimum inflates the short side of portrait and
/// ultra-wide videos (a 9:16 video could not shrink below 240 wide) and keeps
/// the ratio from being applied consistently at small sizes. Keeping both
/// dimensions on the same ratio lets the window scale freely down to
/// [kDesktopPipMinimumShortSide].
Size desktopPipMinimumSize(double? aspectRatio) {
  final ratio = sanitizeDesktopPipAspectRatio(aspectRatio);
  const shortSide = kDesktopPipMinimumShortSide;
  return ratio >= 1
      ? Size(shortSide * ratio, shortSide)
      : Size(shortSide, shortSide / ratio);
}

class DesktopPipPlaybackSource {
  const DesktopPipPlaybackSource({
    required this.controller,
    required this.canPlayPrevious,
    required this.canPlayNext,
  });

  final VideoController controller;
  final bool canPlayPrevious;
  final bool canPlayNext;
}

/// Owns the one secondary desktop view used for picture-in-picture playback.
class DesktopPipWindowSession {
  DesktopPipWindowSession._();

  static int? _viewId;
  static bool _opening = false;
  static StreamSubscription<VideoParams>? _videoParamsSubscription;
  static double? _aspectRatio;
  static Future<void> _geometryUpdate = Future<void>.value();
  static final ValueNotifier<DesktopPipPlaybackSource?> _source =
      ValueNotifier<DesktopPipPlaybackSource?>(null);

  static Future<bool> open({
    required DesktopPipPlaybackSource source,
    required double? aspectRatio,
    required VoidCallback onTogglePlayback,
    required Future<void> Function(Duration position) onSeek,
    required Future<void> Function() onPrevious,
    required Future<void> Function() onNext,
  }) async {
    if (_viewId != null) {
      updateSource(source);
      return true;
    }
    _source.value = source;
    if (_opening) return false;
    _opening = true;

    final ratio = sanitizeDesktopPipAspectRatio(
      pipDisplayAspectRatio(source.controller.player.state.videoParams) ??
          aspectRatio,
    );
    final minimumSize = desktopPipMinimumSize(ratio);
    try {
      final viewId = await openWindow(
        (context, id) {
          _viewId ??= id;
          return _DesktopPipPlayerWindow(
            source: _source,
            viewId: id,
            onTogglePlayback: onTogglePlayback,
            onSeek: onSeek,
            onPrevious: onPrevious,
            onNext: onNext,
            onClosed: () => _handleClosed(id),
          );
        },
        options: WindowOptions(
          size: desktopPipWindowSize(ratio),
          minimumSize: minimumSize,
          alignment: Alignment.bottomRight,
          backgroundColor: Colors.black,
          titleBarStyle: TitleBarStyle.hidden,
          windowButtonVisibility: false,
          // Matches the desktop's generic Picture-in-Picture window rule so
          // Hyprland floats, pins, and preserves the aspect ratio of this view.
          title: kDesktopPipWindowTitle,
          alwaysOnTop: true,
        ),
      );
      _viewId = viewId;

      final window = MultiViewDesktop.fromId(viewId);
      if (Platform.isLinux) window.setAsFrameless();
      await applyDesktopPipWindowAspectRatio(
        window,
        ratio,
        isWayland:
            Platform.isLinux &&
            Platform.environment.containsKey('WAYLAND_DISPLAY'),
        initialSize: desktopPipWindowSize(ratio),
      );
      _aspectRatio = ratio;
      _watchVideoParams(_source.value ?? source);
      if (Platform.isMacOS) {
        window.macos.hideFromCollection(true);
        window.macos.setVisibleOnAllWorkspaces(true, visibleOnFullScreen: true);
      } else {
        window.hideCurrentAppTabFromTaskbar(true);
      }
      return true;
    } catch (_) {
      _viewId = null;
      _stopWatchingVideoParams();
      _source.value = null;
      return false;
    } finally {
      _opening = false;
    }
  }

  static void updateSource(DesktopPipPlaybackSource source) {
    if (_viewId == null) return;
    final controllerChanged = _source.value?.controller != source.controller;
    _source.value = source;
    if (controllerChanged && !_opening) _watchVideoParams(source);
  }

  static void _watchVideoParams(DesktopPipPlaybackSource source) {
    unawaited(_videoParamsSubscription?.cancel());
    final controller = source.controller;
    void update(VideoParams params) {
      final displayRatio = pipDisplayAspectRatio(params);
      final viewId = _viewId;
      if (displayRatio == null || viewId == null) return;
      final ratio = sanitizeDesktopPipAspectRatio(displayRatio);
      // Serialize native changes so late metadata cannot race a scene switch.
      _geometryUpdate = _geometryUpdate
          .then((_) async {
            if (_viewId != viewId ||
                _source.value?.controller != controller ||
                _aspectRatio == ratio) {
              return;
            }
            final window = MultiViewDesktop.fromId(viewId);
            _aspectRatio = null;
            await applyDesktopPipWindowAspectRatio(
              window,
              ratio,
              isWayland:
                  Platform.isLinux &&
                  Platform.environment.containsKey('WAYLAND_DISPLAY'),
            );
            if (_viewId == viewId) _aspectRatio = ratio;
          })
          .catchError((Object error) {
            debugPrint('Desktop PiP aspect ratio update failed: $error');
          });
    }

    _videoParamsSubscription = controller.player.stream.videoParams.listen(
      update,
    );
    update(controller.player.state.videoParams);
  }

  static void _stopWatchingVideoParams() {
    unawaited(_videoParamsSubscription?.cancel());
    _videoParamsSubscription = null;
    _aspectRatio = null;
  }

  static Future<bool> close() async {
    final viewId = _viewId;
    if (viewId == null) return false;
    await MultiViewDesktop.fromId(viewId).closeWindow();
    return true;
  }

  static void _handleClosed(int viewId) {
    if (_viewId != viewId) return;
    _viewId = null;
    _stopWatchingVideoParams();
    _source.value = null;
    scheduleMicrotask(PipMode.windowedWindowClosed);
  }
}

class _DesktopPipPlayerWindow extends StatefulWidget {
  const _DesktopPipPlayerWindow({
    required this.source,
    required this.viewId,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onPrevious,
    required this.onNext,
    required this.onClosed,
  });

  final ValueListenable<DesktopPipPlaybackSource?> source;
  final int viewId;
  final VoidCallback onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final VoidCallback onClosed;

  @override
  State<_DesktopPipPlayerWindow> createState() =>
      _DesktopPipPlayerWindowState();
}

class _DesktopPipPlayerWindowState extends State<_DesktopPipPlayerWindow> {
  bool _showControls = true;

  Future<void> _exitPip() => PipMode.exitIfAvailable();

  @override
  void dispose() {
    widget.onClosed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              unawaited(_exitPip()),
          const SingleActivator(LogicalKeyboardKey.space):
              widget.onTogglePlayback,
        },
        child: Focus(
          autofocus: true,
          child: MouseRegion(
            onEnter: (_) => setState(() => _showControls = true),
            onHover: (_) {
              if (!_showControls) setState(() => _showControls = true);
            },
            onExit: (_) => setState(() => _showControls = false),
            child: ValueListenableBuilder<DesktopPipPlaybackSource?>(
              valueListenable: widget.source,
              builder: (context, source, _) {
                if (source == null) return const SizedBox.expand();
                return _buildPlayer(context, source);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, DesktopPipPlaybackSource source) {
    final controller = source.controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () => unawaited(_exitPip()),
          onPanStart: (_) =>
              MultiViewDesktop.fromId(widget.viewId).startDragging(),
          child: Video(
            key: ValueKey(controller),
            controller: controller,
            controls: null,
            pauseUponEnteringBackgroundMode: false,
          ),
        ),
        IgnorePointer(
          ignoring: !_showControls,
          child: AnimatedOpacity(
            opacity: _showControls ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(child: _PipControlGradient()),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: _PipIconButton(
                    icon: Icons.picture_in_picture_alt_rounded,
                    tooltip: context.l10n.common_exit_pip,
                    onPressed: () => unawaited(_exitPip()),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 4,
                  child: DesktopPipTransportControls(
                    key: ValueKey(controller),
                    controller: controller,
                    canPlayPrevious: source.canPlayPrevious,
                    canPlayNext: source.canPlayNext,
                    onTogglePlayback: widget.onTogglePlayback,
                    onSeek: widget.onSeek,
                    onPrevious: widget.onPrevious,
                    onNext: widget.onNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopPipTransportControls extends StatefulWidget {
  const DesktopPipTransportControls({
    super.key,
    required this.controller,
    required this.canPlayPrevious,
    required this.canPlayNext,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onPrevious,
    required this.onNext,
  });

  final VideoController controller;
  final bool canPlayPrevious;
  final bool canPlayNext;
  final VoidCallback onTogglePlayback;
  final Future<void> Function(Duration position) onSeek;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;

  @override
  State<DesktopPipTransportControls> createState() =>
      _DesktopPipTransportControlsState();
}

class _DesktopPipTransportControlsState
    extends State<DesktopPipTransportControls> {
  bool _isScrubbing = false;
  double _scrubMs = 0;

  @override
  Widget build(BuildContext context) {
    final player = widget.controller.player;
    return StreamBuilder<Duration>(
      stream: player.stream.duration,
      initialData: player.state.duration,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? player.state.duration;
        final durationMs = duration.inMilliseconds.clamp(1, 1 << 53);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              child: VideoProgressBar(
                durationMs: durationMs,
                positionStream: player.stream.position,
                initialPositionMs: player.state.position.inMilliseconds
                    .toDouble(),
                isScrubbing: _isScrubbing,
                currentScrubValue: _scrubMs,
                onChangeStart: (value) => setState(() {
                  _isScrubbing = true;
                  _scrubMs = value;
                }),
                onChanged: (value) => setState(() => _scrubMs = value),
                onChangeEnd: (value) {
                  setState(() {
                    _isScrubbing = false;
                    _scrubMs = value;
                  });
                  unawaited(
                    widget.onSeek(Duration(milliseconds: value.round())),
                  );
                },
              ),
            ),
            StreamBuilder<bool>(
              stream: player.stream.playing,
              initialData: player.state.playing,
              // Scale the fixed-size buttons down instead of overflowing once
              // the window is resized near its minimum.
              builder: (context, playingSnapshot) => FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PipIconButton(
                      icon: Icons.skip_previous_rounded,
                      tooltip: context.l10n.common_skip_previous,
                      onPressed: widget.canPlayPrevious
                          ? () => unawaited(widget.onPrevious())
                          : null,
                    ),
                    _PipIconButton(
                      icon: playingSnapshot.data ?? false
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      tooltip: playingSnapshot.data ?? false
                          ? context.l10n.common_pause
                          : context.l10n.common_play,
                      emphasized: true,
                      onPressed: widget.onTogglePlayback,
                    ),
                    _PipIconButton(
                      icon: Icons.skip_next_rounded,
                      tooltip: context.l10n.common_skip_next,
                      onPressed: widget.canPlayNext
                          ? () => unawaited(widget.onNext())
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PipIconButton extends StatelessWidget {
  const _PipIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: emphasized ? 28 : 22,
      color: Colors.white,
      disabledColor: Colors.white38,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _PipControlGradient extends StatelessWidget {
  const _PipControlGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black45, Colors.transparent, Colors.black87],
          stops: [0, 0.45, 1],
        ),
      ),
    );
  }
}
