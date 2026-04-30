import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';

part 'performer_media_provider.g.dart';

@riverpod
FutureOr<List<Scene>> performerMedia(
  Ref ref,
  String performerId,
) async {
  ref.keepAlive();
  final repository = ref.read(sceneRepositoryProvider);

  return repository.findScenes(
    page: 1,
    perPage: 24,
    performerId: performerId,
  );
}

@riverpod
class PerformerMediaGrid extends _$PerformerMediaGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _performerId;

  @override
  FutureOr<List<Scene>> build(String performerId) async {
    ref.keepAlive();
    _performerId = performerId;
    _currentPage = 1;
    _hasMore = true;
    final repository = ref.read(sceneRepositoryProvider);
    return repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      performerId: performerId,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _performerId == null) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(sceneRepositoryProvider);
      final nextPage = _currentPage + 1;
      final nextItems = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        performerId: _performerId,
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
