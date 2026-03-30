import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
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
  late PageController _pageController;
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                    : 'Untitled Image',
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (items) {
          if (_currentIndex == -1) {
            _currentIndex = items.indexWhere((i) => i.id == widget.imageId);
            if (_currentIndex == -1) _currentIndex = 0;
            _pageController = PageController(initialPage: _currentIndex);
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  // Pre-fetch adjacent images
                  if (index + 1 < items.length) {
                    final next = items[index + 1];
                    precacheImage(
                      NetworkImage(
                        next.paths.image ?? next.paths.preview ?? '',
                      ),
                      context,
                    );
                  }
                  if (index - 1 >= 0) {
                    final prev = items[index - 1];
                    precacheImage(
                      NetworkImage(
                        prev.paths.image ?? prev.paths.preview ?? '',
                      ),
                      context,
                    );
                  }
                  // Load more if near end
                  if (index >= items.length - 2) {
                    ref.read(imageListProvider.notifier).fetchNextPage();
                  }
                },
                itemBuilder: (context, index) {
                  final image = items[index];
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: StashImage(
                        imageUrl: image.paths.image ?? image.paths.preview,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                },
              ),
              // Overlay
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
