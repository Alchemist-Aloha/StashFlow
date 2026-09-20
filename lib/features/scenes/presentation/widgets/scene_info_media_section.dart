import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene.dart';
import '../../data/repositories/preview_availability_service.dart';
import '../providers/player_settings.dart';
import 'scene_cover_fullscreen_viewer.dart';

typedef SceneInfoMediaBuilder =
    Widget Function(BuildContext context, Scene scene);
typedef SceneInfoPreviewBuilder =
    Widget Function(
      BuildContext context,
      Scene scene,
      bool autoplay,
      VoidCallback onUnavailable,
    );

enum _SceneInfoMediaMode { cover, preview }

enum _PreviewAvailability { checking, available, unavailable }

class SceneInfoMediaSection extends ConsumerStatefulWidget {
  const SceneInfoMediaSection({
    required this.scene,
    this.coverBuilder,
    this.previewBuilder,
    super.key,
  });

  final Scene scene;
  final SceneInfoMediaBuilder? coverBuilder;
  final SceneInfoPreviewBuilder? previewBuilder;

  static bool isVisibleFor(Scene scene) {
    return _normalized(scene.paths.screenshot) != null ||
        _normalized(scene.paths.preview) != null;
  }

  static String? _normalized(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  @override
  ConsumerState<SceneInfoMediaSection> createState() =>
      _SceneInfoMediaSectionState();
}

class _SceneInfoMediaSectionState extends ConsumerState<SceneInfoMediaSection> {
  late _SceneInfoMediaMode _mode = _initialMode(widget.scene);
  late bool _previewAutoplay = _mode == _SceneInfoMediaMode.preview;
  _PreviewAvailability _previewAvailability = _PreviewAvailability.checking;
  int _availabilityGeneration = 0;

  String? get _coverUrl =>
      SceneInfoMediaSection._normalized(widget.scene.paths.screenshot);
  String? get _previewUrl =>
      SceneInfoMediaSection._normalized(widget.scene.paths.preview);

  static _SceneInfoMediaMode _initialMode(Scene scene) {
    return SceneInfoMediaSection._normalized(scene.paths.screenshot) != null
        ? _SceneInfoMediaMode.cover
        : _SceneInfoMediaMode.preview;
  }

  Future<void> _showFullscreenCover(String coverUrl) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SceneCoverFullscreenViewer(
          imageUrl: coverUrl,
          imageBuilder: widget.coverBuilder == null
              ? null
              : (viewerContext, imageUrl) =>
                    widget.coverBuilder!(viewerContext, widget.scene),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkPreviewAvailability();
  }

  @override
  void didUpdateWidget(covariant SceneInfoMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.scene.paths.screenshot != widget.scene.paths.screenshot ||
        oldWidget.scene.paths.preview != widget.scene.paths.preview) {
      _mode = _initialMode(widget.scene);
      _previewAutoplay = _mode == _SceneInfoMediaMode.preview;
      _previewAvailability = _PreviewAvailability.checking;
      _checkPreviewAvailability();
    }
  }

  /// Probes the preview URL once so a missing preview never appears as a
  /// selectable option in the pill toggle.
  void _checkPreviewAvailability() {
    final previewUrl = _previewUrl;
    if (previewUrl == null) {
      _previewAvailability = _PreviewAvailability.unavailable;
      return;
    }

    final generation = ++_availabilityGeneration;
    unawaited(
      ref
          .read(previewAvailabilityCheckProvider)(previewUrl)
          .then((available) {
            if (!mounted || generation != _availabilityGeneration) return;
            setState(() {
              _previewAvailability = available
                  ? _PreviewAvailability.available
                  : _PreviewAvailability.unavailable;
              if (!available) _fallBackFromUnavailablePreview();
            });
          })
          .catchError((Object _) {
            if (!mounted || generation != _availabilityGeneration) return;
            setState(
              () => _previewAvailability = _PreviewAvailability.available,
            );
          }),
    );
  }

  /// Moves off a preview that is known to be dead while keeping a cover shown.
  void _fallBackFromUnavailablePreview() {
    if (_mode == _SceneInfoMediaMode.preview && _coverUrl != null) {
      _mode = _SceneInfoMediaMode.cover;
      _previewAutoplay = false;
    }
  }

  /// Handles a preview that failed during playback after passing the probe.
  void _handlePreviewUnavailable() {
    if (!mounted || _previewAvailability == _PreviewAvailability.unavailable) {
      return;
    }
    setState(() {
      _previewAvailability = _PreviewAvailability.unavailable;
      _fallBackFromUnavailablePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _coverUrl;
    final previewUrl = _previewUrl;
    if (coverUrl == null && previewUrl == null) {
      return const SizedBox.shrink();
    }

    final hasBoth = coverUrl != null && previewUrl != null;
    final previewUnavailable =
        _previewAvailability == _PreviewAvailability.unavailable;
    final showCover = coverUrl != null && _mode == _SceneInfoMediaMode.cover;

    return Container(
      key: const Key('scene_info_media_section'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.preview,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (hasBoth && !previewUnavailable)
                SegmentedButton<_SceneInfoMediaMode>(
                  key: const Key('scene_info_media_toggle'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _SceneInfoMediaMode.cover,
                      label: Text(context.l10n.scene_info_cover),
                      icon: const Icon(Icons.image_outlined),
                    ),
                    ButtonSegment(
                      value: _SceneInfoMediaMode.preview,
                      label: Text(context.l10n.preview),
                      icon: const Icon(Icons.play_circle_outline),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _mode = selection.single;
                      _previewAutoplay = _mode == _SceneInfoMediaMode.preview;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: showCover
                    ? Semantics(
                        button: true,
                        label: context.l10n.scene_info_cover,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: const Key('scene_info_media_cover_tap_target'),
                            onTap: () => _showFullscreenCover(coverUrl),
                            child: KeyedSubtree(
                              key: const Key('scene_info_media_cover'),
                              child:
                                  widget.coverBuilder?.call(
                                    context,
                                    widget.scene,
                                  ) ??
                                  StashImage(
                                    imageUrl: coverUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                            ),
                          ),
                        ),
                      )
                    : previewUnavailable
                    ? const _SceneInfoPreviewUnavailable(
                        key: Key('scene_info_media_preview_unavailable'),
                      )
                    : KeyedSubtree(
                        key: const Key('scene_info_media_preview'),
                        child:
                            widget.previewBuilder?.call(
                              context,
                              widget.scene,
                              _previewAutoplay,
                              _handlePreviewUnavailable,
                            ) ??
                            _SceneInfoPreviewPlayer(
                              key: ValueKey(
                                'scene_info_preview_${widget.scene.id}_$previewUrl',
                              ),
                              previewUrl: previewUrl!,
                              autoplay: _previewAutoplay,
                              onUnavailable: _handlePreviewUnavailable,
                            ),
                      ),
              ),
            ),
          ),
          if (previewUnavailable && coverUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              key: const Key('scene_info_media_preview_unavailable_notice'),
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.scene_info_preview_unavailable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SceneInfoPreviewUnavailable extends StatelessWidget {
  const _SceneInfoPreviewUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            color: Colors.white54,
            size: 36,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              context.l10n.scene_info_preview_unavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneInfoPreviewPlayer extends ConsumerStatefulWidget {
  const _SceneInfoPreviewPlayer({
    required this.previewUrl,
    required this.autoplay,
    required this.onUnavailable,
    super.key,
  });

  final String previewUrl;
  final bool autoplay;

  /// Invoked when the preview cannot be loaded or played so the surrounding
  /// section can present a fallback instead of an unusable player surface.
  final VoidCallback onUnavailable;

  @override
  ConsumerState<_SceneInfoPreviewPlayer> createState() =>
      _SceneInfoPreviewPlayerState();
}

class _SceneInfoPreviewPlayerState
    extends ConsumerState<_SceneInfoPreviewPlayer> {
  /// Upper bound for a preview that never finishes loading (for example a
  /// server that accepts the request but never returns media).
  static const Duration _startupTimeout = Duration(seconds: 12);

  Player? _player;
  VideoController? _controller;
  StreamSubscription<Object>? _errorSubscription;
  Timer? _startupWatchdog;
  bool _initializing = true;
  bool _reportedUnavailable = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    unawaited(_disposePlayer());
    super.dispose();
  }

  void _reportUnavailable() {
    if (_reportedUnavailable || !mounted) return;
    _reportedUnavailable = true;
    widget.onUnavailable();
  }

  Future<void> _initialize() async {
    final player = Player();
    final controller = VideoController(
      player,
      configuration: PlayerSettingsStore(
        ref.read(sharedPreferencesProvider),
      ).loadVideoConfiguration(),
    );
    _player = player;
    _controller = controller;

    _errorSubscription = player.stream.error.listen(
      (_) => _reportUnavailable(),
    );
    _startupWatchdog = Timer(_startupTimeout, () {
      if (mounted && _initializing && !_reportedUnavailable) {
        _reportUnavailable();
      }
    });

    try {
      final graphqlEndpoint = Uri.tryParse(ref.read(serverUrlProvider));
      var effectiveUrl = graphqlEndpoint == null
          ? widget.previewUrl
          : resolveGraphqlMediaUrl(
              rawUrl: widget.previewUrl,
              graphqlEndpoint: graphqlEndpoint,
            );
      var effectiveHeaders = ref.read(mediaPlaybackHeadersProvider);

      if (kIsWeb) {
        final authState = ref.read(authProvider);
        effectiveUrl = applyWebMediaAuthFallback(
          url: effectiveUrl,
          authMode: authState.mode,
          apiKey: ref.read(serverApiKeyProvider),
          username: authState.username,
          password: authState.password,
          graphqlEndpoint: graphqlEndpoint,
        );
        effectiveHeaders = const {};
      }

      await player.open(
        Media(effectiveUrl, httpHeaders: effectiveHeaders),
        play: widget.autoplay,
      );
    } catch (_) {
      _reportUnavailable();
    } finally {
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
  }

  Future<void> _disposePlayer() async {
    _startupWatchdog?.cancel();
    _startupWatchdog = null;
    await _errorSubscription?.cancel();
    _errorSubscription = null;
    final player = _player;
    _player = null;
    _controller = null;
    await player?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          _PreviewNativeControls(child: Video(controller: controller)),
        if (_initializing) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _PreviewNativeControls extends StatelessWidget {
  const _PreviewNativeControls({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const mobileControls = MaterialVideoControlsThemeData(
      bottomButtonBarMargin: EdgeInsets.fromLTRB(12, 0, 4, 8),
      seekBarMargin: EdgeInsets.fromLTRB(12, 0, 12, 8),
    );
    const desktopControls = MaterialDesktopVideoControlsThemeData(
      bottomButtonBarMargin: EdgeInsets.fromLTRB(12, 0, 12, 8),
      seekBarMargin: EdgeInsets.fromLTRB(12, 0, 12, 8),
    );

    return MaterialVideoControlsTheme(
      normal: mobileControls,
      fullscreen: mobileControls,
      child: MaterialDesktopVideoControlsTheme(
        normal: desktopControls,
        fullscreen: desktopControls,
        child: child,
      ),
    );
  }
}
