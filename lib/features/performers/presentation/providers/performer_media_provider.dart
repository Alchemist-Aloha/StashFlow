import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../scenes/data/graphql/scenes.graphql.dart';
import '../../../scenes/domain/entities/scene_title_utils.dart';

part 'performer_media_provider.g.dart';

class PerformerMediaItem {
  const PerformerMediaItem({
    required this.sceneId,
    required this.title,
    required this.thumbnailUrl,
  });

  final String sceneId;
  final String title;
  final String thumbnailUrl;
}

@riverpod
FutureOr<List<PerformerMediaItem>> performerMedia(
  Ref ref,
  String performerId,
) async {
  final client = ref.watch(graphqlClientProvider);

  final result = await client.query$FindScenes(
    Options$Query$FindScenes(
      variables: Variables$Query$FindScenes(
        filter: Input$FindFilterType(page: 1, per_page: 24),
        scene_filter: Input$SceneFilterType(
          performers: Input$MultiCriterionInput(
            value: <String>[performerId],
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
        (scene) => PerformerMediaItem(
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
class PerformerMediaGrid extends _$PerformerMediaGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _performerId;

  @override
  FutureOr<List<PerformerMediaItem>> build(String performerId) async {
    _performerId = performerId;
    _currentPage = 1;
    _hasMore = true;
    return _fetchPage(performerId, _currentPage);
  }

  Future<List<PerformerMediaItem>> _fetchPage(
    String performerId,
    int page,
  ) async {
    final client = ref.watch(graphqlClientProvider);

    final result = await client.query$FindScenes(
      Options$Query$FindScenes(
        variables: Variables$Query$FindScenes(
          filter: Input$FindFilterType(page: page, per_page: _perPage),
          scene_filter: Input$SceneFilterType(
            performers: Input$MultiCriterionInput(
              value: <String>[performerId],
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
          (scene) => PerformerMediaItem(
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
    if (_isLoadingMore || !_hasMore || _performerId == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPage(_performerId!, nextPage);

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([
          ...(state.value ?? <PerformerMediaItem>[]),
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
