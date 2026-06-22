import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/criterion.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/domain/entities/scene_filter.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/scene_list_provider.dart';

part 'group_media_provider.g.dart';

final groupMediaProvider = FutureProvider.family<List<Scene>, String>((
  ref,
  groupId,
) async {
  ref.keepAlive();
  final repository = ref.read(sceneRepositoryProvider);

  return repository.findScenes(
    page: 1,
    perPage: 24,
    sceneFilter: SceneFilter(
      groups: HierarchicalMultiCriterion(value: [groupId]),
    ),
  );
});

@riverpod
class GroupMediaGrid extends _$GroupMediaGrid {
  static const int _perPage = 30;
  static const _filterKind = EntityMediaFilterKind.group;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _groupId;

  @override
  FutureOr<List<Scene>> build(String groupId) async {
    ref.keepAlive();
    _groupId = groupId;
    _currentPage = 1;
    _hasMore = true;
    final query = ref.watch(entityMediaSearchQueryProvider(_filterKind));
    final sortConfig = ref.watch(entityMediaSortProvider(_filterKind));
    final baseFilter = ref.watch(entityMediaFilterStateProvider(_filterKind));
    final filter = sceneFilterForEntityMedia(
      filter: baseFilter,
      kind: _filterKind,
      entityId: groupId,
    );
    final organizedFilter = ref.watch(
      entityMediaOrganizedOnlyProvider(_filterKind),
    );
    final repository = ref.read(sceneRepositoryProvider);
    var effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort =
          'random_${ref.watch(entityMediaRandomSeedProvider(_filterKind))}';
    }

    return repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      organized: organizedFilter.toBool() ?? filter.organized,
      sceneFilter: filter,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _groupId == null) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(sceneRepositoryProvider);
      final query = ref.read(entityMediaSearchQueryProvider(_filterKind));
      final sortConfig = ref.read(entityMediaSortProvider(_filterKind));
      final baseFilter = ref.read(entityMediaFilterStateProvider(_filterKind));
      final filter = sceneFilterForEntityMedia(
        filter: baseFilter,
        kind: _filterKind,
        entityId: _groupId!,
      );
      final organizedFilter = ref.read(
        entityMediaOrganizedOnlyProvider(_filterKind),
      );
      var effectiveSort = sortConfig.sort;
      if (effectiveSort == 'random') {
        effectiveSort =
            'random_${ref.read(entityMediaRandomSeedProvider(_filterKind))}';
      }

      final nextPage = _currentPage + 1;
      final nextItems = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        organized: organizedFilter.toBool() ?? filter.organized,
        sceneFilter: filter,
      );

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...(state.value ?? <Scene>[]), ...nextItems]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
