import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/frosted_surface.dart';
import '../../../../core/utils/responsive.dart';
import '../../../scenes/data/repositories/playback_media.dart';
import '../../../scenes/presentation/providers/playback_session_controller.dart';
import '../../../scenes/presentation/providers/player_settings.dart';
import '../../../scenes/presentation/widgets/video_controls/video_progress_bar.dart';

/// Each viewer owns its session; the factory also allows native-free UI tests.
final imageClipSessionFactoryProvider = Provider<PlaybackSession Function()>((
  ref,
) {
  final settings = PlayerSettingsStore(ref.watch(sharedPreferencesProvider));
  return () {
    final player = Player();
    return PlaybackSession(
      player: player,
      controller: VideoController(
        player,
        configuration: settings.loadVideoConfiguration(),
      ),
    );
  };
});

/// A viewer-owned clip session, separate from scene playback and its queue.
/// Mount only for the selected image; unmounting releases the decoder.
class ImageClipPlayer extends ConsumerStatefulWidget {
  const ImageClipPlayer({
    required this.url,
    this.onTap,
    this.controlsInsets = EdgeInsets.zero,
    super.key,
  });

  final String url;
  final VoidCallback? onTap;

  /// Viewer chrome bounds including system insets; video remains full-size.
  final EdgeInsets controlsInsets;

  @override
  ConsumerState<ImageClipPlayer> createState() => _ImageClipPlayerState();
}

class _ImageClipPlayerState extends ConsumerState<ImageClipPlayer>
    with WidgetsBindingObserver {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<String>? _errors;
  Future<void> _initialization = Future.value();
  Future<void> _releasing = Future.value();
  bool _failed = false;
  bool _loading = true;
  bool _resume = false;
  bool _backgrounded = false;
  bool _seeking = false;
  double? _scrubValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialization = _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_release());
    super.dispose();
  }

  Future<void> _release() {
    final player = _player;
    if (player == null) return _releasing;
    unawaited(_errors?.cancel());
    _player = null;
    _controller = null;
    _errors = null;
    return _releasing = (() async {
      try {
        // Detach the texture before releasing its native render context.
        await WidgetsBinding.instance.endOfFrame;
        await player.dispose();
      } on Object catch (error, stack) {
        _log('dispose', error, stack);
      }
    })();
  }

  void _fail() {
    if (!mounted) return;
    setState(() => _failed = true);
    unawaited(_release());
  }

  void _log(String operation, Object error, StackTrace stack) {
    AppLogStore.instance.addError(
      operation,
      error,
      stack,
      source: 'image_clip_player',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final player = _player;
    if (state == AppLifecycleState.resumed) {
      _backgrounded = false;
      if (_resume && !_failed) unawaited(_setPlaying(true));
      _resume = false;
    } else if (!_backgrounded) {
      _backgrounded = true;
      final playing = player?.state.playing ?? false;
      _resume = _resume || playing;
      if (playing) unawaited(_setPlaying(false));
    }
  }

  Future<void> _setPlaying(bool playing) async {
    final player = _player;
    if (player == null) return;
    try {
      await (playing ? player.play() : player.pause());
    } on Object catch (error, stack) {
      _log('playPause', error, stack);
      if (identical(_player, player)) _fail();
    }
  }

  Future<void> _initialize() async {
    try {
      final session = ref.read(imageClipSessionFactoryProvider)();
      final player = session.player;
      _player = player;
      // Publish the surface before awaiting any native startup work.
      setState(() => _controller = session.controller);
      _errors = player.stream.error.listen((error) {
        // mpv also reports recoverable decoder/seek errors here.
        _log('playback', StateError(error), StackTrace.current);
      });
      var url = widget.url;
      if (kIsWeb) {
        final auth = ref.read(authProvider);
        url = applyWebMediaAuthFallback(
          url: url,
          authMode: auth.mode,
          apiKey: ref.read(serverApiKeyProvider),
          username: auth.username,
          password: auth.password,
          graphqlEndpoint: Uri.tryParse(ref.read(serverUrlProvider)),
        );
      }
      final headers = ref.read(mediaPlaybackHeadersProvider);
      final settings = PlayerSettingsStore(ref.read(sharedPreferencesProvider));
      await (() async {
        await session.controller.platform.future;
        if (!mounted || !identical(_player, player) || _failed) return;
        await settings.applyMpvProperties(player);
        if (!mounted || !identical(_player, player) || _failed) return;
        await player.setPlaylistMode(PlaylistMode.single);
        if (!mounted || !identical(_player, player) || _failed) return;
        await player.open(
          createPlaybackMedia(url, httpHeaders: headers),
          play: false,
        );
        if (!mounted || !identical(_player, player) || _failed) return;
        if (WidgetsBinding.instance.lifecycleState == null ||
            WidgetsBinding.instance.lifecycleState ==
                AppLifecycleState.resumed) {
          await player.play();
          await session.controller.waitUntilFirstFrameRendered;
        } else {
          _resume = true;
        }
      })().timeout(const Duration(seconds: 12));
    } on Object catch (error, stack) {
      _log('initialize', error, stack);
      _fail();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _controller = null;
      _resume = false;
      _seeking = false;
      _scrubValue = null;
    });
    await _release();
    await _initialization;
    if (!mounted) return;
    setState(() => _failed = false);
    _initialization = _initialize();
  }

  Future<void> _seek(double value) async {
    final player = _player;
    if (player == null || _seeking) return;
    setState(() => _seeking = true);
    try {
      final target = Duration(
        milliseconds: value.round().clamp(
          0,
          player.state.duration.inMilliseconds,
        ),
      );
      await player.seek(target).timeout(const Duration(seconds: 10));
      // A seek acknowledgement can precede the updated playback position.
      if (mounted &&
          identical(_player, player) &&
          (player.state.position - target).abs() > const Duration(seconds: 1)) {
        await player.stream.position
            .firstWhere(
              (position) =>
                  (position - target).abs() <= const Duration(seconds: 1),
            )
            .timeout(const Duration(seconds: 3), onTimeout: () => target);
      }
    } on Object catch (error, stack) {
      _log('seek', error, stack);
    } finally {
      if (mounted && identical(_player, player)) {
        setState(() {
          _seeking = false;
          _scrubValue = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Center(
        child: TextButton.icon(
          onPressed: _loading ? null : _retry,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.failed_to_load_tap_to_retry),
        ),
      );
    }
    final player = _player;
    final dimensions = context.dimensions;
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= Responsive.tabletBreakpoint
        ? dimensions.spacingLarge
        : dimensions.spacingSmall;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_controller != null)
                Video(
                  controller: _controller!,
                  controls: null,
                  pauseUponEnteringBackgroundMode: false,
                ),
              if (_loading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        if (player != null && !_loading)
          Positioned.fill(
            child: Padding(
              padding: widget.controlsInsets,
              child: SafeArea(
                top: false,
                bottom: widget.controlsInsets.bottom == 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final normalHeight = dimensions.buttonHeight.clamp(
                      kMinInteractiveDimension,
                      double.infinity,
                    );
                    final compact =
                        constraints.maxHeight <
                        normalHeight + dimensions.spacingSmall * 2;
                    final gap = compact
                        ? (constraints.maxHeight - kMinInteractiveDimension)
                              .clamp(0.0, dimensions.spacingSmall)
                        : dimensions.spacingSmall;
                    final buttonHeight = compact
                        ? (constraints.maxHeight - gap).clamp(
                            kMinInteractiveDimension,
                            normalHeight,
                          )
                        : normalHeight;
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            gap,
                          ),
                          child: FrostedSurface(
                            key: const Key('image_clip_controls'),
                            tint: Theme.of(context).colorScheme.surface
                                .withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(
                              dimensions.spacingLarge,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: dimensions.spacingSmall,
                              vertical: compact
                                  ? 0
                                  : dimensions.spacingSmall / 2,
                            ),
                            child: _buildControls(player, buttonHeight),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControls(Player player, double buttonHeight) {
    return Row(
      children: [
        StreamBuilder<bool>(
          stream: player.stream.playing,
          initialData: player.state.playing,
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;
            return SizedBox.square(
              dimension: buttonHeight,
              child: IconButton(
                key: const Key('image_clip_play_pause'),
                padding: EdgeInsets.zero,
                iconSize: (24 * context.dimensions.fontSizeFactor).clamp(
                  0.0,
                  buttonHeight,
                ),
                tooltip: playing
                    ? context.l10n.common_pause
                    : context.l10n.common_play,
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                onPressed: () => unawaited(_setPlaying(!playing)),
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<Duration>(
            stream: player.stream.duration,
            initialData: player.state.duration,
            builder: (context, snapshot) {
              final durationMs =
                  (snapshot.data ?? Duration.zero).inMilliseconds;
              return Semantics(
                label: context.l10n.settings_playback_seek_drag,
                child: IgnorePointer(
                  ignoring: _seeking || durationMs <= 0,
                  child: VideoProgressBar(
                    key: const Key('image_clip_seek_bar'),
                    durationMs: durationMs,
                    positionStream: player.stream.position,
                    initialPositionMs: player.state.position.inMilliseconds
                        .toDouble(),
                    isScrubbing: _scrubValue != null,
                    currentScrubValue: _scrubValue ?? 0,
                    onChangeStart: (value) =>
                        setState(() => _scrubValue = value),
                    onChanged: (value) => setState(() => _scrubValue = value),
                    onChangeEnd: (value) => unawaited(_seek(value)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
