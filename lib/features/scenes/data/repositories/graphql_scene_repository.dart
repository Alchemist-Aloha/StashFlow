import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../graphql/scenes.graphql.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/repositories/scene_repository.dart';

class GraphQLSceneRepository implements SceneRepository {
  final GraphQLClient client;
  GraphQLSceneRepository(this.client);

  Uri get _graphqlEndpoint => client.link is HttpLink
      ? (client.link as HttpLink).uri
      : Uri.parse('https://localhost/graphql');

  @override
  Future<List<Scene>> findScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool? organized,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  }) async {
    String? effectiveSort = sort == 'rating100' ? 'rating' : sort;
    var result = await _runFindScenes(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: effectiveSort,
      descending: descending,
      organized: organized,
      performerId: performerId,
      studioId: studioId,
      tagId: tagId,
      sceneFilter: sceneFilter,
    );

    if (result.hasException &&
        effectiveSort == 'rating' &&
        _isInvalidSort(result.exception!, 'rating')) {
      effectiveSort = 'rating100';
      result = await _runFindScenes(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: effectiveSort,
        descending: descending,
        organized: organized,
        performerId: performerId,
        studioId: studioId,
        tagId: tagId,
        sceneFilter: sceneFilter,
      );
    }

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findScenes.scenes
        .map(
          (s) => Scene(
            id: s.id,
            title: s.title ?? '',
            details: null,
            path: s.files.isNotEmpty ? s.files.first.path : null,
            date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
            rating100: s.rating100,
            oCounter: s.o_counter ?? 0,
            organized: s.organized,
            interactive: s.interactive,
            resumeTime: s.resume_time,
            playCount: s.play_count ?? 0,
            files: [], // Slim data doesn't have files
            paths: ScenePaths(
              screenshot: resolveGraphqlMediaUrl(
                rawUrl: s.paths.screenshot,
                graphqlEndpoint: _graphqlEndpoint,
              ),
              preview: resolveGraphqlMediaUrl(
                rawUrl: s.paths.preview,
                graphqlEndpoint: _graphqlEndpoint,
              ),
              stream: resolveGraphqlMediaUrl(
                rawUrl: s.paths.stream,
                graphqlEndpoint: _graphqlEndpoint,
              ),
            ),
            studioId: s.studio?.id,
            studioName: s.studio?.name,
            studioImagePath: resolveGraphqlMediaUrl(
              rawUrl: s.studio?.image_path,
              graphqlEndpoint: _graphqlEndpoint,
            ),
            performerIds: s.performers.map((p) => p.id).toList(),
            performerNames: s.performers.map((p) => p.name).toList(),
            performerImagePaths: s.performers
                .map(
                  (p) => resolveGraphqlMediaUrl(
                    rawUrl: p.image_path,
                    graphqlEndpoint: _graphqlEndpoint,
                  ),
                )
                .toList(),
            tagIds: [],
            tagNames: [],
          ),
        )
        .toList();
  }

  Future<QueryResult<Query$FindScenes>> _runFindScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    required bool descending,
    bool? organized,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  }) {
    return client.query$FindScenes(
      Options$Query$FindScenes(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindScenes(
          filter: Input$FindFilterType(
            q: filter ?? sceneFilter?.searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          scene_filter: Input$SceneFilterType(
            organized: organized,
            performers:
                (performerId != null ||
                    (sceneFilter?.performerIds?.isNotEmpty ?? false))
                ? Input$MultiCriterionInput(
                    value: performerId != null
                        ? [performerId]
                        : sceneFilter!.performerIds,
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            studios: (studioId != null || sceneFilter?.studioId != null)
                ? Input$HierarchicalMultiCriterionInput(
                    value: studioId != null
                        ? [studioId]
                        : [sceneFilter!.studioId!],
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            tags:
                (tagId != null ||
                    (sceneFilter?.includeTags?.isNotEmpty ?? false))
                ? Input$HierarchicalMultiCriterionInput(
                    value: tagId != null ? [tagId] : sceneFilter!.includeTags,
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            rating100: sceneFilter?.minRating != null
                ? Input$IntCriterionInput(
                    value: sceneFilter!.minRating!,
                    modifier: Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
            play_count: sceneFilter?.isWatched == true
                ? Input$IntCriterionInput(
                    value: 0,
                    modifier: Enum$CriterionModifier.GREATER_THAN,
                  )
                : sceneFilter?.isWatched == false
                ? Input$IntCriterionInput(
                    value: 0,
                    modifier: Enum$CriterionModifier.EQUALS,
                  )
                : null,
            date:
                (sceneFilter?.startDate != null || sceneFilter?.endDate != null)
                ? Input$DateCriterionInput(
                    value:
                        sceneFilter?.startDate?.toIso8601String().split(
                          'T',
                        )[0] ??
                        '',
                    value2: sceneFilter?.endDate?.toIso8601String().split(
                      'T',
                    )[0],
                    modifier: sceneFilter?.endDate != null
                        ? Enum$CriterionModifier.BETWEEN
                        : Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  bool _isInvalidSort(OperationException exception, String attemptedSort) {
    return exception.graphqlErrors.any(
      (e) =>
          e.message.contains('invalid sort') &&
          e.message.contains(attemptedSort),
    );
  }

  @override
  Future<Scene> getSceneById(String id) async {
    final result = await client.query$FindScene(
      Options$Query$FindScene(variables: Variables$Query$FindScene(id: id)),
    );

    if (result.hasException) throw result.exception!;
    final s = result.parsedData!.findScene;
    if (s == null) throw StateError('Scene not found');

    return Scene(
      id: s.id,
      title: s.title ?? '',
      details: s.details,
      path: s.files.isNotEmpty ? s.files.first.path : null,
      date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
      rating100: s.rating100,
      oCounter: s.o_counter ?? 0,
      organized: s.organized,
      interactive: s.interactive,
      resumeTime: s.resume_time,
      playCount: s.play_count ?? 0,
      files: s.files
          .map(
            (f) => SceneFile(
              format: f.format,
              width: f.width,
              height: f.height,
              videoCodec: f.video_codec,
              audioCodec: f.audio_codec,
              bitRate: f.bit_rate,
              duration: f.duration,
              frameRate: f.frame_rate,
            ),
          )
          .toList(),
      paths: ScenePaths(
        screenshot: resolveGraphqlMediaUrl(
          rawUrl: s.paths.screenshot,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        preview: resolveGraphqlMediaUrl(
          rawUrl: s.paths.preview,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        stream: resolveGraphqlMediaUrl(
          rawUrl: s.paths.stream,
          graphqlEndpoint: _graphqlEndpoint,
        ),
      ),
      studioId: s.studio?.id,
      studioName: s.studio?.name,
      studioImagePath: resolveGraphqlMediaUrl(
        rawUrl: s.studio?.image_path,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      performerIds: s.performers.map((p) => p.id).toList(),
      performerNames: s.performers.map((p) => p.name).toList(),
      performerImagePaths: s.performers
          .map(
            (p) => resolveGraphqlMediaUrl(
              rawUrl: p.image_path,
              graphqlEndpoint: _graphqlEndpoint,
            ),
          )
          .toList(),
      tagIds: s.tags.map((t) => t.id).toList(),
      tagNames: s.tags.map((t) => t.name).toList(),
    );
  }
}
