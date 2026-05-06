import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/providers/keybinds_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../galleries/presentation/providers/gallery_details_provider.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../domain/entities/image.dart' as entity;
import '../providers/image_list_provider.dart';

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
    _enterFullScreen();
  }

  @override
  void dispose() {
    _stopSlideshow();
    _pageController.dispose();
    _exitFullScreen();
    super.dispose();
  }

  Future<void> _enterFullScreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        await windowManager.setFullScreen(true);
      }
    } catch (_) {}
  }

  void _exitFullScreen() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      unawaited(windowManager.setFullScreen(false));
    }
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

  Future<void> _saveImageToGallery(entity.Image? image) async {
    if (image == null) return;

    final imageUrl = image.paths.image ?? image.paths.preview;
    if (imageUrl == null || imageUrl.isEmpty) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving to gallery...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final headers = ref.read(mediaHeadersProvider);
      debugPrint('Saving image from URL: $imageUrl');
      final response = await Dio().get<List<int>>(
        imageUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Failed to download image bytes: empty response');
      }
      final contentType = response.headers.value('content-type');
      debugPrint('Downloaded ${bytes.length} bytes, Content-Type: $contentType');

      // Determine extension from Content-Type
      String extension = 'jpg';
      if (contentType != null) {
        if (contentType.contains('webp')) {
          extension = 'webp';
        } else if (contentType.contains('png')) {
          extension = 'png';
        } else if (contentType.contains('gif')) {
          extension = 'gif';
        } else if (contentType.contains('jpeg') || contentType.contains('jpg')) {
          extension = 'jpg';
        }
      }

      // Check for access
      bool hasAccess = await Gal.hasAccess(toAlbum: true);
      debugPrint('Gal.hasAccess(toAlbum: true): $hasAccess');
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess(toAlbum: true);
        debugPrint('Gal.requestAccess(toAlbum: true) result: $hasAccess');
      }

      if (!hasAccess) {
        throw Exception('Gallery access denied');
      }

      final name = 'stash_${image.id}.$extension';
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$name';
      final file = File(tempPath);
      await file.writeAsBytes(bytes);

      try {
        debugPrint('Saving to gallery via putImage: $tempPath');
        await Gal.putImage(tempPath, album: 'StashFlow');
      } finally {
        if (await file.exists()) {
          await file.delete();
          debugPrint('Cleaned up temporary file: $tempPath');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to StashFlow album'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => Gal.open(),
            ),
          ),
        );
      }
    } on GalException catch (e) {
      final message = switch (e.type) {
        GalExceptionType.accessDenied => 'Permission to access the gallery is denied.',
        GalExceptionType.notEnoughSpace => 'Not enough space for storage.',
        GalExceptionType.notSupportedFormat => 'Unsupported file format.',
        GalExceptionType.unexpected => 'An unexpected error has occurred.',
      };
      debugPrint('GalException final failure: ${e.type.name}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery Error: $message')),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleSlideshow(int itemCount) async {
    if (_isSlideshowPlaying) {
      _stopSlideshow();
      return;
    }

    if (itemCount <= 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.images_slideshow_need_two)),
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
              title: Text(context.l10n.images_slideshow_start_title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.images_slideshow_interval(intervalSeconds),
                    ),
                    Slider(
                      value: intervalSeconds,
                      min: 1,
                      max: 15,
                      divisions: 28,
                      label: context.l10n.images_slideshow_interval(
                        intervalSeconds,
                      ),
                      onChanged: (v) {
                        setDialogState(() => intervalSeconds = v);
                      },
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    Text(
                      context.l10n.images_slideshow_transition_ms(
                        transitionMs.round(),
                      ),
                    ),
                    Slider(
                      value: transitionMs,
                      min: 120,
                      max: 1400,
                      divisions: 32,
                      label: context.l10n.images_slideshow_transition_ms(
                        transitionMs.round(),
                      ),
                      onChanged: (v) {
                        setDialogState(() => transitionMs = v);
                      },
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SegmentedButton<_SlideshowDirection>(
                      segments: [
                        ButtonSegment<_SlideshowDirection>(
                          value: _SlideshowDirection.forward,
                          label: Text(context.l10n.common_forward),
                          icon: Icon(Icons.arrow_downward_rounded),
                        ),
                        ButtonSegment<_SlideshowDirection>(
                          value: _SlideshowDirection.backward,
                          label: Text(context.l10n.common_backward),
                          icon: Icon(Icons.arrow_upward_rounded),
                        ),
                      ],
                      selected: <_SlideshowDirection>{direction},
                      onSelectionChanged: (selection) {
                        setDialogState(() => direction = selection.first);
                      },
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.images_slideshow_loop_title),
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
                  child: Text(context.l10n.common_cancel),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(context.l10n.common_start),
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
              title: Text(context.l10n.common_rate),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<_RatingTarget>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment<_RatingTarget>(
                        value: _RatingTarget.image,
                        icon: Icon(Icons.image_outlined),
                        label: Text(context.l10n.common_image),
                      ),
                      ButtonSegment<_RatingTarget>(
                        value: _RatingTarget.gallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(context.l10n.common_gallery),
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
                    SizedBox(height: context.dimensions.spacingSmall),
                    Text(
                      context.l10n.images_gallery_rating_unavailable,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  SizedBox(height: context.dimensions.spacingMedium),
                  Text(
                    context.l10n.images_rating(
                      (rating / 20).toStringAsFixed(1),
                    ),
                  ),
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
                  child: Text(context.l10n.common_cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop((target, rating));
                  },
                  child: Text(context.l10n.common_apply),
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
                ? context.l10n.image_rating_updated
                : context.l10n.gallery_rating_updated,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.details_failed_update_rating(e.toString()),
          ),
        ),
      );
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
      top: context.dimensions.spacingSmall,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dimensions.spacingSmall + 4,
                        vertical: context.dimensions.spacingSmall + 2,
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
                            tooltip: context.l10n.common_back,
                          ),
                          SizedBox(width: context.dimensions.spacingSmall + 2),
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
                                SizedBox(height: context.dimensions.spacingSmall / 4),
                                Text(
                                  '${_currentIndex + 1} / $totalItemCount',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: context.dimensions.spacingSmall),
                          if (hasRating)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.dimensions.spacingSmall + 2,
                                vertical: context.dimensions.spacingSmall - 2,
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
                                  SizedBox(width: context.dimensions.spacingSmall / 2),
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
                          if (hasRating) SizedBox(width: context.dimensions.spacingSmall),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.star_rate_rounded),
                            onPressed: currentImage == null
                                ? null
                                : () => _showRatingDialog(currentImage),
                            tooltip: context.l10n.common_rate,
                          ),
                          SizedBox(width: context.dimensions.spacingSmall),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.download_rounded),
                            onPressed: currentImage == null
                                ? null
                                : () => _saveImageToGallery(currentImage),
                            tooltip: context.l10n.common_download,
                          ),
                          SizedBox(width: context.dimensions.spacingSmall),
                          IconButton.filledTonal(
                            icon: Icon(
                              _isSlideshowPlaying
                                  ? Icons.stop_rounded
                                  : Icons.slideshow_rounded,
                            ),
                            onPressed: () => _toggleSlideshow(loadedItemCount),
                            tooltip: _isSlideshowPlaying
                                ? context.l10n.common_pause
                                : context.l10n.images_slideshow_start_title,
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
      bottom: context.dimensions.spacingSmall,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dimensions.spacingSmall + 6,
                        vertical: context.dimensions.spacingSmall + 4,
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
                            tooltip: context.l10n.common_previous,
                            onPressed: canGoPrevious
                                ? _goToPreviousImage
                                : null,
                          ),
                          SizedBox(width: context.dimensions.spacingSmall + 2),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          SizedBox(width: context.dimensions.spacingSmall + 2),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.chevron_right_rounded),
                            tooltip: context.l10n.common_next,
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
    final keybinds = ref.watch(keybindsProvider);

    return imagesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            context.l10n.common_error(e.toString()),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (items) {
        final Map<ShortcutActivator, VoidCallback> bindings = {};
        for (var entry in keybinds.binds.entries) {
          final action = entry.key;
          final bind = entry.value;

          VoidCallback? callback;
          switch (action) {
            case KeybindAction.previousImage:
              callback = _goToPreviousImage;
              break;
            case KeybindAction.nextImage:
              callback = () => _goToNextImage(items.length);
              break;
            case KeybindAction.closePlayer:
              callback = () => context.pop();
              break;
            default:
              break;
          }

          if (callback != null) {
            bindings[bind.toActivator()] = callback;
          }
        }

        if (!_initialPageSet && items.isNotEmpty) {
          _currentIndex = items.indexWhere((i) => i.id == widget.imageId);
          if (_currentIndex == -1) _currentIndex = 0;
          _pageController.dispose();
          _pageController = ExtendedPageController(initialPage: _currentIndex);
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

        return Scaffold(
          backgroundColor: Colors.black,
          body: CallbackShortcuts(
            bindings: bindings,
            child: Focus(
              autofocus: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideLayout =
                      constraints.maxWidth >= Responsive.tabletBreakpoint;
                  final scrollDirection = useVerticalSwipe
                      ? Axis.vertical
                      : Axis.horizontal;
                  final maxOverlayWidth = isWideLayout
                      ? 720.0
                      : constraints.maxWidth;
                  final horizontalPadding = isWideLayout
                      ? context.dimensions.spacingLarge
                      : context.dimensions.spacingSmall;

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
                                  final begin =
                                      state.gestureDetails!.totalScale;
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
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                color: Colors.white54,
                                                size: 64 * context.dimensions.fontSizeFactor,
                                              ),
                                              SizedBox(height: context.dimensions.spacingMedium),
                                              Text(
                                                'Failed to load. Tap to retry.',
                                                style: const TextStyle(
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
              ),
            ),
          ),
        );
      },
    );
  }
}
