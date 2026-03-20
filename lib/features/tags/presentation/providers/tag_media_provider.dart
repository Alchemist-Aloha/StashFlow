import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../scenes/data/graphql/scenes.graphql.dart';
import '../../../scenes/domain/entities/scene_title_utils.dart';

part 'tag_media_provider.g.dart';

class TagMediaItem {
  const TagMediaItem({
    required this.sceneId,
    required this.title,
    required this.thumbnailUrl,
  });

  final String sceneId;
  final String title;
  final String thumbnailUrl;
}

@riverpod
FutureOr<List<TagMediaItem>> tagMedia(Ref ref, String tagId) async {
  ref.keepAlive();
  final client = ref.read(graphqlClientProvider);

  final result = await client.query$FindScenes(
    Options$Query$FindScenes(
      variables: Variables$Query$FindScenes(
        filter: Input$FindFilterType(page: 1, per_page: 24),
        scene_filter: Input$SceneFilterType(
          tags: Input$HierarchicalMultiCriterionInput(
            value: <String>[tagId],
            modifier: Enum$CriterionModifier.INCLUDES,
          ),
        ),
      ),
    ),
  );

  if (result.hasException) throw result.exception!;

  final prefs = ref.read(sharedPreferencesProvider);
  final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
  final normalizedServerUrl = normalizeGraphqlServerUrl(storedServerUrl);
  final endpoint = Uri.parse(
    normalizedServerUrl.isEmpty
        ? 'http://localhost:9999/graphql'
        : normalizedServerUrl,
  );

  return result.parsedData!.findScenes.scenes
      .map(
        (scene) => TagMediaItem(
          sceneId: scene.id,
          title: buildSceneDisplayTitle(
            title: scene.title,
            filePath: scene.files.isNotEmpty ? scene.files.first.path : null,
            streamPath: scene.paths.stream,
          ),
          thumbnailUrl: resolveGraphqlMediaUrl(
            rawUrl: scene.paths.screenshot ?? scene.paths.preview,
            graphqlEndpoint: endpoint,
          ),
        ),
      )
      .where((item) => item.thumbnailUrl.isNotEmpty)
      .toList();
}

@riverpod
class TagMediaGrid extends _$TagMediaGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _tagId;

  @override
  FutureOr<List<TagMediaItem>> build(String tagId) async {
    ref.keepAlive();
    _tagId = tagId;
    _currentPage = 1;
    _hasMore = true;
    return _fetchPage(tagId, _currentPage);
  }

  Future<List<TagMediaItem>> _fetchPage(String tagId, int page) async {
    final client = ref.read(graphqlClientProvider);

    final result = await client.query$FindScenes(
      Options$Query$FindScenes(
        variables: Variables$Query$FindScenes(
          filter: Input$FindFilterType(page: page, per_page: _perPage),
          scene_filter: Input$SceneFilterType(
            tags: Input$HierarchicalMultiCriterionInput(
              value: <String>[tagId],
              modifier: Enum$CriterionModifier.INCLUDES,
            ),
          ),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    final prefs = ref.read(sharedPreferencesProvider);
    final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
    final normalizedServerUrl = normalizeGraphqlServerUrl(storedServerUrl);
    final endpoint = Uri.parse(
      normalizedServerUrl.isEmpty
          ? 'http://localhost:9999/graphql'
          : normalizedServerUrl,
    );

    return result.parsedData!.findScenes.scenes
        .map(
          (scene) => TagMediaItem(
            sceneId: scene.id,
            title: buildSceneDisplayTitle(
              title: scene.title,
              filePath: scene.files.isNotEmpty ? scene.files.first.path : null,
              streamPath: scene.paths.stream,
            ),
            thumbnailUrl: resolveGraphqlMediaUrl(
              rawUrl: scene.paths.screenshot ?? scene.paths.preview,
              graphqlEndpoint: endpoint,
            ),
          ),
        )
        .where((item) => item.thumbnailUrl.isNotEmpty)
        .toList();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _tagId == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPage(_tagId!, nextPage);

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...(state.value ?? <TagMediaItem>[]), ...nextItems]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
