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
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene.dart';
import 'scene_cover_fullscreen_viewer.dart';

typedef SceneInfoMediaBuilder =
    Widget Function(BuildContext context, Scene scene);
typedef SceneInfoPreviewBuilder =
    Widget Function(BuildContext context, Scene scene, bool autoplay);

enum _SceneInfoMediaMode { cover, preview }

class SceneInfoMediaSection extends StatefulWidget {
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
  State<SceneInfoMediaSection> createState() => _SceneInfoMediaSectionState();
}

class _SceneInfoMediaSectionState extends State<SceneInfoMediaSection> {
  late _SceneInfoMediaMode _mode = _initialMode(widget.scene);
  late bool _previewAutoplay = _mode == _SceneInfoMediaMode.preview;

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
  void didUpdateWidget(covariant SceneInfoMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.scene.paths.screenshot != widget.scene.paths.screenshot ||
        oldWidget.scene.paths.preview != widget.scene.paths.preview) {
      _mode = _initialMode(widget.scene);
      _previewAutoplay = _mode == _SceneInfoMediaMode.preview;
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _coverUrl;
    final previewUrl = _previewUrl;
    if (coverUrl == null && previewUrl == null) {
      return const SizedBox.shrink();
    }

    final hasBoth = coverUrl != null && previewUrl != null;
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
              if (hasBoth)
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
                    : KeyedSubtree(
                        key: const Key('scene_info_media_preview'),
                        child:
                            widget.previewBuilder?.call(
                              context,
                              widget.scene,
                              _previewAutoplay,
                            ) ??
                            _SceneInfoPreviewPlayer(
                              key: ValueKey(
                                'scene_info_preview_${widget.scene.id}_$previewUrl',
                              ),
                              previewUrl: previewUrl!,
                              autoplay: _previewAutoplay,
                            ),
                      ),
              ),
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
    super.key,
  });

  final String previewUrl;
  final bool autoplay;

  @override
  ConsumerState<_SceneInfoPreviewPlayer> createState() =>
      _SceneInfoPreviewPlayerState();
}

class _SceneInfoPreviewPlayerState
    extends ConsumerState<_SceneInfoPreviewPlayer> {
  Player? _player;
  VideoController? _controller;
  StreamSubscription<Object>? _errorSubscription;
  bool _initializing = true;
  String? _error;

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

  Future<void> _initialize() async {
    final player = Player();
    final controller = VideoController(player);
    _player = player;
    _controller = controller;

    _errorSubscription = player.stream.error.listen((error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
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
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
  }

  Future<void> _disposePlayer() async {
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
        if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
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
