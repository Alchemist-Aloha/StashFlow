import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _source.value = source;
    if (_viewId != null) return true;
    if (_opening) return false;
    _opening = true;

    final ratio = sanitizeDesktopPipAspectRatio(aspectRatio);
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
      await window.setAspectRatio(ratio);
      if (Platform.isMacOS) {
        await window.macos.hideFromCollection(true);
        await window.macos.setVisibleOnAllWorkspaces(
          true,
          visibleOnFullScreen: true,
        );
      } else {
        await window.hideCurrentAppTabFromTaskbar(true);
      }
      return true;
    } catch (_) {
      _viewId = null;
      _source.value = null;
      return false;
    } finally {
      _opening = false;
    }
  }

  static void updateSource(DesktopPipPlaybackSource source) {
    if (_viewId != null) _source.value = source;
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
              unawaited(MultiViewDesktop.fromId(widget.viewId).startDragging()),
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
