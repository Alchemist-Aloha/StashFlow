import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/image.dart' as entity;
import '../providers/image_list_provider.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';

class ImageFullscreenPage extends ConsumerStatefulWidget {
  final String imageId;

  const ImageFullscreenPage({required this.imageId, super.key});

  @override
  ConsumerState<ImageFullscreenPage> createState() =>
      _ImageFullscreenPageState();
}

class _ImageFullscreenPageState extends ConsumerState<ImageFullscreenPage> {
  late ExtendedPageController _pageController;
  int _currentIndex = 0;
  bool _initialPageSet = false;
  bool _showOverlays = true;

  @override
  void initState() {
    super.initState();
    _pageController = ExtendedPageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlays() {
    setState(() => _showOverlays = !_showOverlays);
  }

  void _prefetchAdjacent(
    List<entity.Image> items,
    int index,
    Map<String, String> headers,
  ) {
    // Prefetch next 2 and previous 1
    for (var i = 1; i <= 2; i++) {
      if (index + i < items.length) {
        final url = items[index + i].paths.image ?? items[index + i].paths.preview;
        if (url != null) {
          precacheImage(
            ExtendedNetworkImageProvider(url, headers: headers, cache: true),
            context,
          );
        }
      }
    }
    if (index - 1 >= 0) {
      final url = items[index - 1].paths.image ?? items[index - 1].paths.preview;
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

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imageListProvider);
    final headers = ref.watch(mediaHeadersProvider);

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

          return Stack(
            children: [
              ExtendedImageGesturePageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: items.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _prefetchAdjacent(items, index, headers);

                  // Load more if near end
                  if (index >= items.length - 5) {
                    ref.read(imageListProvider.notifier).fetchNextPage();
                  }
                },
                itemBuilder: (context, index) {
                  final image = items[index];
                  final imageUrl = image.paths.image ?? image.paths.preview;

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
                        final pointerDownPosition = state.pointerDownPosition;
                        final begin = state.gestureDetails!.totalScale;
                        double end;

                        // Double tap to zoom
                        if (begin == 1.0) {
                          end = 3.0;
                        } else {
                          end = 1.0;
                        }

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
                            // Wrap the completed image in a detector for overlay toggling
                            // This ensures it doesn't block swipes because it's part of the page item
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _toggleOverlays,
                              child: state.completedWidget,
                            );
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
                                      style: TextStyle(color: Colors.white70),
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
              // Overlays
              if (_showOverlays) ...[
                // Header with Back button, Title, and Index
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top + 8,
                      bottom: 16,
                      left: 8,
                      right: 16,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
