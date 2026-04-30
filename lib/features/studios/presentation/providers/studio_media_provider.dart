import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';

part 'studio_media_provider.g.dart';

@riverpod
FutureOr<List<Scene>> studioMedia(Ref ref, String studioId) async {
  ref.keepAlive();
  final repository = ref.read(sceneRepositoryProvider);

  return repository.findScenes(
    page: 1,
    perPage: 24,
    studioId: studioId,
  );
}

@riverpod
class StudioMediaGrid extends _$StudioMediaGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _studioId;

  @override
  FutureOr<List<Scene>> build(String studioId) async {
    ref.keepAlive();
    _studioId = studioId;
    _currentPage = 1;
    _hasMore = true;
    final repository = ref.read(sceneRepositoryProvider);
    return repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      studioId: studioId,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _studioId == null) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(sceneRepositoryProvider);
      final nextPage = _currentPage + 1;
      final nextItems = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        studioId: _studioId,
      );

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([
          ...(state.value ?? <Scene>[]),
          ...nextItems,
        ]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
