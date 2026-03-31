import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/image_list_provider.dart';
import '../../domain/entities/image.dart' as entity;

class ImageFullscreenPage extends ConsumerStatefulWidget {
  final String imageId;
  const ImageFullscreenPage({required this.imageId, super.key});

  @override
  ConsumerState<ImageFullscreenPage> createState() =>
      _ImageFullscreenPageState();
}

class _ImageFullscreenPageState extends ConsumerState<ImageFullscreenPage> {
  late ExtendedPageController _pageController;
  int _currentIndex = -1;
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
    setState(() {
      _showOverlays = !_showOverlays;
    });
  }

  void _showInfo(BuildContext context, entity.Image image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                image.title?.isNotEmpty == true
                    ? image.title!
                    : (image.files.isNotEmpty
                        ? image.files.first.path
                        : 'Untitled Image'),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (image.date != null) Text('Date: ${image.date}'),
              if (image.rating100 != null)
                Text(
                  'Rating: ${(image.rating100! / 20).toStringAsFixed(1)} Stars',
                ),
              const SizedBox(height: 16),
              if (image.urls.isNotEmpty) ...[
                Text('URLs:', style: context.textTheme.labelLarge),
                ...image.urls.map(
                  (url) => Text(url, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imageListProvider);
    final headers = ref.watch(mediaHeadersProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (items) {
          if (_currentIndex == -1) {
            _currentIndex = items.indexWhere((i) => i.id == widget.imageId);
            if (_currentIndex == -1) _currentIndex = 0;
            _pageController = ExtendedPageController(initialPage: _currentIndex);
          }

          return Stack(
            children: [
              ExtendedImageGesturePageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  // Load more if near end
                  if (index >= items.length - 2) {
                    ref.read(imageListProvider.notifier).fetchNextPage();
                  }
                },
                itemBuilder: (context, index) {
                  final image = items[index];
                  final imageUrl = image.paths.image ?? image.paths.preview;

                  if (imageUrl == null || imageUrl.isEmpty) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                    );
                  }

                  return ExtendedImage.network(
                    imageUrl,
                    headers: headers,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    cache: true,
                    // Use the custom cache manager from StashImage if possible, 
                    // though extended_image uses its own internal cache.
                    // We can also leverage the pre-fetching logic.
                    initGestureConfigHandler: (state) {
                      return GestureConfig(
                        minScale: 0.9,
                        animationMinScale: 0.7,
                        maxScale: 4.0,
                        animationMaxScale: 4.5,
                        speed: 1.0,
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
                          return const Center(child: CircularProgressIndicator());
                        case LoadState.completed:
                          return null; // default image
                        case LoadState.failed:
                          return GestureDetector(
                            onTap: () => state.reLoadImage(),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white54, size: 64),
                                  SizedBox(height: 16),
                                  Text('Failed to load. Tap to retry.', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                          );
                      }
                    },
                  );
                },
              ),
              // Interaction layer to toggle overlays
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleOverlays,
              ),
              // Overlays
              if (_showOverlays) ...[
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(backgroundColor: Colors.black26),
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
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
                ),
                Positioned(
                  bottom: MediaQuery.paddingOf(context).bottom + 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () => _showInfo(context, items[_currentIndex]),
                    style: IconButton.styleFrom(backgroundColor: Colors.black26),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
