import 'dart:async';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import '../../domain/entities/image.dart' as entity;
import '../providers/image_list_provider.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/utils/responsive.dart';

enum _SlideshowDirection { forward, backward }

enum _RatingTarget { image, gallery }

class ImageFullscreenPage extends ConsumerStatefulWidget {
  final String imageId;

  const ImageFullscreenPage({required this.imageId, super.key});

  @override
  ConsumerState<ImageFullscreenPage> createState() =>
      _ImageFullscreenPageState();
}

class _ImageFullscreenPageState extends ConsumerState<ImageFullscreenPage> {
  static const _ratingTargetGalleryKey = 'image_rating_target_gallery';
  static const _imageFullscreenVerticalSwipeKey =
      'image_fullscreen_vertical_swipe';

  late ExtendedPageController _pageController;
  Timer? _slideshowTimer;
  int _currentIndex = 0;
  bool _initialPageSet = false;
  bool _showOverlays = true;
  bool _isSlideshowPlaying = false;
  Duration _slideshowInterval = const Duration(seconds: 3);
  Duration _slideshowTransition = const Duration(milliseconds: 380);
  bool _slideshowLoop = true;
  _SlideshowDirection _slideshowDirection = _SlideshowDirection.forward;
  Offset? _pointerDownPosition;
  DateTime? _pointerDownTime;
  bool _ignoreNextOverlayToggle = false;

  @override
  void initState() {
    super.initState();
    _pageController = ExtendedPageController();
  }

  @override
  void dispose() {
    _stopSlideshow();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlays() {
    setState(() => _showOverlays = !_showOverlays);
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _pointerDownTime = DateTime.now();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_ignoreNextOverlayToggle) {
      _ignoreNextOverlayToggle = false;
      return;
    }

    final downPos = _pointerDownPosition;
    final downTime = _pointerDownTime;
    _pointerDownPosition = null;
    _pointerDownTime = null;

    if (downPos == null || downTime == null) return;

    final movedDistance = (event.position - downPos).distance;
    final elapsed = DateTime.now().difference(downTime);

    // Use pointer events instead of a GestureDetector so swipe gestures
    // are not forced to compete with an extra tap recognizer.
    if (elapsed <= const Duration(milliseconds: 220) && movedDistance < 10) {
      _toggleOverlays();
    }
  }

  void _onOverlayPointerDown(PointerDownEvent event) {
    // Mark the next pointer-up as consumed so overlay control taps do not
    // toggle UI chrome visibility.
    _ignoreNextOverlayToggle = true;
    _pointerDownPosition = null;
    _pointerDownTime = null;
  }

  void _handlePageChanged(
    int index,
    List<entity.Image> items,
    Map<String, String> headers,
  ) {
    setState(() => _currentIndex = index);
    _prefetchAdjacent(items, index, headers);

    if (index >= items.length - 5) {
      ref.read(imageListProvider.notifier).fetchNextPage();
    }
  }

  void _stopSlideshow() {
    _slideshowTimer?.cancel();
    _slideshowTimer = null;
    if (_isSlideshowPlaying && mounted) {
      setState(() => _isSlideshowPlaying = false);
    }
  }

  void _advanceSlideshow(int itemCount) {
    if (!_isSlideshowPlaying || !_pageController.hasClients || !mounted) return;
    if (itemCount <= 1) {
      _stopSlideshow();
      return;
    }

    final delta = _slideshowDirection == _SlideshowDirection.forward ? 1 : -1;
    var targetIndex = _currentIndex + delta;

    if (targetIndex < 0 || targetIndex >= itemCount) {
      if (!_slideshowLoop) {
        _stopSlideshow();
        return;
      }
      targetIndex = _slideshowDirection == _SlideshowDirection.forward
          ? 0
          : itemCount - 1;
    }

    _pageController.animateToPage(
      targetIndex,
      duration: _slideshowTransition,
      curve: Curves.easeInOutCubic,
    );
  }

  void _startSlideshow(int itemCount) {
    if (itemCount <= 1) return;

    _slideshowTimer?.cancel();
    setState(() => _isSlideshowPlaying = true);
    _slideshowTimer = Timer.periodic(_slideshowInterval, (_) {
      _advanceSlideshow(itemCount);
    });
  }

  Future<void> _goToPreviousImage() async {
    // Keep manual navigation behavior aligned with slideshow transition.
    if (!_pageController.hasClients || _currentIndex <= 0) return;
    await _pageController.animateToPage(
      _currentIndex - 1,
      duration: _slideshowTransition,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _goToNextImage(int itemCount) async {
    // Keep manual navigation behavior aligned with slideshow transition.
    if (!_pageController.hasClients || itemCount <= 0) return;
    if (_currentIndex >= itemCount - 1) return;
    await _pageController.animateToPage(
      _currentIndex + 1,
      duration: _slideshowTransition,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _toggleSlideshow(int itemCount) async {
    if (_isSlideshowPlaying) {
      _stopSlideshow();
      return;
    }

    if (itemCount <= 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 2 images for slideshow.')),
      );
      return;
    }

    double intervalSeconds = _slideshowInterval.inMilliseconds / 1000;
    double transitionMs = _slideshowTransition.inMilliseconds.toDouble();
    bool loop = _slideshowLoop;
    _SlideshowDirection direction = _slideshowDirection;

    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Start Slideshow'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interval: ${intervalSeconds.toStringAsFixed(1)}s'),
                    Slider(
                      value: intervalSeconds,
                      min: 1,
                      max: 15,
                      divisions: 28,
                      label: '${intervalSeconds.toStringAsFixed(1)}s',
                      onChanged: (v) {
                        setDialogState(() => intervalSeconds = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('Transition: ${transitionMs.round()}ms'),
                    Slider(
                      value: transitionMs,
                      min: 120,
                      max: 1400,
                      divisions: 32,
                      label: '${transitionMs.round()}ms',
                      onChanged: (v) {
                        setDialogState(() => transitionMs = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_SlideshowDirection>(
                      segments: const [
                        ButtonSegment<_SlideshowDirection>(
                          value: _SlideshowDirection.forward,
                          label: Text('Forward'),
                          icon: Icon(Icons.arrow_downward_rounded),
                        ),
                        ButtonSegment<_SlideshowDirection>(
                          value: _SlideshowDirection.backward,
                          label: Text('Backward'),
                          icon: Icon(Icons.arrow_upward_rounded),
                        ),
                      ],
                      selected: <_SlideshowDirection>{direction},
                      onSelectionChanged: (selection) {
                        setDialogState(() => direction = selection.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Loop slideshow'),
                      value: loop,
                      onChanged: (v) {
                        setDialogState(() => loop = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldStart != true || !mounted) return;

    setState(() {
      _slideshowInterval = Duration(
        milliseconds: (intervalSeconds * 1000).round(),
      );
      _slideshowTransition = Duration(milliseconds: transitionMs.round());
      _slideshowLoop = loop;
      _slideshowDirection = direction;
    });
    _startSlideshow(itemCount);
  }

  Future<void> _showRatingDialog(entity.Image image) async {
    // Rating dialog supports both image-level and gallery-level rating updates.
    // The last chosen target is persisted so repeated rating workflows are fast.
    final prefs = ref.read(sharedPreferencesProvider);
    final galleryId = ref.read(imageFilterStateProvider).galleryId;
    final canRateGallery = galleryId != null;

    var target =
        (prefs.getBool(_ratingTargetGalleryKey) ?? false) && canRateGallery
        ? _RatingTarget.gallery
        : _RatingTarget.image;
    var rating = image.rating100 ?? 0;

    if (target == _RatingTarget.gallery && galleryId != null) {
      try {
        final gallery = await ref
            .read(galleryRepositoryProvider)
            .getGalleryById(galleryId, refresh: true);
        rating = gallery.rating100 ?? 0;
      } catch (_) {
        rating = 0;
      }
    }

    if (!mounted) return;

    final result = await showDialog<(_RatingTarget, int)>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Rate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<_RatingTarget>(
                    showSelectedIcon: false,
                    segments: [
                      const ButtonSegment<_RatingTarget>(
                        value: _RatingTarget.image,
                        icon: Icon(Icons.image_outlined),
                        label: Text('Image'),
                      ),
                      ButtonSegment<_RatingTarget>(
                        value: _RatingTarget.gallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                        enabled: canRateGallery,
                      ),
                    ],
                    selected: <_RatingTarget>{target},
                    onSelectionChanged: (selection) async {
                      final nextTarget = selection.first;
                      var nextRating = image.rating100 ?? 0;

                      if (nextTarget == _RatingTarget.gallery &&
                          galleryId != null) {
                        try {
                          final gallery = await ref
                              .read(galleryRepositoryProvider)
                              .getGalleryById(galleryId, refresh: true);
                          nextRating = gallery.rating100 ?? 0;
                        } catch (_) {
                          nextRating = 0;
                        }
                      }

                      if (!dialogContext.mounted) return;
                      setDialogState(() {
                        target = nextTarget;
                        rating = nextRating;
                      });
                    },
                  ),
                  if (!canRateGallery) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Gallery rating is only available when browsing a gallery.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Rating: ${(rating / 20).toStringAsFixed(1)} / 5'),
                  Slider(
                    value: rating.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: (rating / 20).toStringAsFixed(1),
                    onChanged: (value) {
                      setDialogState(() => rating = value.round());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop((target, rating));
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    final selectedTarget = result.$1;
    final selectedRating = result.$2;
    await prefs.setBool(
      _ratingTargetGalleryKey,
      selectedTarget == _RatingTarget.gallery,
    );

    try {
      if (selectedTarget == _RatingTarget.image) {
        await ref
            .read(imageRepositoryProvider)
            .updateImageRating(image.id, selectedRating);
        ref
            .read(imageListProvider.notifier)
            .updateImageInList(image.copyWith(rating100: selectedRating));
      } else {
        if (galleryId == null) {
          throw Exception('No gallery context available.');
        }
        await ref
            .read(galleryRepositoryProvider)
            .updateGalleryRating(galleryId, selectedRating);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedTarget == _RatingTarget.image
                ? 'Image rating updated.'
                : 'Gallery rating updated.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update rating: $e')));
    }
  }

  void _prefetchAdjacent(
    List<entity.Image> items,
    int index,
    Map<String, String> headers,
  ) {
    // Prefetch next 2 and previous 1
    for (var i = 1; i <= 2; i++) {
      if (index + i < items.length) {
        final url =
            items[index + i].paths.image ?? items[index + i].paths.preview;
        if (url != null) {
          precacheImage(
            ExtendedNetworkImageProvider(url, headers: headers, cache: true),
            context,
          );
        }
      }
    }
    if (index - 1 >= 0) {
      final url =
          items[index - 1].paths.image ?? items[index - 1].paths.preview;
      if (url != null) {
        precacheImage(
          ExtendedNetworkImageProvider(url, headers: headers, cache: true),
          context,
        );
      }
    }
  }

  String _getDisplayTitle(entity.Image? image) {
    if (image == null) return '';
    if (image.title != null && image.title!.trim().isNotEmpty) {
      return image.title!.trim();
    }
    if (image.files.isNotEmpty) {
      final path = image.files.first.path;
      if (path.isNotEmpty) {
        final segments = path.replaceAll('\\', '/').split('/');
        return segments.lastWhere((s) => s.isNotEmpty, orElse: () => path);
      }
    }
    return 'Untitled';
  }

  Widget _buildOverlayHeader(
    BuildContext context,
    entity.Image? currentImage,
    String displayTitle,
    int loadedItemCount,
    int totalItemCount,
    double maxOverlayWidth,
    double horizontalPadding,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final rating100 = currentImage?.rating100;
    final hasRating = rating100 != null && rating100 > 0;
    final ratingLabel = hasRating ? (rating100 / 20).toStringAsFixed(1) : '';

    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onOverlayPointerDown,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxOverlayWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.78),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => context.pop(),
                            tooltip: 'Back',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_currentIndex + 1} / $totalItemCount',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (hasRating)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: colorScheme.tertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ratingLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          if (hasRating) const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.star_rate_rounded),
                            onPressed: currentImage == null
                                ? null
                                : () => _showRatingDialog(currentImage),
                            tooltip: 'Rate',
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: Icon(
                              _isSlideshowPlaying
                                  ? Icons.stop_rounded
                                  : Icons.slideshow_rounded,
                            ),
                            onPressed: () => _toggleSlideshow(loadedItemCount),
                            tooltip: _isSlideshowPlaying
                                ? 'Stop slideshow'
                                : 'Start slideshow',
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
      ),
    );
  }

  Widget _buildOverlayFooter(
    BuildContext context,
    int loadedItemCount,
    int totalItemCount,
    double maxOverlayWidth,
    double horizontalPadding,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = totalItemCount > 1
        ? _currentIndex / (totalItemCount - 1)
        : 0.0;
    final canGoPrevious = _currentIndex > 0;
    final canGoNext = _currentIndex < loadedItemCount - 1;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 8,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onOverlayPointerDown,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxOverlayWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.72,
                        ),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.chevron_left_rounded),
                            tooltip: 'Previous image',
                            onPressed: canGoPrevious
                                ? _goToPreviousImage
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.chevron_right_rounded),
                            tooltip: 'Next image',
                            onPressed: canGoNext
                                ? () => _goToNextImage(loadedItemCount)
                                : null,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imageListProvider);
    final headers = ref.watch(mediaHeadersProvider);
    final galleryId = ref.watch(
      imageFilterStateProvider.select((value) => value.galleryId),
    );
    final galleryDetailsAsync = galleryId == null
        ? null
        : ref.watch(galleryDetailsProvider(galleryId));
    final prefs = ref.watch(sharedPreferencesProvider);
    final useVerticalSwipe =
        prefs.getBool(_imageFullscreenVerticalSwipeKey) ?? true;

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (items) {
          if (!_initialPageSet) {
            _currentIndex = items.indexWhere((i) => i.id == widget.imageId);
            if (_currentIndex == -1) _currentIndex = 0;
            _pageController.dispose();
            _pageController = ExtendedPageController(
              initialPage: _currentIndex,
            );
            _initialPageSet = true;

            // Prefetch initial adjacent images
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _prefetchAdjacent(items, _currentIndex, headers);
            });
          }

          final currentImage = items.isNotEmpty ? items[_currentIndex] : null;
          final displayTitle = _getDisplayTitle(currentImage);
          final totalItemCount =
              galleryDetailsAsync?.maybeWhen(
                data: (gallery) => gallery.imageCount ?? items.length,
                orElse: () => items.length,
              ) ??
              items.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideLayout =
                  constraints.maxWidth >= Responsive.tabletBreakpoint;
              final scrollDirection = useVerticalSwipe
                  ? Axis.vertical
                  : Axis.horizontal;
              final maxOverlayWidth = isWideLayout
                  ? 720.0
                  : constraints.maxWidth;
              final horizontalPadding = isWideLayout ? 24.0 : 8.0;

              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                child: Stack(
                  children: [
                    ExtendedImageGesturePageView.builder(
                      controller: _pageController,
                      scrollDirection: scrollDirection,
                      itemCount: items.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        _handlePageChanged(index, items, headers);
                      },
                      itemBuilder: (context, index) {
                        final image = items[index];
                        final imageUrl =
                            image.paths.image ?? image.paths.preview;

                        if (imageUrl == null || imageUrl.isEmpty) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 64,
                            ),
                          );
                        }

                        return RepaintBoundary(
                          child: ExtendedImage.network(
                            imageUrl,
                            headers: headers,
                            fit: BoxFit.contain,
                            mode: ExtendedImageMode.gesture,
                            cache: true,
                            initGestureConfigHandler: (state) {
                              return GestureConfig(
                                minScale: 0.9,
                                animationMinScale: 0.7,
                                maxScale: 5.0,
                                animationMaxScale: 6.0,
                                speed: 1.0,
                                inertialSpeed: 100.0,
                                initialScale: 1.0,
                                inPageView: true,
                                initialAlignment: InitialAlignment.center,
                              );
                            },
                            onDoubleTap: (ExtendedImageGestureState state) {
                              final pointerDownPosition =
                                  state.pointerDownPosition;
                              final begin = state.gestureDetails!.totalScale;
                              final end = begin == 1.0 ? 3.0 : 1.0;

                              state.handleDoubleTap(
                                scale: end,
                                doubleTapPosition: pointerDownPosition,
                              );
                            },
                            loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                case LoadState.completed:
                                  return state.completedWidget;
                                case LoadState.failed:
                                  return GestureDetector(
                                    onTap: () => state.reLoadImage(),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: Colors.white54,
                                            size: 64,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Failed to load. Tap to retry.',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                              }
                            },
                          ),
                        );
                      },
                    ),
                    if (_showOverlays) ...[
                      _buildOverlayHeader(
                        context,
                        currentImage,
                        displayTitle,
                        items.length,
                        totalItemCount,
                        maxOverlayWidth,
                        horizontalPadding,
                      ),
                      _buildOverlayFooter(
                        context,
                        items.length,
                        totalItemCount,
                        maxOverlayWidth,
                        horizontalPadding,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
