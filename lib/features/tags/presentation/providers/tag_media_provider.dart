import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';

part 'tag_media_provider.g.dart';

@riverpod
FutureOr<List<Scene>> tagMedia(Ref ref, String tagId) async {
  ref.keepAlive();
  final repository = ref.read(sceneRepositoryProvider);

  return repository.findScenes(
    page: 1,
    perPage: 24,
    tagId: tagId,
  );
}

@riverpod
class TagMediaGrid extends _$TagMediaGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _tagId;

  @override
  FutureOr<List<Scene>> build(String tagId) async {
    ref.keepAlive();
    _tagId = tagId;
    _currentPage = 1;
    _hasMore = true;
    final repository = ref.read(sceneRepositoryProvider);
    return repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      tagId: tagId,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _tagId == null) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(sceneRepositoryProvider);
      final nextPage = _currentPage + 1;
      final nextItems = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        tagId: _tagId,
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
